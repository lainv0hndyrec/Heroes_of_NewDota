LinkLuaModifier( "lua_modifier_unfathomed_yield_damage", "heroes/unfathomed/ability_2/lua_modifier_unfathomed_yield", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_unfathomed_yield_motion", "heroes/unfathomed/ability_2/lua_modifier_unfathomed_yield", LUA_MODIFIER_MOTION_HORIZONTAL)

--for shard
LinkLuaModifier( "lua_modifier_unfathomed_overwhelming_presence", "heroes/unfathomed/ability_1/lua_modifier_unfathomed_overwhelming_presence", LUA_MODIFIER_MOTION_NONE )


lua_ability_unfathomed_yield = class({})





function lua_ability_unfathomed_yield:GetCastRange(location,target)
    local range = 0
    local caster = self:GetCaster()
    if not caster then return range end
    range = self:GetCaster():Script_GetAttackRange()
    return range
end



function lua_ability_unfathomed_yield:OnAbilityPhaseStart()
    if self:GetCursorTarget() == self:GetCaster() then return false end
    return true
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
    	true,
    	true,
    	true,
    	false,
    	false,
    	false,
    	true
    )

    damage_mod:Destroy()

end





function lua_ability_unfathomed_yield:Effect_PushPull()




    if self:GetCursorTarget():IsMagicImmune() then return end


    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_unfathomed_yield_motion",
        {duration = 0.1}
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
