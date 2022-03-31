lua_modifier_generic_change_turn_rate= class({})

function lua_modifier_generic_change_turn_rate:IsHidden() return true end
function lua_modifier_generic_change_turn_rate:IsDebuff() return false end
function lua_modifier_generic_change_turn_rate:IsPurgable() return false end
function lua_modifier_generic_change_turn_rate:IsPurgeException() return false end
function lua_modifier_generic_change_turn_rate:RemoveOnDeath() return false end
function lua_modifier_generic_change_turn_rate:AllowIllusionDuplicate() return true end


function lua_modifier_generic_change_turn_rate:DeclareFunctions()
    return {MODIFIER_PROPERTY_TURN_RATE_OVERRIDE}
end



function lua_modifier_generic_change_turn_rate:GetModifierTurnRate_Override()
    if not IsServer() then return end
    return self:GetAbility().Turn_Rate
end
