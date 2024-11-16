local library = loadstring(game:HttpGet("https://pastebin.com/raw/UsfV4ntw"))() --loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
Aiming = loadstring(game:HttpGet("https://pastebin.com/raw/YUFBgmrX"))()

print("Loaded")
-- // Vars
local AimingChecks = Aiming.Checks
local AimingSelected = Aiming.Selected
local AimingIgnored = Aiming.Ignored
local AimingUtilities = Aiming.Utilities
local AimingSettings = Aiming.Settings
local UnlockBind = AimingSettings.LockMode.UnlockBind

local DefaultTargetPart = AimingSettings.TargetPart

-- // Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local replicatedstorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Mouse = LocalPlayer:GetMouse()

local Vector2new = Vector2.new
local random = math.random

local GetPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()

-- // Camera
local Camera = {}
local CurrentCamera
do
	CurrentCamera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass('Camera')
	Camera.CameraUpdate = Workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
		CurrentCamera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass('Camera')
	end)
end

local GroupId = 32058430

local Configuration = {
	Enabled = false,
	Keybind = Enum.KeyCode.C,
	ToggleBind = false,
    SilentAim = {
        Enabled = false,
        Method = "",
        MustInclude = "", 
		AutoPrediction = false,
		AutoPrediction1 = false,
        Prediction = 0, 
    },
    Aimbot = {
        Enabled = false,  
		AutoPrediction = false,
		AutoPrediction1 = false,
        Prediction = 0,     
        No2click = false,
		CameraSensibility = 0,
		MouseSensibility = 0,
        MouseSmoothness = 0,     
    },
    Camlock = {
		Enabled = false,
        RoboticMovement = {
            Types = {  
                First = 'Cubic',
                Second = 'Bounce',
            },
            Sensitivity = 0.20015,
        },
    },
	Custom_Prediction = false,
	Offset = false,
	AirShootFunc = false
}

getgenv().Configuration = Configuration

local ConfigurationToggled = false

-- // Main Tab
local TechGui = library:CreateWindow({
	Name = "Beta",
	Themeable = {
		Info = "marsvill"
	},
	DefaultTheme =
	'{"__Designer.Colors.topGradient":"232323","__Designer.Settings.ShowHideKey":"Enum.KeyCode.LeftAlt","__Designer.Colors.section":"FF0000","__Designer.Colors.hoveredOptionBottom":"2D2D2D","__Designer.Background.ImageAssetID":"","__Designer.Colors.selectedOption":"373737","__Designer.Colors.unselectedOption":"282828","__Designer.Files.WorkspaceFile":"Beta","__Designer.Colors.unhoveredOptionTop":"323232","__Designer.Colors.outerBorder":"777777","__Designer.Background.ImageColor":"FFFFFF","__Designer.Colors.tabText":"B9B9B9","__Designer.Colors.elementBorder":"141414","__Designer.Colors.background":"000000","__Designer.Colors.innerBorder":"003BFF","__Designer.Background.ImageTransparency":100,"__Designer.Colors.bottomGradient":"1D1D1D","__Designer.Colors.hoveredOptionTop":"414141","__Designer.Colors.elementText":"939193","__Designer.Colors.otherElementText":"817F81","__Designer.Colors.main":"FB0000","__Designer.Colors.sectionBackground":"000000","__Designer.Colors.unhoveredOptionBottom":"232323","__Designer.Background.UseBackgroundImage":false}'
})

-- // General Settings
local GeneralTab = TechGui:CreateTab({ Name = "General" })

local GeneralSection = GeneralTab:CreateSection({ Name = "Main" })

GeneralSection:AddToggle({Name = "Enabled",Callback = function(E)
	AimingSettings.Enabled = E
end})

GeneralSection:AddToggle({Name = "Wall Check",Default = AimingSettings.VisibleCheck,Callback = function(E)
	AimingSettings.VisibleCheck = E
end})

GeneralSection:AddToggle({Name = "Team Check",Default = AimingSettings.TeamCheck,Callback = function(E)
	AimingSettings.TeamCheck = E
end})

