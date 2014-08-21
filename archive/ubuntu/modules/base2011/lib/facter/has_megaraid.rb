Facter.add(:has_megaraid) do
	setcode do
		#checkproc=%x{grep -c megaraid /proc/devices}.chomp
		checkproc=Facter::Util::Resolution.exec('grep -c megaraid /proc/devices')

                has_megaraid = case checkproc
                        when checkproc == "0" then "false"
                        else "true"
                end
	end


end
