LinkLuaModifier( "lua_modifier_rogue_golem_run_forest_base", "heroes/rogue_golem/ability_3/lua_modifier_rogue_golem_run_forest", LUA_MODIFIER_MOTION_NONE )


lua_ability_rogue_golem_run_forest = class({})


function lua_ability_rogue_golem_run_forest:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_rogue_golem_run_forest:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_rogue_golem_run_forest:OnSpellStart()
    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_rogue_golem_run_forest_base",
        {duration = self:GetSpecialValueFor("effect_duration")}
    )
end
