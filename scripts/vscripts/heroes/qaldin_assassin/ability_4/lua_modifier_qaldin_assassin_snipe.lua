lua_modifier_qaldin_assassin_snipe_marker = class({})

function lua_modifier_qaldin_assassin_snipe_marker:IsHidden() return true end
function lua_modifier_qaldin_assassin_snipe_marker:IsDebuff() return true end
function lua_modifier_qaldin_assassin_snipe_marker:IsPurgable() return false end
function lua_modifier_qaldin_assassin_snipe_marker:IsPurgeException() return false end

function lua_modifier_qaldin_assassin_snipe_marker:OnCreated(kv)
    if not IsServer() then return end
    self:StartIntervalThink(0.1)

    if not self.particle then
        self.particle = ParticleManager:CreateParticleForTeam(
            "particles/units/heroes/qaldin_assassin/qaldin_assassin_snipe_crosshair.vpcf",
            PATTACH_OVERHEAD_FOLLOW,self:GetParent(),self:GetCaster():GetTeam()
        )

        ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    end


end


function lua_modifier_qaldin_assassin_snipe_marker:OnIntervalThink()
    if not IsServer() then return end

    if self:GetParent():IsAlive() == false then
        self:Interrupt_The_Ability()
        return
    end

    if self:GetCaster():IsAlive() == false then
        self:Interrupt_The_Ability()
        return
    end

    local cast_range = self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(),self:GetParent())
    local max_range = cast_range+self:GetAbility():GetSpecialValueFor("range_check")

    local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
    if self:GetCaster():HasScepter() then
        target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS
    end

    local find_self = FindUnitsInRadius(
        self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),
        nil,max_range,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        target_flags,FIND_ANY_ORDER,false
    )

    local interrupt = true

    for i = 1, #find_self do
        if find_self[i] == self:GetParent() then
            interrupt = false
            break
        end
    end

    if interrupt == true then
        self:Interrupt_The_Ability()
    end

end


function lua_modifier_qaldin_assassin_snipe_marker:Interrupt_The_Ability()
    self:StartIntervalThink(-1)
    self:GetCaster():Interrupt()
    self:Destroy()
end


function lua_modifier_qaldin_assassin_snipe_marker:OnDestroy()
    if not IsServer() then return end

    if not self.particle then return end

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil

end


















--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
lua_modifier_qaldin_assassin_snipe_slow = class({})

function lua_modifier_qaldin_assassin_snipe_slow:IsHidden() return false end
function lua_modifier_qaldin_assassin_snipe_slow:IsDebuff() return true end
function lua_modifier_qaldin_assassin_snipe_slow:IsPurgable() return true end
function lua_modifier_qaldin_assassin_snipe_slow:IsPurgeException() return true end


function lua_modifier_qaldin_assassin_snipe_slow:GetEffectName()
    return "particles/units/heroes/hero_monkey_king/monkey_king_spring_slow.vpcf"
end


function lua_modifier_qaldin_assassin_snipe_slow:GetEffectAttachType()
    return PATTACH_ABSORIGIN
end


function lua_modifier_qaldin_assassin_snipe_slow:CheckState()
    return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end


function lua_modifier_qaldin_assassin_snipe_slow:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end


function lua_modifier_qaldin_assassin_snipe_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetAbility():GetSpecialValueFor("ms_slow_percent")
end
