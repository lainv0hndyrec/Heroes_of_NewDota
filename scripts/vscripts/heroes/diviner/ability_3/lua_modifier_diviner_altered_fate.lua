
lua_modifier_diviner_altered_fate_passive = class({})

function lua_modifier_diviner_altered_fate_passive:IsDebuff() return false end
function lua_modifier_diviner_altered_fate_passive:IsHidden() return false end
function lua_modifier_diviner_altered_fate_passive:IsPurgable() return false end
function lua_modifier_diviner_altered_fate_passive:IsPurgeException() return false end
function lua_modifier_diviner_altered_fate_passive:RemoveOnDeath() return false end



function lua_modifier_diviner_altered_fate_passive:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return dfunc
end



function lua_modifier_diviner_altered_fate_passive:GetModifierConstantHealthRegen()
    local missing_hp = 100 - self:GetParent():GetHealthPercent()
    self:SetStackCount(missing_hp)
    local bonus_hp_regen = self:GetAbility():GetSpecialValueFor("increment_hp_regen")

    local talent = self:GetParent():FindAbilityByName("special_bonus_diviner_altered_fate_passive_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            bonus_hp_regen = bonus_hp_regen + talent:GetSpecialValueFor("value")
        end
    end

    local total_regen = bonus_hp_regen*missing_hp

    return total_regen
end




















--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
lua_modifier_diviner_altered_fate_hp_regen = class({})

function lua_modifier_diviner_altered_fate_hp_regen:IsDebuff() return false end
function lua_modifier_diviner_altered_fate_hp_regen:IsHidden() return false end
function lua_modifier_diviner_altered_fate_hp_regen:IsPurgable() return true end
function lua_modifier_diviner_altered_fate_hp_regen:IsPurgeException() return true end



function lua_modifier_diviner_altered_fate_hp_regen:OnCreated(kv)
    if not IsServer() then return end

    self.hp_table = {}
    self.hp_table["current"] = self:GetParent():GetHealth()
    self.hp_table["max"] = self:GetParent():GetMaxHealth()
    self.hp_table["percent"] = self:GetParent():GetHealthPercent()

    self.mp_table = {}
    self.mp_table["current"] = self:GetParent():GetMana()
    self.mp_table["max"] = self:GetParent():GetMaxMana()
    self.mp_table["percent"] = self:GetParent():GetManaPercent()

    local duration = self:GetDuration()


    local hp_to_give = self.hp_table["max"]*self.mp_table["percent"]*0.01
    local hp_diff = hp_to_give - self.hp_table["current"]

    self.hp_increment = (hp_diff/duration)*0.1

    local mp_to_decrease = self.mp_table["max"]*self.hp_table["percent"]*0.01
    local mp_diff = self.mp_table["current"] - mp_to_decrease

    self.mp_increment = (mp_diff/duration)*0.1

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()

    self:GetParent():EmitSound("Hero_Oracle.PurifyingFlames")
end



function lua_modifier_diviner_altered_fate_hp_regen:OnRefresh(kv)
    self:OnCreated(kv)
end



function lua_modifier_diviner_altered_fate_hp_regen:OnIntervalThink()
    if not IsServer() then return end

    local new_hp = self:GetParent():GetHealth()+self.hp_increment
    self:GetParent():ModifyHealth(new_hp,self:GetAbility(),false,0)
    self:GetParent():ReduceMana(self.mp_increment)
end



function lua_modifier_diviner_altered_fate_hp_regen:GetEffectName()
    return "particles/units/heroes/hero_oracle/oracle_purifyingflames.vpcf"
end



function lua_modifier_diviner_altered_fate_hp_regen:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_Oracle.PurifyingFlames")
end













--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
lua_modifier_diviner_altered_fate_mp_regen = class({})

function lua_modifier_diviner_altered_fate_mp_regen:IsDebuff() return false end
function lua_modifier_diviner_altered_fate_mp_regen:IsHidden() return false end
function lua_modifier_diviner_altered_fate_mp_regen:IsPurgable() return true end
function lua_modifier_diviner_altered_fate_mp_regen:IsPurgeException() return true end



function lua_modifier_diviner_altered_fate_mp_regen:OnCreated(kv)
    if not IsServer() then return end

    self.hp_table = {}
    self.hp_table["current"] = self:GetParent():GetHealth()
    self.hp_table["max"] = self:GetParent():GetMaxHealth()
    self.hp_table["percent"] = self:GetParent():GetHealthPercent()

    self.mp_table = {}
    self.mp_table["current"] = self:GetParent():GetMana()
    self.mp_table["max"] = self:GetParent():GetMaxMana()
    self.mp_table["percent"] = self:GetParent():GetManaPercent()

    local duration = self:GetDuration()

    --mp up hp down
    local mp_to_give = self.mp_table["max"]*self.hp_table["percent"]*0.01
    local mp_diff = mp_to_give - self.mp_table["current"]

    self.mp_increment = (mp_diff/duration)*0.1

    local hp_to_decrease = self.hp_table["max"]*self.mp_table["percent"]*0.01
    local hp_diff = self.hp_table["current"] - hp_to_decrease

    self.hp_increment = (hp_diff/duration)*0.1

    self:StartIntervalThink(0.1)
    self:OnIntervalThink()

    self:GetParent():EmitSound("Hero_Oracle.PurifyingFlames")
end



function lua_modifier_diviner_altered_fate_mp_regen:OnRefresh(kv)
    self:OnCreated(kv)
end



function lua_modifier_diviner_altered_fate_mp_regen:OnIntervalThink()
    if not IsServer() then return end

    local new_hp = self:GetParent():GetHealth()-self.hp_increment
    self:GetParent():ModifyHealth(new_hp,self:GetAbility(),false,0)
    self:GetParent():GiveMana(self.mp_increment)
end



function lua_modifier_diviner_altered_fate_mp_regen:GetEffectName()
    return "particles/units/heroes/diviner/ability_3/diviner_altered_fate.vpcf"
end



function lua_modifier_diviner_altered_fate_hp_regen:OnDestroy()
    if not IsServer() then return end
    self:GetParent():StopSound("Hero_Oracle.PurifyingFlames")
end
