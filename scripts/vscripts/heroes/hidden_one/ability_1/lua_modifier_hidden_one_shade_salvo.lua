lua_modifier_hidden_one_shade_salvo = class({})

function lua_modifier_hidden_one_shade_salvo:IsDebuff() return false end
function lua_modifier_hidden_one_shade_salvo:IsHidden() return true end
function lua_modifier_hidden_one_shade_salvo:IsPurgable() return false end
function lua_modifier_hidden_one_shade_salvo:IsPurgeException() return false end



function lua_modifier_hidden_one_shade_salvo:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end



























-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
lua_modifier_hidden_one_shade_salvo_damage = class({})


function lua_modifier_hidden_one_shade_salvo_damage:IsDebuff() return true end
function lua_modifier_hidden_one_shade_salvo_damage:IsHidden() return true end
function lua_modifier_hidden_one_shade_salvo_damage:IsPurgable() return false end
function lua_modifier_hidden_one_shade_salvo_damage:IsPurgeException() return false end


function lua_modifier_hidden_one_shade_salvo_damage:OnCreated(kv)
    if not IsServer() then return end

    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("first_damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)
end


function lua_modifier_hidden_one_shade_salvo_damage:OnRefresh(kv)
    if not IsServer() then return end

    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("next_damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)
end


























-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
lua_modifier_hidden_one_shade_salvo_slow = class({})


function lua_modifier_hidden_one_shade_salvo_slow:IsDebuff() return true end
function lua_modifier_hidden_one_shade_salvo_slow:IsHidden() return false end
function lua_modifier_hidden_one_shade_salvo_slow:IsPurgable() return true end
function lua_modifier_hidden_one_shade_salvo_slow:IsPurgeException() return true end



function lua_modifier_hidden_one_shade_salvo_slow:GetEffectName()
    return "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_debuff_cloud.vpcf"
end



function lua_modifier_hidden_one_shade_salvo_slow:OnCreated(kv)
    if not IsServer() then return end
    self:SetStackCount(1)
end



function lua_modifier_hidden_one_shade_salvo_slow:OnRefresh(kv)
    if not IsServer() then return end
    local max_stack = self:GetAbility():GetSpecialValueFor("slow_stack_max")
    if self:GetStackCount() >= max_stack then return end
    self:IncrementStackCount()
end



function lua_modifier_hidden_one_shade_salvo_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end



function lua_modifier_hidden_one_shade_salvo_slow:GetModifierMoveSpeedBonus_Percentage()
    local move_slow = self:GetAbility():GetSpecialValueFor("move_slow_percent")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_hidden_one_shade_salvo_slow_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            move_slow = move_slow+talent:GetSpecialValueFor("value")
        end
    end

    local total_slow = self:GetStackCount()*move_slow
    return -total_slow
end
