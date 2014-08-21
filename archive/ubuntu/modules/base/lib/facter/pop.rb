Facter.add(:pop) do
  setcode do
    mydomain = Facter.value('domain')
    myipaddr = Facter.value('ipaddress')

    pop = case mydomain
      when "ash2.prod.example1.com" then "iad1"
      when "ash2.example2.com" then "iad1"
      when "hopper.ash2.example2.com" then "iad1"
      when "pds.iad1.prod.example1.com" then "iad1"
      when "iad1.prod.example1.com" then "iad1"
      when "iad1.staging.example1.com" then "iad1"
      when "sfo1.eng.example1.com" then "sjc1"
      when "sjc1.eng.example1.com" then "sjc1"
      when "sql1.corp.example1.com" then "sql1"
      when "sql1.eng.example1.com" then "sql1"
      when "eu-west-1.dev1.example1.com" then "sjc1"
      when "eu-west-1.qe1.example1.com" then "sjc1"
      when "eu-west-1.staging.example1.com" then "iad1"
      when "eu-west-1.prod.example1.com" then "iad1"
      when "us-west-2.dev1.example1.com" then "sjc1"
      when "us-west-2.qe1.example1.com" then "sjc1"
      when "us-west-2.staging.example1.com" then "iad1"
      when "us-west-2.prod.example1.com" then "iad1"
      else "unknown"
    end

    if pop == "unknown" then
      ipparts = myipaddr.split(".")
      ipparts.pop
      ipparts.pop
      mynetAB = ipparts.join(".")
      pop = case mynetAB
        when "10.0" then "iad1"
        when "10.2" then "sjc1"
        when "172.21" then "iad1"
        when "172.20" then "sjc1"
        when "172.16" then "sql1"
        else "unknown"
      end
    end

    pop
  end

end
