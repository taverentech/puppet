Facter.add(:environment) do
    setcode do
        hostname = Facter.value('fqdn')
        if ( hostname =~ /.*\.prod\.example1\.com$/ )
   		environment = "production"
                
        elsif ( hostname =~ /.*\.stage\.example1\.com$/ )
   		environment = "staging"

        elsif ( hostname =~ /.*\.qe1\.example1\.com$/ )
   		environment = "qe1"

        elsif ( hostname =~ /.*\.dev1\.example1\.com$/ )
   		environment = "dev1"

	else
   		environment = "unknown"

	end	

   	environment

    end
end
