Facter.add(:pwd) do
  setcode do
    Dir.pwd
  end
end
