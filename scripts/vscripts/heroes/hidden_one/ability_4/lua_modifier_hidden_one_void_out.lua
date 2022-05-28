LinkLuaModifier( "lua_modifier_hidden_one_void_out_stun", "heroes/hidden_one/ability_4/lua_modifier_hidden_one_void_out", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_hidden_one_void_out_vulnerable", "heroes/hidden_one/ability_4/lua_modifier_hidden_one_void_out", LUA_MODIFIER_MOTION_NONE )



lua_modifier_hidden_one_void_out_counter = class({})



function lua_modifier_hidden_one_void_out_counter:IsDebuff() return true end
function lua_modifier_hidden_one_void_out_counter:IsHidden() return false end
function lua_modifier_hidden_one_void_out_counter:IsPurgable() return false end
function lua_modifier_hidden_one_void_out_counter:IsPurgeException() return false end



function lua_modifier_hidden_one_void_out_counter:GetEffectName()
    return "particles/items2_fx/veil_of_discord_debuff.vpcf"
end



function lua_modifier_hidden_one_void_out_counter:OnCreated(kv)
    if not IsServer() then return end

    if not kv.ability then
        self:Destroy()
        return
    end

    local frozen_mod = self:GetParent():HasModifier("lua_modifier_hidden_one_void_out_stun")
    if frozen_mod == true then
        self:Destroy()
        return
    end


    self.ability = kv.ability

end



function lua_modifier_hidden_one_void_out_counter:OnRefresh(kv)
    if not IsServer() then return end

    if not kv.ability then
        self:Destroy()
        return
    end

    if self.ability == kv.ability then return end

    self:GetParent():EmitSound("Hero_VoidSpirit.AetherRemnant.Target")

    --stun
    local stun_duration = self:GetAbility():GetSpecialValueFor("stun_duration")
    self:GetParent():AddNewModifier(
        self:GetCaster(),self:GetAbility(),
        "lua_modifier_hidden_one_void_out_stun",
        {duration = stun_duration}
    )


    --vulnerable
    local vulnerable_duration = self:GetAbility():GetSpecialValueFor("vulnerable_duration")
    self:GetParent():AddNewModifier(
        self:GetCaster(),self:GetAbility(),
        "lua_modifier_hidden_one_void_out_vulnerable",
        {duration = vulnerable_duration}
    )


    --damage
    local combo_damage = self:GetAbility():GetSpecialValueFor("combo_damage")
    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = combo_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }

    ApplyDamage(dtable)

    self:Destroy()

end














-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
lua_modifier_hidden_one_void_out_stun = class({})



function lua_modifier_hidden_one_void_out_stun:IsDebuff() return true end
function lua_modifier_hidden_one_void_out_stun:IsHidden() return true end
function lua_modifier_hidden_one_void_out_stun:IsPurgable() return true end
function lua_modifier_hidden_one_void_out_stun:IsPurgeException() return true end



function lua_modifier_hidden_one_void_out_stun:GetStatusEffectName()
    return "particles/status_fx/status_effect_void_spirit_aether_remnant.vpcf"
end



function lua_modifier_hidden_one_void_out_stun:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN]= true
    }
end





















-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
lua_modifier_hidden_one_void_out_vulnerable = class({})



function lua_modifier_hidden_one_void_out_vulnerable:IsDebuff() return true end
function lua_modifier_hidden_one_void_out_vulnerable:IsHidden() return false end
function lua_modifier_hidden_one_void_out_vulnerable:IsPurgable() return true end
function lua_modifier_hidden_one_void_out_vulnerable:IsPurgeException() return true end



function lua_modifier_hidden_one_void_out_vulnerable:GetEffectName()
    return "particles/units/heroes/hero_rubick/rubick_fade_bolt_debuff.vpcf"
end



































-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
lua_modifier_hidden_one_void_out_passive = class({})



function lua_modifier_hidden_one_void_out_passive:IsDebuff() return false end
function lua_modifier_hidden_one_void_out_passive:IsHidden() return true end
function lua_modifier_hidden_one_void_out_passive:IsPurgable() return false end
function lua_modifier_hidden_one_void_out_passive:IsPurgeException() return false end
function lua_modifier_hidden_one_void_out_passive:RemoveOnDeath() return false end
function lua_modifier_hidden_one_void_out_passive:AllowIllusionDuplicate() return true end


function lua_modifier_hidden_one_void_out_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
    }
end



function lua_modifier_hidden_one_void_out_passive:GetModifierProcAttack_BonusDamage_Physical(event)
    if not IsServer() then return end

    if self:GetParent() ~= event.attacker then return end

    if event.target:IsBaseNPC() == false then return end

    if event.target:IsAlive() == false then return end

    if event.target:HasModifier("lua_modifier_hidden_one_void_out_vulnerable") == false then return end

    return self:GetAbility():GetSpecialValueFor("vulnerable_damage")
end
