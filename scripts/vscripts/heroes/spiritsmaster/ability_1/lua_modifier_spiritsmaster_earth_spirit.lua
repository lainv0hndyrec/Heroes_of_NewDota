lua_modifier_spiritsmaster_earth_spirit_transform = class({})

function lua_modifier_spiritsmaster_earth_spirit_transform:IsHidden() return false end
function lua_modifier_spiritsmaster_earth_spirit_transform:IsDebuff() return false end
function lua_modifier_spiritsmaster_earth_spirit_transform:IsPurgable() return true end
function lua_modifier_spiritsmaster_earth_spirit_transform:IsPurgeException() return true end
function lua_modifier_spiritsmaster_earth_spirit_transform:AllowIllusionDuplicate() return true end

function lua_modifier_spiritsmaster_earth_spirit_transform:DeclareFunctions()
    local dfunc ={
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return dfunc
end


function lua_modifier_spiritsmaster_earth_spirit_transform:GetModifierModelChange()
    return "models/heroes/brewmaster/brewmaster_earthspirit.vmdl"
end


function lua_modifier_spiritsmaster_earth_spirit_transform:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("hero_effect_str")
end


function lua_modifier_spiritsmaster_earth_spirit_transform:GetModifierPhysicalArmorBonus(event)
    return self:GetAbility():GetSpecialValueFor("hero_effect_armor")
end


function lua_modifier_spiritsmaster_earth_spirit_transform:GetModifierMagicalResistanceBonus(event)
    return self:GetAbility():GetSpecialValueFor("hero_effect_mr_percent")
end


function lua_modifier_spiritsmaster_earth_spirit_transform:OnAttackStart(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    self:GetParent():EmitSound("Brewmaster_Earth.PreAttack")
end



function lua_modifier_spiritsmaster_earth_spirit_transform:GetAttackSound()
    return "Brewmaster_Earth.Attack"
end


function lua_modifier_spiritsmaster_earth_spirit_transform:GetModifierAttackRangeOverride()
    return 150
end


function lua_modifier_spiritsmaster_earth_spirit_transform:OnAttackLanded(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    if self:GetParent():HasScepter() == false then return end

    local aoe_range = self:GetAbility():GetSpecialValueFor("scepter_aoe_atk_radius")
    local aoe_atk = self:GetAbility():GetSpecialValueFor("scepter_aoe_atk_percent")*0.01
    local atk_dmg = self:GetParent():GetAverageTrueAttackDamage(nil)


    local particle = ParticleManager:CreateParticle(
        "particles/econ/events/ti10/mekanism_ti10_shock.vpcf"
        ,PATTACH_ABSORIGIN,event.target
    )

    ParticleManager:SetParticleControl(particle,0,event.target:GetAbsOrigin())

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),event.target:GetAbsOrigin(),
        nil,aoe_range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false
    )

    for i=1, #enemies do
        local dtable = {
            victim = enemies[i],
            attacker = self:GetParent(),
            damage = atk_dmg*aoe_atk,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self:GetAbility()
        }
        ApplyDamage(dtable)
    end

end



function lua_modifier_spiritsmaster_earth_spirit_transform:GetEffectName()
    return "particles/units/heroes/hero_brewmaster/brewmaster_earth_ambient_b.vpcf"
end


function lua_modifier_spiritsmaster_earth_spirit_transform:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end



function lua_modifier_spiritsmaster_earth_spirit_transform:OnCreated(kv)
    if not IsServer() then return end

    local fire_mod = self:GetParent():FindModifierByName("lua_modifier_spiritsmaster_fire_spirit_transform")
    if not fire_mod == false then
        fire_mod:Destroy()
    end

    local strom_mod = self:GetParent():FindModifierByName("lua_modifier_spiritsmaster_storm_spirit_transform")
    if not strom_mod == false then
        strom_mod:Destroy()
    end

    self.original_scale = self:GetParent():GetModelScale()
    self:GetParent():SetModelScale(1.3)

    self.original_atk_type = self:GetParent():GetAttackCapability()
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end


function lua_modifier_spiritsmaster_earth_spirit_transform:OnDestroy()
    if not IsServer() then return end
    self:GetCaster():SetModelScale(self.original_scale)
    self:GetParent():SetAttackCapability(self.original_atk_type)
end











-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
lua_modifier_spiritsmaster_earth_spirit_slow = class({})

function lua_modifier_spiritsmaster_earth_spirit_slow:IsHidden() return false end
function lua_modifier_spiritsmaster_earth_spirit_slow:IsDebuff() return true end
function lua_modifier_spiritsmaster_earth_spirit_slow:IsPurgable() return true end
function lua_modifier_spiritsmaster_earth_spirit_slow:IsPurgeException() return true end


function lua_modifier_spiritsmaster_earth_spirit_slow:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return dfunc
end


function lua_modifier_spiritsmaster_earth_spirit_slow:GetModifierMoveSpeedBonus_Percentage()
    local slow = self:GetAbility():GetSpecialValueFor("slow_percent")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_spiritsmaster_earth_spirit_slow_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            slow = slow+talent:GetSpecialValueFor("value")
        end
    end
    return -slow
end


function lua_modifier_spiritsmaster_earth_spirit_slow:GetEffectName()
    return "particles/units/heroes/hero_primal_beast/primal_beast_status_effect_slow.vpcf"
end

function lua_modifier_spiritsmaster_earth_spirit_slow:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
