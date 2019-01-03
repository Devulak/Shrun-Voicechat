/* --- PRESETS --- */

local PANEL = {}
local PlayerVoicePanels = {}
local theme = shrun.theme
local VoiceChat = shrun.VoiceChat

VoiceChat.path = "shrun/VoiceChat.txt"
VoiceChat._BARSBOTTOM = 1
VoiceChat._BARSTOP = 2
VoiceChat._BARSREVERSE = 3
VoiceChat._BARSCENTER = 4
VoiceChat._BARSSEQUENCE = 5

function VoiceChat:GetDefaultInfo()
	local Settings = {}
	/* --- DEFAULT SETTINGS --- */
	Settings.VoiceMode = self._BARSSEQUENCE
	Settings.PointsPerSecond = 10
	Settings.PointsWidth = 4
	Settings.PointsGap = 0
	/* --- DEFAULT SETTINGS --- */
	return Settings
end

function VoiceChat:LoadInfo()

	if not file.IsDir("shrun", "DATA") then
		file.CreateDir("shrun")
	end

	if file.Exists(self.path, "DATA") then
		table.Merge(self.Settings, util.JSONToTable(file.Read(self.path, "DATA")))
	else
		self.Settings = self:GetDefaultInfo()
	end

	self:SaveToServer()

end

function VoiceChat:SaveInfo()
	file.Write(self.path, util.TableToJSON(self.Settings, true))
	self:SaveToServer()
end
/* --- PRESETS --- */



