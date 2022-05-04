LinkLuaModifier( "lua_modifier_atniw_druid_atniws_calling", "heroes/atniw_druid/ability_4/lua_modifier_atniw_druid_atniws_calling", LUA_MODIFIER_MOTION_NONE )



lua_ability_atniw_druid_atniws_calling = class({})


function lua_ability_atniw_druid_atniws_calling:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_TOGGLE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end


function lua_ability_atniw_druid_atniws_calling:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    if self:GetCaster():HasScepter() then
        ability_cd = self:GetLevelSpecialValueFor("scepter_cd",0)
    end
    return ability_cd
end


function lua_ability_atniw_druid_atniws_calling:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_atniw_druid_atniws_calling:OnSpellStart()

    if self:GetCaster():HasScepter() then return end

    self:GetCaster():EmitSound("Hero_LoneDruid.BattleCry.Bear")

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self ,"lua_modifier_atniw_druid_atniws_calling",
        {duration = self:GetSpecialValueFor("transform_duration")}
    )

end



function lua_ability_atniw_druid_atniws_calling:OnToggle()
    if self:GetToggleState() then
        self:GetCaster():EmitSound("Hero_LoneDruid.BattleCry.Bear")

        self:GetCaster():AddNewModifier(
            self:GetCaster(),self ,"lua_modifier_atniw_druid_atniws_calling",
            {}
        )
    else
        local mod = self:GetCaster():FindModifierByName("lua_modifier_atniw_druid_atniws_calling")
        if not mod then return end
        mod:Destroy()
        self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))
    end
end
