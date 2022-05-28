LinkLuaModifier( "lua_modifier_rogue_golem_run_forest_buff", "heroes/rogue_golem/ability_3/lua_modifier_rogue_golem_run_forest", LUA_MODIFIER_MOTION_NONE )


lua_modifier_rogue_golem_run_forest_base = class({})


function lua_modifier_rogue_golem_run_forest_base:IsDebuff() return false end
function lua_modifier_rogue_golem_run_forest_base:IsHidden() return false end
function lua_modifier_rogue_golem_run_forest_base:IsPurgable() return true end
function lua_modifier_rogue_golem_run_forest_base:IsPurgeException() return true end


function lua_modifier_rogue_golem_run_forest_base:GetEffectName()
    return "particles/econ/items/rubick/rubick_puppet_master/rubick_telekinesis_puppet_debuff_glow.vpcf"
end


function lua_modifier_rogue_golem_run_forest_base:OnCreated(kv)
    if not IsServer() then return end
    self:StartIntervalThink(0.2)
end


function lua_modifier_rogue_golem_run_forest_base:CheckState()
    return {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true
    }
end


function lua_modifier_rogue_golem_run_forest_base:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end


function lua_modifier_rogue_golem_run_forest_base:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("base_move_speed")
end


function lua_modifier_rogue_golem_run_forest_base:OnIntervalThink()
    if not IsServer() then return end

    local trees = GridNav:GetAllTreesAroundPoint(self:GetParent():GetAbsOrigin(),150,false)
    if #trees > 0 then
        local time = self:GetAbility():GetSpecialValueFor("tree_destroy_duration")
        time = math.min(time,self:GetRemainingTime())

        self:GetCaster():AddNewModifier(
            self:GetCaster(),self:GetAbility(),
            "lua_modifier_rogue_golem_run_forest_buff",
            {duration = time}
        )

        for i=1, #trees do
            trees[i]:CutDown(self:GetParent():GetTeam())

            local talent = self:GetParent():FindAbilityByName("special_bonus_rogue_golem_run_forest_break_heal")
            if not talent == false then
                if talent:GetLevel() > 0 then
                    local heal = talent:GetSpecialValueFor("value")
                    self:GetParent():Heal(heal,self:GetAbility())
                end
            end

        end
    end

end










------------------------------------------------------------------------------------------------------------------------


lua_modifier_rogue_golem_run_forest_buff = class({})


function lua_modifier_rogue_golem_run_forest_buff:IsDebuff() return false end
function lua_modifier_rogue_golem_run_forest_buff:IsHidden() return false end
function lua_modifier_rogue_golem_run_forest_buff:IsPurgable() return true end
function lua_modifier_rogue_golem_run_forest_buff:IsPurgeException() return true end


function lua_modifier_rogue_golem_run_forest_buff:CheckState()
    return {
        [MODIFIER_STATE_UNSLOWABLE] = true
    }
end


function lua_modifier_rogue_golem_run_forest_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end


function lua_modifier_rogue_golem_run_forest_buff:GetModifierMoveSpeedBonus_Constant()

    local speed = self:GetAbility():GetSpecialValueFor("tree_destroy_ms")
    local talent = self:GetParent():FindAbilityByName("special_bonus_rogue_golem_run_forest_break_speed_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            speed = speed + talent:GetSpecialValueFor("value")
        end
    end

    return speed
end
