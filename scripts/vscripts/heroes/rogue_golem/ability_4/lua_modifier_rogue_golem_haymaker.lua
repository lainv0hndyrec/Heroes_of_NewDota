

lua_modifier_rogue_golem_haymaker_buff = class({})




function lua_modifier_rogue_golem_haymaker_buff:IsDebuff() return false end
function lua_modifier_rogue_golem_haymaker_buff:IsHidden() return false end
function lua_modifier_rogue_golem_haymaker_buff:IsPurgable() return true end
function lua_modifier_rogue_golem_haymaker_buff:IsPurgeException() return true end


function lua_modifier_rogue_golem_haymaker_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end



function lua_modifier_rogue_golem_haymaker_buff:OnCreated(kv)
    if not IsServer() then return end
    if not kv.str_gain then return end
    self:SetStackCount(kv.str_gain)
end


function lua_modifier_rogue_golem_haymaker_buff:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_rogue_golem_haymaker_buff:GetModifierBonusStats_Strength()
    return self:GetStackCount()
end













--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
lua_modifier_rogue_golem_haymaker_slow = class({})


function lua_modifier_rogue_golem_haymaker_slow:IsDebuff() return true end
function lua_modifier_rogue_golem_haymaker_slow:IsHidden() return false end
function lua_modifier_rogue_golem_haymaker_slow:IsPurgable() return true end
function lua_modifier_rogue_golem_haymaker_slow:IsPurgeException() return true end

function lua_modifier_rogue_golem_haymaker_slow:GetEffectName()
    return "particles/units/heroes/hero_primal_beast/primal_beast_slow_debuff.vpcf"
end


function lua_modifier_rogue_golem_haymaker_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end


function lua_modifier_rogue_golem_haymaker_slow:OnCreated(kv)
    if not IsServer() then return end
    self:SetStackCount(100)
    self.interval = (100/self:GetDuration())*0.2
    self:StartIntervalThink(0.2)
end


function lua_modifier_rogue_golem_haymaker_slow:OnIntervalThink()
    if not IsServer() then return end
    local current_stack = math.max(self:GetStackCount()-self.interval,0)
    self:SetStackCount(current_stack)
end


function lua_modifier_rogue_golem_haymaker_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetStackCount()
end
