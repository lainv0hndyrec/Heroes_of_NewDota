LinkLuaModifier( "lua_modifier_spiritsmaster_fire_spirit_steal_debuff", "heroes/spiritsmaster/ability_2/lua_modifier_spiritsmaster_fire_spirit", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_spiritsmaster_fire_spirit_steal_buff", "heroes/spiritsmaster/ability_2/lua_modifier_spiritsmaster_fire_spirit", LUA_MODIFIER_MOTION_NONE )



lua_modifier_spiritsmaster_fire_spirit_transform = class({})

function lua_modifier_spiritsmaster_fire_spirit_transform:IsHidden() return false end
function lua_modifier_spiritsmaster_fire_spirit_transform:IsDebuff() return false end
function lua_modifier_spiritsmaster_fire_spirit_transform:IsPurgable() return true end
function lua_modifier_spiritsmaster_fire_spirit_transform:IsPurgeException() return true end
function lua_modifier_spiritsmaster_fire_spirit_transform:AllowIllusionDuplicate() return true end


function lua_modifier_spiritsmaster_fire_spirit_transform:CheckState()
    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = self:GetParent():HasScepter(),
        [MODIFIER_STATE_CANNOT_MISS] = self:GetParent():HasScepter()
    }
    return cstate
end


function lua_modifier_spiritsmaster_fire_spirit_transform:DeclareFunctions()
    local dfunc ={
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE
    }
    return dfunc
end


function lua_modifier_spiritsmaster_fire_spirit_transform:GetModifierModelChange()
    return "models/heroes/brewmaster/brewmaster_firespirit.vmdl"
end


function lua_modifier_spiritsmaster_fire_spirit_transform:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("hero_effect_agi")
end


function lua_modifier_spiritsmaster_fire_spirit_transform:GetModifierMoveSpeedBonus_Constant()
    local speed = self:GetAbility():GetSpecialValueFor("hero_effect_ms_bonus")
    local talent = self:GetParent():FindAbilityByName("special_bonus_spiritsmaster_fire_spirit_speed_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            speed = speed+talent:GetSpecialValueFor("value")
        end
    end
    return speed
end


function lua_modifier_spiritsmaster_fire_spirit_transform:OnAttackStart(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    self:GetParent():EmitSound("Brewmaster_Fire.PreAttack")
end


function lua_modifier_spiritsmaster_fire_spirit_transform:GetAttackSound()
    return "Brewmaster_Fire.Attack"
end


function lua_modifier_spiritsmaster_fire_spirit_transform:GetModifierAttackRangeOverride()
    return 150
end


function lua_modifier_spiritsmaster_fire_spirit_transform:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient.vpcf"
end


function lua_modifier_spiritsmaster_fire_spirit_transform:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end




function lua_modifier_spiritsmaster_fire_spirit_transform:OnCreated(kv)
    if not IsServer() then return end

    local earth_mod = self:GetParent():FindModifierByName("lua_modifier_spiritsmaster_earth_spirit_transform")
    if not earth_mod == false then
        earth_mod:Destroy()
    end

    local strom_mod = self:GetParent():FindModifierByName("lua_modifier_spiritsmaster_storm_spirit_transform")
    if not strom_mod == false then
        strom_mod:Destroy()
    end

    self.original_scale = self:GetParent():GetModelScale()
    self:GetParent():SetModelScale(1.1)

    self.original_atk_type = self:GetParent():GetAttackCapability()
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

end


function lua_modifier_spiritsmaster_fire_spirit_transform:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():SetModelScale(self.original_scale)
	self:GetParent():SetAttackCapability(self.original_atk_type)
end






















-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

lua_modifier_spiritsmaster_fire_spirit_dash = class({})



function lua_modifier_spiritsmaster_fire_spirit_dash:IsHidden() return true end
function lua_modifier_spiritsmaster_fire_spirit_dash:IsDebuff() return false end
function lua_modifier_spiritsmaster_fire_spirit_dash:IsPurgable() return false end
function lua_modifier_spiritsmaster_fire_spirit_dash:IsPurgeException() return false end


function lua_modifier_spiritsmaster_fire_spirit_dash:CheckState()
    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }
    return cstate
end


function lua_modifier_spiritsmaster_fire_spirit_dash:OnCreated(kv)

    if not IsServer() then return end

    self.target = EntIndexToHScript(kv.target)

    self:GetParent():StartGesture(ACT_DOTA_RUN)

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,self:GetParent()
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,0,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,
            "attach_hitloc",Vector(0,0,0),true
        )
    end

    if self:ApplyHorizontalMotionController() == false then
	    self:Destroy()
    end
end


