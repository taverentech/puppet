Facter.add(:php_ver) do
  setcode do
    php_ver=Facter::Util::Resolution.exec("php5 -i |grep ^'PHP Version' | head -1| awk -F'>' '{print $2}' |sed -e 's/ //g' 2>/dev/null")
    php_ver
  end

end