function PANEL:Init()

	self:Dock(BOTTOM)
	self.Paint = function(self, w, h)
		if not IsValid(self.ply) then return end
		self:SetSize(theme.rem * 15, theme.rem * 2.5)
		self:DockPadding(theme.rem * .25, theme.rem * .25, theme.rem * .25, theme.rem * .25)
		self:DockMargin(0, theme.rem * .25, 0, 0)
		draw.RoundedBox(theme.round, 0, 0, w, h, theme:Transparency(theme.bgAlternative, .9))
	end

	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:Dock(LEFT)
	self.Avatar.Paint = function(self, w, h)
		self:SetWide(h)
		self:DockMargin(0, 0, theme.rem * .5, 0)
	end

	self.Spectrum = vgui.Create("DPanel", self)
	self.Spectrum:Dock(FILL)
	self.Spectrum.Shell = false;
	self.Spectrum.Paint = function(self, w, h)
		if not IsValid( self.ply ) then return end

		local Settings = self.ply.VoiceChatSettings or VoiceChat.Settings // This is where the issue could be
		local voice = self.ply:VoiceVolume();
		if self.Shell then
			voice = math.Rand(0, 1);
			Settings = VoiceChat.Settings
		end

		// Voice Table to average the volume between bars/nodes
		self.voiceTable = self.voiceTable or {}
		table.insert(self.voiceTable, voice)

		if self.Timer == nil then
			self.Timer = 0;
		end
		self.Timer = self.Timer + RealFrameTime()*Settings.PointsPerSecond;

		if self.Bars == nil then
			self.Bars = {};
		end

		if self.Reverse == nil then
			self.Reverse = false;
		end

		while math.ceil(self.Timer) > #self.Bars do
			local sum = 0

			for k,v in pairs(self.voiceTable) do
				sum = sum + v
			end

			table.insert(self.Bars, sum / #self.voiceTable);

			self.voiceTable = {}
		end

		local colBox = theme.blue;
		if evolve and GAMEMODE.Name == "Sandbox" then
			local usergroup = self.ply:EV_GetRank()
			colBox = evolve.ranks[ usergroup ].Color or GAMEMODE:GetTeamColor(self.ply);
		else
			colBox = GAMEMODE:GetTeamColor(self.ply)
		end



		local offset = 0
		local PointsWidth = Settings.PointsWidth * theme.rem / 16
		local PointsGap = Settings.PointsGap * theme.rem / 16
		local function GetPosPoint(k, v)
			local x = (k - 1 - self.Timer) * (PointsWidth + PointsGap) + w + offset;
			local y = h - v * h;
			return x, y;
		end

		for k,v in pairs(self.Bars) do
			local xPos, yPos = GetPosPoint(k, v);
			// Remove fill
			if xPos < 0 then
				table.remove(self.Bars, k);
				self.Timer = self.Timer - 1;

				if self.Reverse then
					self.Reverse = false;
				else
					self.Reverse = true;
				end
			else
				surface.SetDrawColor(Color(colBox.r,colBox.g,colBox.b,(xPos/w*255)))

				if Settings.VoiceMode == VoiceChat._BARSBOTTOM then
					surface.DrawRect(xPos, yPos, PointsWidth, v * h)
				elseif Settings.VoiceMode == VoiceChat._BARSTOP then
					surface.DrawRect(xPos, 0, PointsWidth, v * h)
				elseif Settings.VoiceMode == VoiceChat._BARSREVERSE then
					surface.DrawRect(xPos, h - v * h/2, PointsWidth, v * h/2)
					surface.DrawRect(xPos, 0, PointsWidth, v * h/2)
				elseif Settings.VoiceMode == VoiceChat._BARSCENTER then
					surface.DrawRect(xPos, yPos/2, PointsWidth, v * h)
				elseif k != 1 then
					offset = PointsWidth + PointsGap
					local xPos, yPos = GetPosPoint(k, v);
					local xPos2, yPos2 = GetPosPoint(k-1, self.Bars[k-1]);
					kc = k;
					if self.Reverse then
						kc = kc + 1
					end

					if kc % 2 == 0 then
						surface.DrawLine(xPos2, yPos2 / 2, xPos, h - yPos / 2);
					else
						surface.DrawLine(xPos2, h - yPos2 / 2, xPos, yPos / 2);
					end
				end
			end
		end
	end

	self.LabelName = vgui.Create("DLabel", self)
	self.LabelName:SetFont("ChatFont")
	self.LabelName:Dock(FILL)
	self.LabelName.Paint = function(self, w, h)
		self:SetTextColor(theme.txt)
	end

end

function PANEL:Setup( ply )

	if not ply then self.Spectrum.Shell = true end

	ply = ply or LocalPlayer()

	self.ply = ply
	self.Spectrum.ply = ply
	self.LabelName:SetText(ply:Nick())
	self.Avatar:SetPlayer( ply )
	
	self.Color = team.GetColor( ply:Team() )
	
	self:InvalidateLayout()

end

function PANEL:Think()
	
	if ( IsValid( self.ply ) ) then
		self.LabelName:SetText( self.ply:Nick() )
	end

	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end

end

function PANEL:FadeOut( anim, delta, data )
	
	if ( anim.Finished ) then
		if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
			PlayerVoicePanels[ self.ply ]:Remove()
			PlayerVoicePanels[ self.ply ] = nil;
			return
		end
		
	return end
	
	self:SetAlpha( 255 - ( 255 * delta ) )

end

derma.DefineControl( "VoiceNotifyR", "", PANEL, "DPanel" )



function ShrunPlayerStartVoice( ply )

	if ( !IsValid( g_VoicePanelList ) ) then return end
	
	-- There'd be an exta one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice( ply )


	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then

		if ( PlayerVoicePanels[ ply ].fadeAnim ) then
			PlayerVoicePanels[ ply ].fadeAnim:Stop()
			PlayerVoicePanels[ ply ].fadeAnim = nil
		end

		PlayerVoicePanels[ ply ]:SetAlpha( 255 )

		return false;

	end

	if ( !IsValid( ply ) ) then return end

	local pnl = g_VoicePanelList:Add( "VoiceNotifyR" )
	pnl:Setup( ply )
	
	PlayerVoicePanels[ ply ] = pnl

	return false;

end

local function VoiceCleanR()

	for k, v in pairs( PlayerVoicePanels ) do
	
		if ( !IsValid( k ) ) then
			GAMEMODE:PlayerEndVoice( k )
		end
	
	end

end
timer.Create( "VoiceCleanR", 10, 0, VoiceCleanR )

function ShrunPlayerEndVoice( ply )

	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then

		if PlayerVoicePanels[ ply ].fadeAnim then return end

		PlayerVoicePanels[ ply ].fadeAnim = Derma_Anim( "FadeOut", PlayerVoicePanels[ ply ], PlayerVoicePanels[ ply ].FadeOut )
		PlayerVoicePanels[ ply ].fadeAnim:Start( 2 )

	end

	return false;

end

local function ShrunCreateVoiceVGUI()
	VoiceChat:LoadInfo()
	VoiceChat:GetAllFromServer()
	g_VoicePanelList = vgui.Create( "DPanel" )

	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList.Paint = function(self, w, h)

		local width = theme.rem * 15
		self:SetPos(ScrW() - width - theme.rem, theme.rem);
		self:SetWide(width)

		if shrun.BottomRightHeight then
			self:SetTall(ScrH() - theme.rem * 2 - shrun.BottomRightHeight)
		else
			self:SetTall(ScrH() - 200)
		end

		// draw.RoundedBox(theme.round, 0, 0, self:GetWide(), self:GetTall(), theme:Transparency(theme.bg, .5));
	end

	return false;

end

//hook.Remove("InitPostEntity", "CreateVoiceVGUI");
hook.Add( "InitPostEntity", "ShrunCreateVoice", ShrunCreateVoiceVGUI )
hook.Add( "PlayerEndVoice", "ShrunPlayerEndVoice", ShrunPlayerEndVoice )
hook.Add( "PlayerStartVoice", "ShrunPlayerStartVoice", ShrunPlayerStartVoice )

local HideElements = {"CHudVoiceStatus", "CHudVoiceSelfStatus"}
hook.Add( "HUDShouldDraw", "ShrunRemoveVoice", function(Element)
	if table.HasValue(HideElements, Element) then
		return false;
	end
end)
