
lua_modifier_diviner_karma = class({})

function lua_modifier_diviner_karma:IsDebuff() return true end
function lua_modifier_diviner_karma:IsHidden() return false end
function lua_modifier_diviner_karma:IsPurgable() return true end
function lua_modifier_diviner_karma:IsPurgeException() return true end



function lua_modifier_diviner_karma:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return dfunc
end



function lua_modifier_diviner_karma:OnCreated(kv)
    if not IsServer() then return end

    local min_slow = self:GetAbility():GetSpecialValueFor("min_slow_percent")
    local max_slow = self:GetAbility():GetSpecialValueFor("max_slow_percent")

    local int_minus_hp_loss_percent = self:GetAbility():GetSpecialValueFor("int_minus_hp_loss_percent")

    local current_int = self:GetCaster():GetIntellect()
    local add_percent = int_minus_hp_loss_percent*current_int

    local percent_diff_hp = 100 - self:GetCaster():GetHealthPercent()

    local total_diff_hp = (add_percent+percent_diff_hp)*0.01

    local add_slow = (max_slow-min_slow)*total_diff_hp

    local total_slow = math.min(min_slow+add_slow,max_slow)

    self:SetStackCount(total_slow)
end



function lua_modifier_diviner_karma:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetStackCount()
end



function lua_modifier_diviner_karma:GetEffectName()
    return "particles/units/heroes/hero_oracle/oracle_fortune_purge.vpcf"
end
