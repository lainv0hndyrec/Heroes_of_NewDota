
lua_modifier_diviner_shared_fate_scepter = class({})

function lua_modifier_diviner_shared_fate_scepter:IsDebuff() return true end
function lua_modifier_diviner_shared_fate_scepter:IsHidden() return true end
function lua_modifier_diviner_shared_fate_scepter:IsPurgable() return false end
function lua_modifier_diviner_shared_fate_scepter:IsPurgeException() return false end


function lua_modifier_diviner_shared_fate_scepter:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():InterruptMotionControllers(true)
end


function lua_modifier_diviner_shared_fate_scepter:CheckState()
    local cstate ={
        [MODIFIER_STATE_STUNNED] = true
    }
    return cstate
end

function lua_modifier_diviner_shared_fate_scepter:DeclareFunctions()
    local dfunc ={
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
    return dfunc
end


function lua_modifier_diviner_shared_fate_scepter:GetOverrideAnimation()
    return ACT_DOTA_DISABLED
end
