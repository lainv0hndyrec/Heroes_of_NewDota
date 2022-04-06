LinkLuaModifier( "lua_modifier_corruptedlord_unleashed_transform_demon", "heroes/corruptedlord/ability_4/lua_modifier_corruptedlord_unleashed", LUA_MODIFIER_MOTION_NONE )

-------------------------------------
--Transformation animation
-------------------------------------
lua_modifier_corruptedlord_unleashed_transform_animation = class({})



function lua_modifier_corruptedlord_unleashed_transform_animation:IsHidden() return true end



function lua_modifier_corruptedlord_unleashed_transform_animation:IsPurgable() return false end



function lua_modifier_corruptedlord_unleashed_transform_animation:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end



function lua_modifier_corruptedlord_unleashed_transform_animation:OnCreated()

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
	self.duration = self.ability:GetSpecialValueFor("ult_duration")

	local transform_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self.caster
    )

	ParticleManager:ReleaseParticleIndex(transform_particle)
end



function lua_modifier_corruptedlord_unleashed_transform_animation:OnDestroy()

    if not IsServer() then return end

    self.caster:AddNewModifier(
        self.caster,
        self.ability,
        "lua_modifier_corruptedlord_unleashed_transform_demon",
        {duration = self.duration}
    )
end





-------------------------------------
--Transformation effects
-------------------------------------
lua_modifier_corruptedlord_unleashed_transform_demon = class({})



function lua_modifier_corruptedlord_unleashed_transform_demon:IsPurgable() return false end

function lua_modifier_corruptedlord_unleashed_transform_demon:IsPurgeException() return false end

function lua_modifier_corruptedlord_unleashed_transform_demon:AllowIllusionDuplicate() return true end


function lua_modifier_corruptedlord_unleashed_transform_demon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_PROJECTILE_NAME,

		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,

		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end



function lua_modifier_corruptedlord_unleashed_transform_demon:OnCreated()

    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

	self.attack_range 	= self.ability:GetSpecialValueFor("attack_range")
	self.attack_aoe		= self.ability:GetSpecialValueFor("attack_aoe")
    self.aoe_damage_scale = self.ability:GetSpecialValueFor("aoe_damage_scale")
	self.tapering_armor = self.ability:GetSpecialValueFor("tapering_armor")


	self.current_tapering_armor = self.tapering_armor

	local talent = self.caster:FindAbilityByName("special_bonus_corruptedlord_unleashed_armor_duration")
    local arm_dur_val = self.ability:GetSpecialValueFor("talent_max_armor_duration")
    if not talent == false then
        if talent:GetLevel() > 0 then
			arm_dur_val = arm_dur_val+talent:GetSpecialValueFor("value")
		end
	end

	self.max_armor_duration = arm_dur_val - 2.0
	self.armor_duration = arm_dur_val
	self.interval = 0.20
	self:StartIntervalThink(self.interval)

	if not IsServer() then return end

	self.original_attack_type = self:GetParent():GetAttackCapability()
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

end



function lua_modifier_corruptedlord_unleashed_transform_demon:OnRefresh(table)
	self.caster = self:GetCaster()
    self.ability = self:GetAbility()

	self.attack_range 	= self.ability:GetSpecialValueFor("attack_range")
	self.attack_aoe		= self.ability:GetSpecialValueFor("attack_aoe")
    self.aoe_damage_scale = self.ability:GetSpecialValueFor("aoe_damage_scale")
	self.tapering_armor = self.ability:GetSpecialValueFor("tapering_armor")

	self.current_tapering_armor = self.tapering_armor

	local talent = self.caster:FindAbilityByName("special_bonus_corruptedlord_unleashed_armor_duration")
    local arm_dur_val = self.ability:GetSpecialValueFor("talent_max_armor_duration")
    if not talent == false then
        if talent:GetLevel() > 0 then
			arm_dur_val = arm_dur_val+talent:GetSpecialValueFor("value")
		end
	end

	self.max_armor_duration = arm_dur_val - 2.0
	self.armor_duration = arm_dur_val
	self.interval = 0.20
	self:StartIntervalThink(self.interval)

	if not IsServer() then return end
	self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end



function lua_modifier_corruptedlord_unleashed_transform_demon:OnIntervalThink()

	if self.armor_duration <= 0.0 then
		self:StartIntervalThink(-1)
		return
	end

	self.armor_duration = self.armor_duration-self.interval
	self.current_tapering_armor = self.tapering_armor * math.min(1.0,self.armor_duration/self.max_armor_duration)

end



function lua_modifier_corruptedlord_unleashed_transform_demon:OnDestroy()
	if not IsServer() then return end

	self.caster:StartGesture(ACT_DOTA_CAST_ABILITY_3_END)

	self.caster:SetAttackCapability(self.original_attack_type)
end



function lua_modifier_corruptedlord_unleashed_transform_demon:GetModifierModelChange()
	return "models/heroes/terrorblade/demon.vmdl"
end



function lua_modifier_corruptedlord_unleashed_transform_demon:GetModifierProjectileName()
	return "particles/units/heroes/corrupted_lord/ability_4/corrupted_lord_demon_projectile.vpcf"
end



function lua_modifier_corruptedlord_unleashed_transform_demon:OnAttackStart(keys)
	if keys.attacker:IsAlive() == false then return end
	if keys.attacker ~= self.caster then return end
	self.caster:EmitSound("Hero_Terrorblade_Morphed.preAttack")
end



function lua_modifier_corruptedlord_unleashed_transform_demon:OnAttack(keys)
	if keys.attacker:IsAlive() == false then return end
	if keys.attacker ~= self.caster then return end
    self.caster:EmitSound("Hero_Terrorblade_Morphed.Attack")
end



function lua_modifier_corruptedlord_unleashed_transform_demon:OnAttackLanded(keys)
	--if keys.attacker:IsAlive() == false then return end
	if keys.attacker ~= self.caster then return end

	--DebugDrawCircle(keys.target:GetAbsOrigin(),Vector(255,0,0),1,self.attack_aoe,false,0.5)

    if not IsServer() then return end

	self.caster:EmitSound("Hero_Terrorblade_Morphed.projectileImpact")

    local range_scaled_damage = keys.damage*self.aoe_damage_scale*0.01

    local damaged_enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        keys.target:GetAbsOrigin(),
        nil,
        self.attack_aoe,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    for _,enemy in pairs(damaged_enemies) do
		if (enemy:IsNull() == false) and (enemy:IsAlive() == true) and (IsValidEntity(enemy) == true) then
	        if keys.target ~= enemy then
	            local damage_table = {
	                victim = enemy,
	                attacker = self.caster,
	                damage = range_scaled_damage,
	                damage_type = DAMAGE_TYPE_PHYSICAL,
	                damage_flags = DOTA_DAMAGE_FLAG_NONE,
	                ability = self.ability
	            }
	            ApplyDamage(damage_table)
	        end
		end
	end
end



function lua_modifier_corruptedlord_unleashed_transform_demon:GetModifierAttackRangeOverride()
	return self.attack_range
end




function lua_modifier_corruptedlord_unleashed_transform_demon:GetModifierPhysicalArmorBonus(keys)
	return self.current_tapering_armor
end
