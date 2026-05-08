local Module = {
    Function = {},
    Service = {
        Workspace = game:get_service("Workspace"),
        Players = game:get_service("Players")
    },
    Stored = {
        Cache = {},
        Folders = {}
    }
}

function Module.Function:IsCharacter(Model)
    for _, Player in ipairs(Module.Service.Players:get_children()) do
        if Player.class_name == "Player" then
            local Character = Player.character
            if Character and Character:isvalid() and Character.identity == Model.identity then
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
        if Humanoid:isvalid() and Humanoid:isa("Humanoid") then
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
        if not Entity:isvalid() or not Entity:get_parent() then
            Module.Stored.Cache[Identity] = nil
        end
    end
    
    for _, Directory in ipairs(Module.Stored.Folders) do
        for _, Entity in ipairs(Directory:get_children()) do
            if Entity:isvalid() and Entity:get_parent() and Entity:isa("Model") then
                Module.Stored.Cache[Entity.identity] = Entity
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
        if Entity:isvalid() and Entity:get_parent() then
            local Humanoid = Entity:find_first_child_class("Humanoid")
            local HumanoidRootPart = Entity:find_first_child("HumanoidRootPart")

            if Humanoid and Humanoid:isvalid() and HumanoidRootPart and HumanoidRootPart:isvalid() then
                local BoundingSize

                if #Module.Stored.Cache < 25 then
                    local MinBound = vector3(math.huge, math.huge, math.huge)
                    local MaxBound = vector3(-math.huge, -math.huge, -math.huge)

                    for _, Part in ipairs(Entity:get_children()) do
                        if Part:isvalid() and (Part:isa("MeshPart") or Part:isa("Part")) then
                            local Position = Part.position
                            local Size = Part.size / 2

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

                    BoundingSize = MaxBound - MinBound

                    if BoundingSize.x > 10 or BoundingSize.y > 10 or BoundingSize.z > 10 then
                        BoundingSize = vector3(3, 4, 3)
                    end
                else
                    BoundingSize = vector3(3, 4, 3)
                end

                add_entity(Entity.name, HumanoidRootPart, Humanoid, true, BoundingSize / 2, BoundingSize / 2)
            end
        end
    end
end)
