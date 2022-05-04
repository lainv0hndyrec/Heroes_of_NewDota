LinkLuaModifier( "lua_modifier_atniw_druid_tangling_roots_thinker", "heroes/atniw_druid/ability_1/lua_modifier_atniw_druid_tangling_roots", LUA_MODIFIER_MOTION_NONE )



lua_ability_atniw_druid_tangling_roots = class({})


function lua_ability_atniw_druid_tangling_roots:GetAOERadius()
    local aoe_redius = self:GetLevelSpecialValueFor("aoe_redius",0)
    return aoe_redius
end


function lua_ability_atniw_druid_tangling_roots:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_atniw_druid_tangling_roots_range_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cast_range = cast_range+talent:GetSpecialValueFor("value")
        end
    end

    return cast_range
end


function lua_ability_atniw_druid_tangling_roots:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_atniw_druid_tangling_roots:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_atniw_druid_tangling_roots:OnSpellStart()
    local diff = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
    local normal = diff:Normalized()

    self:GetCaster():EmitSound("LoneDruid_SpiritBear.Entangle")

    CreateModifierThinker(
        self:GetCaster(),self,
        "lua_modifier_atniw_druid_tangling_roots_thinker",
        {
            duration = 4.0,
            norm_x = normal.x,
            norm_y = normal.y,
            norm_z = normal.z
        },
        self:GetCaster():GetAbsOrigin(),
        self:GetCaster():GetTeam(),false
    )
end
