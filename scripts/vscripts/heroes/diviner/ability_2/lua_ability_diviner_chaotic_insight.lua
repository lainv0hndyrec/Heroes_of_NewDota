LinkLuaModifier( "lua_modifier_diviner_chaotic_insight", "heroes/diviner/ability_2/lua_modifier_diviner_chaotic_insight", LUA_MODIFIER_MOTION_NONE )



lua_ability_diviner_chaotic_insight = class({})




function lua_ability_diviner_chaotic_insight:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_diviner_chaotic_insight:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_diviner_chaotic_insight_cd_down")
    if not talent == false then
        if talent:GetLevel() > 0 then
            ability_cd = ability_cd - talent:GetSpecialValueFor("value")
        end
    end

    return ability_cd
end


function lua_ability_diviner_chaotic_insight:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_diviner_chaotic_insight:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():EmitSound("Hero_Oracle.FatesEdict.Cast")

    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_diviner_chaotic_insight",
        {duration = self:GetSpecialValueFor("effect_duration")}
    )


end