function lua_modifier_spiritsmaster_fire_spirit_dash:UpdateHorizontalMotion(me,dt)
    if not IsServer() then return end

    if self.target:IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetParent():IsAlive() == false then
        self:Destroy()
        return
    end

    if self:GetParent():IsStunned() then
        self:Destroy()
        return
    end

    if self:GetParent():IsRooted() then
        self:Destroy()
        return
    end

    local speed = self:GetAbility():GetSpecialValueFor("dash_speed")*dt
    local target_pos = self.target:GetAbsOrigin()
    local my_pos = self:GetParent():GetAbsOrigin()
    local diff = target_pos-my_pos
    local diff_norm = diff:Normalized()
    local diff_length = diff:Length2D()
    local velocity = my_pos+(speed*diff_norm)
    velocity = GetGroundPosition(velocity,self:GetParent())

    self:GetParent():FaceTowards(target_pos)

    if diff_length <= 150 then
        self:GetParent():SetAbsOrigin(target_pos-(diff_norm*150))
        self:StealAttack()
        return
    end

    self:GetParent():SetAbsOrigin(velocity)
end


function lua_modifier_spiritsmaster_fire_spirit_dash:OnHorizontalMotionInterrupted()
    self:Destroy()
end


function lua_modifier_spiritsmaster_fire_spirit_dash:StealAttack()
    if not IsServer() then return end

    if self.target:GetTeam() == self:GetParent():GetTeam() then
        self:Destroy()
        return
    end

    self:GetParent():MoveToTargetToAttack(self.target)


    if self.target:IsMagicImmune() then
        self:Destroy()
        return
    end

    if self.target:TriggerSpellAbsorb(self:GetAbility()) then
        self:Destroy()
        return
    end


    --get the value
    local target_damage = self.target:GetAverageTrueAttackDamage(nil)
    local steal_percent = 0.0
    if self.target:IsHero() then
        steal_percent = self:GetAbility():GetSpecialValueFor("dmg_steal_hero_percent")
    else
        steal_percent = self:GetAbility():GetSpecialValueFor("dmg_steal_creep_percent")
    end

    local talent = self:GetParent():FindAbilityByName("special_bonus_spiritsmaster_fire_spirit_steal_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            steal_percent = steal_percent+talent:GetSpecialValueFor("value")
        end
    end

    local stolen_dmg = target_damage*steal_percent*0.01

    -- steal
    self.target:AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_fire_spirit_steal_debuff",
        {
            duration = self:GetAbility():GetSpecialValueFor("dmg_steal_time"),
            damage_bonus = stolen_dmg
        }
    )


    -- leech
    self:GetParent():AddNewModifier(
        self:GetCaster(),self,
        "lua_modifier_spiritsmaster_fire_spirit_steal_buff",
        {
            duration = self:GetAbility():GetSpecialValueFor("dmg_steal_time"),
            damage_bonus = stolen_dmg
        }
    )

    --applydamage
    local dtable = {
        victim = self.target,
        attacker = self:GetParent(),
        damage = self:GetAbility():GetSpecialValueFor("ability_dmg"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)

    self:Destroy()
end


function lua_modifier_spiritsmaster_fire_spirit_dash:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveGesture(ACT_DOTA_RUN)
    self:GetParent():RemoveHorizontalMotionController(self)
    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
end
































-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

lua_modifier_spiritsmaster_fire_spirit_steal_debuff = class({})



function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:IsHidden() return false end
function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:IsDebuff() return true end
function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:IsPurgable() return true end
function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:IsPurgeException() return true end


function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end


function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:OnCreated(kv)
    if not IsServer() then return end
    self:SetStackCount(kv.damage_bonus)
end

function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:GetModifierPreAttack_BonusDamage()
    return -self:GetStackCount()
end


function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient.vpcf"
end


function lua_modifier_spiritsmaster_fire_spirit_steal_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
















-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

lua_modifier_spiritsmaster_fire_spirit_steal_buff = class({})



function lua_modifier_spiritsmaster_fire_spirit_steal_buff:IsHidden() return false end
function lua_modifier_spiritsmaster_fire_spirit_steal_buff:IsDebuff() return false end
function lua_modifier_spiritsmaster_fire_spirit_steal_buff:IsPurgable() return true end
function lua_modifier_spiritsmaster_fire_spirit_steal_buff:IsPurgeException() return true end


function lua_modifier_spiritsmaster_fire_spirit_steal_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end


function lua_modifier_spiritsmaster_fire_spirit_steal_buff:OnCreated(kv)
    if not IsServer() then return end
    self:SetStackCount(kv.damage_bonus)
end

function lua_modifier_spiritsmaster_fire_spirit_steal_buff:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end
