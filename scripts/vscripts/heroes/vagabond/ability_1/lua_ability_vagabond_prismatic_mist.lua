
LinkLuaModifier( "lua_modifier_vagabond_prismatic_mist_invi_aura", "heroes/vagabond/ability_1/lua_modifier_vagabond_prismatic_mist", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_prismatic_mist_slow_aura", "heroes/vagabond/ability_1/lua_modifier_vagabond_prismatic_mist", LUA_MODIFIER_MOTION_NONE )


lua_ability_vagabond_prismatic_mist = class({})

function lua_ability_vagabond_prismatic_mist:Init()
    if IsServer() == false then return end

    if not self:GetCaster() then return end

    print(self:GetCaster())
end






function lua_ability_vagabond_prismatic_mist:OnSpellStart()


    self.caster = self:GetCaster()

    local talent_duration = 0
    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_prismatic_mist_duration")
    if not talent == false then
        if talent:GetLevel() > 0 then
            talent_duration = talent:GetSpecialValueFor("value")
        end
    end

    local scepter_duration = 0
    if self:GetCaster():HasScepter() then
        scepter_duration = 2
    end

    self.invi_modifier = self.caster:AddNewModifier(
        self.caster,
        self,
        "lua_modifier_vagabond_prismatic_mist_invi_aura",
        {duration = self:GetSpecialValueFor("duration")+talent_duration+scepter_duration}
    )

    self.slow_modifier = self.caster:AddNewModifier(
        self.caster,
        self,
        "lua_modifier_vagabond_prismatic_mist_slow_aura",
        {duration = self:GetSpecialValueFor("duration")+talent_duration+scepter_duration}
    )

    if not IsServer() then return end
    self.caster:EmitSound("Hero_PhantomLancer.Doppelwalk")
end
