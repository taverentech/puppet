Facter.add(:mysqld_ver) do
  setcode do
    mysqld_ver=Facter::Util::Resolution.exec('mysqld --version 2>/dev/null')
  end


end
