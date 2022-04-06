LinkLuaModifier( "lua_modifier_qaldin_assassin_qaldin_eye_truesight", "heroes/qaldin_assassin/ability_2/lua_modifier_qaldin_assassin_qaldin_eye", LUA_MODIFIER_MOTION_NONE )


lua_modifier_qaldin_assassin_qaldin_eye_ward = class({})


function lua_modifier_qaldin_assassin_qaldin_eye_ward:IsHidden() return true end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:IsDebuff() return false end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:IsPurgable() return false end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:IsPurgeException() return false end


function lua_modifier_qaldin_assassin_qaldin_eye_ward:IsAura() return true end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetAuraDuration() return 0.0 end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetAuraRadius() return self:GetParent():GetDayTimeVisionRange() end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_OTHER end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:IsAuraActiveOnDeath() return false end
function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetModifierAura()
    return "lua_modifier_qaldin_assassin_qaldin_eye_truesight"
end





function lua_modifier_qaldin_assassin_qaldin_eye_ward:CheckState()

    local is_invi = true

    if self:GetStackCount() > 0 then
        is_invi = false
    end

    local cstate = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
        [MODIFIER_STATE_INVISIBLE] = is_invi
    }

    return cstate
end


function lua_modifier_qaldin_assassin_qaldin_eye_ward:DeclareFunctions()
    local dfunc = {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_EVENT_ON_TAKEDAMAGE

    }
    return dfunc
end


function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetBonusDayVision()
    return self.ward_vision
end


function lua_modifier_qaldin_assassin_qaldin_eye_ward:GetBonusNightVision()
    return self.ward_vision
end



function lua_modifier_qaldin_assassin_qaldin_eye_ward:OnTakeDamage(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end

    local current_time = math.max(GameRules:GetDOTATime(false,false),0.0)
    local gbounty = 100+(math.floor(current_time/60)*4)
    local xbounty = 50+(math.floor(current_time/60)*6)

    self:GetParent():SetMinimumGoldBounty(gbounty)
    self:GetParent():SetMaximumGoldBounty(gbounty)
    self:GetParent():SetDeathXP(xbounty)

end



function lua_modifier_qaldin_assassin_qaldin_eye_ward:OnCreated(kv)

    self.ward_vision = self:GetAbility():GetSpecialValueFor("ward_vision")

    if not IsServer() then return end
    self:StartIntervalThink(0.1)
    self:OnIntervalThink()
end




function lua_modifier_qaldin_assassin_qaldin_eye_ward:OnIntervalThink()
    if not IsServer() then return end

    local ward_unhide_range = self:GetAbility():GetSpecialValueFor("ward_unhide_range")
    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),self:GetParent():GetAbsOrigin(),nil,
        ward_unhide_range,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,FIND_ANY_ORDER,false
    )

    self:SetStackCount(#enemies)
end















lua_modifier_qaldin_assassin_qaldin_eye_truesight = class({})


function lua_modifier_qaldin_assassin_qaldin_eye_truesight:IsHidden() return true end
function lua_modifier_qaldin_assassin_qaldin_eye_truesight:IsDebuff() return true end
function lua_modifier_qaldin_assassin_qaldin_eye_truesight:IsPurgable() return false end
function lua_modifier_qaldin_assassin_qaldin_eye_truesight:IsPurgeException() return false end
function lua_modifier_qaldin_assassin_qaldin_eye_truesight:GetPriority() return MODIFIER_PRIORITY_ULTRA end


function lua_modifier_qaldin_assassin_qaldin_eye_truesight:CheckState()
    return {[MODIFIER_STATE_INVISIBLE] = false}
end
