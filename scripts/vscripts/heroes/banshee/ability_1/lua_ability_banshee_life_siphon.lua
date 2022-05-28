LinkLuaModifier( "lua_modifier_banshee_life_siphon", "heroes/banshee/ability_1/lua_modifier_banshee_life_siphon", LUA_MODIFIER_MOTION_NONE )



lua_ability_banshee_life_siphon = class({})



function lua_ability_banshee_life_siphon:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_banshee_life_siphon:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_banshee_life_siphon:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_banshee_life_siphon:OnSpellStart()

    local mod_ride = self:GetCaster():FindModifierByName("lua_modifier_banshee_possess_ride")

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end


    if not mod_ride then --not riding

        self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_banshee_life_siphon",
            {
                target = self:GetCursorTarget():GetEntityIndex(),
                duration = self:GetSpecialValueFor("leech_duration")
            }
        )

    else

        --give the siphon to the ride
        mod_ride.target:AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_banshee_life_siphon",
            {
                target = self:GetCursorTarget():GetEntityIndex(),
                duration = self:GetSpecialValueFor("leech_duration")
            }
        )

    end

end
