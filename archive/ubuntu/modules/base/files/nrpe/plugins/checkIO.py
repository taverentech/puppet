#!/usr/bin/python

from optparse import OptionParser
import time
import sys
import os
import re
import subprocess

class IODevice:
    "Sysfs view of a block device" 

    def __init__(self, shortName, sysfs="/sys"):
        self.sysfs=sysfs
        self.shortName=shortName
        self.countersField=["nbReads","nbMergedReads",
                            "nbSectorRead","timeSpentReading",
                            "nbWrites","nbMergedWrites",
                            "nbSectorWritten","timeSpentWriting",
                            "ioQueue","timeSpentIO","timeSpentIOWeighted"]
        self.smartctl='/usr/sbin/smartctl'
        self.sudo='/usr/bin/sudo'
        self.smartctlOutput=[ re.compile("^\s*SMART Health Status:\s*(.+)\s*$"),
                              re.compile("^\s*SMART overall-health self-assessment test result:\s*(.+)\s*$"),
                              re.compile("^\s*Smartctl open device: \S+ failed:\s+(.*)\s*$")]
        self.verifyExistence()
    
    def __del__(self):
        pass

    def __repr__(self):
        return self.shortName

    def __baseNode(self):
        "The base localtion in sysfs for the interface"
        return os.path.join(self.sysfs,"block",self.shortName)

    def verifyExistence(self):
        "Verify that the device exists in sysfs, raise NameError"
        if not os.path.isdir(self.__baseNode()):
            raise NameError("The device %s does not exist"%(self.shortName,))
        return True
 
    def getCounter(self,counterName):
        "Read the value from the sysfs statistics, raise NameError"
        counterPath=os.path.join(self.__baseNode(),"stat")
        try:
            file=open(counterPath,'r')
            counters=file.readline().strip()
            counters=filter(lambda x : x!="", counters.split())
            if len(counters)!=len(self.countersField): raise IndexError("The counters list does not match the names we have")
            value=long(counters[self.countersField.index(counterName)])
        except ValueError:
            raise NameError("%s is not a valid counter name"%(counterName,))
        return value
       
    def getSlaves(self):
        "Return the list of slave devices"
        slavesPath=os.path.join(self.__baseNode(),"slaves")
        if not os.path.isdir(slavesPath): raise IOError("No slaves list defined in sysfs")
        slaves=[]
        for shortName in os.listdir(slavesPath):
            if shortName!="":
                slaves.append(IODevice(shortName))
        return slaves
       
    def getIOErrorCount(self):
        "get the total of failed io operarions for the device, raise IOError"
        ioerrPath=os.path.join(self.__baseNode(), "device", "ioerr_cnt")
        try:
            file=open(ioerrPath,'r')
            value=int(file.readline().strip(),16)
        except:
            raise IOError("The ioerr interface is not available")
        return value

    def getSmartHealth(self):
        "Query the SMART subsystem, raise NameError"
        commandLine="%s %s -H /dev/%s 2>&1"%(self.sudo,self.smartctl,self.shortName)
        try:
            command=subprocess.Popen(commandLine,shell=True,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE,
                                     close_fds=True)
            os.waitpid(command.pid,0)
            for line in command.stdout:
                for format in self.smartctlOutput:
                    match=format.match(line)
                    if match: return match.group(1)
            raise NameError("Unable to parse the result of smartctl")
        except:
            raise

