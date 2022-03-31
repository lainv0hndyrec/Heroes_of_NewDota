LinkLuaModifier( "lua_modifier_kalligromancer_death_portrait", "heroes/kalligromancer/ability_4/lua_modifier_kalligromancer_death_portrait", LUA_MODIFIER_MOTION_NONE )


lua_ability_kalligromancer_death_portrait = class({})



-- function lua_ability_kalligromancer_death_portrait:OnAbilityPhaseStart()
--     if self:GetCursorTarget():IsCreepHero() then return false end
--     if self:GetCursorTarget():IsSummoned() then return false end
--
--     return true
-- end




function lua_ability_kalligromancer_death_portrait:CastFilterResultTarget(target)
    if not IsServer() then return end
    if target:GetTeam() == self:GetCaster():GetTeam() then return UF_FAIL_FRIENDLY end
    if target:IsCreep() then return UF_FAIL_CREEP end
    if target:IsBuilding() then return UF_FAIL_BUILDING end
    if target:IsCourier() then return UF_FAIL_COURIER end
    if target:IsOther() then return UF_FAIL_OTHER end
    if target:IsAncient() then return UF_FAIL_ANCIENT end
    if target:IsSummoned() then return UF_FAIL_SUMMONED end
    if target:IsDominated() then return UF_FAIL_DOMINATED end
    if target:IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():IsAlive() == false then return UF_FAIL_DEAD end
    if target:IsMagicImmune() then return UF_FAIL_CUSTOM end
    if target:IsInvulnerable() then return UF_FAIL_INVULNERABLE end
    if self:GetCaster():CanEntityBeSeenByMyTeam(target) == false then return UF_FAIL_IN_FOW end
    if target:IsInvisible() then return UF_FAIL_INVISIBLE end
    if target:IsOutOfGame() then return UF_FAIL_OUT_OF_WORLD end
    if target:IsHero() == false then return UF_FAIL_CUSTOM end

    return UF_SUCCESS
end



function lua_ability_kalligromancer_death_portrait:GetCustomCastErrorTarget(target)
    if target:IsMagicImmune() then
        return "Target is Magic Immune"
    end

    if target:IsHero() == false then
        return "Target is not a Hero"
    end
end












function lua_ability_kalligromancer_death_portrait:OnSpellStart()

    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    local spawn_pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector()*self:GetSpecialValueFor("spawn_distance")
    spawn_pos = GetGroundPosition(spawn_pos,self:GetCursorTarget())


    local portrait = CreateIllusions(
        self:GetCaster(),
        self:GetCursorTarget(),
        {
            outgoing_damage = 0.0,
            incoming_damage = 0.0,
            bounty_base = 0.0,
            bounty_growth = 0.0,
            outgoing_damage_structure = 0.0,
            outgoing_damage_roshan = 0.0
        },
        1,
        self:GetCursorTarget():GetHullRadius(),
        false,
        true
    )

    FindClearSpaceForUnit(portrait[1],spawn_pos,true)

    portrait[1]:AddNewModifier(
        self:GetCaster(),
        self,
        "modifier_chaos_knight_phantasm_illusion",
        {duration = self:GetSpecialValueFor("portrait_duration")}
    )

    portrait[1]:AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_kalligromancer_death_portrait",
        {duration = self:GetSpecialValueFor("portrait_duration")}
    )

    portrait[1]:SetTeam(self:GetCursorTarget():GetTeam())
end
