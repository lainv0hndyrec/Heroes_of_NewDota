
lua_modifier_diviner_chaotic_insight = class({})

function lua_modifier_diviner_chaotic_insight:IsDebuff() return false end
function lua_modifier_diviner_chaotic_insight:IsHidden() return false end
function lua_modifier_diviner_chaotic_insight:IsPurgable() return true end
function lua_modifier_diviner_chaotic_insight:IsPurgeException() return true end



function lua_modifier_diviner_chaotic_insight:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return dfunc
end



function lua_modifier_diviner_chaotic_insight:OnCreated(kv)
    if not IsServer() then return end
    self.total_damage = 0
    self:GetParent():EmitSound("Hero_Oracle.FatesEdict")
end



function lua_modifier_diviner_chaotic_insight:GetModifierIncomingDamage_Percentage(event)
    if not IsServer() then return end
    if event.target ~= self:GetParent() then return end

    local percent = self:GetAbility():GetSpecialValueFor("absorb_damage")

    local absorbed_damage = event.original_damage*percent*0.01

    self.total_damage = self.total_damage + absorbed_damage

    return -percent
end



function lua_modifier_diviner_chaotic_insight:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_Oracle.FatesEdict")
    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetParent(),
        damage = self.total_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self
    }
    ApplyDamage(dtable)
end



function lua_modifier_diviner_chaotic_insight:GetEffectName()
    return "particles/units/heroes/hero_oracle/oracle_fatesedict.vpcf"
end
