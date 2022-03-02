lua_modifier_corruptedlord_demonic_scars = class({})

function lua_modifier_corruptedlord_demonic_scars:IsHidden()
    return false
end

function lua_modifier_corruptedlord_demonic_scars:IsPurgable()
    return false
end



function lua_modifier_corruptedlord_demonic_scars:IsDebuff()
	return false
end

function lua_modifier_corruptedlord_demonic_scars:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function lua_modifier_corruptedlord_demonic_scars:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end


function lua_modifier_corruptedlord_demonic_scars:OnCreated()
    self.ability = self:GetAbility()
	self.caster	= self.ability:GetCaster()
    self.max_attack_speed = self.ability:GetSpecialValueFor("max_attack_speed")
	self.magic_resistance = self.ability:GetSpecialValueFor("magic_resistance")
    self.stacks = 0

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/corrupted_lord/ability_3/corrupted_lord_ability_demonic_scars.vpcf",
            PATTACH_POINT_FOLLOW,
            self.caster
        )
    end


    self:StartIntervalThink(0.2)
end



function lua_modifier_corruptedlord_demonic_scars:OnRefresh()
    self.ability = self:GetAbility()
	self.caster	= self.ability:GetCaster()
    self.max_attack_speed = self.ability:GetSpecialValueFor("max_attack_speed")
	self.magic_resistance = self.ability:GetSpecialValueFor("magic_resistance")
    self.stacks = 0

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/corrupted_lord/ability_3/corrupted_lord_ability_demonic_scars.vpcf",
            PATTACH_POINT_FOLLOW,
            self.caster
        )
    end

    self:StartIntervalThink(0.2)
end



function lua_modifier_corruptedlord_demonic_scars:OnIntervalThink()
    self.stacks = math.ceil((100-self.caster:GetHealthPercent())*0.1)
    self:SetStackCount(self.stacks)

    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/corrupted_lord/ability_3/corrupted_lord_ability_demonic_scars.vpcf",
            PATTACH_POINT_FOLLOW,
            self.caster
        )
    end

    ParticleManager:SetParticleControl(self.particle,1,Vector(self.stacks*10,0,0))
end



function lua_modifier_corruptedlord_demonic_scars:GetModifierAttackSpeedBonus_Constant()
    if self.caster:PassivesDisabled() then return end

    local attack_bonus = math.ceil(self.max_attack_speed*self.stacks*0.1)
    return attack_bonus
end


function lua_modifier_corruptedlord_demonic_scars:GetModifierMagicalResistanceBonus()
    if self.caster:PassivesDisabled() then return end

    local mag_resist = math.ceil(self.magic_resistance*self.stacks*0.1)
    return mag_resist
end


function lua_modifier_corruptedlord_demonic_scars:OnDestroy()
    self:StartIntervalThink(-1)
    self.stacks = 0
    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end
end
