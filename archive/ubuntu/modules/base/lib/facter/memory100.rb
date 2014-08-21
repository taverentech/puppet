Facter.add(:memory100) do
    setcode do
	memorytotal = Facter.value('memorytotal')
        memory = memorytotal.match(/^([0-9\.]+)\s+/)[1]
        units  = memorytotal.match(/^[0-9\.]+\s+([A-Z])/)[1]
        ratio = 1.00
	memory100 = (memory.to_f * ratio).to_i
        memory100.to_s<<units
        memory100
    end
end
