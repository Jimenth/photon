local GameID = tonumber(get_gameid())

_G.EnableWeapon = true
_G.WeaponColor = color(1, 1, 1, 1)

local UI = gui.create("Better Weapon ESP", false)
UI:set_pos(100, 100)
UI:set_size(400, 300)

local EnableWeapon = UI:add_checkbox("Enabled", _G.EnableWeapon)
local WeaponColor = UI:add_color("Color", _G.WeaponColor)

EnableWeapon:change_callback(function()
    _G.EnableWeapon = EnableWeapon:get_value()
end)

WeaponColor:change_callback(function()
    local c = WeaponColor:get_color()
    _G.WeaponColor = color(c.r, c.g, c.b, c.a)
end)

local Games = {
    [358276974] = { -- AR2
        Weapon = function(Character)
            if Character and Character:isvalid() then
                local Equipped = Character:find_first_child("Equipped")
                if Equipped and Equipped:isvalid() then
                    local Children = Equipped:get_children()
                    if Children and #Children > 0 and Children[1] and Children[1]:isvalid() then
                        return Children[1].name or ""
                    end
                end
            end
            return ""
        end
    },

    [3747388906] = { -- Fallen Survival
        Weapon = function(Character)
            if Character and Character:isvalid() then
                for _, Child in ipairs(Character:get_children()) do
                    if Child:isvalid() and Child.class_name == "Model"
                        and Child:find_first_child("Handle")
                        and Child.name:sub(1, 5) ~= "Armor"
                        and Child.name ~= "Hair"
                        and Child.name ~= "HolsterModel"
                    then
                        return Child.name or ""
                    end
                end
            end
            return ""
        end
    },

    [1865489894] = { -- Base Battles
        Weapon = function(Character)
            if Character and Character:isvalid() then
                for _, Child in ipairs(Character:get_children()) do
                    if Child:isvalid() and Child.class_name == "Model"
                        and Child.name ~= "GunModel"
                        and Child:find_first_child("Muzzle")
                    then
                        return Child.name or ""
                    end
                end
            end
            return ""
        end
    },

    [5611522097] = { -- Airsoft Battles
        Weapon = function(Character)
            if Character and Character:isvalid() then
                for _, Child in ipairs(Character:get_children()) do
                    if Child:isvalid() and Child.class_name == "Model" and Child:find_first_child("Handle") then
                        return Child.name or ""
                    end
                end
            end
            return ""
        end
    },

    [2257943402] = { -- Energy Assault FPS
        Weapon = function(Character)
            if Character and Character:isvalid() then
                local Replicated = Character:find_first_child("animinfo")
                if Replicated and Replicated:isvalid() then
                    local Value = Replicated:find_first_child("weapon")
                    if Value and Value:isvalid() then
                        return Value:get_value_string() or ""
                    end
                end
            end
            return ""
        end
    },

    [4914269443] = { -- Unnamed Shooter
        Weapon = function(Character)
            if Character and Character:isvalid() then
                local Value = Character:find_first_child("Equipped")
                if Value and Value:isvalid() then
                    local Object = Value:get_value_object()
                    if Object and Object:isvalid() then
                        return Object.name or ""
                    end
                end
            end
            return ""
        end
    },

    [2382284116] = { -- No Scope Arcade
        Weapon = function(Character)
            if Character and Character:isvalid() then
                for _, Child in ipairs(Character:get_children()) do
                    if Child:isvalid() and Child.class_name == "Model" and Child:find_first_child("Handle") then
                        return Child.name or ""
                    end
                end
            end
            return ""
        end
    },

    [6676525126] = { -- Planks
        Weapon = function(Character)
            if Character and Character:isvalid() then
                for _, Child in ipairs(Character:get_children()) do
                    if Child:isvalid() and Child.class_name == "Model" and Child:find_first_child("FirePart") then
                        return Child.name or ""
                    end
                end
            end
            return ""
        end
    },

    [2862098693] = { -- Project Delta
        Weapon = function(Character)
            local Items = {}
            if Character and Character:isvalid() then
                for _, Child in ipairs(Character:get_children()) do
                    if Child:isvalid() and Child.class_name == "Model" and Child:find_first_child("ItemRoot") then
                        table.insert(Items, Child.name)
                    end
                end
            end
            if #Items > 0 then
                return table.concat(Items, ", ")
            else
                return ""
            end
        end
    }
}

local function HandleGame()
    local Game = Games[GameID] or {}

    return {
        Weapon = Game.Weapon or function(Character)
            for _, Tool in ipairs(Character:get_children()) do
                if Tool.class_name == "Tool" then
                    return Tool.name or ""
                end
            end
            return ""
        end
    }
end

hook.add("esp_drawextra", "weapon_esp", function(Player)
    if not _G.EnableWeapon then return end

    local character = Player.character
    if not character or not character:isvalid() then return end

    local Game = HandleGame()
    local Name = Game.Weapon(character)

    if Name and Name ~= "" then
        render.add_extra(Name, ESP_BOTTOM, _G.WeaponColor)
    end
end)
