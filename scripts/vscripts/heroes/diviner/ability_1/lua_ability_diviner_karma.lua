LinkLuaModifier( "lua_modifier_diviner_karma", "heroes/diviner/ability_1/lua_modifier_diviner_karma", LUA_MODIFIER_MOTION_NONE )



lua_ability_diviner_karma = class({})


function lua_ability_diviner_karma:GetAOERadius()
    local radius = self:GetLevelSpecialValueFor("ability_radius",0)
    return radius
end


function lua_ability_diviner_karma:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_diviner_karma:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)

    local talent = self:GetCaster():FindAbilityByName("special_bonus_diviner_karma_cd_down")
    if not talent == false then
        if talent:GetLevel() > 0 then
            ability_cd = ability_cd - talent:GetSpecialValueFor("value")
        end
    end

    return ability_cd
end


function lua_ability_diviner_karma:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_diviner_karma:OnSpellStart()
    if not IsServer() then return end

    self:GetCaster():EmitSound("Hero_Oracle.FortunesEnd.Attack")

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    local ptable = {
        vSourceLoc = self:GetCaster():GetAbsOrigin(),
        Target = self:GetCursorTarget(),
        iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
        flExpireTime = GameRules:GetGameTime() + 10.0,
        bDodgeable = true,
        bIsAttack = false,
        bReplaceExisting = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true,
        EffectName = "particles/units/heroes/hero_oracle/oracle_fortune_prj.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        bProvidesVision = false
    }

    ProjectileManager:CreateTrackingProjectile(ptable)
end


function lua_ability_diviner_karma:OnProjectileHit(target,pos)
    if not IsServer() then return end

    local slow_duration = self:GetSpecialValueFor("slow_duration")
    local min_damage = self:GetSpecialValueFor("min_damage")
    local max_damage = self:GetSpecialValueFor("max_damage")

    local talent = self:GetCaster():FindAbilityByName("special_bonus_diviner_karma_max_dmg_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            max_damage = max_damage + talent:GetSpecialValueFor("value")
        end
    end

    local int_minus_hp_loss_percent = self:GetSpecialValueFor("int_minus_hp_loss_percent")
    local current_int = self:GetCaster():GetIntellect()
    local add_percent = int_minus_hp_loss_percent*current_int
    local percent_diff_hp = 100 - self:GetCaster():GetHealthPercent()
    local total_diff_hp = (add_percent+percent_diff_hp)*0.01
    local add_damage = (max_damage-min_damage)*total_diff_hp

    local total_damage = math.min(min_damage+add_damage,max_damage)

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),pos,
        nil,self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )

    for i=1, #enemies do

        enemies[i]:AddNewModifier(
            self:GetCaster(),self ,
            "lua_modifier_diviner_karma",
            {duration = slow_duration}
        )

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = total_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }
        ApplyDamage(dtable)

    end

    self:GetCaster():EmitSound("Hero_Oracle.FortunesEnd.Target")

    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_oracle/oracle_fortune_aoe.vpcf",
        PATTACH_ABSORIGIN,self:GetCaster()
    )
    ParticleManager:SetParticleControl(particle,0,pos)
    ParticleManager:SetParticleControl(particle,2,Vector(self:GetAOERadius(),0,0))
    ParticleManager:ReleaseParticleIndex(particle)

    return true
end
