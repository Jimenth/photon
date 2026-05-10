local Menu = gui.create("Fallen", false)
Menu:set_pos(100, 100)
Menu:set_size(400, 300)

local Enabled = Menu:add_checkbox("Enabled", true)
local Keybind = Menu:add_keybind("Aim", 0x45)
local SensitivitySlider = Menu:add_slider("Sensitivity", 0.1, 2, 1.0)
local SmoothX = Menu:add_slider("Smooth X", 1, 20, 5)
local SmoothY = Menu:add_slider("Smooth Y", 1, 20, 5)
local Parts = { "Head", "UpperTorso", "LowerTorso" }
local Hitparts = Menu:add_multicombo("Hitparts", Parts, {1})

local Players = game:get_service("Players")
local Workspace = game:get_service("Workspace")
local Camera = Workspace:find_first_child_class("Camera")
local LocalPlayer = Players.local_player

local Weapons = {
    ["Boulder"] = { Speed = 500, Gravity = 0.55, MaxRange = 1100, Dropoff = { Start = 550, End = 1000 } },
    ["Salvaged M14"] = { Speed = 2100, Gravity = 0.55, MaxRange = 1100, Dropoff = { Start = 550, End = 1000 } },
    ["Military M39"] = { Speed = 2400, Gravity = 0.52, MaxRange = 1300, Dropoff = { Start = 600, End = 1150 } },
    ["Salvaged AK47"] = { Speed = 2100, Gravity = 0.55, MaxRange = 1100, Dropoff = { Start = 550, End = 1000 } },
    ["Military M4A1"] = { Speed = 2100, Gravity = 0.55, MaxRange = 1050, Dropoff = { Start = 550, End = 950 } },
    ["Bruno's M4A1"] = { Speed = 2100, Gravity = 0.55, MaxRange = 1050, Dropoff = { Start = 550, End = 950 } },
    ["Military PKM"] = { Speed = 2400, Gravity = 0.55, MaxRange = 1250, Dropoff = { Start = 600, End = 1000 } },
    ["Salvaged AK74u"] = { Speed = 1800, Gravity = 0.60, MaxRange = 800, Dropoff = { Start = 325, End = 700 } },
    ["Military MP7"] = { Speed = 1900, Gravity = 0.60, MaxRange = 800, Dropoff = { Start = 325, End = 700 } },
    ["Crossbow"] = { Speed = 420, Gravity = 0.20, MaxRange = 500, Dropoff = { Start = 175, End = 375 } },
    ["Wooden Bow"] = { Speed = 280, Gravity = 0.20, MaxRange = 400, Dropoff = { Start = 125, End = 300 } },
    ["Salvaged P250"] = { Speed = 1400, Gravity = 0.60, MaxRange = 600, Dropoff = { Start = 250, End = 500 } },
    ["Military USP"] = { Speed = 1500, Gravity = 0.60, MaxRange = 650, Dropoff = { Start = 275, End = 525 } },
    ["Salvaged SMG"] = { Speed = 1800, Gravity = 0.60, MaxRange = 750, Dropoff = { Start = 325, End = 700 } },
    ["Salvaged Skorpion"] = { Speed = 1600, Gravity = 0.60, MaxRange = 550, Dropoff = { Start = 250, End = 500 } },
    ["Salvaged Python"] = { Speed = 1800, Gravity = 0.60, MaxRange = 700, Dropoff = { Start = 325, End = 600 } },
    ["Nail Gun"] = { Speed = 165, Gravity = 0.25, MaxRange = 125, Dropoff = { Start = 25, End = 100 } },
    ["Salvaged RPG"] = { Speed = 100, Gravity = 0.12, MaxRange = 1000, Dropoff = { Start = 1000, End = 1000 } },
    ["Pumpkin Launcher"] = { Speed = 80, Gravity = 0.16, MaxRange = 2000, Dropoff = { Start = 1000, End = 1000 } },
    ["Military Grenade Launcher"] = { Speed = 85, Gravity = 0.15, MaxRange = 2000, Dropoff = { Start = 1000, End = 1000 } },
    ["Salvaged Grenade Launcher"] = { Speed = 85, Gravity = 0.15, MaxRange = 2000, Dropoff = { Start = 1000, End = 1000 } },
    ["Salvaged Pipe Rifle"] = { Speed = 1700, Gravity = 0.60, MaxRange = 850, Dropoff = { Start = 400, End = 750 } },
    ["Military Barrett"] = { Speed = 2500, Gravity = 0.55, MaxRange = 1100, Dropoff = { Start = 550, End = 1000 } },
    ["Salvaged Sniper"] = { Speed = 2400, Gravity = 0.55, MaxRange = 1100, Dropoff = { Start = 550, End = 1000 } },
    ["Salvaged Double Barrel"] = { Speed = 550, Gravity = 0.60, MaxRange = 200, Dropoff = { Start = 12, End = 150 } },
    ["Salvaged Break Action"] = { Speed = 550, Gravity = 0.60, MaxRange = 200, Dropoff = { Start = 12, End = 150 } },
    ["Salvaged Shotgun"] = { Speed = 400, Gravity = 0.60, MaxRange = 100, Dropoff = { Start = 10, End = 80 } },
    ["Military AA12"] = { Speed = 600, Gravity = 0.60, MaxRange = 200, Dropoff = { Start = 16, End = 150 } },
    ["Salvaged Pump Action"] = { Speed = 650, Gravity = 0.60, MaxRange = 200, Dropoff = { Start = 20, End = 150 } },
}

