Facter.add(:apache2_ver) do
  setcode do
    apache2_ver=Facter::Util::Resolution.exec('apache2 -v |head -1 2>/dev/null')
  end

end
