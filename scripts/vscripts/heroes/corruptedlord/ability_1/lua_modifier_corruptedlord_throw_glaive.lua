LinkLuaModifier( "lua_modifier_corruptedlord_throw_glaive_attack", "heroes/corruptedlord/ability_1/lua_modifier_corruptedlord_throw_glaive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_corruptedlord_throw_glaive_slow", "heroes/corruptedlord/ability_1/lua_modifier_corruptedlord_throw_glaive", LUA_MODIFIER_MOTION_NONE )

lua_modifier_corruptedlord_throw_glaive_thinker = class({})



function lua_modifier_corruptedlord_throw_glaive_thinker:IsHidden()return true end



function lua_modifier_corruptedlord_throw_glaive_thinker:IsPurgable() return false end



function lua_modifier_corruptedlord_throw_glaive_thinker:IsPurgeException() return false end



function lua_modifier_corruptedlord_throw_glaive_thinker:OnCreated( kv )

    if not IsServer() then return end

    self.parent = self:GetParent()
	self.cursorPt = Vector( kv.target_x, kv.target_y, kv.target_z )
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.teamNum = self.caster:GetTeamNumber()

	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" )
	self.projectile_speed = self.ability:GetSpecialValueFor( "projectile_speed" )
	self.projectile_aoe = self.ability:GetSpecialValueFor( "projectile_aoe" )
	self.ability_range = self.ability:GetCastRange(self.caster:GetAbsOrigin(),self.caster)


	self.target_team = self.ability:GetAbilityTargetTeam()
	self.target_type = self.ability:GetAbilityTargetType()
	self.target_flags = self.ability:GetAbilityTargetFlags()
	self.damage_type = self.ability:GetAbilityDamageType()


    self.move_direction = self.cursorPt - self.caster:GetAbsOrigin()
    self.move_direction = self.move_direction:Normalized()
	self.move_direction.z = 0

	self.total_range = 0.0

	self.is_returning = 0

	self.victim_table = {}

	self.blink_q = self.caster:FindAbilityByName("lua_ability_corruptedlord_throw_glaive_blink")

    self.projectile_particle = ParticleManager:CreateParticle("particles/units/heroes/corrupted_lord/ability_1/corrupted_lord_ability_1.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.parent)
	local place_particle = self.parent:GetAbsOrigin()
	ParticleManager:SetParticleControl(self.projectile_particle, 0, place_particle)
	ParticleManager:SetParticleControl(self.projectile_particle, 5, Vector(160,1,1))
	self:change_color_based_on_duality()

    self:StartIntervalThink(FrameTime())
	self:OnIntervalThink()
end



function lua_modifier_corruptedlord_throw_glaive_thinker:OnIntervalThink()
	if not IsServer() then return end

    local weapon_moving = self.parent:GetAbsOrigin()
	local ms_fps = self.projectile_speed*FrameTime()
	local effect_height = 75
	self:change_color_based_on_duality()

	if self.caster:IsAlive() == false then
		self:OnDestroy()
		return
	end


	if self.is_returning == 0 then

	    weapon_moving = weapon_moving + (self.move_direction*ms_fps)
		weapon_moving = GetGroundPosition(weapon_moving,self.caster)
		weapon_moving.z = weapon_moving.z+effect_height

	    self.parent:SetAbsOrigin(weapon_moving)

		--debug
		--DebugDrawCircle(weapon_moving,Vector(255,0,0),0.5,self.projectile_aoe,true,FrameTime())
		AddFOWViewer(self.teamNum,weapon_moving,self.projectile_aoe,0.25,false)

		self.total_range = self.total_range + ms_fps


		if self.total_range >= self.ability_range then
			self.is_returning = 1
		end

	elseif self.is_returning == 1 then

		local return_distance = self.caster:GetAbsOrigin() - weapon_moving
		local return_direction = return_distance:Normalized()

		local return_movement = return_direction*ms_fps
		weapon_moving = weapon_moving + return_movement
		weapon_moving = GetGroundPosition(weapon_moving,self.caster)
		weapon_moving.z = weapon_moving.z+effect_height

		self.parent:SetAbsOrigin(weapon_moving)


		if return_distance:Length2D() <= ms_fps*2 then
			self.is_returning = -1
			weapon_moving = self.caster:GetAbsOrigin()
			weapon_moving = GetGroundPosition(weapon_moving,self.caster)
			weapon_moving.z = weapon_moving.z+effect_height
			self.parent:SetAbsOrigin(weapon_moving)
		end

		--DebugDrawCircle(weapon_moving,Vector(255,0,0),0.5,self.projectile_aoe,true,FrameTime())
		AddFOWViewer(self.teamNum,weapon_moving,self.projectile_aoe,0.25,false)

		if self.is_returning == -1 then
			self:Destroy()
			return
		end
	end


	local enemies = FindUnitsInRadius(
		self.teamNum,
		weapon_moving,
		nil,
		self.projectile_aoe,
		self.target_team,
		self.target_type,
		self.target_flags,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do

		if not self.victim_table[enemy] then
			self.victim_table[enemy] = true
			self:apply_ability_damage_and_effect(enemy)
		end

	end


end



function lua_modifier_corruptedlord_throw_glaive_thinker:apply_ability_damage_and_effect(enemy)

	if not IsServer() then return end

    if (enemy:IsNull() == true) or (enemy:IsAlive() == false) or (IsValidEntity(enemy) == false) then return end

	local modifier = self.caster:AddNewModifier(
		self.caster,
		self.ability,
		"lua_modifier_corruptedlord_throw_glaive_attack",
		{}
	)

	self:GetCaster():PerformAttack (
		enemy,
		true,
		true,
		true,
		false,
		false,
		false,
		true
	)

	modifier:Destroy()

	if enemy:IsMagicImmune() == true then return end

	enemy:AddNewModifier(
		self.caster,
		self.ability, -- ability source
		"lua_modifier_corruptedlord_throw_glaive_slow", -- modifier name
		{duration = self.slow_duration}
	)
end



function lua_modifier_corruptedlord_throw_glaive_thinker:OnDestroy()
	if not IsServer() then return end

	self.blink_q = self.caster:FindAbilityByName("lua_ability_corruptedlord_throw_glaive_blink")

	if not self.blink_q == false then
		if self.blink_q.modifier == self then
			self.blink_q:SetActivated(false)
		end
	end

	ParticleManager:DestroyParticle(self.projectile_particle, false)
	ParticleManager:ReleaseParticleIndex(self.projectile_particle)
	UTIL_Remove(self.parent)
end



function lua_modifier_corruptedlord_throw_glaive_thinker:change_color_based_on_duality()
	local chaos = self.caster:HasModifier("lua_modifier_corruptedlord_duality_chaos")
	local solace = self.caster:HasModifier("lua_modifier_corruptedlord_duality_solace")
	self.duality_color = Vector(0,255,255)

	if chaos == true then
		self.duality_color = Vector(255,0,0)
	end
	if solace == true then
		self.duality_color = Vector(0,255,0)
	end

	ParticleManager:SetParticleControl(self.projectile_particle, 60, self.duality_color)
end







---------------------------------------------
--ATTACK DAMAGE
---------------------------------------------

lua_modifier_corruptedlord_throw_glaive_attack = class({})



function lua_modifier_corruptedlord_throw_glaive_attack:IsHidden() return true end



function lua_modifier_corruptedlord_throw_glaive_attack:IsPurgable() return false end



function lua_modifier_corruptedlord_throw_glaive_attack:OnCreated( kv )
	-- references
	self.base_ability_damage = self:GetAbility():GetSpecialValueFor( "base_ability_damage" )
	self.attack_factor = self:GetAbility():GetSpecialValueFor( "attack_factor" )
end



function lua_modifier_corruptedlord_throw_glaive_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end




function lua_modifier_corruptedlord_throw_glaive_attack:GetModifierPreAttack_BonusDamage( params )
	if IsServer() then
        local caster = self:GetCaster()
        local no_shard = 1
        if caster:HasModifier("modifier_item_aghanims_shard") == false then
            no_shard = 0
        end

		local attack_damage = caster:GetAttackDamage()
        local percentage = (100-self.attack_factor)*0.01
        local new_damage = self.base_ability_damage - (attack_damage*percentage*no_shard)

		return new_damage
	end
end








---------------------------------------------
--SLOW EFFECT
---------------------------------------------

lua_modifier_corruptedlord_throw_glaive_slow = class({})



function lua_modifier_corruptedlord_throw_glaive_slow:IsHidden() return false end



function lua_modifier_corruptedlord_throw_glaive_slow:IsDebuff() return true end



function lua_modifier_corruptedlord_throw_glaive_slow:IsPurgable() return true end



function lua_modifier_corruptedlord_throw_glaive_slow:OnCreated( kv )
	-- references
	self.ability_slow = self:GetAbility():GetSpecialValueFor( "ability_slow" ) -- special value
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" ) -- special value
	self.max_duration = kv.duration
	self.current_duration = self.max_duration
	self:StartIntervalThink(FrameTime())
end



function lua_modifier_corruptedlord_throw_glaive_slow:OnRefresh( kv )
	-- references
    self.ability_slow = self:GetAbility():GetSpecialValueFor( "ability_slow" ) -- special value
	self.slow_duration = self:GetAbility():GetSpecialValueFor( "slow_duration" ) -- special value
	self.max_duration = kv.duration
	self.current_duration = self.max_duration
	self:StartIntervalThink(FrameTime())
end



function lua_modifier_corruptedlord_throw_glaive_slow:OnDestroy( kv )
end



function lua_modifier_corruptedlord_throw_glaive_slow:OnIntervalThink()
	self.current_duration = self.current_duration-FrameTime()

	if self.current_duration <= 0.0 then
		self.current_duration = 0.0
		self:StartIntervalThink( -1 )
	end
end



function lua_modifier_corruptedlord_throw_glaive_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end



function lua_modifier_corruptedlord_throw_glaive_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ability_slow * (self.current_duration/self.max_duration)
end



function lua_modifier_corruptedlord_throw_glaive_slow:GetStatusEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end
