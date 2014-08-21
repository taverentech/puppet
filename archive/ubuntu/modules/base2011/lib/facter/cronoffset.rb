Facter.add(:cronoffset) do
    setcode do
	ipaddress = Facter.value('ipaddress')
        (aa,bb,cc,dd) = ipaddress.split(".")
	parts = dd.to_i
        ratio = 8.75
	cronoffset = (parts.to_f / ratio).to_i
    end
end
