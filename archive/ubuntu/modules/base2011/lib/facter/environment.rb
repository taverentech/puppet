Facter.add(:environment) do
    setcode do
        hostname = Facter.value('fqdn')
        if ( hostname =~ /.*-preview\..*\.example\.com$/ )
   		environment = "preview"
                
        elsif ( hostname =~ /.*-qa\..*\.example\.com$/ )
   		environment = "qa"
                
        elsif ( hostname =~ /.*-ex\..*\.example\.com$/ )
   		environment = "ex"
                
        elsif ( hostname =~ /.*-vm\..*\.example\.com$/ )
   		environment = "vm"
                
        elsif ( hostname =~ /.*\.dev\.example\.com$/ )
   		environment = "dev"

        elsif ( hostname =~ /.*\.test\.example\.com$/ )
   		environment = "test"

        elsif ( hostname =~ /.*\.stage\.example\.com$/ )
   		environment = "stage"

	else
   		environment = "prod"

	end	

   	environment

    end
end
