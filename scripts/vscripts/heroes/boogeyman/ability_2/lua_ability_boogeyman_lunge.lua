LinkLuaModifier( "lua_modifier_boogeyman_lunge_dash", "heroes/boogeyman/ability_2/lua_modifier_boogeyman_lunge", LUA_MODIFIER_MOTION_HORIZONTAL )


lua_ability_boogeyman_lunge = class({})


function lua_ability_boogeyman_lunge:GetAOERadius()
    local range = self:GetLevelSpecialValueFor("aoe_range",0)
    return range
end


function lua_ability_boogeyman_lunge:GetCastRange(pos,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_boogeyman_lunge_range_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cast_range = cast_range + talent:GetSpecialValueFor("value")
        end
    end

    return cast_range
end


function lua_ability_boogeyman_lunge:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_boogeyman_lunge:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end



function lua_ability_boogeyman_lunge:OnSpellStart()

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    self:GetCaster():EmitSound("Hero_Nightstalker.Void")

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_boogeyman_lunge_dash",
        {
            duration = self:GetSpecialValueFor("flight_time"),
            target = self:GetCursorTarget():GetEntityIndex()
        }
    )
end
