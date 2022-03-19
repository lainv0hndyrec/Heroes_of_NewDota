LinkLuaModifier( "lua_modifier_vagabond_death_light", "heroes/vagabond/ability_4/lua_modifier_vagabond_death_light", LUA_MODIFIER_MOTION_NONE )


lua_ability_vagabond_death_light = class({})



function lua_ability_vagabond_death_light:OnSpellStart()
    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_vagabond_death_light",
        {duration = self:GetSpecialValueFor("counter_time")}
    )

    self:GetCaster():EmitSoundParams("Hero_PhantomLancer.Death",1,10,0)
end




function lua_ability_vagabond_death_light:create_projectile_when_you_are_hit(target_position)
    local direction = (target_position - self:GetCaster():GetAbsOrigin()):Normalized()

    local ptable = {
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        vVelocity = self:GetSpecialValueFor("projectile_speed")*direction,
        fDistance = self:GetSpecialValueFor("projectile_distance"),
        fStartRadius = self:GetSpecialValueFor("projectile_radius"),
        fEndRadius = self:GetSpecialValueFor("projectile_radius"),
        fExpireTime = GameRules:GetGameTime() + 10.0,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlag = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        EffectName = "particles/units/heroes/vagabond/ability_4/death_light_wave.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        bProvidesVision = true,
        iVisionRadius = self:GetSpecialValueFor("projectile_radius"),
        iVisionTeamNumber = self:GetCaster():GetTeamNumber()
    }

    ProjectileManager:CreateLinearProjectile(ptable)
end




function lua_ability_vagabond_death_light:OnProjectileHit(target,location)

    if not target then return true end

    target:AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_stunned",
        {duration = self:GetSpecialValueFor("stun_duration")}
    )



    local add_damage = 0
    local talent = self:GetCaster():FindAbilityByName("special_bonus_vagabond_phantom_death_light_damage")
    if not talent == false then
        if talent:GetLevel() > 0 then
            add_damage = talent:GetSpecialValueFor("value")
        end
    end


    local dtable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = self:GetSpecialValueFor("magic_damage")+add_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self
    }

    ApplyDamage(dtable)
    target:EmitSound("Hero_PhantomLancer.SpiritLance.Impact")

    return false
end
