Facter.add(:php_ver) do
  setcode do
    php_ver=Facter::Util::Resolution.exec('php -v |head -1 2>/dev/null')
  end

end
