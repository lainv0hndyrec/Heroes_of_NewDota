lua_modifier_unfathomed_spatial_manipulation = class({})

function lua_modifier_unfathomed_spatial_manipulation:IsHidden() return true end
function lua_modifier_unfathomed_spatial_manipulation:IsDebuff() return false end
function lua_modifier_unfathomed_spatial_manipulation:IsPurgable() return false end
function lua_modifier_unfathomed_spatial_manipulation:IsPurgeException() return false end



function lua_modifier_unfathomed_spatial_manipulation:OnCreated(kv)
    if not IsServer() then return end

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
    if self:GetCaster():HasScepter() then
        self.effect_distance = self:GetAbility():GetSpecialValueFor("effect_distance")+self:GetAbility():GetSpecialValueFor("scepter_distance")
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




function lua_modifier_unfathomed_spatial_manipulation:OnRefresh(kv)
    self:OnCreated(kv)
end





function lua_modifier_unfathomed_spatial_manipulation:UpdateHorizontalMotion( me, dt )
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
    local hull = self:GetParent():GetHullRadius()*4
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(),hull,false)
end



function lua_modifier_unfathomed_spatial_manipulation:OnHorizontalMotionInterrupted()
    self:Destroy()
end





function lua_modifier_unfathomed_spatial_manipulation:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController(self)
    AddFOWViewer(
        self:GetCaster():GetTeam(),
        self:GetParent():GetAbsOrigin(),
        self:GetAbility():GetSpecialValueFor("vision_range"),
        self:GetAbility():GetSpecialValueFor("vision_time"),
        false
    )

    if not self.particle then return end
    print("wtf?")
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil
end
