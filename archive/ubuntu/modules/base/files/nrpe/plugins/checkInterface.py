#!/usr/bin/python

from optparse import OptionParser
import time
import sys
import os

class NetworkInterface:
    "Sysfs view of the network interface"

    def __init__(self, shortName, sysfs="/sys"):
        self.sysfs=sysfs
        self.shortName=shortName
        self.verifyExistence()
    
    def __del__(self):
        pass

    def __repr__(self):
        return self.shortName

    def __baseNode(self):
        "The base localtion in sysfs for the interface"
        return os.path.join(self.sysfs,"class","net",self.shortName)

    def verifyExistence(self):
        "Verify that the interface exists in sysfs, raise NameError"
        if not os.path.isdir(self.__baseNode()):
            raise NameError("The interface %s does not exist"%(self.shortName,))
        return True
 
    def getCounter(self,counterName):
        "Read the value from the sysfs statistics, raise NameError"
        counterPath=os.path.join(self.__baseNode(),"statistics",counterName)
        if not os.path.isfile(counterPath): raise NameError("%s is not a valid counter name"%(counterName,))
        file=open(counterPath,'r')
        value=long(file.readline())
        return value
       
    def getState(self):
        "Return up/down for the interface"
        statePath=os.path.join(self.__baseNode(),"operstate")
        if not os.path.isfile(statePath): raise NameError("%s does not have a defined state"%(self,))
        file=open(statePath,'r')
        state=file.readline()
        return state.rstrip()

    def getSlaves(self):
        "Return the list of slave interface or False if not a bonding interface"
        bondingPath=os.path.join(self.__baseNode(),"bonding")
        if not os.path.isdir(bondingPath): return False
        slavesPath=os.path.join(bondingPath,"slaves")
        file=open(slavesPath,'r')
        slaves=[]
        for shortName in file.readline().strip().split(' '):
            if shortName!="":
                slaves.append(NetworkInterface(shortName))
        return slaves

    def isBonded(self):
        "Return True if interface is a bonding group"
        res=self.getSlaves()
        if res: return True
        else: return False
        
class InterfaceChecker:
    "Check the status of an interface"

    def __init__(self):
        self.statusOk=0
        self.statusWarning=1
        self.statusCritical=2
        self.statusUnknown=3
        self.counterLabels=[("rxBytes","rx_bytes"),
                            ("txBytes","tx_bytes"),
                            ("rxPkts","rx_packets"),
                            ("txPkts","tx_packets"),
                            ("rxErrs","rx_errors"),
                            ("txErrs","tx_errors")]

    def __del__(self):
        pass

    def __checkPhysicalInterface(self,target):
        "Check a physical interface return a status,comment pair" 
        status=self.statusOk
        comments=[]
        if target.getState()!="up" and target.getState()!="unknown":
            status=max(status,self.statusWarning)
            comments.append("%s in down"%(target,))
        else:
            status=max(status,self.statusOk)
            comments.append("%s is OK"%(target,))
        return (status," ; ".join(comments))
    
    def __checkBondedInterface(self,target):
        "Check a bonded interface and its slaves, return a status,comment pair" 
        status=self.statusOk
        comments=[]
        if target.getState()!="up" and target.getState()!="unknown":
            status=max(status,self.statusWarning)
            comments.append("%s in down"%(target,))
        else:
            status=max(status,self.statusOk)
            comments.append("%s is OK"%(target,))
        slaves=target.getSlaves()
        if slaves:
            for slave in slaves:
                (slaveStatus,slaveComment)=self.checkInterface(slave)
                status=max(status,slaveStatus)
                comments.append(slaveComment)
        return (status," ; ".join(comments))

    def checkInterface(self,target):
        "General check entry"
        if target.isBonded():
            return self.__checkBondedInterface(target)
        else:
            return self.__checkPhysicalInterface(target)
        
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

    def examineInterface(self,target):
        "Check the interface and append countersto the comments"
        (status,comment)=self.checkInterface(target)
        counters=self.getCounters(target)
        return (status,comment+'|'+' '.join(counters))

def main():
    parser=OptionParser(usage="%s <interface>"%(sys.argv[0]))
    #parser.add_option("--bc", "--buffer-critical", dest="bc", \
    #                  type="int", default=10,\
    #                  help="Buffer critical threshold")
    (options,args)=parser.parse_args()
    try:
       check=InterfaceChecker()
       if len(args)!=1:
           code,comment=(3,"Incorrect number of checks")
       else: 
           target=NetworkInterface(args[0])
           checker=InterfaceChecker()
           code,comment=checker.examineInterface(target)
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
 
