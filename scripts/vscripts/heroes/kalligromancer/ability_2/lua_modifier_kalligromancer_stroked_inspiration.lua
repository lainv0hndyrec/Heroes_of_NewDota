LinkLuaModifier( "lua_modifier_kalligromancer_stroked_inspiration_thinker", "heroes/kalligromancer/ability_2/lua_modifier_kalligromancer_stroked_inspiration", LUA_MODIFIER_MOTION_NONE )

lua_modifier_kalligromancer_stroked_inspiration = class({})


function lua_modifier_kalligromancer_stroked_inspiration:IsHidden() return false end

function lua_modifier_kalligromancer_stroked_inspiration:IsDebuff() return true end

function lua_modifier_kalligromancer_stroked_inspiration:IsPurgable() return true end

function lua_modifier_kalligromancer_stroked_inspiration:GetModifierProvidesFOWVision() return 1 end

function lua_modifier_kalligromancer_stroked_inspiration:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
    return dfunc
end

function lua_modifier_kalligromancer_stroked_inspiration:CheckState()
    if not IsServer() then return end


    if self.controlable then
        local dfunc = {
            [MODIFIER_STATE_ATTACK_ALLIES] = true,
            [MODIFIER_STATE_SILENCED] = true
        }
        return dfunc
    end

    local dfunc = {
        [MODIFIER_STATE_ATTACK_ALLIES] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED ] = true
    }
    return dfunc
end




function lua_modifier_kalligromancer_stroked_inspiration:OnCreated(kv)
    self.closest_target = nil
    self.controlable = true
    self.scan_range = self:GetAbility():GetSpecialValueFor("scan_range")

    --particle
    --[[
    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControlEnt(self.particle,2,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,"follow_origin",self:GetParent():GetAbsOrigin(),false)
    ParticleManager:SetParticleControl(self.particle,60,Vector(255,0,0))
    ParticleManager:SetParticleControl(self.particle,61,Vector(1,0,0))
    ]]

    self.overhead_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_marker_tgt_model.vpcf",
        PATTACH_OVERHEAD_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControlEnt(self.overhead_particle,1,self:GetParent(),PATTACH_OVERHEAD_FOLLOW,"follow_overhead",self:GetParent():GetAbsOrigin(),false)

    self.outline_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_main_outline.vpcf",
        PATTACH_POINT_FOLLOW,
        self:GetParent()
    )
    ParticleManager:SetParticleControlEnt(self.outline_particle,0,self:GetParent(),PATTACH_POINT_FOLLOW,"follow_hitloc",self:GetParent():GetAbsOrigin(),false)



    self:StartIntervalThink(FrameTime())

    if not IsServer() then return end
    --thinker transfer damage here
    self.thinker = CreateModifierThinker(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_kalligromancer_stroked_inspiration_thinker",
        { duration = self:GetDuration() },
        self:GetParent():GetAbsOrigin(),
        self:GetCaster():GetTeamNumber(),
        false
    )
end




function lua_modifier_kalligromancer_stroked_inspiration:OnRefresh(kv)

    if not IsServer() then return end
    --thinker transfer damage here
    self.thinker = CreateModifierThinker(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_kalligromancer_stroked_inspiration_thinker",
        { duration = self:GetDuration() },
        self:GetParent():GetAbsOrigin(),
        self:GetCaster():GetTeamNumber(),
        false
    )

end




