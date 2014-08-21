Facter.add(:environment) do
    setcode do
        hostname = Facter.value('fqdn')
        if ( hostname =~ /.*\.dev\.example3\.com$/ )
   		environment = "dev"

        elsif ( hostname =~ /.*\.test\.example3\.com$/ )
   		environment = "test"

        elsif ( hostname =~ /.*\.stage\.example3\.com$/ )
   		environment = "stage"

	else
   		environment = "prod"

	end	

   	environment

    end
end
