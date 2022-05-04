LinkLuaModifier( "lua_modifier_atniw_druid_bear_rush", "heroes/atniw_druid/ability_3/lua_modifier_atniw_druid_bear_rush", LUA_MODIFIER_MOTION_NONE )



lua_ability_atniw_druid_bear_rush = class({})





function lua_ability_atniw_druid_bear_rush:CastFilterResultLocation(pos)
    if not IsServer() then return end

    local mypos = self:GetCaster():GetAbsOrigin()
    if GridNav:CanFindPath(mypos,pos) == false then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end


function lua_ability_atniw_druid_bear_rush:GetCustomCastErrorLocation(pos)
    return "No Path"
end


function lua_ability_atniw_druid_bear_rush:GetAOERadius()
    local cast_range = self:GetLevelSpecialValueFor("aoe_redius",0)
    return cast_range
end


function lua_ability_atniw_druid_bear_rush:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_atniw_druid_bear_rush_range_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cast_range = cast_range+talent:GetSpecialValueFor("value")
        end
    end

    return cast_range
end


function lua_ability_atniw_druid_bear_rush:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_atniw_druid_bear_rush:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_atniw_druid_bear_rush:OnSpellStart()

    self:GetCaster():EmitSound("Hero_LoneDruid.SpiritBear.Cast")

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_atniw_druid_bear_rush",
        {
            pos_x = self:GetCursorPosition().x,
            pos_y = self:GetCursorPosition().y,
            pos_z = self:GetCursorPosition().z
        }
    )


end