class DeviceChecker:
    "Check the status of an interface"

    def __init__(self,errorCountWarning=None,errorCountCritical=None):
        self.statusOk=0
        self.statusWarning=1
        self.statusCritical=2
        self.statusUnknown=3
        self.counterLabels=[("nbSectorRead","nbSectorRead"),
                            ("nbSectorWritten","nbSectorWritten"),
                            ("nbReads","nbMergedReads"),
                            ("nbWrites","nbMergedWrites"),
                            ("IOTimeMs","timeSpentIO"),
                            ("IOQueueSize","ioQueue")]
        self.errorCountWarning=errorCountWarning
        self.errorCountCritical=errorCountCritical

    def __del__(self):
        pass

    def __checkDeviceSmartHealth(self,target):
        "Check the SMART attribute from the device and return the status,comment pair"
        okStates=["OK","PASSED"]
        try:
            health=target.getSmartHealth()
            if health in okStates:
                status=self.statusOk
                comments=["%s SMART health is OK"%(target,)]
            elif health == "Permission denied":
                status=self.statusUnknown
                comments=["%s: SMART data collection impossible (%s)"%(target,health)]
            else:
                status=self.statusCritical
                comments=["%s is reporting SMART failure (%s)"%(target,health)]
        except:
            status=self.statusWarning
            comments=["Unable to collect SMART data for %s"%(target,)]
        return (status,comments)
            
    def __checkDeviceErrorCount(self,target):
        "Access the error and return the pair status comment"
        if self.errorCountCritical==None or self.errorCountWarning==None:
            return (self.statusOk,[])
        errorCount=target.getIOErrorCount()
        if errorCount >= self.errorCountCritical:
            status=self.statusCritical
            comments=["%s is reporting %d errors"%(target,errorCount)]
        elif errorCount >= self.errorCountWarning:
            status=self.statusWarning
            comments=["%s is reporting %d errors"%(target,errorCount)]
        else:
            status=self.statusOk
            comments=["%s is OK"%(target,errorCount)]
        return (status,comments)
    
    def __checkPhysicalDevice(self,target):
        "Check a physical interface return a status,comment pair"
        status=self.statusOk
        comments=[]
        testStatus,testComments=self.__checkDeviceSmartHealth(target)
        status=max(status,testStatus)
        comments.extend(testComments)
        testStatus,testComments=self.__checkDeviceErrorCount(target)
        status=max(status,testStatus)
        comments.extend(testComments)
        return (status," ; ".join(comments))
    
    def __checkDMDevice(self,target):
        "Check a bonded interface and its slaves, return a status,comment pair" 
        status=self.statusOk
        comments=["%s is OK"%(target,)]
        slaves=target.getSlaves()
        if slaves:
            for slave in slaves:
                (slaveStatus,slaveComment)=self.checkDevice(slave)
                status=max(status,slaveStatus)
                comments.append(slaveComment)
        return (status," ; ".join(comments))

    def checkDevice(self,target):
        "General check entry"
        if len(target.getSlaves())!=0:
            return self.__checkDMDevice(target)
        else:
            return self.__checkPhysicalDevice(target)
        
    def getCounters(self,target):
        "Build the name=value list of counters"
        result=[]
        warnTest=""
        critTest=""
        minTest=""
        maxTest=""
        for (label,counter) in self.counterLabels:
            result.append(";".join(["%s=%d"%(label,target.getCounter(counter)),warnTest,critTest,minTest,maxTest]))
        return result

    def examineDevice(self,target):
        "Check the interface and append countersto the comments"
        (status,comment)=self.checkDevice(target)
        counters=self.getCounters(target)
        return (status,comment+'|'+' '.join(counters))

def main():
    parser=OptionParser(usage="%s <interface>"%(sys.argv[0]))
    parser.add_option("--ew", "--error-warning", dest="ew", \
                      type="int", default=None,\
                      help="Warning error count")
    parser.add_option("--ec", "--error-critical", dest="ec", \
                      type="int", default=None,\
                      help="Critical error count")
    (options,args)=parser.parse_args()
    try:
       if len(args)!=1:
           code,comment=(3,"Incorrect number of checks")
       else: 
           target=IODevice(args[0])
           checker=DeviceChecker(errorCountWarning=options.ew,\
                                 errorCountCritical=options.ec)
           code,comment=checker.examineDevice(target)
    except NameError:
       code=3
       comment="Unknown interface %s"%(args[0],)
    except:
       code=3
       comment="Internal error"
    print comment
    sys.exit(code)
    
if __name__ == '__main__':
    main()
 
