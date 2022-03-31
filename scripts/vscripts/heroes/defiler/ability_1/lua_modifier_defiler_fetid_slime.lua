lua_modifier_defiler_fetid_slime_buff = class({})

function lua_modifier_defiler_fetid_slime_buff:IsDebuff() return false end
function lua_modifier_defiler_fetid_slime_buff:IsPurgable() return true end
function lua_modifier_defiler_fetid_slime_buff:IsPurgeException() return true end

function lua_modifier_defiler_fetid_slime_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function lua_modifier_defiler_fetid_slime_buff:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("stolen_ms")
end















lua_modifier_defiler_fetid_slime_debuff = class({})

function lua_modifier_defiler_fetid_slime_debuff:IsDebuff() return true end
function lua_modifier_defiler_fetid_slime_debuff:IsPurgable() return true end
function lua_modifier_defiler_fetid_slime_debuff:IsPurgeException() return true end

function lua_modifier_defiler_fetid_slime_debuff:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
    return dfunc
end

function lua_modifier_defiler_fetid_slime_debuff:GetModifierMoveSpeedBonus_Constant()
    return -self:GetAbility():GetSpecialValueFor("stolen_ms")
end


function lua_modifier_defiler_fetid_slime_debuff:GetEffectName()
    return "particles/units/heroes/defiler/ability_1/fetid_slime_debuff.vpcf"
end

function lua_modifier_defiler_fetid_slime_debuff:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end
