lua_modifier_unfathomed_yield_damage = class({})


function lua_modifier_unfathomed_yield_damage:IsHidden() return true end
function lua_modifier_unfathomed_yield_damage:IsDebuff() return false end
function lua_modifier_unfathomed_yield_damage:IsPurgable() return false end
function lua_modifier_unfathomed_yield_damage:IsPurgeException() return false end
function lua_modifier_unfathomed_yield_damage:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end




function lua_modifier_unfathomed_yield_damage:OnCreated(kv)
    local strength = self:GetParent():GetStrength()
    local percent_damage = self:GetAbility():GetSpecialValueFor("str_damage")*0.01
    self.damage = percent_damage*strength
end



function lua_modifier_unfathomed_yield_damage:GetModifierPreAttack_BonusDamage()
    return self.damage
end











lua_modifier_unfathomed_yield_motion = class({})

function lua_modifier_unfathomed_yield_motion:IsHidden() return true end
function lua_modifier_unfathomed_yield_motion:IsDebuff() return false end
function lua_modifier_unfathomed_yield_motion:IsPurgable() return false end
function lua_modifier_unfathomed_yield_motion:IsPurgeException() return false end





function lua_modifier_unfathomed_yield_motion:OnCreated(kv)
    if not IsServer() then return end

    if not kv.duration then self:Destroy() return end

    --PARTICLE
    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle,60,Vector(255,0,255))
        ParticleManager:SetParticleControl(self.particle,61,Vector(1,0,0))
    end



    --MAIN EFFECTS
    self.is_push = false --pull if false
    local eorder_ability = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_ethereal_order")
    if not eorder_ability == false then
        self.is_push = eorder_ability:GetToggleState()
    end

    self.duration = kv.duration

    self.effect_distance = self:GetAbility():GetSpecialValueFor("effect_distance")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unfathomed_yield_range")
    if not talent == false then
        if talent:GetLevel() > 0 then
            self.effect_distance = self:GetAbility():GetSpecialValueFor("effect_distance")+talent:GetSpecialValueFor("value")
        end
    end


    local caster_facing = self:GetCaster():GetForwardVector()*self:GetCaster():GetHullRadius()
    self.caster_position = self:GetCaster():GetAbsOrigin()+caster_facing
    self.parent_position = self:GetParent():GetAbsOrigin()

    local distance = (self.caster_position - self.parent_position):Length2D()

    self.direction = self.parent_position - self.caster_position
    self.direction = self.direction:Normalized()

    if self.is_push == false then
        self.direction = -1*self.direction
        self.effect_distance = math.min(self.effect_distance,distance)
        if not self.particle == false then
            ParticleManager:SetParticleControl(self.particle,60,Vector(0,255,255))
        end
    end

    if self:ApplyHorizontalMotionController() then return end
	self:Destroy()
end





function lua_modifier_unfathomed_yield_motion:OnRefresh(kv)
    self:OnCreated(kv)
end





function lua_modifier_unfathomed_yield_motion:UpdateHorizontalMotion( me, dt )
    if not IsServer() then return end
    local speed = (dt/self.duration) * self.effect_distance


    local current_pos = self:GetParent():GetAbsOrigin()

    local new_pos = current_pos + (self.direction*speed)
    local ground_pos = GetGroundPosition(new_pos, self:GetParent())

    --set the position
    if ground_pos.z > -16 and ground_pos.z <= 550 then
        self:GetParent():SetAbsOrigin(ground_pos)
    end

    --remove trees
    GridNav:DestroyTreesAroundPoint(ground_pos,150,false)
end



function lua_modifier_unfathomed_yield_motion:OnHorizontalMotionInterrupted()
    self:Destroy()
end




function lua_modifier_unfathomed_yield_motion:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController(self)

    if not self.particle then return end

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil
end
