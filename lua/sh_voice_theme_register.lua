if SERVER then

	util.AddNetworkString("SendVoiceChatSettings") // Send an updated setting to the server
	util.AddNetworkString("RequestChatSettings") // Request the whole list
	util.AddNetworkString("RecieveChatSettings") // Get the setting of a player

	net.Receive("SendVoiceChatSettings", function(len, ply)

		ply.VoiceChatSettings = net.ReadTable()
		// print("Server recieved ", ply, ply.VoiceChatSettings)

		net.Start("RecieveChatSettings")
			net.WriteEntity(ply)
			net.WriteTable(ply.VoiceChatSettings)
		net.Broadcast()

	end)

	net.Receive("RequestChatSettings", function(len, ply)

		pl = net.ReadEntity()
		// print("Server is sending to you", ply, pl.VoiceChatSettings)

		net.Start("RecieveChatSettings")
			net.WriteEntity(pl)
			net.WriteTable(pl.VoiceChatSettings)
		net.Send(ply)

	end)

end



if CLIENT then

	////////////////////
	function shrun.VoiceChat:SaveToServer()
		net.Start("SendVoiceChatSettings")

		net.WriteTable(self.Settings)
		// print("You're sending ", self.Settings)

		net.SendToServer()
	end

	function shrun.VoiceChat:GetAllFromServer()

		for k,v in pairs(player.GetAll()) do
			if v == LocalPlayer() then return end
			
			net.Start("RequestChatSettings")

			net.WriteEntity(v)
			// print("You're requesting ", v)

			net.SendToServer()

		end
	end
	////////////////////

	net.Receive("RecieveChatSettings", function(len)
		local ply = net.ReadEntity()
		if ply == LocalPlayer() then return end
		local VoiceChatSettings = net.ReadTable()
		ply.VoiceChatSettings = VoiceChatSettings
		// print("You recieved ", ply, ply.VoiceChatSettings)
	end)

end