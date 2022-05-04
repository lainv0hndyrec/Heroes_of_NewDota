lua_modifier_soul_warden_ionic_absorption = class({})

function lua_modifier_soul_warden_ionic_absorption:IsHidden() return false end
function lua_modifier_soul_warden_ionic_absorption:IsDebuff() return false end
function lua_modifier_soul_warden_ionic_absorption:IsPurgable() return true end
function lua_modifier_soul_warden_ionic_absorption:IsPurgeException() return true end



function lua_modifier_soul_warden_ionic_absorption:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end


function lua_modifier_soul_warden_ionic_absorption:OnCreated(kv)
	if not IsServer() then return end
	self:SetStackCount(kv.ms_stacks)
end



function lua_modifier_soul_warden_ionic_absorption:OnRefresh(kv)
    self:OnCreated(kv)
end



function lua_modifier_soul_warden_ionic_absorption:GetModifierMoveSpeedBonus_Constant()
    local initial_ms = self:GetAbility():GetSpecialValueFor("ms_initial")
	local ms_per_stack = self:GetAbility():GetSpecialValueFor("ms_per_stack")*self:GetStackCount()
	return initial_ms+ms_per_stack
end