local function GetWeaponName()
    local Character = LocalPlayer.character
    if Character and Character:isvalid() then
        for _, Child in ipairs(Character:get_children()) do
            if Child:isvalid() and Child.class_name == "Model" and Child:find_first_child("Handle") and Child.name:sub(1, 5) ~= "Armor" and Child.name ~= "Hair" and Child.name ~= "HolsterModel" then
                return Child.name or ""
            end
        end
    end
    return ""
end

local function CalculateDrop(Data, Distance)
    local DropMulti

    if Distance <= Data.Dropoff.Start then
        DropMulti = 0
    elseif Distance >= Data.Dropoff.End then
        DropMulti = 1
    else
        DropMulti = (Distance - Data.Dropoff.Start) / (Data.Dropoff.End - Data.Dropoff.Start)
    end

    return 0.5 * get_gravity() * Data.Gravity * (Distance / Data.Speed ^ 2) * DropMulti
end

local function GetClosestPart(Character)
    local ScreenCenter = get_screen_size():divide_scalar(2)
    local Targeting = {
        Part = nil,
        Distance = math.huge
    }

    for _, Index in ipairs(Hitparts:get_selected()) do
        local Name = Parts[Index + 1]
        if Name then
            local Part = Character:find_first_child(Name)
            if Part and Part:isvalid() then
                local Screen = world_to_screen(Part.position)
                if in_screen(Screen) then
                    local Dist = Screen:distance(ScreenCenter)
                    if Dist < Targeting.Distance then
                        Targeting.Distance = Dist
                        Targeting.Part = Part
                    end
                end
            end
        end
    end

    return Targeting.Part
end

local function Main()
    if not Enabled:get_value() then return end

    local Weapon = GetWeaponName()
    local Data = Weapons[Weapon]
    if not Data then return end

    local Targeting = {
        World = nil,
        Velocity = nil,
        Distance = math.huge
    }

    for _, Player in ipairs(Players:get_children()) do
        if Player:isvalid() and Player.class_name == "Player" and Player.identity ~= LocalPlayer.identity then
            local Character = Player.character
            if Character and Character:isvalid() then
                local Part = GetClosestPart(Character)
                if Part then
                    local Screen = world_to_screen(Part.position)
                    if in_screen(Screen) then
                        local ScreenDistance = Screen:distance(get_screen_size():divide_scalar(2))
                        if ScreenDistance < Targeting.Distance then
                            Targeting.Distance = ScreenDistance
                            Targeting.World = Part.position
                            Targeting.Velocity = Part.linear_velocity
                        end
                    end
                end
            end
        end
    end

    if not Targeting.World then return end

    local CameraPosition = Camera.camera_position
    local WorldDistance = CameraPosition:distance(Targeting.World)
    if WorldDistance > Data.MaxRange then return end

    local Predicted = vector3( Targeting.World.x + Targeting.Velocity.x * WorldDistance / Data.Speed, Targeting.World.y + Targeting.Velocity.y * WorldDistance / Data.Speed, Targeting.World.z + Targeting.Velocity.z * WorldDistance / Data.Speed)
    local PredictedDistance = CameraPosition:distance(Predicted)
    if PredictedDistance > Data.MaxRange then return end

    local Drop = CalculateDrop(Data, PredictedDistance)
    local Compensated = vector3(Predicted.x, Predicted.y + Drop, Predicted.z)

    local ScreenAim = world_to_screen(Compensated)
    if not in_screen(ScreenAim) then return end

    local CurrentMouse = input.get_mouse_position()

    input.set_mouse_position_rel(vector2(
        (ScreenAim.x - CurrentMouse.x) / SmoothX:get_value() * SensitivitySlider:get_value(),
        (ScreenAim.y - CurrentMouse.y) / SmoothY:get_value() * SensitivitySlider:get_value()
    ))
end

hook.add("render", "aiming", function()
    if Keybind:get_state() then
        Main()
    end
end)
