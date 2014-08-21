Facter.add(:memory85) do
    setcode do
	memorytotal = Facter.value('memorytotal')
        memory = memorytotal.match(/^([0-9\.]+)\s+/)[1]
        units  = memorytotal.match(/^[0-9\.]+\s+([A-Z])/)[1]
        ratio = 0.85
	memory85 = (memory.to_f * ratio).to_i
        memory85.to_s<<units
    end
end
