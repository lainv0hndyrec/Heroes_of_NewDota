LinkLuaModifier( "lua_modifier_vagabond_prismatic_mist_invi_applier", "heroes/vagabond/ability_1/lua_modifier_vagabond_prismatic_mist", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_prismatic_mist_invi", "heroes/vagabond/ability_1/lua_modifier_vagabond_prismatic_mist", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_prismatic_mist_slow", "heroes/vagabond/ability_1/lua_modifier_vagabond_prismatic_mist", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_vagabond_prismatic_mist_particle_thinker", "heroes/vagabond/ability_1/lua_modifier_vagabond_prismatic_mist", LUA_MODIFIER_MOTION_NONE )



-------------------------------------------------------------
-- THE INVI AURA
---------------------------------------------------------------

lua_modifier_vagabond_prismatic_mist_invi_aura = class({})

function lua_modifier_vagabond_prismatic_mist_invi_aura:IsPurgable()	return false end

function lua_modifier_vagabond_prismatic_mist_invi_aura:RemoveOnDeath()	return true end

function lua_modifier_vagabond_prismatic_mist_invi_aura:IsPurgeException() return false end

function lua_modifier_vagabond_prismatic_mist_invi_aura:IsAura() return true end

function lua_modifier_vagabond_prismatic_mist_invi_aura:GetAuraEntityReject(target) return false end

function lua_modifier_vagabond_prismatic_mist_invi_aura:GetAuraDuration() return 0.0 end

function lua_modifier_vagabond_prismatic_mist_invi_aura:IsAuraActiveOnDeath() return false end


function lua_modifier_vagabond_prismatic_mist_invi_aura:OnCreated(kv)

	if IsServer() == false then return end

	self.mist_thinker = CreateModifierThinker(
		self:GetCaster(),
		self:GetAbility(),
		"lua_modifier_vagabond_prismatic_mist_particle_thinker",
		{},
		self:GetCaster():GetAbsOrigin(),
		DOTA_TEAM_NOTEAM,
		false
	)

end


function lua_modifier_vagabond_prismatic_mist_invi_aura:GetAuraRadius()
	return self:GetAbility():GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster())
end


function lua_modifier_vagabond_prismatic_mist_invi_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end



function lua_modifier_vagabond_prismatic_mist_invi_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end



function lua_modifier_vagabond_prismatic_mist_invi_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end



function lua_modifier_vagabond_prismatic_mist_invi_aura:GetModifierAura()
	return "lua_modifier_vagabond_prismatic_mist_invi_applier"
end


function lua_modifier_vagabond_prismatic_mist_invi_aura:OnDestroy()
	if IsServer() == false then return end

	self.mist_thinker:Destroy()
end








-----------------------------------------------
-- THE INVI APPLIER
-----------------------------------------------

lua_modifier_vagabond_prismatic_mist_invi_applier = class({})

function lua_modifier_vagabond_prismatic_mist_invi_applier:IsPurgable()	return false end

function lua_modifier_vagabond_prismatic_mist_invi_applier:RemoveOnDeath()	return true end

function lua_modifier_vagabond_prismatic_mist_invi_applier:IsPurgeException() return false end

function lua_modifier_vagabond_prismatic_mist_invi_applier:IsHidden() return true end


function lua_modifier_vagabond_prismatic_mist_invi_applier:DeclareFunctions()
	local dfucs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return dfucs

end



function lua_modifier_vagabond_prismatic_mist_invi_applier:OnCreated(kv)
	if not IsServer() then return end

	--[[
	self.mod_invi = self:GetParent():AddNewModifier(
		self:GetCaster(),
		self:GetAbility(),
		"lua_modifier_vagabond_prismatic_mist_invi",
		{}
	)]]


	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("fade_time"))
end



function lua_modifier_vagabond_prismatic_mist_invi_applier:OnIntervalThink()

	self:StartIntervalThink(-1)

	if not IsServer() then return end

	self.mod_invi = self:GetParent():AddNewModifier(
		self:GetCaster(),
		self:GetAbility(),
		"lua_modifier_vagabond_prismatic_mist_invi",
		{}
	)

end



function lua_modifier_vagabond_prismatic_mist_invi_applier:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("ms_speed")
end



function lua_modifier_vagabond_prismatic_mist_invi_applier:OnDestroy()
	self:StartIntervalThink(-1)

	if not IsServer() then return end

	local invi_mod = self:GetParent():FindModifierByName("lua_modifier_vagabond_prismatic_mist_invi")
	if not invi_mod == false then
		invi_mod:Destroy()
	end
end











-------------------------------------------------------------
-- THE INVI
------------------------------------------------------------

lua_modifier_vagabond_prismatic_mist_invi = class({})

function lua_modifier_vagabond_prismatic_mist_invi:IsPurgable()	return false end

function lua_modifier_vagabond_prismatic_mist_invi:RemoveOnDeath()	return true end

function lua_modifier_vagabond_prismatic_mist_invi:IsPurgeException() return false end

function lua_modifier_vagabond_prismatic_mist_invi:IsHidden() return true end





function lua_modifier_vagabond_prismatic_mist_invi:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
	return state
end




function lua_modifier_vagabond_prismatic_mist_invi:DeclareFunctions()
	local dfucs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return dfucs
end




function lua_modifier_vagabond_prismatic_mist_invi:GetModifierInvisibilityLevel()
	return 1
end



function lua_modifier_vagabond_prismatic_mist_invi:OnAbilityFullyCast(event)

	if event.unit ~= self:GetParent() then return end
	if event.ability == self:GetAbility() then return end
	self:Destroy()

