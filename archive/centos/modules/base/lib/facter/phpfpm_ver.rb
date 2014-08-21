Facter.add(:phpfpm_ver) do
  setcode do
    phpfpm=Facter::Util::Resolution.exec('php-fpm -v |head -1 2>/dev/null')
  end

end
