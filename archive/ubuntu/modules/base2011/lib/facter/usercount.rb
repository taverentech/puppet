Facter.add(:usercount) do
	setcode do
		%x{/usr/bin/who | wc -l}.chomp
	end
end