end




function lua_modifier_vagabond_prismatic_mist_invi:OnAttack(event)

	if event.attacker ~= self:GetParent() then return end
	self:Destroy()

end


function lua_modifier_vagabond_prismatic_mist_invi:OnDestroy()

	if not IsServer() then return end

	local applier_mod = self:GetParent():FindModifierByName("lua_modifier_vagabond_prismatic_mist_invi_applier")
	if not applier_mod == false then
		applier_mod:StartIntervalThink(self:GetAbility():GetSpecialValueFor("fade_time"))
	end

end









-----------------------------------------------------------
--Aura SLow
------------------------------------------------------------

lua_modifier_vagabond_prismatic_mist_slow_aura = class({})

function lua_modifier_vagabond_prismatic_mist_slow_aura:IsPurgable()	return false end

function lua_modifier_vagabond_prismatic_mist_slow_aura:RemoveOnDeath()	return true end

function lua_modifier_vagabond_prismatic_mist_slow_aura:IsPurgeException() return false end

function lua_modifier_vagabond_prismatic_mist_slow_aura:IsAura() return true end

function lua_modifier_vagabond_prismatic_mist_slow_aura:GetAuraEntityReject(target) return false end

function lua_modifier_vagabond_prismatic_mist_slow_aura:GetAuraDuration() return 0.0 end

function lua_modifier_vagabond_prismatic_mist_slow_aura:IsAuraActiveOnDeath() return false end

function lua_modifier_vagabond_prismatic_mist_slow_aura:IsHidden() return true end

function lua_modifier_vagabond_prismatic_mist_slow_aura:GetModifierAura()
	return "lua_modifier_vagabond_prismatic_mist_slow"
end


function lua_modifier_vagabond_prismatic_mist_slow_aura:GetAuraRadius()
	return self:GetAbility():GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster())
end


function lua_modifier_vagabond_prismatic_mist_slow_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end



function lua_modifier_vagabond_prismatic_mist_slow_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end



function lua_modifier_vagabond_prismatic_mist_slow_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end






lua_modifier_vagabond_prismatic_mist_slow = class({})

function lua_modifier_vagabond_prismatic_mist_slow:IsPurgable()	return false end

function lua_modifier_vagabond_prismatic_mist_slow:RemoveOnDeath()	return true end

function lua_modifier_vagabond_prismatic_mist_slow:IsPurgeException() return false end

function lua_modifier_vagabond_prismatic_mist_slow:IsHidden() return false end

function lua_modifier_vagabond_prismatic_mist_slow:DeclareFunctions()
	local dfucs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAG,
		MODIFIER_PROPERTY_TOOLTIP
	}
	return dfucs
end


function lua_modifier_vagabond_prismatic_mist_slow:OnCreated(kv)
	local scepter = self:GetCaster():HasScepter()

	if scepter == false then return end

	if not self.particle == false then return end

	self.particle = ParticleManager:CreateParticle(
		"particles/generic_gameplay/generic_silenced.vpcf",
		PATTACH_OVERHEAD_FOLLOW,
		self:GetParent()
	)

	ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle,60,Vector(255,0,0))
	ParticleManager:SetParticleControl(self.particle,61,Vector(1,0,0))


end


function lua_modifier_vagabond_prismatic_mist_slow:OnRefresh(kv)
	self:OnCreated(kv)
end



function lua_modifier_vagabond_prismatic_mist_slow:CheckState()
	local scepter = self:GetCaster():HasScepter()
	local cstate = {
		[MODIFIER_STATE_SILENCED] = scepter,
		[MODIFIER_STATE_MUTED] = scepter
	}
	return cstate
end


function lua_modifier_vagabond_prismatic_mist_slow:GetModifierMoveSpeedBonus_Percentage()
	return -(self:GetAbility():GetSpecialValueFor("ms_slow"))
end



function lua_modifier_vagabond_prismatic_mist_slow:OnDestroy()
	if not self.particle then return end

	ParticleManager:DestroyParticle(self.particle,false)
	ParticleManager:ReleaseParticleIndex(self.particle)
end



-----------------------------------------------------------
-- Thinker Particle
------------------------------------------------------------

lua_modifier_vagabond_prismatic_mist_particle_thinker = class({})

function lua_modifier_vagabond_prismatic_mist_particle_thinker:IsPurgable()	return false end

function lua_modifier_vagabond_prismatic_mist_particle_thinker:IsPurgeException() return false end

function lua_modifier_vagabond_prismatic_mist_particle_thinker:IsHidden() return true end


function lua_modifier_vagabond_prismatic_mist_particle_thinker:OnCreated(kv)

	self.mist_particle = ParticleManager:CreateParticle(
		"particles/units/heroes/vagabond/ability_1/prismatic_mist.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self:GetParent()
	)

	ParticleManager:SetParticleControlEnt(
		self.mist_particle,
		1, self:GetParent(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetAbsOrigin(),
		true
	)

	self:StartIntervalThink(FrameTime())
end


function lua_modifier_vagabond_prismatic_mist_particle_thinker:OnIntervalThink()
	if IsServer() == false then return end
	self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin())

end

function lua_modifier_vagabond_prismatic_mist_particle_thinker:OnDestroy()
	self:StartIntervalThink(-1)
	ParticleManager:DestroyParticle(self.mist_particle,true)
	ParticleManager:ReleaseParticleIndex(self.mist_particle)
	UTIL_Remove(self.parent)
end
