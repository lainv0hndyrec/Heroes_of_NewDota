lua_modifier_kalligromancer_captivate = class({})


function lua_modifier_kalligromancer_captivate:IsHidden() return false end

function lua_modifier_kalligromancer_captivate:IsDebuff() return true end

function lua_modifier_kalligromancer_captivate:IsPurgable() return true end

function lua_modifier_kalligromancer_captivate:DeclareFunctions() return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end

function lua_modifier_kalligromancer_captivate:GetModifierProvidesFOWVision() return 1 end


function lua_modifier_kalligromancer_captivate:OnCreated(kv)

    self.origin_pos = self:GetParent():GetAbsOrigin()

    self.aoe_vision = self:GetAbility():GetSpecialValueFor("aoe_vision")

    self:create_particle_effects()

    self:StartIntervalThink(FrameTime())

    if not IsServer() then return end

    self.viewer = AddFOWViewer(
        self:GetCaster():GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        self.aoe_vision,
        self:GetDuration(),
        false
    )
end




function lua_modifier_kalligromancer_captivate:OnRefresh(kv)
    self:OnCreated(kv)
end




function lua_modifier_kalligromancer_captivate:OnIntervalThink()


    local vector_diff =  self:GetParent():GetAbsOrigin() - self.origin_pos
    local direction = -vector_diff:Normalized()
    local distance  = vector_diff:Length2D()

    local pullrate = distance*FrameTime()*2

    if not IsServer() then return end
    if self:GetParent():IsCurrentlyHorizontalMotionControlled() then return end

    local new_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + (pullrate*direction),self:GetParent())
    self:GetParent():SetAbsOrigin(new_pos)
end




function lua_modifier_kalligromancer_captivate:OnDestroy()

    if not self.particle_orb == false then

        ParticleManager:DestroyParticle(self.particle_orb,false)
        ParticleManager:DestroyParticle(self.particle_trail,false)
        ParticleManager:ReleaseParticleIndex(self.particle_orb)
        ParticleManager:ReleaseParticleIndex(self.particle_trail)

    end


    if not IsServer() then return end
    RemoveFOWViewer(self:GetCaster():GetTeamNumber(),self.viewer)
    ResolveNPCPositions(self:GetParent():GetAbsOrigin(),self.aoe_vision)
end




function lua_modifier_kalligromancer_captivate:create_particle_effects()

    if not self.particle_orb == false then

        ParticleManager:DestroyParticle(self.particle_orb,false)
        ParticleManager:DestroyParticle(self.particle_trail,false)
        ParticleManager:ReleaseParticleIndex(self.particle_orb)
        ParticleManager:ReleaseParticleIndex(self.particle_trail)

    end


    local orb_pos = self.origin_pos
    orb_pos.z = orb_pos.z + 200

    self.particle_orb = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_grimstroke/grimstroke_base_attack.vpcf",
        PATTACH_ABSORIGIN,
        self:GetParent()
    )

    ParticleManager:SetParticleControl(
        self.particle_orb,0,orb_pos
    )


    self.particle_trail = ParticleManager:CreateParticle(
        "particles/units/heroes/kalligromancer/ability_1/captivate_bind.vpcf",
        PATTACH_ABSORIGIN,
        self:GetParent()
    )

    ParticleManager:SetParticleControl(
        self.particle_trail,0,orb_pos
    )

    ParticleManager:SetParticleControlEnt(
        self.particle_trail, 1, self:GetParent(),
        PATTACH_POINT_FOLLOW, "follow_hitloc",
        Vector(0,0,0), false
    )
end
