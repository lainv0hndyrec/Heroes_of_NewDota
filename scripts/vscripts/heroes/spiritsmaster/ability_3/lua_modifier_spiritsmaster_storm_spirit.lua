lua_modifier_spiritsmaster_storm_spirit_transform = class({})

function lua_modifier_spiritsmaster_storm_spirit_transform:IsHidden() return false end
function lua_modifier_spiritsmaster_storm_spirit_transform:IsDebuff() return false end
function lua_modifier_spiritsmaster_storm_spirit_transform:IsPurgable() return true end
function lua_modifier_spiritsmaster_storm_spirit_transform:IsPurgeException() return true end
function lua_modifier_spiritsmaster_storm_spirit_transform:AllowIllusionDuplicate() return true end


function lua_modifier_spiritsmaster_storm_spirit_transform:DeclareFunctions()
    local dfunc ={
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_OVERRIDE_ATTACK_MAGICAL,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS
    }
    return dfunc
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetModifierModelChange()
    return "models/heroes/brewmaster/brewmaster_windspirit.vmdl"
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("hero_effect_int")
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetOverrideAttackMagical()
    return 1
end


function lua_modifier_spiritsmaster_storm_spirit_transform:OnAttackStart(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    self:GetParent():EmitSound("Brewmaster_Storm.PreAttack")
end


function lua_modifier_spiritsmaster_storm_spirit_transform:OnAttackLanded(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    if event.attacker:IsIllusion() then return end
    if event.target:IsBaseNPC() == false then return end
    if event.target:IsAlive() == false then return end
    if event.target:IsMagicImmune() then return end
    if event.target:IsBuilding() then return end

    local spec_val = self:GetAbility():GetSpecialValueFor("m_dmg_based_int_percent")*0.01
    local int = self:GetParent():GetIntellect()
    local m_dmg = spec_val*int


    if self:GetParent():HasScepter() then
        local mana = event.target:GetMana()
        local stolen_mana = math.min(m_dmg,mana)

        event.target:ReduceMana(stolen_mana)
        self:GetParent():GiveMana(stolen_mana)
    end


    local dtable = {
        victim = event.target,
        attacker = self:GetParent(),
        damage = m_dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetAttackSound()
    return "Brewmaster_Storm.Attack"
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetModifierAttackRangeOverride()
    local range = self:GetAbility():GetSpecialValueFor("attack_range")
    local talent = self:GetParent():FindAbilityByName("special_bonus_spiritsmaster_storm_spirit_atk_range_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            range = range+talent:GetSpecialValueFor("value")
        end
    end
    return range
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_storm_ambient.vpcf"
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetModifierProjectileName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_storm_attack.vpcf"
end


function lua_modifier_spiritsmaster_storm_spirit_transform:GetModifierProjectileSpeedBonus()
    if not IsServer() then return end
    return self.new_projectile_speed
end


function lua_modifier_spiritsmaster_storm_spirit_transform:OnCreated(kv)
    if not IsServer() then return end

    local fire_mod = self:GetParent():FindModifierByName("lua_modifier_spiritsmaster_fire_spirit_transform")
    if not fire_mod == false then
        fire_mod:Destroy()
    end

    local earth_mod = self:GetParent():FindModifierByName("lua_modifier_spiritsmaster_earth_spirit_transform")
    if not earth_mod == false then
        earth_mod:Destroy()
    end

    self.new_projectile_speed = self:GetAbility():GetSpecialValueFor("projectile_speed") - self:GetParent():GetProjectileSpeed()

    self.original_scale = 0.88480001688004
    self:GetParent():SetModelScale(1.1)

    self.original_atk_type = self:GetParent():GetAttackCapability()
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end


function lua_modifier_spiritsmaster_storm_spirit_transform:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():SetModelScale(self.original_scale)
    self:GetParent():SetAttackCapability(self.original_atk_type)
end












----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
lua_modifier_spiritsmaster_storm_spirit_bolt = class({})

function lua_modifier_spiritsmaster_storm_spirit_bolt:IsHidden() return false end
function lua_modifier_spiritsmaster_storm_spirit_bolt:IsDebuff() return false end
function lua_modifier_spiritsmaster_storm_spirit_bolt:IsPurgable() return false end
function lua_modifier_spiritsmaster_storm_spirit_bolt:IsPurgeException() return false end


function lua_modifier_spiritsmaster_storm_spirit_bolt:DeclareFunctions()
    local dfunc ={
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return dfunc
end


function lua_modifier_spiritsmaster_storm_spirit_bolt:OnAttackLanded(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    if event.attacker:IsIllusion() then return end
    if event.target:IsBaseNPC() == false then return end
    if event.target:IsAlive() == false then return end
    if event.target:IsBuilding() then return end

    if event.target:IsMagicImmune() == false then

        event.target:EmitSound("Brewmaster_Storm.ProjectileImpact")

        local particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_zuus/zuus_smaller_lightning_bolt.vpcf",
            PATTACH_WORLDORIGIN,event.target
        )
        local t_pos = event.target:GetAbsOrigin()
        t_pos.z = t_pos.z + 900
        ParticleManager:SetParticleControl(particle,0,t_pos)
        ParticleManager:SetParticleControl(particle,1,event.target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)


        local stun_time = self:GetAbility():GetSpecialValueFor("atk_bolt_stun")
        local talent = self:GetParent():FindAbilityByName("special_bonus_spiritsmaster_storm_spirit_stun_time_up")
        if not talent == false then
            if talent:GetLevel() > 0 then
                stun_time = stun_time+talent:GetSpecialValueFor("value")
            end
        end


        event.target:AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "modifier_stunned",
            {duration = stun_time}
        )

        local m_dmg = self:GetAbility():GetSpecialValueFor("atk_bolt_magic_damage")

        local dtable = {
            victim = event.target,
            attacker = self:GetParent(),
            damage = m_dmg,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self:GetAbility()
        }

        ApplyDamage(dtable)
    end

    self:Destroy()
end














----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
lua_modifier_spiritsmaster_storm_spirit_sight = class({})

function lua_modifier_spiritsmaster_storm_spirit_sight:IsHidden() return true end
function lua_modifier_spiritsmaster_storm_spirit_sight:IsDebuff() return false end
function lua_modifier_spiritsmaster_storm_spirit_sight:IsPurgable() return false end
function lua_modifier_spiritsmaster_storm_spirit_sight:IsPurgeException() return false end


function lua_modifier_spiritsmaster_storm_spirit_sight:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():EmitSound("Brewmaster_Storm.DispelMagic")
    self:GetParent():EmitSound("Brewmaster_Storm.Cyclone")


    if not self.cloud then
        self.cloud = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_razor_reduced_flash/razor_rain_storm_reduced_flash.vpcf",
            PATTACH_WORLDORIGIN,self:GetParent()
        )
        ParticleManager:SetParticleControl(self.cloud,0,self:GetParent():GetAbsOrigin())
    end


    if not self.eye then
        self.eye = ParticleManager:CreateParticle(
            "particles/econ/items/invoker/invoker_apex/invoker_apex_quas_eye_b.vpcf",
            PATTACH_WORLDORIGIN,self:GetParent()
        )
        local pos = self:GetParent():GetAbsOrigin()
        pos.z = pos.z+512
        ParticleManager:SetParticleControl(self.eye,3,pos)
    end


    local vision_range = self:GetAbility():GetSpecialValueFor("cast_range")
    AddFOWViewer(
        self:GetCaster():GetTeam(),self:GetParent():GetAbsOrigin(),
        vision_range,self:GetRemainingTime(),false
    )




end



function lua_modifier_spiritsmaster_storm_spirit_sight:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Brewmaster_Storm.Cyclone")
    if not self.cloud == false then
        ParticleManager:DestroyParticle(self.cloud,false)
        ParticleManager:ReleaseParticleIndex(self.cloud)
        self.cloud = nil
    end
    if not self.eye == false then
        ParticleManager:DestroyParticle(self.eye,false)
        ParticleManager:ReleaseParticleIndex(self.eye)
        self.eye = nil
    end

    UTIL_Remove(self:GetParent())
end
