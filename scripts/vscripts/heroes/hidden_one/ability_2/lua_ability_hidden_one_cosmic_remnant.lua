--LinkLuaModifier( "lua_modifier_rogue_golem_rock_locker_thinker", "heroes/rogue_golem/ability_1/lua_modifier_rogue_golem_rock_locker", LUA_MODIFIER_MOTION_NONE )

lua_ability_hidden_one_cosmic_remnant = class({})


function lua_ability_hidden_one_cosmic_remnant:GetAOERadius()
    local cast_aoe = self:GetLevelSpecialValueFor("cast_aoe",0)
    return cast_aoe
end


function lua_ability_hidden_one_cosmic_remnant:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_hidden_one_cosmic_remnant:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",0)

    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")
    if not ult == false then
        if ult:GetLevel() > 0 then
            local cdr_abilities = ult:DecreaseCoolDown(ult:GetLevel())
            ability_cd = ability_cd - cdr_abilities
        end
    end

    return ability_cd
end


function lua_ability_hidden_one_cosmic_remnant:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_hidden_one_cosmic_remnant:OnSpellStart()

    self:GetCaster():EmitSound("Hero_VoidSpirit.AstralStep.Target")

    if not self.projectile_table then
        self.projectile_table = {}
    end


    local diff = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
    local length = diff:Length2D()
    local normal = diff:Normalized()
    local velo = (normal*self:GetSpecialValueFor("projectile_speed"))

    local ignore_self = true
    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard == true then
        ignore_self = false
    end

    local ptable = {
        vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
        vVelocity = velo,
        fDistance = length,
        fStartRadius = self:GetAOERadius(),
        fEndRadius = self:GetAOERadius(),
        flExpireTime = GameRules:GetGameTime() + 3.0,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        bIgnoreSource = ignore_self,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true,
        EffectName = "particles/units/heroes/hero_void_spirit/aether_remnant/void_spirit_aether_remnant_run.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        bProvidesVision = true,
        iVisionRadius = self:GetSpecialValueFor("projectile_vision"),
        iVisionTeamNumber = self:GetCaster():GetTeam()
    }
    local proj_id = ProjectileManager:CreateLinearProjectile(ptable)

    self.projectile_table[proj_id] = 0

end



function lua_ability_hidden_one_cosmic_remnant:OnProjectileHitHandle(target,pos,proj_id)
    if not IsServer() then return end

    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")

    -- the projectile reached the end
    if not target then

        self:GetCaster():EmitSound("Hero_VoidSpirit.AstralStep.End")

        local base_dmg = self:GetSpecialValueFor("aoe_damage")

        local dmg_per_heal = self:GetSpecialValueFor("damage_up_per_heal")
        local talent = self:GetCaster():FindAbilityByName("special_bonus_hidden_one_cosmic_remnant_healed_dmg_up")
        if not talent == false then
            if talent:GetLevel() > 0 then
                dmg_per_heal = dmg_per_heal+talent:GetSpecialValueFor("value")
            end
        end

        local total_healed = self.projectile_table[proj_id]

        local max_dmg = self:GetSpecialValueFor("maximum_damage")
        if shard == true then
            max_dmg = max_dmg+self:GetSpecialValueFor("shard_max_dmg")
        end

        local total_dmg = base_dmg + (total_healed*dmg_per_heal)
        total_dmg = math.min(total_dmg,max_dmg)

        --AOE
        local aoe_part = ParticleManager:CreateParticle(
            "particles/units/heroes/hidden_one/hidden_one_cosmic_remnant.vpcf",
            PATTACH_ABSORIGIN,self:GetCaster()
        )
        ParticleManager:SetParticleControl(aoe_part,0,pos)
        ParticleManager:SetParticleControl(aoe_part,1,Vector(self:GetAOERadius()*2,0,0))
        ParticleManager:ReleaseParticleIndex(aoe_part)

        --damage
        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeam(),pos,nil,
            self:GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
        )

        for i=1,#enemies do

            if not ult == false then
                if ult:GetLevel() > 0 then
                    ult:ApplyVoidOutModifier(enemies[i],self)
                end
            end

            local dtable = {
                victim = enemies[i],
                attacker = self:GetCaster(),
                damage = total_dmg,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                ability = self
            }

            ApplyDamage(dtable)

        end

        self.projectile_table[proj_id] = nil
        return true
    end

    -- the projectile hits a unit
    if target:IsBaseNPC() == false then return end

    -- the projectile hits a unit
    if target:GetTeam() == self:GetCaster():GetTeam() then
        --ALLY
        local heal = self:GetSpecialValueFor("ally_heal")

        local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
        if shard == true then
            heal = heal+self:GetSpecialValueFor("shard_heal")
        end


        local origin_player = self:GetCaster():GetPlayerOwner()
        SendOverheadEventMessage(origin_player,OVERHEAD_ALERT_HEAL,target,heal,origin_player)
        if self:GetCaster() ~= target then
            local target_player = target:GetPlayerOwner()
            SendOverheadEventMessage(target_player,OVERHEAD_ALERT_HEAL,target,heal,origin_player)
        end

        target:Heal(heal,self)

        self.projectile_table[proj_id] = self.projectile_table[proj_id]+1
        local particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_undying/undying_soul_rip_heal_impact_body.vpcf",
            PATTACH_POINT_FOLLOW,target
        )
        ParticleManager:SetParticleControl(particle,0,target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(aoe_part)
    else
        --ENEMY
        if not ult == false then
            if ult:GetLevel() > 0 then
                ult:ApplyVoidOutModifier(target,self)
            end
        end
    end


    return false
end
