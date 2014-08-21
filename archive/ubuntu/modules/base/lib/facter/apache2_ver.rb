Facter.add(:apache2_ver) do
  setcode do
    apache2_ver=Facter::Util::Resolution.exec("apache2 -v | head -1 | awk -F':' '{print $2}' |sed -e 's/ //g' 2>/dev/null")
    apache2_ver
  end

end
