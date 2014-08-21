Facter.add(:serverid) do
    setcode do
	ipaddress = Facter.value('ipaddress')
        ipparts = ipaddress.split(".")
        ipparts.shift
        serverid = ipparts.join
    end
end
