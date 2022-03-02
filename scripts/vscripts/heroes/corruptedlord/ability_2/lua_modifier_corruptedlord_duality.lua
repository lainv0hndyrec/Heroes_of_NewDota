lua_modifier_corruptedlord_duality_chaos = class({})

function lua_modifier_corruptedlord_duality_chaos:IsHidden()
	return false
end

function lua_modifier_corruptedlord_duality_chaos:IsDebuff()
	return false
end

function lua_modifier_corruptedlord_duality_chaos:IsPurgable()
	return false
end

function lua_modifier_corruptedlord_duality_chaos:IsPurgeException()
    return false
end

function lua_modifier_corruptedlord_duality_chaos:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end


function lua_modifier_corruptedlord_duality_chaos:OnCreated( kv )
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.add_attack_damage = self:GetAbility():GetSpecialValueFor("add_attack_damage")
    self.self_damage = self:GetAbility():GetSpecialValueFor("self_damage")

end


function lua_modifier_corruptedlord_duality_chaos:OnRefresh( kv )
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.add_attack_damage = self:GetAbility():GetSpecialValueFor("add_attack_damage")
    self.self_damage = self:GetAbility():GetSpecialValueFor("self_damage")
end


function lua_modifier_corruptedlord_duality_chaos:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_TOOLTIP
	}

	return funcs
end

function lua_modifier_corruptedlord_duality_chaos:GetModifierPreAttack_BonusDamage()
	if self.caster:IsSilenced() == true then return end
    return self.add_attack_damage
end


function lua_modifier_corruptedlord_duality_chaos:OnAttack(event)
	if not IsServer() then return end
	if event.attacker:IsSilenced() == true then return end
    if event.attacker ~= self.caster then return end

    local emo = {
        victim = self.caster,
        attacker = self.caster,
        damage = self.self_damage,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self.ability
    }

    ApplyDamage(emo)

end


function lua_modifier_corruptedlord_duality_chaos:OnTooltip()
	return self.self_damage
end










lua_modifier_corruptedlord_duality_solace = class({})

function lua_modifier_corruptedlord_duality_solace:IsHidden()
	return false
end

function lua_modifier_corruptedlord_duality_solace:IsDebuff()
	return false
end

function lua_modifier_corruptedlord_duality_solace:IsPurgable()
	return false
end

function lua_modifier_corruptedlord_duality_solace:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end


function lua_modifier_corruptedlord_duality_solace:OnCreated( kv )
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.add_attack_damage = self:GetAbility():GetSpecialValueFor("add_attack_damage")
    self.heal = self:GetAbility():GetSpecialValueFor("heal")
end


function lua_modifier_corruptedlord_duality_solace:OnRefresh( kv )
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.add_attack_damage = self:GetAbility():GetSpecialValueFor("add_attack_damage")
    self.heal = self:GetAbility():GetSpecialValueFor("heal")
end


function lua_modifier_corruptedlord_duality_solace:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TOOLTIP
	}

	return funcs
end

function lua_modifier_corruptedlord_duality_solace:GetModifierPreAttack_BonusDamage()
	if self.caster:IsSilenced() == true then return end
    return self.add_attack_damage
end


function lua_modifier_corruptedlord_duality_solace:OnAttackLanded(event)

    if event.attacker ~= self.caster then return end

	if event.attacker:IsSilenced() == true then return end

    if event.target:IsBuilding() == true then return end

	local lifesteal = self.heal + event.damage*0.05

    self.caster:Heal(lifesteal,self.ability)

	local particle_lifesteal_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, event.attacker)
	ParticleManager:SetParticleControlEnt(particle_lifesteal_fx, 0, event.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", event.attacker:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_lifesteal_fx, 1, event.target, PATTACH_POINT_FOLLOW, "attach_hitloc", event.target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle_lifesteal_fx)
end


function lua_modifier_corruptedlord_duality_solace:OnTooltip()
	return self.heal
end
