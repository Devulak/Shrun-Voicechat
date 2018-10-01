local VoiceChatEditor = {}

function VoiceChatEditor:createCategoryPanel(name)
	local panel = vgui.Create("DPanel");
	panel.Paint = nil;
	panel:Dock(FILL);
	panel:DockPadding(10, 10, 10, 10);

	local category = self.categoryList:Add(name);
	category:SetExpanded(false);
	category:SetContents(panel);

	return panel;
end

function VoiceChatEditor:createNumSlider(name, description, min, max, func)
	local panel = self:createCategoryPanel(name);

	local numSlider = vgui.Create("DNumSlider", panel);
	numSlider:Dock(TOP);
	numSlider:SetText(description);
	numSlider:SetTall(20);
	numSlider:SetMin(min);
	numSlider:SetMax(max);
	numSlider:SetDecimals(0);
	numSlider:SetDark(true);
	numSlider.OnValueChanged = func;

	return numSlider;
end

function VoiceChatEditor:createComboBox(name)
	local panel = self:createCategoryPanel(name);

	local ComboBx = vgui.Create("DComboBox", panel)
	ComboBx:Dock(TOP);

	return ComboBx;
end

function VoiceChatEditor:Init()
	if not shrun.VoiceChat then return end
	if not shrun.VoiceChat.Settings then return end
	local VoiceChat = shrun.VoiceChat
	local Settings = VoiceChat.Settings

	if self.window then
		self.window:Remove()
	end

	// Create the window
	self.window = vgui.Create("DFrame");
	self.window:SetDraggable(true)
	self.window:SetSizable(false)
	self.window:MakePopup()
	self.window:SetSize(20*16, 32*16)
	self.window:Center()
	self.window:SetTitle("Voice Chat Editor")
	self.window.OnClose = function()
		VoiceChat:SaveInfo()
	end

	// Category List
	self.categoryList = vgui.Create("DCategoryList", self.window);
	self.categoryList:Dock(FILL);

	// VoiceMode
	self.VoiceMode = self:createComboBox("Voice Mode");
	self.VoiceMode:AddChoice("Sequence", VoiceChat._BARSSEQUENCE, Settings.VoiceMode == VoiceChat._BARSSEQUENCE);
	self.VoiceMode:AddChoice("Bottom", VoiceChat._BARSBOTTOM, Settings.VoiceMode == VoiceChat._BARSBOTTOM);
	self.VoiceMode:AddChoice("Top", VoiceChat._BARSTOP, Settings.VoiceMode == VoiceChat._BARSTOP);
	self.VoiceMode:AddChoice("Center", VoiceChat._BARSCENTER, Settings.VoiceMode == VoiceChat._BARSCENTER);
	self.VoiceMode:AddChoice("Reverse", VoiceChat._BARSREVERSE, Settings.VoiceMode == VoiceChat._BARSREVERSE);
	function self.VoiceMode:OnSelect(index, value, data)
		Settings.VoiceMode = data
	end

	// PointsPerSecond
	self.PointsPerSecond = self:createNumSlider("Nodes Per Second", "Nodes Per Second", 4, 32, function(self, value)
		if Settings.PointsPerSecond != math.Round(value) then
			Settings.PointsPerSecond = math.Round(value);
		end
	end);
	self.PointsPerSecond:SetValue(Settings.PointsPerSecond)

	// PointsWidth
	self.PointsWidth = self:createNumSlider("Node Width", "Node Width", 1, 16, function(self, value)
		if Settings.PointsWidth != math.Round(value) then
			Settings.PointsWidth = math.Round(value);
		end
	end);
	self.PointsWidth:SetValue(Settings.PointsWidth)

	// PointsGap
	self.PointsGap = self:createNumSlider("Node Gap", "Node Gap", 0, 4, function(self, value)
		if Settings.PointsGap != math.Round(value) then
			Settings.PointsGap = math.Round(value);
		end
	end);
	self.PointsGap:SetValue(Settings.PointsGap)
end

list.Set("DesktopWindows", "VoiceChat", 
{
	title		= "Personalize Voice Chat",
	icon		= "entities/chair_wood.png",
	init		= function(icon, window)
		VoiceChatEditor:Init();
	end
})

// Opens the theme menu to edit current theme
concommand.Add("voice_chat_editor", function()
	VoiceChatEditor:Init();
end)