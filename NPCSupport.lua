local Workspace = game:get_service("Workspace")
local Players = game:get_service("Players")

local GameID = tonumber(get_gameid())
local Self = Players.local_player

local Paths = {
    [962862716] = function() -- AimH4X
        return Workspace:find_first_child("CurrentBots")
    end,
    [187796008] = function() -- Those Who Remain
        local E = Workspace:find_first_child("Entities")
        return E and E:find_first_child("Infected")
    end,
    [3104101863] = function() -- Michael's Zombies
        local I = Workspace:find_first_child("Ignore")
        return I and I:find_first_child("Zombies")
    end,
    [504035427] = function() -- Zombie Attack
        return Workspace:find_first_child("enemies")
    end,
    [3349613241] = function() -- AI Test
        return Workspace:find_first_child("NPCs")
    end,
    [1709832923] = function() -- Zombie Uprising
        return Workspace:find_first_child("Zombies")
    end,
    [169302362] = function() -- Project Lazarus
        return Workspace:find_first_child("Baddies")
    end,
    [3956073837] = function() -- Korrupt Zombies
        return Workspace:find_first_child("Zombies")
    end,
    [2263267302] = function() -- Infamy
        local N = Workspace:find_first_child("NPCs")
        return N and N:find_first_child("policeForce")
    end,
    [2575793677] = function() -- Aniphobia
        return Workspace:find_first_child("OtherWaifus")
    end,
    [3326279937] = function() -- Blackout Zombies
        local N = Workspace:find_first_child("NPCs")
        return N and N:find_first_child("Custom")
    end,
    [1000233041] = function() -- SCP 3008
        local G = Workspace:find_first_child("GameObjects")
        local P = G and G:find_first_child("Physical")
        return P and P:find_first_child("Employees")
    end,
    [5091490171] = function() -- Jailbird Co-Op
        return Workspace:find_first_child("Bots")
    end,
    [1003981402] = function() -- Reminiscence Zombies
        return Workspace:find_first_child("Zombies")
    end,
    [3747388906] = function() -- Fallen Survival
        local M = Workspace:find_first_child("Military")
        return M and M:get_children()
    end,
    [6907570572] = function() -- A-888
        local M = Workspace:find_first_child("mainGame")
        return M and M:find_first_child("active_anomaly")
    end
}

hook.add("init_custom_entity", "universal_npc", function()
    local EntitySource = Paths[GameID]
    if not EntitySource then return end

    local EntityRoot = EntitySource()
    if not EntityRoot or not EntityRoot:isvalid() then return end

    for _, NPC in ipairs(EntityRoot:get_children()) do
        if NPC:isa("Model") and NPC:find_first_child("Humanoid") and NPC:isvalid() then
            local Humanoid = NPC:find_first_child_class("Humanoid")
            local HumanoidRootPart = NPC:find_first_child("HumanoidRootPart")

            if Humanoid and Humanoid:isvalid() then
                if NPC.name ~= Self.name and HumanoidRootPart:isvalid() then
                    local MinBound = vector3(math.huge, math.huge, math.huge)
                    local MaxBound = vector3(-math.huge, -math.huge, -math.huge)

                    for _, Part in ipairs(NPC:get_children()) do
                        if (Part:isa("MeshPart") or Part:isa("Part")) and Part:isvalid() then
                            local Pos = Part.position
                            local Size = Part.size / 2

                            local PartMin = Pos - Size
                            local PartMax = Pos + Size

                            MinBound = vector3(
                                math.min(MinBound.x, PartMin.x),
                                math.min(MinBound.y, PartMin.y),
                                math.min(MinBound.z, PartMin.z)
                            )

                            MaxBound = vector3(
                                math.max(MaxBound.x, PartMax.x),
                                math.max(MaxBound.y, PartMax.y),
                                math.max(MaxBound.z, PartMax.z)
                            )
                        end
                    end

                    local BoundingSize = MaxBound - MinBound
                    add_entity(NPC.name, HumanoidRootPart, Humanoid, true, BoundingSize / 2, BoundingSize / 2)
                end
            end
        end
    end
end)
