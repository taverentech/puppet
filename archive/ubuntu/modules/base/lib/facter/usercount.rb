Facter.add(:usercount) do
  setcode do
    usercount=Facter::Util::Resolution.exec("/usr/bin/who | awk '{print $1}'| sort -u |wc -l")
    usercount
  end
end

