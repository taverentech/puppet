Facter.add(:pop) do
	setcode do
		mydomain = Facter.value('domain')
                myipaddr = Facter.value('ipaddress')
                myipaddr_bond = Facter.value('ipaddress_bond0')
                if myipaddr == myipaddr_bond then
                	mynetwork= Facter.value('network_bond0')
		else
                	mynetwork= Facter.value('network_eth0')
		end
		pop = case mydomain
			when "ams.example.com" then "ams"
			when "sea.example.com" then "sea"
			when "dal.example.com" then "dal"
			when "sjc.example.com" then "sjc"
			when "sjc2.example.com" then "sjc2"
			when "dc.example.com" then "dc"
			when "hq.example.com" then "hq"
			#when "sfo1.example.com" then "sfo1"
			else "unknown"
		end
		if pop == "unknown" then
        		ipparts = myipaddr.split(".")
        		ipparts.pop
        		ipparts.pop
			mynetAB = ipparts.join(".")
			pop = case mynetAB
				when "10.24" then "dc"
				when "10.25" then "dc"
				when "10.32" then "dc"
				when "10.56" then "dc"
				when "10.70" then "dc"
				when "10.52" then "sjc"
				when "10.54" then "sjc"
				when "10.55" then "sjc"
				when "192.168" then "sjc2"
				else "unknown"
			end
		end
		pop

	end
end

