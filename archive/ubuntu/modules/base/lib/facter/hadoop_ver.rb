Facter.add(:hadoop_ver) do
  setcode do
    hadoop_ver=Facter::Util::Resolution.exec("hadoop version |head -1|awk '{print $2}'")
    hadoop_ver
  end

end