GeneralSection:AddToggle({Name = "Health Check",Default = AimingSettings.HealthCheck,Callback = function(P)
	AimingSettings.HealthCheck = P
end})

GeneralSection:AddToggle({Name = "Friend Check",Default = AimingSettings.FriendCheck,Callback = function(P)
	AimingSettings.FriendCheck = P
end})

GeneralSection:AddToggle({Name = "Player Check",Default = AimingSettings.PlayerCheck,Callback = function(E)
	AimingSettings.PlayerCheck = E
end})

GeneralSection:AddToggle({Name = "Ignored Check",Default = AimingSettings.IgnoredCheck,Callback = function(P)
	AimingSettings.IgnoredCheck = P
end})

local ModuleExtras = GeneralTab:CreateSection({ Name = "Extra" })

ModuleExtras:AddToggle({Name = "Force Field Check",Default = AimingSettings.ForcefieldCheck,Callback = function(P)
	AimingSettings.ForcefieldCheck = P
end})

ModuleExtras:AddToggle({Name = "Invisible Check",Default = AimingSettings.InvisibleCheck,Callback = function(P)
	AimingSettings.InvisibleCheck = P
end})

ModuleExtras:AddToggle({Name = "Air Check",Default = Configuration.AirShootFunc,Callback = function(P)
	Configuration.AirShootFunc = P
end})

-- // Target Part Section for Aiming Page
local TargetPartCharacterSection = GeneralTab:CreateSection({ Name = "Hibox" })

