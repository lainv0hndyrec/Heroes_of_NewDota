LinkLuaModifier( "lua_modifier_spiritsmaster_earth_spirit_transform", "heroes/spiritsmaster/ability_1/lua_modifier_spiritsmaster_earth_spirit", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_spiritsmaster_earth_spirit_slow", "heroes/spiritsmaster/ability_1/lua_modifier_spiritsmaster_earth_spirit", LUA_MODIFIER_MOTION_NONE )


lua_ability_spiritsmaster_earth_spirit = class({})



function lua_ability_spiritsmaster_earth_spirit:GetAOERadius()
    local aoe_range = self:GetLevelSpecialValueFor("cast_range",0)
    return aoe_range
end



function lua_ability_spiritsmaster_earth_spirit:GetCastRange(pos,target)
    return self:GetAOERadius()
end


function lua_ability_spiritsmaster_earth_spirit:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_spiritsmaster_earth_spirit:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end









function lua_ability_spiritsmaster_earth_spirit:OnSpellStart()

    self:GetCaster():EmitSound("Hero_Brewmaster.ThunderClap")

    self:GetCaster():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_earth_spirit_transform",
        {duration = self:GetSpecialValueFor("hero_effect_time")}
    )

    local clap = ParticleManager:CreateParticle(
        "particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )

    local aoe_range = self:GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster())
    ParticleManager:SetParticleControl(clap,0,self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(clap,1,Vector(aoe_range,0,0))

    local slow_time = self:GetSpecialValueFor("slow_time")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_spiritsmaster_earth_spirit_slow_time_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            slow_time = slow_time+talent:GetSpecialValueFor("value")
        end
    end


    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),
        nil,aoe_range,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,false
    )


    for i=1, #enemies do
        enemies[i]:AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_spiritsmaster_earth_spirit_slow",
            {duration = slow_time}
        )

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = self:GetSpecialValueFor("ability_damage"),
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }

        ApplyDamage(dtable)
    end


end
