do
local originalReceiveChat = ReceiveChat

function ReceiveChat(sender, msg)
	originalReceiveChat(sender, msg)
	PlaySound(Sound({Bank = 'Interface', Cue = 'UI_Diplomacy_Close'}))
end

end