do
	-- // Get some parts
	local function GetCharacterParts()
		-- // Vars
		local Parts = {}

		-- // Loop through Players
		for _, Player in ipairs(Players:GetPlayers()) do
			-- // Attempt to get their character
			local Character = AimingUtilities.Character(Player)
			if (not Character) then
				continue
			end

			-- //
			local CharacterParts = AimingUtilities.GetBodyParts(Character)
			if (#CharacterParts > 0) then
				Parts = CharacterParts
				break
			end
		end

		-- // Return
		table.insert(Parts, "All")
		return Parts
	end

	-- //
	local CharacterParts = AimingUtilities.ArrayToString(GetCharacterParts())
	local TargetPartCharacterInput = TargetPartCharacterSection:AddDropdown({Name = "Select Hitbox",Multi = "Parts",List = CharacterParts,Callback = function(t)
		AimingSettings.TargetPart = t
	end})
end

local HitChan = GeneralTab:CreateSection({ Name = "Chance" })
HitChan:AddSlider({Name = "Chance",Value = 100,Min = 0,Max = 100,Textbox = true,Callback = function(K)
	AimingSettings.HitChance = K
end})

local Distance = GeneralTab:CreateSection({ Name = "Distance" })
Distance:AddSlider({Name = "Max Distance",Value = 500,Min = 0,Max = 1000,Textbox = true,Callback = function(K)
	AimingSettings.MaxDistance  = K
end})


-- // Fov Settings
local fovset = GeneralTab:CreateSection({ Name = "Fov Config", Side = "Right" })
fovset:AddToggle({Name = "Enabled",Flag = "Enabled",Callback = function(P)
	AimingSettings.FOVSettings.Enabled = P
end})

fovset:AddToggle({Name = "Visible",Callback = function(P)
	AimingSettings.FOVSettings.Visible = P
end})

fovset:AddToggle({Name = "Follow Selected",Callback = function(P)
	AimingSettings.FOVSettings.FollowSelected = P
end})

fovset:AddSlider({Name = "Size",Value = 60,Min = 1,Max = 300,Textbox = true,Callback = function(M)
	AimingSettings.FOVSettings.Scale = M
end})

fovset:AddDropdown({Name = "Type",List = {"Static", "Dynamic"},Callback = function(selection)
	AimingSettings.FOVSettings.Type = selection
end})

fovset:AddSlider({Name = "Dynamic Constant", Flag = "Dynami_Constant", Value = 30, Min = 1, Max = 50, Textbox = true, Callback = function(M)
	AimingSettings.FOVSettings.DynamicFOVConstant = M
end})

fovset:AddColorpicker({Name = "Colour",Callback = function(Q)
	AimingSettings.FOVSettings.Colour = Q
end})

local LockModeSet = GeneralTab:CreateSection({ Name = "Focus Target", Side = "Left" })
LockModeSet:AddToggle({Name = "Enabled",Callback = function(P)
	AimingSettings.LockMode.Enabled = P
end})

LockModeSet:AddKeybind({Name = "Key",Default = UnlockBind.EnumType == Enum.KeyCode and UnlockBind.Name or UnlockBind,Callback = function(value)
	AimingSettings.LockMode.UnlockBind = value
end})

-- // Tracer Settings
local tracerco = GeneralTab:CreateSection({ Name = "Tracer Settings", Side = "Right" })

tracerco:AddToggle({Name = "Tracer",Callback = function(P)
	AimingSettings.TracerSettings.Enabled = P
end})

tracerco:AddSlider({Name = "Thickness",Flag = "tracer_Thickness",Value = 2,Min = 1,Max = 30,Textbox = true,Callback = function(M)
	AimingSettings.TracerSettings.Thickness = M
end})

tracerco:AddColorpicker({Name = "Color",Callback = function(Q)
	AimingSettings.TracerSettings.Colour = Q
end})

local BoxConfig = GeneralTab:CreateSection({ Name = "Boxes Settings", Side = "Right" })

BoxConfig:AddToggle({Name = "Enabled",Callback = function(P)
	AimingSettings.BoxSettings.Enabled = P
end})

BoxConfig:AddColorpicker({Name = "Color",Callback = function(Q)
	AimingSettings.BoxSettings.Colour = Q
end})


-- // Offsets
local OffsetSettings = GeneralTab:CreateSection({ Name = "Offsets", Side = "Right" })

OffsetSettings:AddToggle({Name = "Enabled",Callback = function(P)
	Configuration.Offset = P
end})

OffsetSettings:AddSlider({Name = "Offset X",Flag = "OffsetX",Value = 0,Min = -100,Max = 100,Textbox = true,Callback = function()
	AimingSettings.Offset = Vector2new(library.flags.OffsetX, library.flags.OffsetY)
end})

OffsetSettings:AddSlider({Name = "Offset Y",Flag = "OffsetY",Value = 0,Min = -100,Max = 100,Textbox = true,Callback = function()
	AimingSettings.Offset = Vector2new(library.flags.OffsetX, library.flags.OffsetY)
end})

-- //  Aim
local AimingTab = TechGui:CreateTab({Name = "Aim"})

local AimTab = AimingTab:CreateSection({ Name = "Enabled" })

AimTab:AddToggle({Name = "Aim enabled",Default = Configuration.Enabled,Callback = function(E)
	Configuration.Enabled = E
end})

AimTab:AddToggle({Name = "Silent-Aim enabled",Default = Configuration.SilentAim.Enabled,Callback = function(E)
	Configuration.SilentAim.Enabled = E
end})

local Settings = AimingTab:CreateSection({ Name = "Settings"})

Settings:AddKeybind({Name = "Keybind",Default = Configuration.Keybind,Callback = function(value)
	Configuration.Keybind = value
end})

Settings:AddToggle({Name = "Toggle",Default = Configuration.ToggleBind,Callback = function(value)
	Configuration.ToggleBind = value
end})

local AimMethod = AimingTab:CreateSection({ Name = "Aim Method"})

AimMethod:AddToggle({Name = "Mouse",Default = Configuration.Aimbot.Enabled,Callback = function(E)
	Configuration.Aimbot.Enabled = E
end})

AimMethod:AddToggle({Name = "Camera",Default = Configuration.Camlock.Enabled,Callback = function(E)
	Configuration.Camlock.Enabled = E
end})

local MouseSettings = AimingTab:CreateSection({ Name = "Mouse Settings", Side = "Right" })

MouseSettings:AddSlider({Name = "Mouse Sensibility",Precise = 1,Min = 0,Max = 10,Textbox = true,IllegalInput = true,Callback = function(M)
	Configuration.Aimbot.MouseSensibility = M
end})

MouseSettings:AddSlider({Name = "Mouse Smoothness",Min = 0,Max = 50,Textbox = true,IllegalInput = true,Callback = function(M)
	Configuration.Aimbot.MouseSmoothness = M
end})

local CameraSettings = AimingTab:CreateSection({ Name = "Camera Settings", Side = "Right" })

CameraSettings:AddDropdown({Name = "Robotic Movement First Type",List = {"Cubic", "Bounce"},Callback = function(selection)
	Configuration.Camlock.RoboticMovement.Types.First = selection
end})

CameraSettings:AddDropdown({Name = "Robotic Movement Second Type",List = {"Cubic", "Bounce"},Callback = function(selection)
	Configuration.Camlock.RoboticMovement.Types.Second = selection
end})

CameraSettings:AddSlider({Name = "Robotic Movement Sensitivity",Precise = 5,Min = 0,Max = 1,Textbox = true,IllegalInput = true,Callback = function(value)
	Configuration.Camlock.RoboticMovement.Sensitivity = value
end})

-- // Advanced Tab
local AdvancedTab = TechGui:CreateTab({ Name = "Advanced" })

-- // Predict Section
local SilentPredicSlider = AdvancedTab:CreateSection({ Name = "Silent Aim" })

SilentPredicSlider:AddToggle({Name = "Auto Prediction",Default = Configuration.SilentAim.AutoPrediction,Callback = function(E)
	Configuration.SilentAim.AutoPrediction = E
end})

SilentPredicSlider:AddToggle({Name = "Auto Prediction 1",Default = Configuration.SilentAim.AutoPrediction1,Callback = function(E)
	Configuration.SilentAim.AutoPrediction1 = E
end})

local ManualPredict = AdvancedTab:CreateSection({ Name = "Manual Predict" })

ManualPredict:AddSlider({Name = "Manual Predict",Precise = 3,Min = 0,Max = .600,IllegalInput = true,Textbox = true,Callback = function(M)
	Configuration.SilentAim.Prediction = M
end})

local AimbotPredicSlider = AdvancedTab:CreateSection({ Name = "Aimbot", Side = "Right" })

AimbotPredicSlider:AddToggle({Name = "Auto Prediction",Default = Configuration.Aimbot.AutoPrediction,Callback = function(E)
	Configuration.Aimbot.AutoPrediction = E
end})

AimbotPredicSlider:AddToggle({Name = "Auto Prediction 1",Default = Configuration.Aimbot.AutoPrediction1,Callback = function(E)
	Configuration.Aimbot.AutoPrediction1 = E
end})

local ManualPredict2 = AdvancedTab:CreateSection({ Name = "Manual Predict", Side = "Right" })

ManualPredict2:AddSlider({Name = "Manual Predict",Precise = 3,Min = 0, Max = .450, IllegalInput = true,extbox = true, Callback = function(M)
	Configuration.Aimbot.Prediction = M
end})

-- // Whitelist
local whitelistab = TechGui:CreateTab({ Name = "Whitelist" })

local whit = whitelistab:CreateSection({ Name = "Whitelist Players" })
whit:AddButton({Name = "Add Player to the Whitelist", Callback = function()
	whit:AddSearchBox({Name = "Whitelist",List = game.Players, Callback = function(X)
		AimingIgnored.IgnorePlayer(X)
	end})
end})

local Unwhit = whitelistab:CreateSection({ Name = "UnWhitelist", Side = "Right" })
Unwhit:AddButton({Name = "Remove from the Whitelist", Callback = function()
	Unwhit:AddSearchBox({Name = "UnWhitelist",List = game.Players, Callback = function(Y)
		AimingIgnored.UnIgnorePlayer(Y)
	end})
end})


-- Function to get adjusted velocity
local function GetVelocity(Position, Velocity, Multiplier)
    return Position + (Velocity * Multiplier)
end

local function SilentPrediction(SelectedPart)
    local Multiplier

    if Configuration.SilentAim.AutoPrediction then
        if GetPing > 200 then Multiplier = 0.55
        elseif GetPing > 190 then Multiplier = 0.49
        elseif GetPing > 180 then Multiplier = 0.44
        elseif GetPing > 170 then Multiplier = 0.37
        elseif GetPing > 160 then Multiplier = 0.32
        elseif GetPing > 150 then Multiplier = 0.31
        elseif GetPing > 140 then Multiplier = 0.28
        elseif GetPing > 130 then Multiplier = 0.25
        elseif GetPing > 120 then Multiplier = 0.22
        elseif GetPing > 110 then Multiplier = 0.189
        elseif GetPing > 100 then Multiplier = 0.186
        elseif GetPing > 90 then Multiplier = 0.183
        elseif GetPing > 80 then Multiplier = 0.181
        elseif GetPing > 70 then Multiplier = 0.179
        elseif GetPing > 60 then Multiplier = 0.177
    	end
    elseif Configuration.SilentAim.AutoPrediction1 then
        if GetPing > 200 then Multiplier = 0.22554
        elseif GetPing > 190 then Multiplier = 0.22554
        elseif GetPing > 180 then Multiplier = 0.21722
        elseif GetPing > 170 then Multiplier = 0.2089
        elseif GetPing > 160 then Multiplier = 0.20058
        elseif GetPing > 150 then Multiplier = 0.14728054792824583
        elseif GetPing > 140 then Multiplier = 0.14676912883558116
        elseif GetPing > 130 then Multiplier = 0.14614337395777216
        elseif GetPing > 120 then Multiplier = 0.14556534594403
        elseif GetPing > 110 then Multiplier = 0.1673
        elseif GetPing > 100 then Multiplier = 0.15066
        elseif GetPing > 90 then Multiplier = 0.14234
        elseif GetPing > 80 then Multiplier = 0.13402
        elseif GetPing > 70 then Multiplier = 0.1312
        elseif GetPing > 60 then Multiplier = 0.1229
        end
    else
        Multiplier = Configuration.SilentAim.Prediction
    end

    return GetVelocity(SelectedPart.Position, SelectedPart.Velocity, Multiplier or 0)
end

local games = {
	[4436053088] = { remote = replicatedstorage:FindFirstChild('MAINEVENT'), arg = 'MOUSE' },
	[5641075481] = { remote = replicatedstorage:FindFirstChild('MAINEVENT'), arg = 'MOUSE' },
	[5641076065] = { remote = replicatedstorage:FindFirstChild('MAINEVENT'), arg = 'MOUSE' },
	[5235037897] = { remote = replicatedstorage:FindFirstChild('MAINEVENT'), arg = 'MOUSE' },
	[6752601955] = { remote = replicatedstorage:FindFirstChild('MAINEVENT'), arg = 'MOUSE' },
	[6706894695] = { remote = replicatedstorage:FindFirstChild('MAINEVENT'), arg = 'MOUSE' },
	[4550058213] = { remote = replicatedstorage:FindFirstChild('Remote'), arg = 'UpdateMousePos' }, -- DAT
}

local game_data = games[game.GameId]
local remote, remote_args, remote_override;

if (game_data and game_data.place_id) then
	for _, data in pairs(games) do
		if (data.place_id == game.PlaceId) then
			game_data = data
			break
		end
	end
end

if (game_data) then
	remote_override = rawget(game_data, 'override')
	remote = game_data.remote
	remote_args = game_data.arg
end

local update_pos = function(position)
	if (not game_data) then return end

	if (typeof(remote_override) == 'table') then
		if (rawget(remote_override, 'MousePos')) then
			remote_override.MousePos = position
			remote_override.Camera = position
		else
			remote_override[1] = position
			remote_override[2] = position
		end

		remote:FireServer(remote_args, remote_override)
	elseif (typeof(remote_override) == 'string') then
		remote:FireServer(remote_args, position, remote_override)
	elseif (typeof(remote_override) == 'Vector3') then
		remote:FireServer(remote_args, { position })
	else
		remote:FireServer(remote_args, position)
	end
end

local apply_silent = function()
	if (ConfigurationToggled and Configuration.SilentAim.Enabled and AimingChecks.IsAvailable()) then
		local TargetPart = AimingSelected.Part
		update_pos(SilentPrediction(TargetPart))
	end
end

local on_tool = function(obj)
	if not (obj:IsA('Tool') and obj:FindFirstChildWhichIsA('Script')) then return end

	if (weapon_connection) then
		weapon_connection:Disconnect()
		weapon_connection = nil
	end

	weapon_connection = obj.Activated:Connect(apply_silent)
end

local on_character_added = function(char)
	if (charcon) then
		charcon:Disconnect()
		charcon = nil
	end

	charcon = char.ChildAdded:Connect(on_tool)
end

-- // AimbotPrediction
local function AimbotPrediction(SelectedPart)
    local Multiplier
    if Configuration.Aimbot.AutoPrediction then
        if GetPing > 200 then Multiplier = 0.55
        elseif GetPing > 190 then Multiplier = 0.49
        elseif GetPing > 180 then Multiplier = 0.44
        elseif GetPing > 170 then Multiplier = 0.37
        elseif GetPing > 160 then Multiplier = 0.32
        elseif GetPing > 150 then Multiplier = 0.31
        elseif GetPing > 140 then Multiplier = 0.28
        elseif GetPing > 130 then Multiplier = 0.25
        elseif GetPing > 120 then Multiplier = 0.22
        elseif GetPing > 110 then Multiplier = 0.189
        elseif GetPing > 100 then Multiplier = 0.186
        elseif GetPing > 90 then Multiplier = 0.183
        elseif GetPing > 80 then Multiplier = 0.181
        elseif GetPing > 70 then Multiplier = 0.179
        elseif GetPing > 60 then Multiplier = 0.177
        end
    else
        Multiplier = Configuration.Aimbot.Prediction
    end
    return SelectedPart.CFrame + (SelectedPart.Velocity * Multiplier)
end

-- // CameraPosition
local function CameraPosition(SelectedPart)
    local Multiplier
    if Configuration.Aimbot.AutoPrediction then
        if GetPing < 60 then Multiplier = 0.177
        elseif GetPing < 70 then Multiplier = 0.179
        elseif GetPing < 80 then Multiplier = 0.181
        elseif GetPing < 90 then Multiplier = 0.183
        elseif GetPing < 100 then Multiplier = 0.186
        elseif GetPing < 110 then Multiplier = 0.189
        elseif GetPing < 120 then Multiplier = 0.22
        elseif GetPing < 130 then Multiplier = 0.25
        elseif GetPing < 140 then Multiplier = 0.28
        elseif GetPing < 150 then Multiplier = 0.31
        elseif GetPing < 160 then Multiplier = 0.32
        elseif GetPing < 170 then Multiplier = 0.37
        elseif GetPing < 180 then Multiplier = 0.44
        elseif GetPing < 190 then Multiplier = 0.49
        elseif GetPing < 200 then Multiplier = 0.55
        end
    elseif Configuration.Aimbot.AutoPrediction1 then
        if GetPing > 200 then Multiplier = 0.22554
        elseif GetPing > 190 then Multiplier = 0.22554
        elseif GetPing > 180 then Multiplier = 0.21722
        elseif GetPing > 170 then Multiplier = 0.2089
        elseif GetPing > 160 then Multiplier = 0.20058
        elseif GetPing > 150 then Multiplier = 0.19226
        elseif GetPing > 140 then Multiplier = 0.18394
        elseif GetPing > 130 then Multiplier = 0.17562
        elseif GetPing > 120 then Multiplier = 0.1673
        elseif GetPing > 110 then Multiplier = 0.1673
        elseif GetPing > 100 then Multiplier = 0.15066
        elseif GetPing > 90 then Multiplier = 0.14234
        elseif GetPing > 80 then Multiplier = 0.13402
        elseif GetPing > 70 then Multiplier = 0.1312
        elseif GetPing > 60 then Multiplier = 0.1229
        end
    else
        Multiplier = Configuration.Aimbot.Prediction
    end
    return SelectedPart.Position + (SelectedPart.Velocity * Multiplier)
end


function AimLockPosition(CameraMode)
	local Position

	local Hit = AimbotPrediction(AimingSelected.Part)
	local HitPosition = Hit.Position

	if (CameraMode) then
		Position = HitPosition
	else
		local Vector, _ = CurrentCamera:WorldToScreenPoint(HitPosition)
		local Vector2D = Vector2.new(Vector.X, Vector.Y)

		Position = Vector2D
	end
	return Position
end

local function CheckInput(Input, Expected)
	local InputType = Expected.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType"
	return Input[InputType] == Expected
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	-- // Make sure is not processed
	if (GameProcessedEvent) then
		return
	end

	if (CheckInput(Input, Configuration.Keybind)) then
		if (Configuration.ToggleBind) then
			ConfigurationToggled = not ConfigurationToggled
		else
			ConfigurationToggled = true
		end
	end

	if (CheckInput(Input, Enum.UserInputType.MouseButton2) and Configuration.Aimbot.No2click) then
		ConfigurationToggled = false
	end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
	if (GameProcessedEvent) then
		return
	end

	if (CheckInput(Input, Configuration.Keybind) and not Configuration.ToggleBind) then
		ConfigurationToggled = false
	end
end)

