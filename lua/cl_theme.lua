// Create a shell if it doesn't exist
// Failsafe to be able to work independent
shrun = shrun or {}

// If no theme has been initialized, do this
shrun.theme = shrun.theme or {}

// DEFAULT THEME
shrun.theme.loadDefault = function()
	shrun.theme.rem = 16
	shrun.theme.round = 4

	shrun.theme.bg = Color(49, 53, 61)
	shrun.theme.bgAlternative = Color(41, 44, 51)
	shrun.theme.txt = Color(255, 255, 255)
	shrun.theme.txtAlternative = Color(98, 106, 122)
	shrun.theme.red = Color(230, 93, 80)
	shrun.theme.green = Color(146, 217, 76)
	shrun.theme.blue = Color(80, 180, 230)
	shrun.theme.yellow = Color(230, 167, 80)
end
shrun.theme.loadDefault();

// Read custom theme
local fileName = "shrun/theme.txt"
if file.Exists(fileName, "DATA") then
	table.Merge(shrun.theme, util.JSONToTable(file.Read(fileName, "DATA")))
end

// Create transparency function
function shrun.theme:Transparency(colour, opacity)
	return Color(colour.r, colour.g, colour.b, opacity*255)
end

// Overwrite global fonts for shrun
if CLIENT then
	// hud description font tags
	surface.CreateFont("Description", {
		font = "Open Sans",
		size = .9*shrun.theme.rem,
		weight = 400,
		antialias = true,
	})

	// chat font
	surface.CreateFont("ChatFont", {
		font = "Open Sans",
		size = 1.25*shrun.theme.rem,
		weight = 700,
		antialias = true,
	})

	surface.CreateFont("FontTitle", {
		font = "Open Sans",
		size = 2.25*shrun.theme.rem,
		weight = 300,
		antialias = true,
	})

	surface.CreateFont("FontHeader", {
		font = "Open Sans",
		size = 1.375*shrun.theme.rem,
		weight = 300,
		antialias = true,
	})

	surface.CreateFont("FontSub", {
		font = "Open Sans",
		size = shrun.theme.rem,
		weight = 700,
		antialias = true,
	})
end

print("shrun theme initialization complete");