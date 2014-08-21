Facter.add(:nodetype) do
    setcode do
	hostname = Facter.value('hostname')
	nodetype = hostname.match(/^([^0-9\.]+).*/)[1]
	nodetype
    end
end

