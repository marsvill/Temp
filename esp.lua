local ESP = {
    Objects = {},
    Enabled = false,
    Settings = {
        TeamCheck = false,
        Boxes = false,
        Tracers = false,
        TracerOrigin = "Bottom", -- "Bottom", "Mouse", "Top"
        TracerTransparency = 0.5,
        BoxesTransparency = 0.5
    }
}

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local function CreateDrawing(type, properties)
    local obj = Drawing.new(type)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

function ESP:CreateObject(player)
    local objects = {
        Box = CreateDrawing("Square", {
            Thickness = 1,
            Filled = false,
            Transparency = self.Settings.BoxesTransparency,
            Color = Color3.new(1, 1, 1),
            Visible = false,
            ZIndex = 1
        }),
        BoxOutline = CreateDrawing("Square", {
            Thickness = 3,
            Filled = false,
            Transparency = self.Settings.BoxesTransparency,
            Color = Color3.new(0, 0, 0),
            Visible = false,
            ZIndex = 0
        }),
        Tracer = CreateDrawing("Line", {
            Thickness = 1,
            Transparency = self.Settings.TracerTransparency,
            Color = Color3.new(1, 1, 1),
            Visible = false,
            ZIndex = 1
        }),
        TracerOutline = CreateDrawing("Line", {
            Thickness = 3,
            Transparency = self.Settings.TracerTransparency,
            Color = Color3.new(0, 0, 0),
            Visible = false,
            ZIndex = 0
        })
    }
    
    self.Objects[player] = objects
    return objects
end

function ESP:RemoveObject(player)
    local objects = self.Objects[player]
    if objects then
        for _, obj in pairs(objects) do
            obj:Remove()
        end
        self.Objects[player] = nil
    end
end

function ESP:UpdateObject(player)
    local objects = self.Objects[player]
    if not objects then
        objects = self:CreateObject(player)
    end

    -- Reset visibility
    for _, obj in pairs(objects) do
        obj.Visible = false
    end

    if not self.Enabled then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and root) then return end

    -- Team check
    if self.Settings.TeamCheck and player.Team == LocalPlayer.Team then return end

    local rootPos = root.Position
    local pos2d, onScreen = Camera:WorldToViewportPoint(rootPos)
    if not onScreen then return end

    -- Update box
    if self.Settings.Boxes then
        local size = Vector2.new(1000 / pos2d.Z, 2000 / pos2d.Z)
        local pos = Vector2.new(pos2d.X - size.X / 2, pos2d.Y - size.Y / 2)
        
        objects.Box.Size = size
        objects.Box.Position = pos
        objects.Box.Visible = true
        
        objects.BoxOutline.Size = size
        objects.BoxOutline.Position = pos
        objects.BoxOutline.Visible = true
    end

    -- Update tracer
    if self.Settings.Tracers then
        local tracerStart
        if self.Settings.TracerOrigin == "Bottom" then
            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif self.Settings.TracerOrigin == "Mouse" then
            tracerStart = UserInputService:GetMouseLocation()
        elseif self.Settings.TracerOrigin == "Top" then
            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, 0)
        end

        objects.Tracer.From = tracerStart
        objects.Tracer.To = Vector2.new(pos2d.X, pos2d.Y)
        objects.Tracer.Visible = true

        objects.TracerOutline.From = tracerStart
        objects.TracerOutline.To = Vector2.new(pos2d.X, pos2d.Y)
        objects.TracerOutline.Visible = true
    end
end

function ESP:Toggle(enabled)
    self.Enabled = enabled
    if not enabled then
        for _, objects in pairs(self.Objects) do
            for _, obj in pairs(objects) do
                obj.Visible = false
            end
        end
    end
end

-- Setup player connections
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        ESP:CreateObject(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ESP:RemoveObject(player)
end)

-- Initialize existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ESP:CreateObject(player)
    end
end

-- Update loop
game:GetService("RunService").RenderStepped:Connect(function()
    for player, _ in pairs(ESP.Objects) do
        ESP:UpdateObject(player)
    end
end)

return ESP
