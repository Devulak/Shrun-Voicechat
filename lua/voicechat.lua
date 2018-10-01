/* --- PRESETS --- */
shrun = shrun or {}
shrun.VoiceChat = shrun.VoiceChat or {}
shrun.VoiceChat.Settings = shrun.VoiceChat.Settings or {}
local VoiceChat = shrun.VoiceChat
local Settings = VoiceChat.Settings
VoiceChat.path = "shrun/VoiceChat.txt"
VoiceChat._BARSBOTTOM = 1
VoiceChat._BARSTOP = 2
VoiceChat._BARSREVERSE = 3
VoiceChat._BARSCENTER = 4
VoiceChat._BARSSEQUENCE = 5

function VoiceChat:ResetInfo()
	local Settings = self.Settings
	/* --- SETTINGS --- */
	Settings.VoiceMode = self._BARSSEQUENCE
	Settings.PointsPerSecond = 10
	Settings.PointsWidth = 2
	Settings.PointsGap = 2
	/* --- SETTINGS --- */
end

function VoiceChat:LoadInfo()
	if file.Exists(self.path, "DATA") then
		table.Merge(self.Settings, util.JSONToTable(file.Read(self.path, "DATA")))
	else
		self:ResetInfo()
	end
end
VoiceChat:LoadInfo()

function VoiceChat:SaveInfo()
	file.Write(self.path, util.TableToJSON(self.Settings, true))
end
/* --- PRESETS --- */



local theme = shrun.theme;

local PANEL = {}
local PlayerVoicePanels = {}

function PANEL:Init()

	self:SetSize( 250, 32 + 8 )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin( 0, 4, 0, 0 )
	self:Dock( BOTTOM )

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:Dock( LEFT )
	self.Avatar:SetSize( self:GetTall()-8, 32 )
	self.Avatar:DockMargin(0, 0, 8, 0)

	self.Spectrum = vgui.Create( "DPanel", self )
	self.Spectrum:Dock( FILL )
	self.Spectrum.Paint = function(self, w, h)
		if not IsValid( self.ply ) then return end
		local voice = self.ply:VoiceVolume();
		voice = math.Rand(0, .5);

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
			table.insert(self.Bars, voice);
		end

		//if self.ply == LocalPlayer() then return end

		local colBox = theme.blue;
		if evolve and GAMEMODE.Name == "Sandbox" then
			local usergroup = self.ply:EV_GetRank()
			colBox = evolve.ranks[ usergroup ].Color;
		else
			colBox = GAMEMODE:GetTeamColor(self.ply)
		end



		local offset = 0
		local function GetPosPoint(k, v)
			local x = (k - 1 - self.Timer) * (Settings.PointsWidth + Settings.PointsGap) + w + offset;
			local y = h - v * h;
			return x, y;
		end

		for k,v in pairs(self.Bars) do
			local xPos, yPos = GetPosPoint(k, v);
			surface.SetDrawColor(Color(colBox.r,colBox.g,colBox.b,(xPos/w*255)))

			if Settings.VoiceMode == VoiceChat._BARSBOTTOM then
				surface.DrawRect(xPos, yPos, Settings.PointsWidth, v * h)
			elseif Settings.VoiceMode == VoiceChat._BARSTOP then
				surface.DrawRect(xPos, 0, Settings.PointsWidth, v * h)
			elseif Settings.VoiceMode == VoiceChat._BARSREVERSE then
				surface.DrawRect(xPos, h - v * h/2, Settings.PointsWidth, v * h/2)
				surface.DrawRect(xPos, 0, Settings.PointsWidth, v * h/2)
			elseif Settings.VoiceMode == VoiceChat._BARSCENTER then
				surface.DrawRect(xPos, yPos/2, Settings.PointsWidth, v * h)
			elseif k != 1 then
				offset = Settings.PointsWidth + Settings.PointsGap
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



			// Remove fill
			if xPos < 0 then
				table.remove(self.Bars, k);
				self.Timer = self.Timer - 1;

				if self.Reverse then
					self.Reverse = false;
				else
					self.Reverse = true;
				end
			end
		end
	end

	self.LabelName = vgui.Create( "DLabel", self )
	self.LabelName:SetFont( "GModNotify" )
	self.LabelName:Dock( FILL )
	self.LabelName:SetTextColor( Color( 255, 255, 255, 255 ) )

end

function PANEL:Setup( ply )

	self.ply = ply
	self.Spectrum.ply = ply
	self.LabelName:SetText( ply:Nick() )
	self.Avatar:SetPlayer( ply )
	
	self.Color = team.GetColor( ply:Team() )
	
	self:InvalidateLayout()

end

function PANEL:Paint(w, h)
	if not IsValid( self.ply ) then return end
	draw.RoundedBox( 4, 0, 0, w, h, theme:Transparency(theme.bgAlternative, .9) )

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

	g_VoicePanelList = vgui.Create( "DPanel" )

	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList:SetPos( ScrW() - 300, 100 )
	g_VoicePanelList:SetSize( 250, ScrH() - 200 )
	g_VoicePanelList.Paint = function(self, w, h)
		if shrun.BottomRightHeight then
			local width = theme.rem * 15;
			g_VoicePanelList:SetPos(ScrW() - width -  theme.rem, theme.rem * 18);
			g_VoicePanelList:SetSize(width, ScrH() - theme.rem * 19 - shrun.BottomRightHeight)
		end
		//draw.RoundedBox(theme.round, 0, 0, self:GetWide(), self:GetTall(), theme:Transparency(theme.bg, .5));
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
