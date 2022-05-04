LinkLuaModifier( "lua_modifier_atniw_druid_dream_flies_debuff", "heroes/atniw_druid/ability_2/lua_modifier_atniw_druid_dream_flies", LUA_MODIFIER_MOTION_NONE )



lua_ability_atniw_druid_dream_flies = class({})


function lua_ability_atniw_druid_dream_flies:GetAOERadius()
    local aoe_redius = self:GetLevelSpecialValueFor("aoe_redius",0)
    return aoe_redius
end


function lua_ability_atniw_druid_dream_flies:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_atniw_druid_dream_flies:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_atniw_druid_dream_flies:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_atniw_druid_dream_flies:OnSpellStart()

    self:GetCaster():EmitSound("Hero_LoneDruid.SpiritLink.Cast")

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCursorPosition(),
        nil,self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,false
    )

    for i=1, #enemies do

        if enemies[i]:IsInvisible() == false then

            local proj ={
                vSourceLoc = self:GetCaster():GetAbsOrigin(),
                Target = enemies[i],
                iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
                bDodgeable = true,
                bIsAttack = false,
                bReplaceExisting = false,
                bIgnoreObstructions = true,
                EffectName = "particles/units/heroes/atniw_druid/ability_2/antiw_druid_dream_fliesshot.vpcf",
                Ability = self,
                Source = self:GetCaster(),
                bProvidesVision = true,
                iVisionRadius = 100,
                iVisionTeamNumber = self:GetCaster():GetTeam()
            }

            ProjectileManager:CreateTrackingProjectile(proj)

        end
    end

end


function lua_ability_atniw_druid_dream_flies:OnProjectileHit(target,pos)

    if not target then return true end

    if target:IsAlive() == false then return true end

    if target:IsMagicImmune() then return true end

    if target:TriggerSpellAbsorb(self) then return end

    target:EmitSound("LoneDruid_SpiritBear.ReturnStart")

    local view_radius = self:GetSpecialValueFor("impact_vision")
    local view_duration = self:GetSpecialValueFor("vision_duration")
    AddFOWViewer(
        self:GetCaster():GetTeam(),target:GetAbsOrigin(),
        view_radius,view_duration,false
    )


    if target:IsMoving() then
        target:EmitSound("LoneDruid_SpiritBear.Return")
        target:AddNewModifier(
            self:GetCaster(),self ,"modifier_stunned",
            {duration = self:GetSpecialValueFor("move_stun_duration")}
        )
    end

    local ms_slow_duration = self:GetSpecialValueFor("ms_slow_duration")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_atniw_druid_dream_flies_slow_time_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            ms_slow_duration = ms_slow_duration+talent:GetSpecialValueFor("value")
        end
    end

    target:AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_atniw_druid_dream_flies_debuff",
        {duration = ms_slow_duration}
    )

    local dtable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = self:GetSpecialValueFor("ability_damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self
    }
    ApplyDamage(dtable)

    return true
end
