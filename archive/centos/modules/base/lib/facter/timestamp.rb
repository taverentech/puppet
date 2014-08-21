Facter.add(:timestamp) do
	setcode do
		%x{date +%F-%H:%M}.chomp
	end
end

