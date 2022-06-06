LinkLuaModifier( "lua_modifier_soul_warden_wardens_purge_ally", "heroes/soul_warden/ability_4/lua_modifier_soul_warden_wardens_purge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_soul_warden_wardens_purge_enemy", "heroes/soul_warden/ability_4/lua_modifier_soul_warden_wardens_purge", LUA_MODIFIER_MOTION_NONE)

lua_ability_soul_warden_wardens_purge = class({})


-- function lua_ability_soul_warden_wardens_purge:OnAbilityPhaseStart()
--     if self:GetCursorTarget():IsMagicImmune() then return false end
--     return true
-- end
function lua_ability_soul_warden_wardens_purge:CastFilterResultTarget(target)
    if not IsServer() then return end

    if target:IsBuilding() then return UF_FAIL_BUILDING end
    if target:IsCourier() then return UF_FAIL_COURIER end
    if target:IsOther() then return UF_FAIL_OTHER end
    if target:IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():IsAlive() == false then return UF_FAIL_DEAD end
    if target:IsMagicImmune() then return UF_FAIL_CUSTOM end
    if target:IsInvulnerable() then return UF_FAIL_INVULNERABLE end
    if self:GetCaster():CanEntityBeSeenByMyTeam(target) == false then return UF_FAIL_IN_FOW end
    if target:IsInvisible() then return UF_FAIL_INVISIBLE end
    if target:IsOutOfGame() then return UF_FAIL_OUT_OF_WORLD end

    return UF_SUCCESS
end



function lua_ability_soul_warden_wardens_purge:GetCustomCastErrorTarget(target)
    if target:IsMagicImmune() then
        return "Target is Magic Immune"
    end
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

    ParticleManager:ReleaseParticleIndex(arc_effect)

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



function lua_ability_soul_warden_wardens_purge:GetCastRange(ps,target)
    return self:GetLevelSpecialValueFor("cast_range",0)
end
