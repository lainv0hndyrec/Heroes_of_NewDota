LinkLuaModifier( "lua_modifier_defiler_defiling_touch_debuff", "heroes/defiler/ability_3/lua_modifier_defiler_defiling_touch", LUA_MODIFIER_MOTION_NONE )

lua_modifier_defiler_defiling_touch_source = class({})


function lua_modifier_defiler_defiling_touch_source:IsDebuff() return false end
function lua_modifier_defiler_defiling_touch_source:IsHidden() return true end
function lua_modifier_defiler_defiling_touch_source:IsPurgable() return false end
function lua_modifier_defiler_defiling_touch_source:IsPurgeException() return false end
function lua_modifier_defiler_defiling_touch_source:RemoveOnDeath() return false end



function lua_modifier_defiler_defiling_touch_source:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
    return dfunc
end


function lua_modifier_defiler_defiling_touch_source:GetModifierTotalDamageOutgoing_Percentage(event)
    if event.attacker:IsAlive() == false then return 0 end
    if event.attacker ~= self:GetParent() then return 0 end
    if event.target:IsAlive() == false then return 0 end
    if event.target:GetName() == "npc_dota_roshan" then return 0 end
    if event.target:IsMagicImmune() then return 0 end
    if event.target:IsBuilding() then return 0 end
    if self:GetParent():PassivesDisabled() then return 0 end


    local debuff_name = "lua_modifier_defiler_defiling_touch_debuff"
    local debuff = event.target:FindModifierByName(debuff_name)
    local debuff_time = self:GetAbility():GetSpecialValueFor("debuff_time")

    event.target:AddNewModifier(
        self:GetParent(),self:GetAbility(),debuff_name,{duration = debuff_time}
    )

    local dmg_up = self:GetAbility():GetSpecialValueFor("dmg_bonus_percent")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_defiler_defiling_touch_bonus_dmg")
    if not talent == false then
        if talent:GetLevel() > 0 then
            dmg_up =  dmg_up + talent:GetSpecialValueFor("value")
        end
    end

    return dmg_up

end


function lua_modifier_defiler_defiling_touch_source:GetModifierIncomingDamage_Percentage(event)
    if event.attacker:IsAlive() == false then return 0 end
    if event.attacker:HasModifier("lua_modifier_defiler_defiling_touch_debuff") == false then return 0 end
    if event.target:IsAlive() == false then return 0 end
    if event.target ~= self:GetParent() then return 0 end

    local dmg_down = self:GetAbility():GetSpecialValueFor("dmg_decrease_percent")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_defiler_defiling_touch_decrease_dmg")
    if not talent == false then
        if talent:GetLevel() > 0 then
            dmg_down =  dmg_down + talent:GetSpecialValueFor("value")
        end
    end

    return -dmg_down
end





































lua_modifier_defiler_defiling_touch_debuff = class({})

function lua_modifier_defiler_defiling_touch_debuff:IsDebuff() return true end
function lua_modifier_defiler_defiling_touch_debuff:IsPurgable() return true end
