LinkLuaModifier( "lua_modifier_whistlepunk_rockets_stacks", "heroes/whistlepunk/ability_1/lua_modifier_whistlepunk_rockets", LUA_MODIFIER_MOTION_NONE )


lua_ability_whistlepunk_rockets = class({})




function lua_ability_whistlepunk_rockets:IsHiddenWhenStolen()
    return true
end




function lua_ability_whistlepunk_rockets:OnUnStolen()
    local find_stacks = self:GetCaster():FindModifierByName("lua_modifier_whistlepunk_rockets_stacks")
    if not find_stacks == false then
        find_stacks:Destroy()
    end
end




function lua_ability_whistlepunk_rockets:GetCastRange(location,target)
    if not self:GetCaster() then return 0 end

    local range = self:GetSpecialValueFor("cast_range")

    local shard_mod = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard_mod == true then
        range = self:GetSpecialValueFor("cast_range")+self:GetSpecialValueFor("shard_add_range")
    end

    return range
end




function lua_ability_whistlepunk_rockets:OnUpgrade()

    self.caster = self:GetCaster()
    self.rocket_stacks = self:GetSpecialValueFor("rocket_stacks")
    --self.rocket_cooldown = self:GetSpecialValueFor("rocket_cooldown")
    self.rocket_max_range_damage_percent = self:GetSpecialValueFor("rocket_max_range_damage_percent")
    self.rocket_add_damage_range = self:GetSpecialValueFor("rocket_add_damage_range")
    self.rocket_damage = self:GetSpecialValueFor("rocket_damage")
    self.rocket_aoe = self:GetSpecialValueFor("rocket_aoe")
    self.rocket_speed = self:GetSpecialValueFor("rocket_speed")
    --self.ability_range = self:GetCastRange(self.caster:GetAbsOrigin(),self.caster)
    self.stun_duration = self:GetSpecialValueFor("stun_duration")
    self.rocket_explode_vision = self:GetSpecialValueFor("rocket_explode_vision")

    self.shard_explode_aoe_damage = self:GetSpecialValueFor("shard_explode_aoe_damage")
    --self.shard_add_range = self:GetSpecialValueFor("shard_add_range")


    if not self.ability_stacks then
        self.ability_stacks = self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_whistlepunk_rockets_stacks",
            {}
        )
    else
        self.ability_stacks.max_count = self.rocket_stacks
        self.ability_stacks:IncrementStackCount()
    end
end




function lua_ability_whistlepunk_rockets:OnSpellStart()
    if not IsServer() then return end

    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then return end

    local direction = (self:GetCursorPosition() - self.caster:GetAbsOrigin()):Normalized()
    local shard_mod = self.caster:HasModifier("modifier_item_aghanims_shard")
    local shard_up = 0
    if shard_mod == true then
        shard_up = 1
    end

    -- Fire arrow in the set direction
	local projectile_table = {
		Ability = self,
		EffectName = "particles/units/heroes/whisltepunk/ability_1/whistlepunk_rockets.vpcf",
		vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
		fDistance = self:GetCastRange(self:GetCaster():GetAbsOrigin(),self:GetCaster()),
		fStartRadius = self.rocket_aoe,
		fEndRadius = self.rocket_aoe,
		Source = self.caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		vVelocity = direction * self.rocket_speed * Vector(1, 1, 0),
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bProvidesVision = true,
		iVisionRadius = self.rocket_aoe,
		iVisionTeamNumber = self.caster:GetTeamNumber(),
        ExtraData = {
            ox = tostring(self.caster:GetAbsOrigin().x),
            oy = tostring(self.caster:GetAbsOrigin().y),
            oz = tostring(self.caster:GetAbsOrigin().z)
        }
	}

	self.rocket_projectile = ProjectileManager:CreateLinearProjectile(projectile_table)
    self.caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile")

end




function lua_ability_whistlepunk_rockets:OnProjectileHit_ExtraData(target,location,extradata)

    if not IsServer() then return false end

    if not target then return false end

    local origin_position = Vector(tonumber(extradata.ox),tonumber(extradata.oy),tonumber(extradata.oz))

    local diff_distance = (location - origin_position)*Vector(1,1,0)
    diff_distance = diff_distance:Length2D()

    local is_additional_damage = math.max(0,diff_distance - self.rocket_add_damage_range)

    if is_additional_damage > 0 then
        if target:GetName() == "npc_dota_roshan" then
            is_additional_damage = 0
        else
            is_additional_damage = 1
        end
    end

    local new_damage = self.rocket_damage + (target:GetMaxHealth()*is_additional_damage*self.rocket_max_range_damage_percent*0.01)

    local explode_particle = ParticleManager:CreateParticle(
        "particles/units/heroes/whisltepunk/ability_1/rocket_trail_explosion.vpcf",
        PATTACH_ABSORIGIN,
        target
    )
    ParticleManager:SetParticleControl(explode_particle,3,target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(explode_particle)

    AddFOWViewer(self.caster:GetTeamNumber(),location,self.rocket_explode_vision,1.5,false)

    EmitSoundOnLocationWithCaster(location,"Hero_Tinker.Heat-Seeking_Missile.Impact",self.caster)


    local shard_mod = self.caster:HasModifier("modifier_item_aghanims_shard")
    if shard_mod == false then
        if target:IsMagicImmune() == false then
            local damageTable = {
                victim = target,
        		damage = new_damage,
        		damage_type = DAMAGE_TYPE_MAGICAL,
        		attacker = self.caster,
        		ability = self
        	}

            ApplyDamage(damageTable)
            target:AddNewModifier(self.caster,self,"modifier_stunned", {duration = self.stun_duration})
        end

    else

        local enemies = FindUnitsInRadius(
    		self.caster:GetTeamNumber(),
    		target:GetAbsOrigin(),
    		nil,
    		self.shard_explode_aoe_damage,
    		DOTA_UNIT_TARGET_TEAM_ENEMY,
    		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    		DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
    	)

    	for _,enemy in pairs(enemies) do
            local damageTable = {
                victim = enemy,
        		damage = new_damage,
        		damage_type = DAMAGE_TYPE_MAGICAL,
        		attacker = self.caster,
        		ability = self
        	}

            ApplyDamage(damageTable)
            enemy:AddNewModifier(self.caster,self,"modifier_stunned", {duration = self.stun_duration})
    	end
    end

    --[[
    local modifiers = target:FindAllModifiers()
    for _,mod in pairs(modifiers) do
        print(mod:GetName())
    end]]

    --[[
    for skill = 0,10,1 do
        print(target:GetAbilityByIndex(skill):GetName())
    end]]

    return true
end