function lua_modifier_kalligromancer_stroked_inspiration:OnIntervalThink()
    if not IsServer() then return end

    --in no target, then find one
    if not self.closest_target then
        local units_near = FindUnitsInRadius(
            self:GetParent():GetTeamNumber(),
            self:GetParent():GetAbsOrigin(),
            self:GetParent(),
            self.scan_range,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NO_INVIS,
            FIND_CLOSEST,
            false
        )

        for _,unit in pairs(units_near) do
            if unit ~= self:GetParent() then
                self.closest_target = unit
                self.controlable = false
                self:GetParent():MoveToTargetToAttack(self.closest_target)
                self:GetParent():SetAggroTarget(self.closest_target)
                if self:GetParent():GetTeamNumber() == self.closest_target:GetTeamNumber() then
                    self:GetParent():SetForceAttackTargetAlly(nil)
                end
                return
            end
        end

        self:GetParent():SetForceAttackTargetAlly(nil)
        return
    end

    -- if target is dead
    if self.closest_target:IsAlive() == false then
        self.closest_target = nil
        self.controlable = true
        self:GetParent():SetForceAttackTargetAlly(nil)
        return
    end


    -- if target is immune
    if self.closest_target:IsAttackImmune() == true then
        self.closest_target = nil
        self.controlable = true
        self:GetParent():SetForceAttackTargetAlly(nil)
        return
    end

    -- if target is IsInvulnerable
    if self.closest_target:IsInvulnerable() == true then
        self.closest_target = nil
        self.controlable = true
        self:GetParent():SetForceAttackTargetAlly(nil)
        return
    end

    -- if target is invi
    if self.closest_target:IsInvisible() == true then
        self.closest_target = nil
        self.controlable = true
        self:GetParent():SetForceAttackTargetAlly(nil)
        return
    end


    -- if target is too far
    local range = (self.closest_target:GetAbsOrigin() -  self:GetParent():GetAbsOrigin()):Length2D()
    local attack_range = self:GetParent():Script_GetAttackRange()
    if range > attack_range then
        self:GetParent():MoveToTargetToAttack(self.closest_target)
        self:GetParent():SetAggroTarget(self.closest_target)
        if self:GetParent():GetTeamNumber() == self.closest_target:GetTeamNumber() then
            self:GetParent():SetForceAttackTargetAlly(nil)
        end
        return
    end

    self:GetParent():MoveToTargetToAttack(self.closest_target)
    self:GetParent():SetAggroTarget(self.closest_target)
    if self:GetParent():GetTeamNumber() == self.closest_target:GetTeamNumber() then
        self:GetParent():SetForceAttackTargetAlly(self.closest_target)
    end
end




function lua_modifier_kalligromancer_stroked_inspiration:GetModifierTotalDamageOutgoing_Percentage(event)
    if event.attacker:IsAlive() == false then return 0 end
    if event.attacker ~= self:GetParent() then return 0 end

    if not self.closest_target then return 0 end

    if event.target:IsBaseNPC() == false then return 0 end
    if event.target:IsAlive() == false then return 0 end
    if event.target ~= self.closest_target then return 0 end

    if self.closest_target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then return -50 end

    if IsServer() then
        local add_damage = 0
        local talent = self:GetCaster():FindAbilityByName("special_bonus_kalligromancer_stroked_inspiration_plus_damage")
        if not talent == false then
            if talent:GetLevel() > 0 then
                add_damage = talent:GetSpecialValueFor("value")
            end
        end

        local damage_mult = (self:GetAbility():GetSpecialValueFor("damage_mult")+add_damage)*0.01

        local dtable = {
            victim = self.closest_target,
            attacker = self.thinker,
            damage = event.original_damage*damage_mult,
            damage_type = event.damage_type,
            damage_flags = event.damage_flags,
            ability = self:GetAbility()
        }

        ApplyDamage(dtable)
    end

    return -100
end




function lua_modifier_kalligromancer_stroked_inspiration:OnDestroy()


    ParticleManager:DestroyParticle(self.overhead_particle,false)
    ParticleManager:ReleaseParticleIndex(self.overhead_particle)

    ParticleManager:DestroyParticle(self.outline_particle,false)
    ParticleManager:ReleaseParticleIndex(self.outline_particle)

    if not IsServer() then return end
    self:GetParent():SetForceAttackTargetAlly(nil)

end

--createhero npc_dota_hero_axe enemy






lua_modifier_kalligromancer_stroked_inspiration_thinker = class({})

function lua_modifier_kalligromancer_stroked_inspiration_thinker:IsHidden() return true end

function lua_modifier_kalligromancer_stroked_inspiration_thinker:IsDebuff() return false end

function lua_modifier_kalligromancer_stroked_inspiration_thinker:IsPurgable() return false end

function lua_modifier_kalligromancer_stroked_inspiration_thinker:CheckState()
    return {MODIFIER_STATE_INVULNERABLE = true}
end

function lua_modifier_kalligromancer_stroked_inspiration_thinker:OnDestroy()
    UTIL_Remove(self:GetParent())
end
