lua_modifier_corruptedlord_duality_chaos = class({})

function lua_modifier_corruptedlord_duality_chaos:IsHidden()return false end
function lua_modifier_corruptedlord_duality_chaos:IsDebuff() return false end
function lua_modifier_corruptedlord_duality_chaos:IsPurgable() return false end
function lua_modifier_corruptedlord_duality_chaos:IsPurgeException() return false end
function lua_modifier_corruptedlord_duality_chaos:AllowIllusionDuplicate() return true end


function lua_modifier_corruptedlord_duality_chaos:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_TOOLTIP
	}

	return funcs
end



function lua_modifier_corruptedlord_duality_chaos:OnCreated(kv)
	if not IsServer() then return end
	if not self.weapon_particle then
		self.weapon_particle = ParticleManager:CreateParticle(
			"particles/units/heroes/corrupted_lord/ability_2/duality_modifier_1.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			self:GetParent()
		)

		ParticleManager:SetParticleControl(self.weapon_particle,60,Vector(255,0,0))
	end
end




function lua_modifier_corruptedlord_duality_chaos:GetModifierPreAttack_BonusDamage()
	if self:GetParent():IsSilenced() == true then return end
    return self:GetAbility():GetSpecialValueFor("add_attack_damage")
end


function lua_modifier_corruptedlord_duality_chaos:OnAttack(event)
	if not IsServer() then return end
	if event.attacker ~= self:GetParent() then return end
	if event.attacker:IsSilenced() == true then return end


    local emo = {
        victim = self:GetParent(),
        attacker = self:GetParent(),
        damage = self:GetAbility():GetSpecialValueFor("self_damage"),
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self:GetAbility()
    }

    ApplyDamage(emo)

end


function lua_modifier_corruptedlord_duality_chaos:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("self_damage")
end


function lua_modifier_corruptedlord_duality_chaos:OnDestroy()
	if not IsServer() then return end
	if not self.weapon_particle == false then
		ParticleManager:DestroyParticle(self.weapon_particle,false)
		ParticleManager:ReleaseParticleIndex(self.weapon_particle)
		self.weapon_particle = nil
	end
end





----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

lua_modifier_corruptedlord_duality_solace = class({})

function lua_modifier_corruptedlord_duality_solace:IsHidden() return false end
function lua_modifier_corruptedlord_duality_solace:IsDebuff() return false end
function lua_modifier_corruptedlord_duality_solace:IsPurgable() return false end
function lua_modifier_corruptedlord_duality_solace:IsPurgeException() return false end
function lua_modifier_corruptedlord_duality_solace:AllowIllusionDuplicate() return true end



function lua_modifier_corruptedlord_duality_solace:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TOOLTIP
	}

	return funcs
end


function lua_modifier_corruptedlord_duality_solace:OnCreated(kv)
	if not IsServer() then return end
	if not self.weapon_particle then
		self.weapon_particle = ParticleManager:CreateParticle(
			"particles/units/heroes/corrupted_lord/ability_2/duality_modifier_1.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			self:GetParent()
		)

		ParticleManager:SetParticleControl(self.weapon_particle,60,Vector(0,255,0))
	end
end


function lua_modifier_corruptedlord_duality_solace:GetModifierPreAttack_BonusDamage()
	if self:GetParent():IsSilenced() == true then return end
    return self:GetAbility():GetSpecialValueFor("add_attack_damage")
end


function lua_modifier_corruptedlord_duality_solace:OnAttackLanded(event)

	if event.attacker ~= self:GetParent() then return end

	if event.attacker:IsSilenced() == true then return end

	if event.target:IsBaseNPC() == false then return end
	
    if event.target:IsBuilding() == true then return end

	local heal = self:GetAbility():GetSpecialValueFor("heal")

	local lifesteal = heal + event.damage*0.05

    self:GetParent():Heal(lifesteal,self:GetAbility())

	local particle_lifesteal_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, event.attacker)
	ParticleManager:SetParticleControlEnt(particle_lifesteal_fx, 0, event.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", event.attacker:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle_lifesteal_fx, 1, event.target, PATTACH_POINT_FOLLOW, "attach_hitloc", event.target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle_lifesteal_fx)
end


function lua_modifier_corruptedlord_duality_solace:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("heal")
end


function lua_modifier_corruptedlord_duality_solace:OnDestroy()
	if not IsServer() then return end
	if not self.weapon_particle == false then
		ParticleManager:DestroyParticle(self.weapon_particle,false)
		ParticleManager:ReleaseParticleIndex(self.weapon_particle)
		self.weapon_particle = nil
	end
end