local function onPlayerAdded(player)
	local character = player.Character or player.CharacterAdded:Wait()
	if character then
		if player:IsInGroup(GroupId) then
			AimingIgnored.IgnorePlayer(player)
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		onPlayerAdded(player)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

task.spawn(function()
	while (true) do 
	-- // Make sure key (or mouse button) is down
		if (Configuration.Enabled and ConfigurationToggled and AimingChecks.IsAvailable()) then
			-- // Vars
			Position = AimLockPosition(CameraMode)
			local Part = AimingSelected.Part
			local Pos = CameraPosition(Part)
			local Magnitude = Vector2new(Position.X - Mouse.X, Position.Y - Mouse.Y)
			if Configuration.Offset then
				Magnitude = Magnitude + Vector2new(library.flags.OffsetX, library.flags.OffsetY)
			end
			if Configuration.Aimbot.Enabled then
				mousemoverel((Magnitude.X * Configuration.Aimbot.MouseSensibility) / Configuration.Aimbot.MouseSmoothness,
					(Magnitude.Y * Configuration.Aimbot.MouseSensibility) / Configuration.Aimbot.MouseSmoothness)
			end
			if Configuration.Camlock.Enabled then
				CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(CFrame.new(CurrentCamera.CFrame.Position, Pos), Configuration.Camlock.RoboticMovement.Sensitivity or 0.095, Enum.EasingStyle[Configuration.Camlock.RoboticMovement.Types.First or 'Elastic'], Enum.EasingDirection.InOut, Enum.EasingStyle[Configuration.Camlock.RoboticMovement.Types.Second or 'Bounce'])
			end
		end
		if Configuration.AirShootFunc then
			if AimingChecks.IsAvailable() then
				local Character = AimingUtilities.Character(AimingSelected.Instance)
				if Character then
					local Humanoid = Character:FindFirstChild("Humanoid")
					if Humanoid then
						if Humanoid.Jump == true or Humanoid.FloorMaterial == Enum.Material.Air then
							AimingSettings.TargetPart = { "RightFoot", "LeftFoot" }
						else
							AimingSettings.TargetPart = { "Head", "HumanoidRootPart" }
						end

						if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
							AimingSettings.TargetPart = { "RightFoot", "LeftFoot" }
						else
							AimingSettings.TargetPart = { "Head", "HumanoidRootPart" }
						end
					end
				end
			end
		end
		RunService.PostSimulation:Wait()
	end
end)

LocalPlayer.CharacterAdded:Connect(on_character_added)

if (LocalPlayer.Character) then
	charcon = LocalPlayer.Character.ChildAdded:Connect(on_tool)
end
