local UI = gui.create("Aftermath", false)
UI:set_pos(100, 100)
UI:set_size(400, 300)

_G.Weapons = false
_G.Zombies = true

local Script = {
    Cache = {
        Weapons = {},
        Processed = {},
        References = {
            LastCount = 0,
            Interval = 100,
            FrameCount = 0
        }
    }
}

local RenderZombies = UI:add_checkbox("Render Zombies", _G.Zombies)
local RenderWeapons = UI:add_checkbox("Render Weapons", _G.Weapons)

local Weapons = {
    {Name = 'Glock', Path = {'Handle2', 'Slide'}},
    {Name = 'M1911', Path = {'Bullet', 'SKIN01'}},
    {Name = 'Makarov', Path = {'Static', 'Mag'}},
    {Name = 'Desert Eagle', Path = {'Static', 'Meshes/DesertEagle_Body', 'SKIN01'}},
    {Name = 'Gold Desert Eagle', Path = {'Slide', 'SurfaceAppearance'}},
    {Name = 'FNX-45', Path = {'Static', 'Barrel'}},
    {Name = 'S&W .44 Magnum', Path = {'Loader'}},
    {Name = 'P226', Path = {'Static', 'Meshes/SigSaur_Button1'}},
    {Name = 'M9', Path = {'Mag', 'SKIN02'}},
    {Name = 'MK4', Path = {'Handle', 'Safety'}},
    {Name = 'TEC9', Path = {'MovingParts', '9mm', 'Part6'}},
    
    {Name = 'Uzi', Path = {'Static', 'Meshes/uzi_better_as_fbx_uzi.001'}},
    {Name = 'MP5', Path = {'ChargingHandle', 'MP51'}},
    {Name = 'P90', Path = {'SlideDraw'}},
    {Name = 'UMP45', Path = {'Gun'}},
    {Name = 'Makeshift SMG', Path = {'Gas'}},
    
    {Name = 'AR-15', Path = {'Bullets', 'Weld'}},
    {Name = 'M4A1', Path = {'Mag', 'MagVisible', 'Weld'}},
    {Name = 'AKM', Path = {'Mount'}},
    {Name = 'AK-47', Path = {'Misc', 'Meshes/AK_Grip'}},
    {Name = 'FN-FAL', Path = {'Misc', 'Fal'}},
    {Name = 'SCAR-H', Path = {'Static', 'Scar'}},
    {Name = 'MK-18', Path = {'Body3'}},
    {Name = 'MK-14 EBR', Path = {'Body5'}},
    {Name = 'MK-47 Mutant', Path = {'MK473'}},
    {Name = 'Famas', Path = {'Meshes/Famas_FamasRBX.001'}},
    {Name = 'G36k', Path = {'hkey_lp001'}},
    
    {Name = 'SKS', Path = {'Static', 'Wood'}},
    {Name = 'M110k', Path = {'Static', 'Sights'}},
    {Name = 'MRAD', Path = {'Misc', 'Meshes/Rifle_sbg_precision_rifle_01_buttstock.001'}},
    {Name = 'AWM', Path = {'Stand'}},
    {Name = 'M82A1', Path = {'pad_low'}},
    {Name = 'SVD', Path = {'MagBullet'}},
    {Name = 'Mosin Nagant', Path = {'BoltBody'}},
    {Name = 'M40A1', Path = {'Supressor'}},
    {Name = 'Remington 700', Path = {'BoltVisible'}},
    {Name = 'Makeshift Sniper', Path = {'Fabric'}},
    
    {Name = 'Renelli M4', Path = {'Shotgun'}},
    {Name = 'MP-133', Path = {'Primary Frame', 'Base'}},
    {Name = 'Sawed Off', Path = {'Meshes/DoubleBarrelSawedOff_stock_low'}},
    {Name = 'Remington 1894', Path = {'Barrels'}},
    {Name = 'Mossberg 500', Path = {'Static', 'Meshes/SM_Mossberg590A1_LP (1)'}},
    {Name = 'SPAS-12', Path = {'AttachmentReticle', 'RED DOT'}},
    {Name = 'Saiga-12', Path = {'Static', 'SaigaSP'}},
    
    {Name = 'M249', Path = {'Mag', 'MagHandle'}},
    {Name = 'PKM', Path = {'Static', 'Grip'}},
    
    {Name = 'Makeshift Bow', Path = {'Bow', 'bow_mid'}},
    {Name = 'Recurve Bow', Path = {'Bow', 'Bow'}},
    {Name = 'T13 Crossbow', Path = {'CrossbowExport'}},
    {Name = '10/22 Takedown', Path = {'GunParts'}},
    {Name = 'Wrench', Path = {'Wrench'}}
}

