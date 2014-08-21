Facter.add(:game) do
    setcode do
	hostname = Facter.value('hostname')
	(game,platform) = hostname.split("-")
	game
    end
end

