local Module = {
    Function = {},
    Service = {
        Workspace = game:get_service("Workspace"),
        Players = game:get_service("Players")
    },
    Stored = {
        Cache = {},
        Folders = {}
    },
    Data = {
        R15 = {
            Head = "Head",
            UpperTorso = "UpperTorso",
            LowerTorso = "LowerTorso",
            LeftUpperArm = "LeftUpperArm",
            LeftLowerArm = "LeftLowerArm",
            LeftHand = "LeftHand",
            RightUpperArm = "RightUpperArm",
            RightLowerArm = "RightLowerArm",
            RightHand = "RightHand",
            LeftUpperLeg = "LeftUpperLeg",
            LeftLowerLeg = "LeftLowerLeg",
            LeftFoot = "LeftFoot",
            RightUpperLeg = "RightUpperLeg",
            RightLowerLeg = "RightLowerLeg",
            RightFoot = "RightFoot"
        },

        R6 = {
            Head = "Head",
            Torso = "Torso",
            ["Left Arm"] = "Left Arm",
            ["Right Arm"] = "Right Arm",
            ["Left Leg"] = "Left Leg",
            ["Right Leg"] = "Right Leg"
        }
    }
}

function Module.Function:GetBodyData(Model)
    if not Model or not Model:isvalid() then return nil end
    if not Model:get_parent() or not Model:get_parent():isvalid() then return nil end

    local Humanoid = Model:find_first_child_class("Humanoid")
    if not Humanoid or not Humanoid:isvalid() then return nil end
    if not Humanoid:get_parent() or not Humanoid:get_parent():isvalid() then return nil end

    local RigType = Humanoid:get_rigtype()
    local BodyData = {}
    local Data

    if RigType == 1 then
        Data = Module.Data.R15
    elseif RigType == 0 then
        Data = Module.Data.R6
    else
        return nil
    end

    for Key, Name in pairs(Data) do
        local Part = Model:find_first_child(Name)

        if Part and Part:isvalid() and Part:get_parent() and Part:get_parent():isvalid() then
            table.insert(BodyData, { Key, Part })
        end
    end

    if #BodyData == 0 then return nil end

    return BodyData
end

function Module.Function:IsCharacter(Model)
    if not Model or not Model:isvalid() then return false end

    for _, Player in ipairs(Module.Service.Players:get_children()) do
        if Player and Player:isvalid() and Player.class_name == "Player" then
            local Character = Player.character
            if Character and Character:isvalid() and Character:get_parent() and Character.identity == Model.identity then
                return true
            end
        end
    end
    return false
end

function Module.Function:Scan()
    Module.Stored.Folders = {}

    local Temporary = {}

    for _, Humanoid in ipairs(Module.Service.Workspace:get_descendants()) do
        if Humanoid and Humanoid:isvalid() and Humanoid:isa("Humanoid") then
            local Entity = Humanoid:get_parent()

            if Entity and Entity:isvalid() and Entity:isa("Model") and not Module.Function:IsCharacter(Entity) then
                local Folder = Entity:get_parent()

                if Folder and Folder:isvalid() and not Temporary[Folder] then
                    Temporary[Folder] = true
                    table.insert(Module.Stored.Folders, Folder)
                end
            end
        end
    end
end

function Module.Function:Cache()
    for Identity, Entity in pairs(Module.Stored.Cache) do
        if not Entity or not Entity:isvalid() or not Entity:get_parent() or not Entity:get_parent():isvalid() then
            Module.Stored.Cache[Identity] = nil
        end
    end

    for _, Directory in ipairs(Module.Stored.Folders) do
        if Directory and Directory:isvalid() then
            for _, Entity in ipairs(Directory:get_children()) do
                if Entity and Entity:isvalid() and Entity:get_parent() and Entity:get_parent():isvalid() and Entity:isa("Model") then
                    Module.Stored.Cache[Entity.identity] = Entity
                end
            end
        end
    end
end

local UI = gui.create("$", false)
UI:set_pos(100, 100)
UI:set_size(300, 300)

UI:add_button("Rescan", function()
    Module.Function:Scan()
end)

spawn(function()
    while true do
        wait(1000)
        Module.Function:Cache()
    end
end)

hook.add("init_custom_entity", "universal_npc", function()
    for _, Entity in pairs(Module.Stored.Cache) do
        if Entity and Entity:isvalid() and Entity:get_parent() and Entity:get_parent():isvalid() and not Module.Function:IsCharacter(Entity) then
            local Humanoid = Entity:find_first_child_class("Humanoid")
            local HumanoidRootPart = Entity:find_first_child("HumanoidRootPart")

            if Humanoid and Humanoid:isvalid() and Humanoid:get_parent() and Humanoid:get_parent():isvalid()
            and HumanoidRootPart and HumanoidRootPart:isvalid() and HumanoidRootPart:get_parent() and HumanoidRootPart:get_parent():isvalid() then
                local BodyData = Module.Function:GetBodyData(Entity)

                if BodyData and #BodyData > 0 then
                    local BoundingSize

                    if #Module.Stored.Cache < 25 then
                        local MinBound = vector3(math.huge, math.huge, math.huge)
                        local MaxBound = vector3(-math.huge, -math.huge, -math.huge)
                        local ValidPartFound = false

                        for _, Part in ipairs(Entity:get_children()) do
                            if Part and Part:isvalid() and Part:get_parent() and Part:get_parent():isvalid()
                            and (Part:isa("MeshPart") or Part:isa("Part")) then
                                local Position = Part.position
                                local Size = Part.size

                                if Position and Size then
                                    Size = Size / 2
                                    ValidPartFound = true

                                    MinBound = vector3(
                                        math.min(MinBound.x, (Position - Size).x),
                                        math.min(MinBound.y, (Position - Size).y),
                                        math.min(MinBound.z, (Position - Size).z)
                                    )
                                    MaxBound = vector3(
                                        math.max(MaxBound.x, (Position + Size).x),
                                        math.max(MaxBound.y, (Position + Size).y),
                                        math.max(MaxBound.z, (Position + Size).z)
                                    )
                                end
                            end
                        end

                        if ValidPartFound then
                            BoundingSize = MaxBound - MinBound

                            if BoundingSize.x > 10 or BoundingSize.y > 10 or BoundingSize.z > 10 then
                                BoundingSize = vector3(3, 4, 3)
                            end
                        else
                            BoundingSize = vector3(3, 4, 3)
                        end
                    else
                        BoundingSize = vector3(3, 4, 3)
                    end

                    add_entity_ex(Entity.name, Entity, Humanoid, HumanoidRootPart, true, BoundingSize / 2, BoundingSize / 2, BodyData)
                end
            end
        end
    end
end)
