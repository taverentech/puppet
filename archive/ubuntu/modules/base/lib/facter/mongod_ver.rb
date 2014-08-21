Facter.add(:mongod_ver) do
  setcode do
    mongod_ver=Facter::Util::Resolution.exec('mongod --version |head -1 2>/dev/null')
    mongod_ver
  end

end
