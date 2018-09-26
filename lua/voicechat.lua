local theme = shrun.theme;

local PANELR = {}
local PlayerVoicePanels = {}

function PANELR:Init()

	self.LabelName = vgui.Create( "DLabel", self )
	self.LabelName:SetFont( "GModNotify" )
	self.LabelName:Dock( FILL )
	self.LabelName:DockMargin( 8, 0, 0, 0 )
	self.LabelName:SetTextColor( Color( 255, 255, 255, 255 ) )

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:Dock( LEFT )
	self.Avatar:SetSize( 32, 32 )

	self.Color = color_transparent

	self:SetSize( 250, 32 + 8 )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin(0, 4, 0, 0)
	self:Dock( BOTTOM )

end

function PANELR:Setup( ply )

	self.ply = ply
	self.LabelName:SetText( ply:Nick() )
	self.Avatar:SetPlayer( ply )
	
	self.Color = team.GetColor( ply:Team() )
	
	self:InvalidateLayout()

end

function PANELR:Paint( w, h )

	if not IsValid( self.ply ) then return end
	local voice = self.ply:VoiceVolume();
	voice = 1;
	voice = math.Rand(0, .5);

	if self.Timer == nil then
		self.Timer = 0;
	end
	self.Timer = self.Timer + RealFrameTime()*8;

	if self.Bars == nil then
		self.Bars = {};
	end

	while math.ceil(self.Timer) > #self.Bars do
		table.insert(self.Bars, voice);
	end

	//draw.RoundedBox( 4, 0, 0, w, h, Color( 0, voice * 255, 0, 240 ) )
	draw.RoundedBox( 4, 0, 0, w, h, theme.bgAlternative )
	//draw.RoundedBox( 4, 0, h - 8, voice * w, 8, Color( 0, voice * 255, 0, 240 ) )

	colBox = theme.blue;

	for k,v in pairs(self.Bars) do
		if k != 1 then
			local width = 4
			local offset = width
			local outerMargin = 4
			local gap = 0

			local xPos = (k - 1 - self.Timer) * (width + gap) + w + offset;
			local yPos = h - v * (h - outerMargin*2) - outerMargin;
			local xPos2 = (k - 2 - self.Timer) * (width + gap) + w + offset;
			local yPos2 = h - self.Bars[k-1] * (h - outerMargin*2) - outerMargin;

			// Bars
			/*surface.SetDrawColor(v * 255, 255 - v * 255, 0, 255)
			surface.DrawRect(xPos, yPos, width, v * (h - outerMargin*2))/**/

			// Bars Unicolor
			/*surface.SetDrawColor(theme.bg)
			surface.DrawRect(xPos, yPos, width, v * (h - outerMargin*2))/**/


			surface.SetDrawColor(colBox)

			// Hills
			//surface.DrawLine(xPos2, yPos2, xPos, yPos);/**/

			// Sequence
			if k % 2 == 0 then
				surface.DrawLine(xPos2, (yPos2 + outerMargin) / 2, xPos, h - (yPos + outerMargin) / 2);
			else
				surface.DrawLine(xPos2, h - (yPos2 + outerMargin) / 2, xPos, (yPos + outerMargin) / 2);
			end/**/
		end
	end

	draw.RoundedBox(4, 0, 0, 40, 40, theme:Transparency(colBox, voice));

	while #self.Bars > 24 do
		table.remove( self.Bars, 1 );
		self.Timer = self.Timer - 1;
		table.remove( self.Bars, 1 );
		self.Timer = self.Timer - 1;
	end

end

function PANELR:Think()
	
	if ( IsValid( self.ply ) ) then
		self.LabelName:SetText( self.ply:Nick() )
	end

	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end

end

function PANELR:FadeOut( anim, delta, data )
	
	if ( anim.Finished ) then
		if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
			PlayerVoicePanels[ self.ply ]:Remove()
			PlayerVoicePanels[ self.ply ] = nil;
			return
		end
		
	return end
	
	self:SetAlpha( 255 - ( 255 * delta ) )

end

derma.DefineControl( "VoiceNotifyR", "", PANELR, "DPanel" )



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
