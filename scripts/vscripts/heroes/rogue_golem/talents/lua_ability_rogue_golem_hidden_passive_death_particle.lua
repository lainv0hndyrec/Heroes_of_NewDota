LinkLuaModifier( "lua_modifier_rogue_golem_hidden_passive_death_particle", "heroes/rogue_golem/talents/lua_ability_rogue_golem_hidden_passive_death_particle", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_rogue_golem_hidden_passive_death_particle_thinker", "heroes/rogue_golem/talents/lua_ability_rogue_golem_hidden_passive_death_particle", LUA_MODIFIER_MOTION_NONE )



lua_ability_rogue_golem_hidden_passive_death_particle = class({})



function lua_ability_rogue_golem_hidden_passive_death_particle:IsStealable()
    return false
end



function lua_ability_rogue_golem_hidden_passive_death_particle:GetIntrinsicModifierName()
	return "lua_modifier_rogue_golem_hidden_passive_death_particle"
end













-------------------------------------------[MODIFIER]-----------------------------------------------------

lua_modifier_rogue_golem_hidden_passive_death_particle = class({})


function lua_modifier_rogue_golem_hidden_passive_death_particle:IsDebuff() return false end
function lua_modifier_rogue_golem_hidden_passive_death_particle:IsHidden() return true end
function lua_modifier_rogue_golem_hidden_passive_death_particle:IsPurgable() return false end
function lua_modifier_rogue_golem_hidden_passive_death_particle:IsPurgeException() return false end
function lua_modifier_rogue_golem_hidden_passive_death_particle:RemoveOnDeath() return false end




function lua_modifier_rogue_golem_hidden_passive_death_particle:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }
end



function lua_modifier_rogue_golem_hidden_passive_death_particle:GetModifierModelChange()
    return "models/heroes/tiny/tiny_04/tiny_04.vmdl"
end



function lua_modifier_rogue_golem_hidden_passive_death_particle:OnDeath(event)
    if not IsServer() then return end

    if event.unit ~= self:GetParent() then return end

    CreateModifierThinker(
        self:GetParent(),self:GetAbility(),
        "lua_modifier_rogue_golem_hidden_passive_death_particle_thinker",
        {duration = 5.0},
        self:GetParent():GetAbsOrigin(),
        self:GetParent():GetTeam(),false
    )

end







-------------------------------------------[MODIFIER THINKER]-----------------------------------------------------
lua_modifier_rogue_golem_hidden_passive_death_particle_thinker = class({})


function lua_modifier_rogue_golem_hidden_passive_death_particle_thinker:IsDebuff() return false end
function lua_modifier_rogue_golem_hidden_passive_death_particle_thinker:IsHidden() return true end
function lua_modifier_rogue_golem_hidden_passive_death_particle_thinker:IsPurgable() return false end
function lua_modifier_rogue_golem_hidden_passive_death_particle_thinker:IsPurgeException() return false end


function lua_modifier_rogue_golem_hidden_passive_death_particle_thinker:OnCreated(kv)

    if not IsServer() then return end

    self.particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_tiny/tiny04_death.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())

end



function lua_modifier_rogue_golem_hidden_passive_death_particle_thinker:OnDestroy()

    if not IsServer() then return end

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil

    UTIL_Remove(self:GetParent())

end
