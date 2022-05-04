

lua_modifier_pope_of_pestilence_soul_explosion_thinker = class({})


function lua_modifier_pope_of_pestilence_soul_explosion_thinker:IsDebuff() return false end
function lua_modifier_pope_of_pestilence_soul_explosion_thinker:IsHidden() return true end
function lua_modifier_pope_of_pestilence_soul_explosion_thinker:IsPurgable() return false end
function lua_modifier_pope_of_pestilence_soul_explosion_thinker:IsPurgeException() return false end


function lua_modifier_pope_of_pestilence_soul_explosion_thinker:OnCreated(kv)
    if not IsServer() then return end

    self.particle = ParticleManager:CreateParticle(
        "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())

    self:StartIntervalThink(0.1)

    self.phase = 0

    self:GetParent():EmitSound("Hero_Necrolyte.DeathPulse")
end


function lua_modifier_pope_of_pestilence_soul_explosion_thinker:OnIntervalThink()
    if not IsServer() then return end

    if self.phase  == 0 then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self:StartIntervalThink(-1)
        self:StartIntervalThink(2.0)
        self.phase = 1
        return
    end

    if self.phase  == 1 then
        self:StartIntervalThink(-1)
        self:Destroy()
        return
    end

end



function lua_modifier_pope_of_pestilence_soul_explosion_thinker:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())

end
