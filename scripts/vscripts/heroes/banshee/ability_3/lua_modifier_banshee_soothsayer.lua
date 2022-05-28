
LinkLuaModifier( "lua_modifier_banshee_soothsayer_regen", "heroes/banshee/ability_3/lua_modifier_banshee_soothsayer", LUA_MODIFIER_MOTION_NONE )



lua_modifier_banshee_soothsayer_aura = class({})


function lua_modifier_banshee_soothsayer_aura:IsDebuff() return false end
function lua_modifier_banshee_soothsayer_aura:IsHidden() return true end
function lua_modifier_banshee_soothsayer_aura:IsPurgable() return false end
function lua_modifier_banshee_soothsayer_aura:IsPurgeException() return false end
function lua_modifier_banshee_soothsayer_aura:RemoveOnDeath() return false end

function lua_modifier_banshee_soothsayer_aura:IsAura() return true end
function lua_modifier_banshee_soothsayer_aura:GetAuraRadius() return 99999 end
function lua_modifier_banshee_soothsayer_aura:IsAuraActiveOnDeath() return false end
function lua_modifier_banshee_soothsayer_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function lua_modifier_banshee_soothsayer_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function lua_modifier_banshee_soothsayer_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function lua_modifier_banshee_soothsayer_aura:GetModifierAura()
    if self:GetParent():PassivesDisabled() then return end
    return "lua_modifier_banshee_soothsayer_regen"
end










-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

lua_modifier_banshee_soothsayer_regen = class({})

function lua_modifier_banshee_soothsayer_regen:IsDebuff() return false end
function lua_modifier_banshee_soothsayer_regen:IsHidden() return false end
function lua_modifier_banshee_soothsayer_regen:IsPurgable() return false end
function lua_modifier_banshee_soothsayer_regen:IsPurgeException() return false end


function lua_modifier_banshee_soothsayer_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
end


function lua_modifier_banshee_soothsayer_regen:GetModifierConstantHealthRegen()

    if not IsServer() then

        local maxhp = self:GetParent():GetMaxHealth()
        local percent = self:GetAbility():GetSpecialValueFor("pecent_hp_regen")*0.01
        local base_regen = self:GetAbility():GetSpecialValueFor("base_hp_regen")

        local total = base_regen + math.ceil(maxhp*percent)
        self:SetStackCount(total)

    end

    return self:GetStackCount()

end
