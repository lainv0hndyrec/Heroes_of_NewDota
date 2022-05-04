
lua_ability_boogeyman_fear = class({})



function lua_ability_boogeyman_fear:GetAOERadius()
    local aoe_range = self:GetLevelSpecialValueFor("cast_range",0)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_boogeyman_fear_range_up")

    if not talent == false then
        if talent:GetLevel() > 0 then
            aoe_range = aoe_range + talent:GetSpecialValueFor("value")
        end
    end

    return aoe_range
end



function lua_ability_boogeyman_fear:GetCastRange(pos,target)
    return self:GetAOERadius()
end


function lua_ability_boogeyman_fear:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_boogeyman_fear:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end









function lua_ability_boogeyman_fear:OnSpellStart()

    self:GetCaster():EmitSound("Hero_Nightstalker.Void.Nihility")

    local aoe_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )
    ParticleManager:SetParticleControl(aoe_particle,0,self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(aoe_particle,1,self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(aoe_particle,1,Vector(self:GetAOERadius(),0,0))
    ParticleManager:DestroyParticle(aoe_particle,false)
    ParticleManager:ReleaseParticleIndex(aoe_particle)

    local dmg = self:GetSpecialValueFor("ability_damage")
    local fear = self:GetSpecialValueFor("ability_fear")

    local devour_stacks = self:GetCaster():FindModifierByName("lua_modifier_boogeyman_devour_stacks")
    if not devour_stacks == false then
        dmg = dmg + (devour_stacks:GetStackCount()*self:GetSpecialValueFor("devour_damage_stack"))
        fear = fear + (devour_stacks:GetStackCount()*self:GetSpecialValueFor("devour_fear_stack"))
    end

    local talent = self:GetCaster():FindAbilityByName("special_bonus_generic_boogeyman_fear_time_up")

    -- if not talent == false then
    --     if talent:GetLevel() > 0 then
    --         fear = fear + talent:GetSpecialValueFor("value")
    --     end
    -- end


    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),
        self:GetCaster():GetAbsOrigin(),
        nil,
        self:GetAOERadius(),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    for i=1, #enemies do
        enemies[i]:AddNewModifier(
            self:GetCaster(),self,
            "modifier_fear",
            {duration = fear}
        )

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }
        ApplyDamage(dtable)
    end

end
