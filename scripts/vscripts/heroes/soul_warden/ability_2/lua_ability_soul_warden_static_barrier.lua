LinkLuaModifier( "lua_modifier_soul_warden_static_barrier", "heroes/soul_warden/ability_2/lua_modifier_soul_warden_static_barrier", LUA_MODIFIER_MOTION_NONE )


lua_ability_soul_warden_static_barrier = class({})





function lua_ability_soul_warden_static_barrier:GetAOERadius()
    local spark_aoe = self:GetLevelSpecialValueFor("spark_aoe",0)
    return spark_aoe
end







function lua_ability_soul_warden_static_barrier:GetCastRange(pos,target)
    return self:GetAOERadius()
end







function lua_ability_soul_warden_static_barrier:GetManaCost(lvl)
    local mana_cost = self:GetSpecialValueFor("min_mana")

    if not mana_cost then return end

    local current_mana = self:GetCaster():GetMana()
    local mana_percent = self:GetSpecialValueFor("mana_cost_percent")*0.01
    local new_mana_cost = current_mana*mana_percent
    mana_cost = math.max(new_mana_cost,mana_cost)

    return mana_cost
end



function lua_ability_soul_warden_static_barrier:CastFilterResult()

    local mana_barrier_percent = self:GetSpecialValueFor("mana_barrier_percent")*0.01
    self.barrier_value = self:GetManaCost(1)*mana_barrier_percent

    return UF_SUCCESS
end







function lua_ability_soul_warden_static_barrier:OnSpellStart()
    --self:GetCaster():EmitSound("Ability.static.start")

    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_soul_warden_static_barrier",
        {duration = self:GetSpecialValueFor("barrier_duration")}
    )


end
