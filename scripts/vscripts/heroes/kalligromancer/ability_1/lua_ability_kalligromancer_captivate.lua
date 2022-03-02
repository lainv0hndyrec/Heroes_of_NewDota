LinkLuaModifier( "lua_modifier_kalligromancer_captivate", "heroes/kalligromancer/ability_1/lua_modifier_kalligromancer_captivate", LUA_MODIFIER_MOTION_NONE )


lua_ability_kalligromancer_captivate = class({})




function lua_ability_kalligromancer_captivate:GetBehavior()
    local shard_mod = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard_mod == false then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end

    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET+DOTA_ABILITY_BEHAVIOR_AOE
end




function lua_ability_kalligromancer_captivate:GetAOERadius()
    local shard_mod = self:GetCaster():HasModifier("modifier_item_aghanims_shard")
    if shard_mod == false then
        return 0
    end
    return self:GetSpecialValueFor("aoe_vision")
end





function lua_ability_kalligromancer_captivate:OnSpellStart()

    local talent = self:GetCaster():FindAbilityByName("special_bonus_kalligromancer_captivate_plus_duration")
    local hold_time = self:GetSpecialValueFor("hold_time")
    if not talent == false then
        hold_time = hold_time + talent:GetSpecialValueFor("value")
    end

    if shard_mod == false then

        self:add_modifier_to_this_target(self:GetCursorTarget(),talent,hold_time)

    else

        local enemies = FindUnitsInRadius(
            self:GetCaster():GetTeamNumber(),
            self:GetCursorTarget():GetAbsOrigin(),
            nil,
            self:GetAOERadius(),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        for _,enemy in pairs(enemies) do
            if (enemy:IsNull() == false) and (enemy:IsAlive() == true) and (IsValidEntity(enemy) == true) then
    		    self:add_modifier_to_this_target(enemy,talent,hold_time)
            end
    	end

    end


    --[[
    if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end

    local talent = self:GetCaster():FindAbilityByName("special_bonus_kalligromancer_captivate_plus_duration")
    local hold_time = self:GetSpecialValueFor("hold_time")

    if not talent == false then
        hold_time = hold_time + talent:GetSpecialValueFor("value")
    end


    self:GetCursorTarget():AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_kalligromancer_captivate",
        {duration = hold_time}
    )

    self:GetCursorTarget():EmitSound("Hero_Grimstroke.SoulChain.Cast")
    ]]

end






function lua_ability_kalligromancer_captivate:add_modifier_to_this_target(target,talent,hold_time)

    if target:TriggerSpellAbsorb(self) then return end

    target:AddNewModifier(
        self:GetCaster(),
        self,
        "lua_modifier_kalligromancer_captivate",
        {duration = hold_time}
    )

    self:GetCursorTarget():EmitSound("Hero_Grimstroke.SoulChain.Cast")
end



--createhero npc_dota_hero_axe enemy
