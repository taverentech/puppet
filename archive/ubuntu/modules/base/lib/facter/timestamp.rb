Facter.add(:timestamp) do
  setcode do
    timestamp=Facter::Util::Resolution.exec("date +%F-%H:%M")
    timestamp
  end
end
