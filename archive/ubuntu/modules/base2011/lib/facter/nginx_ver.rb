Facter.add(:nginx_ver) do
  setcode do
    nginx_ver=Facter::Util::Resolution.exec('nginx -v |head -1 2>/dev/null')
  end

end
