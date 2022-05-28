LinkLuaModifier( "lua_modifier_unfathomed_yield_damage", "heroes/unfathomed/ability_2/lua_modifier_unfathomed_yield", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_unfathomed_yield_motion", "heroes/unfathomed/ability_2/lua_modifier_unfathomed_yield", LUA_MODIFIER_MOTION_HORIZONTAL)

--for shard
LinkLuaModifier( "lua_modifier_unfathomed_overwhelming_presence", "heroes/unfathomed/ability_1/lua_modifier_unfathomed_overwhelming_presence", LUA_MODIFIER_MOTION_NONE )


lua_ability_unfathomed_yield = class({})





function lua_ability_unfathomed_yield:GetCastRange(location,target)

    local range = self:GetLevelSpecialValueFor("base_cast_range",0)
    local ethereal_order = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_ethereal_order")
    if not ethereal_order == false then
        range = range + ethereal_order:GetSpecialValueFor("add_range")
    end

    local talent = self:GetCaster():FindAbilityByName("special_bonus_unfathomed_ethereal_order_range")
    if not talent == false then
        if talent:GetLevel() > 0 then
            range = range+talent:GetSpecialValueFor("value")
        end
    end

    return range
end



-- function lua_ability_unfathomed_yield:OnAbilityPhaseStart()
--     if self:GetCursorTarget() == self:GetCaster() then return false end
--     return true
-- end


function lua_ability_unfathomed_yield:CastFilterResultTarget(target)
    if not IsServer() then return end

    if target:IsBuilding() then return UF_FAIL_BUILDING end
    if target:IsCourier() then return UF_FAIL_COURIER end
    if target:IsOther() then return UF_FAIL_OTHER end
    if target:IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():IsAlive() == false then return UF_FAIL_DEAD end
    if target:IsInvulnerable() then return UF_FAIL_INVULNERABLE end
    if self:GetCaster():CanEntityBeSeenByMyTeam(target) == false then return UF_FAIL_IN_FOW end
    if target:IsInvisible() then return UF_FAIL_INVISIBLE end
    if target:IsOutOfGame() then return UF_FAIL_OUT_OF_WORLD end
    if target == self:GetCaster() then return UF_FAIL_CUSTOM end

    return UF_SUCCESS
end



function lua_ability_unfathomed_yield:GetCustomCastErrorTarget(target)
    if target == self:GetCaster() then
        return "Ability Can't Target Self"
    end
end














function lua_ability_unfathomed_yield:OnSpellStart()

    self:GetCaster():EmitSound("Hero_Enigma.Black_Hole.Stop")

    --LINKEN TRIGGER
    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    --EFFECT
    self:Effect_PushPull()

    -- DAMAGE
    if self:GetCaster():GetTeamNumber() == self:GetCursorTarget():GetTeamNumber() then return end

    local damage_mod = self:GetCaster():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_unfathomed_yield_damage",
        {}
    )

    self:GetCaster():PerformAttack(
    	self:GetCursorTarget(),
    	true,true,true,false,
        false,false,true
    )

    damage_mod:Destroy()

end





function lua_ability_unfathomed_yield:Effect_PushPull()

    if self:GetCursorTarget():IsMagicImmune() then return end


    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_unfathomed_yield_motion",
        {duration = 0.2}
    )

    --SHARD
    if self:GetCursorTarget():GetTeam() == self:GetCaster():GetTeam() then return end

    local shard = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard == false then return end

    local q_ability = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_overwhelming_presence")
    if not q_ability then return end
    if q_ability:GetLevel() <= 0 then return end

    local dtime = q_ability:GetSpecialValueFor("effect_duration")

    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),
        q_ability,
        "lua_modifier_unfathomed_overwhelming_presence",
        {duration = dtime}
    )

end
