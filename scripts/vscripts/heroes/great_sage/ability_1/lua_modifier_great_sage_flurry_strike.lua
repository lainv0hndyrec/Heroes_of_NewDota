LinkLuaModifier( "lua_modifier_great_sage_flurry_strike_timer", "heroes/great_sage/ability_1/lua_modifier_great_sage_flurry_strike", LUA_MODIFIER_MOTION_NONE )

lua_modifier_great_sage_flurry_strike_timer = class({})

function lua_modifier_great_sage_flurry_strike_timer:IsHidden() return false end
function lua_modifier_great_sage_flurry_strike_timer:IsDebuff() return false end
function lua_modifier_great_sage_flurry_strike_timer:IsPurgable() return false end
function lua_modifier_great_sage_flurry_strike_timer:IsPurgeException() return false end



function lua_modifier_great_sage_flurry_strike_timer:OnDestroy()
    if not IsServer() then return end

    local ability = self:GetAbility()

    local cd = ability:GetEffectiveCooldown(ability:GetLevel()-1)
    ability:StartCooldown(cd)
end












lua_modifier_great_sage_flurry_strike_dash = class({})

function lua_modifier_great_sage_flurry_strike_dash:IsHidden() return true end
function lua_modifier_great_sage_flurry_strike_dash:IsDebuff() return false end
function lua_modifier_great_sage_flurry_strike_dash:IsPurgable() return false end
function lua_modifier_great_sage_flurry_strike_dash:IsPurgeException() return false end



function lua_modifier_great_sage_flurry_strike_dash:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end




function lua_modifier_great_sage_flurry_strike_dash:GetModifierPreAttack_BonusDamage()
    return self.bonus_attack_damage
end




function lua_modifier_great_sage_flurry_strike_dash:CheckState()
    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION]  = true,
        [MODIFIER_STATE_STUNNED] = true
    }
    return cstate
end




function lua_modifier_great_sage_flurry_strike_dash:OnCreated(kv)

    self.effect_distance = self:GetAbility():GetSpecialValueFor("flurry_range")
    self.flurry_radius = self:GetAbility():GetSpecialValueFor("flurry_radius")

    local dmg = self:GetAbility():GetSpecialValueFor("bonus_attack_damage")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_great_sage_flurry_strike_damage")
    if not talent == false then
        if talent:GetLevel() > 0 then
            dmg = dmg + talent:GetSpecialValueFor("value")
        end
    end

    self.bonus_attack_damage = dmg

    self.damaged_units = {}

    if not IsServer() then return end

    if not kv.additional_dash then self:Destroy() return end
    if not kv.duration then self:Destroy() return end

    ProjectileManager:ProjectileDodge(self:GetParent())

    self:GetParent():EmitSound("Hero_MonkeyKing.Strike.Cast")

    self.direction = self:GetParent():GetForwardVector()

    self.duration = kv.duration

    self.additional_dash = kv.additional_dash

    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_STATUE,4.0)

    if self:ApplyHorizontalMotionController() then return end

	self:Destroy()
end




function lua_modifier_great_sage_flurry_strike_dash:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local speed = (dt/self.duration) * self.effect_distance

    self:PerformAttackAroundYou()

    local current_pos = self:GetParent():GetAbsOrigin()

    local new_pos = current_pos + (self.direction*speed)
    local ground_pos = GetGroundPosition(new_pos, self:GetParent())

    GridNav:DestroyTreesAroundPoint(ground_pos,self.flurry_radius,false)

    if GridNav:IsTraversable(ground_pos) then
        self:GetParent():SetAbsOrigin(ground_pos)
    end


    local particle = ParticleManager:CreateParticle("particles/units/heroes/great_sage/ability_1/image_trail.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, current_pos)
    ParticleManager:SetParticleControl(particle, 1, ground_pos)
    ParticleManager:SetParticleControlEnt(particle, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,RandomInt(0,360),0), true)
    ParticleManager:DestroyParticle(particle,false)


    -- ParticleManager:SetParticleControlEnt(particle,0,self:GetParent(),PATTACH_ABSORIGIN,attach_origin,self:GetParent():GetAbsOrigin(),false)
    -- ParticleManager:SetParticleControlEnt(particle,1,self:GetParent(),PATTACH_ABSORIGIN,attach_origin,self:GetParent():GetAbsOrigin(),false)

    --set the position
    -- if ground_pos.z > -16 and ground_pos.z <= 550 then
    --     self:GetParent():SetAbsOrigin(ground_pos)
    -- end

    --remove trees
    -- local hull = self:GetParent():GetHullRadius()*4
    -- GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(),hull,false)
end




function lua_modifier_great_sage_flurry_strike_dash:OnHorizontalMotionInterrupted()
    self:Destroy()
end




function lua_modifier_great_sage_flurry_strike_dash:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController(self)
end



function lua_modifier_great_sage_flurry_strike_dash:PerformAttackAroundYou()

    local free_dash = false

    local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		self:GetParent():GetAbsOrigin(),
		nil,
		self.flurry_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false
	)

	for _,enemy in pairs(enemies) do

		if not self.damaged_units[enemy] then
			self.damaged_units[enemy] = true
            free_dash = true
			self:GetParent():PerformAttack (
        		enemy,
        		true,
        		true,
        		true,
        		false,
        		false,
        		false,
        		true
        	)
		end
	end


    if free_dash == false then return end

    if self.additional_dash == 0 then return end

    self.additional_dash = 0


    local free_cast_dur = self:GetAbility():GetSpecialValueFor("additional_cast_duration")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_great_sage_flurry_strike_freecast_duration")
    if not talent == false then
        if talent:GetLevel() > 0 then
            free_cast_dur = free_cast_dur + talent:GetSpecialValueFor("value")
        end
    end


    self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self:GetAbility(),
        "lua_modifier_great_sage_flurry_strike_timer",
        {duration = free_cast_dur}
    )

    self:GetAbility():EndCooldown()
    self:GetAbility():StartCooldown(0.2)

end
