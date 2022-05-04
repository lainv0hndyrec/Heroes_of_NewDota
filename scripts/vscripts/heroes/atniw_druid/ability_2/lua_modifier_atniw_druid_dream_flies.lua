

lua_modifier_atniw_druid_dream_flies_debuff = class({})

function lua_modifier_atniw_druid_dream_flies_debuff:IsDebuff() return true end
function lua_modifier_atniw_druid_dream_flies_debuff:IsHidden() return false end
function lua_modifier_atniw_druid_dream_flies_debuff:IsPurgable() return true end
function lua_modifier_atniw_druid_dream_flies_debuff:IsPurgeException() return true end

function lua_modifier_atniw_druid_dream_flies_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function lua_modifier_atniw_druid_dream_flies_debuff:GetModifierMoveSpeedBonus_Percentage()

    local ms_slow_percent = self:GetAbility():GetSpecialValueFor("ms_slow_percent")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_atniw_druid_dream_flies_slow_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            ms_slow_percent = ms_slow_percent+talent:GetSpecialValueFor("value")
        end
    end

    return -ms_slow_percent
end


function lua_modifier_atniw_druid_dream_flies_debuff:GetEffectName()
    return "particles/units/heroes/atniw_druid/ability_2/antiw_druid_dream_flies_debuff.vpcf"
end
