lua_modifier_soul_warden_restrain = class({})

function lua_modifier_soul_warden_restrain:IsHidden() return false end
function lua_modifier_soul_warden_restrain:IsDebuff() return true end
function lua_modifier_soul_warden_restrain:IsPurgable() return false end
function lua_modifier_soul_warden_restrain:IsPurgeException() return false end
function lua_modifier_soul_warden_restrain:GetModifierProvidesFOWVision() return 1 end
function lua_modifier_soul_warden_restrain:GetPriority() return MODIFIER_PRIORITY_HIGH  end


function lua_modifier_soul_warden_restrain:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end



function lua_modifier_soul_warden_restrain:CheckState()
    local cstate = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }
    return cstate
end



function lua_modifier_soul_warden_restrain:GetOverrideAnimation()
    return ACT_DOTA_DISABLED
end



function lua_modifier_soul_warden_restrain:OnCreated(kv)

    if not self.link_particle then
        self.link_particle = ParticleManager:CreateParticle(
            "particles/econ/items/razor/razor_punctured_crest/razor_static_link_blade.vpcf",
            PATTACH_POINT,
            self:GetCaster()
        )

        ParticleManager:SetParticleControlEnt(
            self.link_particle,0,self:GetCaster(),PATTACH_POINT_FOLLOW,
            "attach_static",Vector(0,0,0),false
        )

        ParticleManager:SetParticleControlEnt(
            self.link_particle,1,self:GetParent(),PATTACH_POINT_FOLLOW,
            "attach_hitloc",Vector(0,0,0),false
        )
    end

    if not self.wrap_particle then
        self.wrap_particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex_recipient_b.vpcf",
            PATTACH_POINT,
            self:GetParent()
        )

        ParticleManager:SetParticleControlEnt(
            self.wrap_particle,1,self:GetParent(),PATTACH_POINT_FOLLOW,
            "attach_hitloc",Vector(0,0,0),false
        )
    end


    self.max_length = self:GetAbility():GetSpecialValueFor("hold_range")
    self:StartIntervalThink(FrameTime())
    self:OnIntervalThink()

    if not IsServer() then return end
    self:GetParent():EmitSound("Ability.static.loop")
end




function lua_modifier_soul_warden_restrain:OnRefresh(kv)
    self:OnCreated(kv)
end




function lua_modifier_soul_warden_restrain:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local length = caster:GetAbsOrigin() - parent:GetAbsOrigin()
    length = length:Length2D()

    if length > self.max_length then
        self:Destroy()
        return
    end

    if caster:IsStunned() then
        self:Destroy()
        return
    end

    if caster:IsSilenced() then
        self:Destroy()
        return
    end

    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard == false then return end
    local max_mana = self:GetParent():GetMaxMana()
    local shard_mana_leech_percent = self:GetAbility():GetSpecialValueFor("shard_mana_leech_percent")*0.01
    local mana_per_sec = max_mana*shard_mana_leech_percent*FrameTime()

    if not IsServer() then return end
    self:GetParent():ReduceMana(mana_per_sec)
    self:GetCaster():GiveMana(mana_per_sec)


end




function lua_modifier_soul_warden_restrain:OnDestroy()
    if not self.link_particle == false then
        ParticleManager:DestroyParticle(self.link_particle,false)
        ParticleManager:ReleaseParticleIndex(self.link_particle)
        self.link_particle = nil
    end

    if not self.wrap_particle == false then
        ParticleManager:DestroyParticle(self.wrap_particle,false)
        ParticleManager:ReleaseParticleIndex(self.wrap_particle)
        self.wrap_particle = nil
    end

    if not IsServer() then return end
    self:GetParent():StopSound("Ability.static.loop")
end
