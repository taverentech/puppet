Facter.add(:mysqld_ver) do
  setcode do
    mysqld_ver=Facter::Util::Resolution.exec("mysqld --version |awk '{print $3}' 2>/dev/null")
    mysqld_ver
  end


end
