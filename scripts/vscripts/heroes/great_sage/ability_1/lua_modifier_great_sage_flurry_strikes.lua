LinkLuaModifier( "lua_modifier_great_sage_flurry_strikes_timer", "heroes/great_sage/ability_1/lua_modifier_great_sage_flurry_strikes", LUA_MODIFIER_MOTION_NONE )

lua_modifier_great_sage_flurry_strikes_timer = class({})

function lua_modifier_great_sage_flurry_strikes_timer:IsHidden() return false end
function lua_modifier_great_sage_flurry_strikes_timer:IsDebuff() return false end
function lua_modifier_great_sage_flurry_strikes_timer:IsPurgable() return false end
function lua_modifier_great_sage_flurry_strikes_timer:IsPurgeException() return false end



function lua_modifier_great_sage_flurry_strikes_timer:OnDestroy()
    if not IsServer() then return end

    local ability = self:GetAbility()

    local cd = ability:GetEffectiveCooldown(ability:GetLevel()-1)
    ability:StartCooldown(cd)
end








----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------


lua_modifier_great_sage_flurry_strikes_zoomies = class({})

function lua_modifier_great_sage_flurry_strikes_zoomies:IsHidden() return true end
function lua_modifier_great_sage_flurry_strikes_zoomies:IsDebuff() return false end
function lua_modifier_great_sage_flurry_strikes_zoomies:IsPurgable() return false end
function lua_modifier_great_sage_flurry_strikes_zoomies:IsPurgeException() return false end


function lua_modifier_great_sage_flurry_strikes_zoomies:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end


function lua_modifier_great_sage_flurry_strikes_zoomies:GetModifierPreAttack_BonusDamage()

    local dmg = self:GetAbility():GetSpecialValueFor("bonus_attack_damage")
    local talent = self:GetParent():FindAbilityByName("special_bonus_great_sage_flurry_strikes_damage")
    if not talent == false then
        if talent:GetLevel() > 0 then
            dmg = dmg + talent:GetSpecialValueFor("value")
        end
    end

    return dmg
end




function lua_modifier_great_sage_flurry_strikes_zoomies:CheckState()
    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_STUNNED] = true
    }
    return cstate
end




function lua_modifier_great_sage_flurry_strikes_zoomies:OnCreated(kv)

    if not IsServer() then return end

    self.effect_distance = self:GetAbility():GetSpecialValueFor("flurry_range")
    self.flurry_radius = self:GetAbility():GetSpecialValueFor("flurry_radius")
    self.flurry_speed = self:GetAbility():GetSpecialValueFor("flurry_speed")
    self.damaged_units = {}

    local id = self:GetParent():GetPlayerID()
    GameRules:SendCustomMessage("on created initiated",id,id)

    ProjectileManager:ProjectileDodge(self:GetParent())

    self:GetParent():EmitSound("Hero_MonkeyKing.Strike.Cast")

    self.direction = self:GetParent():GetForwardVector()

    self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_STATUE,4.0)

    local id = self:GetParent():GetPlayerID()
    GameRules:SendCustomMessage("kv additional_dash existed",id,id)


    if self:ApplyHorizontalMotionController() == false then
        local id = self:GetParent():GetPlayerID()
        GameRules:SendCustomMessage("motion controller failed",id,id)
	    self:Destroy()
    end
end




function lua_modifier_great_sage_flurry_strikes_zoomies:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local speed = self.flurry_speed*dt

    local id = self:GetParent():GetPlayerID()
    GameRules:SendCustomMessage("motion controller good",id,id)

    local current_pos = me:GetAbsOrigin()

    self.effect_distance = self.effect_distance - speed
    if self.effect_distance <= 0 then
        speed = speed + self.effect_distance
    end

    local new_pos = current_pos + (self.direction*speed)
    local ground_pos = GetGroundPosition(new_pos, me)

    GridNav:DestroyTreesAroundPoint(ground_pos,self.flurry_radius,false)

    if GridNav:IsTraversable(ground_pos) then
        me:SetAbsOrigin(ground_pos)
    end

    self:PerformAttackAroundYou()

    local particle = ParticleManager:CreateParticle("particles/units/heroes/great_sage/ability_1/image_trail.vpcf", PATTACH_ABSORIGIN, me)
    ParticleManager:SetParticleControl(particle, 0, current_pos)
    ParticleManager:SetParticleControl(particle, 1, ground_pos)
    ParticleManager:SetParticleControlEnt(particle, 2, me, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,RandomInt(0,360),0), true)
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)


    if self.effect_distance <= 0 then
        self:Destroy()
    end
end




function lua_modifier_great_sage_flurry_strikes_zoomies:OnHorizontalMotionInterrupted()
    local id = self:GetParent():GetPlayerID()
    GameRules:SendCustomMessage("motion controller interrupted",id,id)
    self:Destroy()
end




function lua_modifier_great_sage_flurry_strikes_zoomies:OnDestroy()
    if not IsServer() then return end
    local id = self:GetParent():GetPlayerID()
    GameRules:SendCustomMessage("buff destroyed",id,id)
    self:GetParent():RemoveHorizontalMotionController(self)
end



function lua_modifier_great_sage_flurry_strikes_zoomies:PerformAttackAroundYou()
    if not IsServer() then return end

    local id = self:GetParent():GetPlayerID()
    GameRules:SendCustomMessage("performing attack",id,id)

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

    if self:GetStackCount() <= 0 then return end

    self:SetStackCount(0)

    local free_cast_dur = self:GetAbility():GetSpecialValueFor("additional_cast_duration")
    local talent = self:GetParent():FindAbilityByName("special_bonus_great_sage_flurry_strikes_freecast_duration")
    if not talent == false then
        if talent:GetLevel() > 0 then
            free_cast_dur = free_cast_dur + talent:GetSpecialValueFor("value")
        end
    end

    self:GetParent():AddNewModifier(
        self:GetParent(),
        self:GetAbility(),
        "lua_modifier_great_sage_flurry_strikes_timer",
        {duration = free_cast_dur}
    )

    self:GetAbility():EndCooldown()
    self:GetAbility():StartCooldown(0.2)

end
