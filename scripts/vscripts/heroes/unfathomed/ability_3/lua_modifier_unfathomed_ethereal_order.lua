lua_modifier_unfathomed_ethereal_order = class({})

function lua_modifier_unfathomed_ethereal_order:IsHidden() return false end

function lua_modifier_unfathomed_ethereal_order:IsDebuff() return false end

function lua_modifier_unfathomed_ethereal_order:IsPurgable() return false end

function lua_modifier_unfathomed_ethereal_order:IsPurgeException() return false end

function lua_modifier_unfathomed_ethereal_order:RemoveOnDeath() return false end





function lua_modifier_unfathomed_ethereal_order:DeclareFunctions()
    dfunc = {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
    return dfunc
end


function lua_modifier_unfathomed_ethereal_order:OnCreated(kv)
    self.add_range = self:GetAbility():GetSpecialValueFor("add_range")
end


function lua_modifier_unfathomed_ethereal_order:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_unfathomed_ethereal_order:GetModifierAttackRangeBonus()

    local range = self.add_range
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unfathomed_ethereal_order_range")
    if not talent == false then
        range = range+talent:GetSpecialValueFor("value")
    end
    return range
end





lua_modifier_unfathomed_ethereal_order_status_color = class({})

function lua_modifier_unfathomed_ethereal_order_status_color:IsHidden() return true end

function lua_modifier_unfathomed_ethereal_order_status_color:IsDebuff() return false end

function lua_modifier_unfathomed_ethereal_order_status_color:IsPurgable() return false end

function lua_modifier_unfathomed_ethereal_order_status_color:IsPurgeException() return false end

function lua_modifier_unfathomed_ethereal_order_status_color:GetStatusEffectName()
    return "particles/status_fx/status_effect_faceless_timewalk.vpcf"
end
