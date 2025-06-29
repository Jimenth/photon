local GameID = tonumber(get_gameid())

_G.EnableWeapon = true
_G.WeaponColor = color(1, 1, 1, 1)

local UI = gui.create("Better Weapon ESP", false)
UI:set_pos(100, 100)
UI:set_size(400, 300)

local EnableWeapon = UI:add_checkbox("enable_weapon", "Enabled", _G.EnableWeapon)
local WeaponColor = UI:add_color("weapon_color", "Color", _G.WeaponColor)

EnableWeapon:change_callback(function()
    _G.EnableWeapon = EnableWeapon:get_value()
end)

WeaponColor:change_callback(function()
    local c = WeaponColor:get_color()
    _G.WeaponColor = color(c.r, c.g, c.b, c.a)
end)

local Games = {
    [1865489894] = { -- Base Battles
        Weapon = function(Character)
            for _, Child in ipairs(Character:get_children()) do
                if Child.class_name == "Model" and Child.name ~= "GunModel" and Child:find_first_child("Muzzle") then
                    return Child.name or ""
                end
            end

            return ""
        end
    },

    [5611522097] = { -- Airsoft Battles
        Weapon = function(Character)
            for _, Child in ipairs(Character:get_children()) do
                if Child.class_name == "Model" and Child:find_first_child("Handle") then
                    return Child.name or ""
                end
            end

            return ""
        end
    },

    [2257943402] = { -- Energy Assault FPS
        Weapon = function(Character)
            local Replicated = Character:find_first_child("animinfo")
            local Value = Replicated:find_first_child("weapon")
            if Value then
                return Value:get_value_string() or ""
            end

            return ""
        end,
    },

    [4914269443] = { -- Unnamed Shooter
        Weapon = function(Character)
            local Value = Character:find_first_child("Equipped")
            if Value then
                return Value:get_value_object().name or ""
            end

            return ""
        end
    },

    [2382284116] = { -- No Scope Arcade
        Weapon = function(Character)
            for _, Child in ipairs(Character:get_children()) do
                if Child.class_name == "Model" and Child:find_first_child("Handle") then
                    return Child.name or ""
                end
            end

            return ""
        end
    },

    [6676525126] = { -- Planks
        Weapon = function(Character)
            for _, Child in ipairs(Character:get_children()) do
                if Child.class_name == "Model" and Child:find_first_child("FirePart") then
                    return Child.name or ""
                end
            end

            return ""
        end
    },

    [2862098693] = { -- Project Delta
        Weapon = function(Character)
            local Items = {}

            for _, Child in ipairs(Character:get_children()) do
                if Child.class_name == "Model" and Child:find_first_child("ItemRoot") then
                    table.insert(Items, Child.name)
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

local function HandleGame(GameId)
    local Game = Games[GameId] or {}

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

    local Game = HandleGame(GameID)
    local WeaponName = Game.Weapon(Player.character)

    if WeaponName then
        render.add_extra(WeaponName, ESP_BOTTOM, _G.WeaponColor)
    end
end)