local ZombieMeshes = {
    ['rbxassetid://17661257035'] = 'Chinese Zombie',
    ['rbxassetid://11613771301'] = 'Tactical Zombie',
}

local function ResolvePath(Base, Segments)
    local Current = Base
    for _, Segment in ipairs(Segments) do
        if not Current or not Current:isvalid() then return nil end
        for Token in string.gmatch(Segment, "[^/]+") do
            Current = Current:find_first_child(Token)
            if not Current or not Current:isvalid() then return nil end
        end
    end
    return Current
end

local function IdentifyWeapon(Instance)
    local Key = tostring(Instance)
    local Cache = Script.Cache.Processed

    if Cache[Key] ~= nil then return Cache[Key] end

    for _, Entry in ipairs(Weapons) do
        local Match = ResolvePath(Instance, Entry.Path)
        if Match then
            local Result = { Name = Entry.Name, Object = Match }
            Cache[Key] = Result
            return Result
        end
    end

    Cache[Key] = false
    return false
end

local function RefreshItems()
    local Container = game:get_service("Workspace"):find_first_child("world_assets"):find_first_child("StaticObjects"):find_first_child("Misc")

    if not Container then return end

    local Elements = Container:get_children()
    local CurrentCount = #Elements
    local LastCount = Script.Cache.References.LastCount
    local Cache = Script.Cache

    if CurrentCount == LastCount then return end

    local Start = 1
    if CurrentCount < LastCount then
        Cache.Weapons, Cache.Processed = {}, {}
    else
        Start = LastCount + 1
    end

    for i = Start, CurrentCount do
        local Model = Elements[i]

        if Model and Model:isvalid() and Model:isa("Model") then
            if IdentifyWeapon(Model) then table.insert(Cache.Weapons, IdentifyWeapon(Model)) end
        end
    end

    Cache.References.LastCount = CurrentCount
end

local function Cache()
    local List = Script.Cache.Weapons
    for i = #List, 1, -1 do
        local Ref = List[i].Object
        if not Ref or not Ref:isvalid() then
            table.remove(List, i)
        end
    end
end

hook.add("render", "aftermath", function()
    if not _G.Weapons then return end

    local References = Script.Cache.References
    References.FrameCount = References.FrameCount + 1

    RefreshItems()

    if References.FrameCount % References.Interval == 0 then
        Cache()
    end

    for _, Entry in ipairs(Script.Cache.Weapons) do
        local Obj = Entry.Object
        if Obj and Obj:isvalid() and (Obj:isa("Part") or Obj:isa("MeshPart")) then
            local Pos = world_to_screen(Obj.position)
            if Pos then
                render.add_text(Pos, Entry.Name, color(1, 1, 1, 1))
            end
        end
    end
end)

hook.add("init_custom_entity", "entity_render", function()
    if not _G.Zombies then return end 

    local ZombiesPath = game:get_service("Workspace"):find_first_child("game_assets"):find_first_child("NPCs")
    if not ZombiesPath or not ZombiesPath:isvalid() then return end
    
    for _, Zombie in ipairs(ZombiesPath:get_children()) do
        if Zombie:isa("Model") then
            local HumanoidRootPart = Zombie:find_first_child("HumanoidRootPart")
            if HumanoidRootPart then
                local ZombieName = "Zombie"
                
                for _, Child in ipairs(Zombie:get_children()) do
                    if Child:isa("MeshPart") then
                        if ZombieMeshes[Child:get_meshid()] then
                            ZombieName = ZombieMeshes[Child:get_meshid()]
                            break
                        end
                    end
                end
                
                add_entity_ex(ZombieName, Zombie, nil_instance, HumanoidRootPart, true,  vector3(2, 3, 1.5), vector3(2, 2, 1), {{"Head", Zombie:find_first_child("Head")}, {"Torso", Zombie:find_first_child("Torso")}, {"Left Arm", Zombie:find_first_child("Left Arm")}, {"Right Arm", Zombie:find_first_child("Right Arm")}, {"Left Leg", Zombie:find_first_child("Left Leg")}, {"Right Leg", Zombie:find_first_child("Right Leg")}})
            end
        end
    end
end)

RenderZombies:change_callback(function()
    _G.Zombies = RenderZombies:get_value()
end)

RenderWeapons:change_callback(function()
    _G.Weapons = RenderWeapons:get_value()
end)
