LinkLuaModifier( "lua_modifier_soul_warden_wardens_purge_ally", "heroes/soul_warden/ability_4/lua_modifier_soul_warden_wardens_purge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_soul_warden_wardens_purge_enemy", "heroes/soul_warden/ability_4/lua_modifier_soul_warden_wardens_purge", LUA_MODIFIER_MOTION_NONE)

lua_ability_soul_warden_wardens_purge = class({})


function lua_ability_soul_warden_wardens_purge:OnAbilityPhaseStart()
    if self:GetCursorTarget():IsMagicImmune() then return false end
    return true
end




function lua_ability_soul_warden_wardens_purge:OnSpellStart()
    local team_value = self:GetCursorTarget():GetTeam()

    --apply particle effect
    local arc_effect = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf",
        PATTACH_ROOTBONE_FOLLOW,
        self:GetCaster()
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,0,self:GetCaster(),PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,1,self:GetCursorTarget(),PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    ParticleManager:SetParticleControlEnt(
        arc_effect,2,self:GetCaster(),PATTACH_ROOTBONE_FOLLOW,
        "attach_hitlock",Vector(0,0,0),false
    )

    --if Ally
    if team_value == self:GetCaster():GetTeam() then

        self:GetCursorTarget():AddNewModifier(
            self:GetCaster(),
            self,"lua_modifier_soul_warden_wardens_purge_ally",
            {
                duration = self:GetSpecialValueFor("ms_duration"),
                chain_order = 0
            }
        )

        return
    end

    --if Enemy
    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),
        self,"lua_modifier_soul_warden_wardens_purge_enemy",
        {
            duration = self:GetSpecialValueFor("ms_duration"),
            chain_order = 0
        }
    )

end
