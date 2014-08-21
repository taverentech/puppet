Facter.add(:memory65) do
    setcode do
	memorytotal = Facter.value('memorytotal')
        memory = memorytotal.match(/^([0-9\.]+)\s+/)[1]
        units  = memorytotal.match(/^[0-9\.]+\s+([A-Z])/)[1]
        ratio = 0.65
	memory65 = (memory.to_f * ratio).to_i
        memory65.to_s<<units
    end
end
