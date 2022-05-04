LinkLuaModifier( "lua_modifier_great_sage_somersault_cloud_act_cloudrun", "heroes/great_sage/ability_4/lua_modifier_great_sage_somersault_cloud", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_great_sage_somersault_cloud_act_arcana", "heroes/great_sage/ability_4/lua_modifier_great_sage_somersault_cloud", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_great_sage_somersault_cloud_act_run", "heroes/great_sage/ability_4/lua_modifier_great_sage_somersault_cloud", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_great_sage_somersault_cloud_bonus", "heroes/great_sage/ability_4/lua_modifier_great_sage_somersault_cloud", LUA_MODIFIER_MOTION_NONE)




lua_modifier_great_sage_somersault_cloud = class({})

function lua_modifier_great_sage_somersault_cloud:IsHidden() return true end
function lua_modifier_great_sage_somersault_cloud:IsDebuff() return false end
function lua_modifier_great_sage_somersault_cloud:IsPurgable() return false end
function lua_modifier_great_sage_somersault_cloud:IsPurgeException() return false end
function lua_modifier_great_sage_somersault_cloud:RemoveOnDeath() return false end
function lua_modifier_great_sage_somersault_cloud:AllowIllusionDuplicate() return true end



function lua_modifier_great_sage_somersault_cloud:DeclareFunctions()
    local dfuncs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return dfuncs
end


function lua_modifier_great_sage_somersault_cloud:OnTakeDamage(event)

    if not IsServer() then return end

    if event.unit ~= self:GetParent() then return end
    if event.attacker == self:GetParent() then return end

    if event.attacker:IsHero() == false then return end

    self:RemoveCloud()

    local cd = self:GetAbility():GetEffectiveCooldown(0)
    self:GetAbility():StartCooldown(cd)
    self:StartIntervalThink(cd)
end


function lua_modifier_great_sage_somersault_cloud:OnCreated(kv)
    if not IsServer() then return end
    self:SpawnCloud()
end


function lua_modifier_great_sage_somersault_cloud:SpawnCloud()

    if not self.cloudrun then
        self.cloudrun = self:GetParent():AddNewModifier(
            self:GetParent(),self:GetAbility(),"lua_modifier_great_sage_somersault_cloud_act_cloudrun",{}
        )
    end

    if not self.arcana then
        self.arcana = self:GetParent():AddNewModifier(
            self:GetParent(),self:GetAbility(),"lua_modifier_great_sage_somersault_cloud_act_arcana",{}
        )
    end

    if not self.run then
        self.run = self:GetParent():AddNewModifier(
            self:GetParent(),self:GetAbility(),"lua_modifier_great_sage_somersault_cloud_act_run",{}
        )
    end

    if not self.bonus then
        self.bonus = self:GetParent():AddNewModifier(
            self:GetParent(),self:GetAbility(),"lua_modifier_great_sage_somersault_cloud_bonus",{}
        )
    end


    if not self.particle then
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/great_sage/ability_4/cloud_ride.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent()
        )

        ParticleManager:SetParticleControlEnt(
            self.particle,0,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,"attach_cloud",self:GetParent():GetAbsOrigin(),true
        )
    end
end


function lua_modifier_great_sage_somersault_cloud:RemoveCloud()

    if not self.cloudrun == false then
        self.cloudrun:Destroy()
        self.cloudrun = nil
    end

    if not self.arcana == false then
        self.arcana:Destroy()
        self.arcana = nil
    end

    if not self.run == false then
        self.run:Destroy()
        self.run = nil
    end

    if not self.bonus == false then
        self.bonus:Destroy()
        self.bonus = nil
    end

    if not self.particle == false then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
end


function lua_modifier_great_sage_somersault_cloud:OnIntervalThink()
    if not IsServer() then return end
    if self:GetAbility():IsCooldownReady() then
        self:SpawnCloud()
        self:StartIntervalThink(-1)
    else

        local current_cd = self:GetAbility():GetCooldownTimeRemaining()
        self:StartIntervalThink(current_cd)
    end
end


function lua_modifier_great_sage_somersault_cloud:OnDestroy()
    if not IsServer() then return end
    --remove on death
    self:RemoveCloud()
    self:StartIntervalThink(-1)
end



------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
lua_modifier_great_sage_somersault_cloud_act_cloudrun = class({})

function lua_modifier_great_sage_somersault_cloud_act_cloudrun:IsHidden() return true end
function lua_modifier_great_sage_somersault_cloud_act_cloudrun:IsDebuff() return false end
function lua_modifier_great_sage_somersault_cloud_act_cloudrun:IsPurgable() return false end
function lua_modifier_great_sage_somersault_cloud_act_cloudrun:IsPurgeException() return false end
function lua_modifier_great_sage_somersault_cloud_act_cloudrun:RemoveOnDeath() return false end
function lua_modifier_great_sage_somersault_cloud_act_cloudrun:AllowIllusionDuplicate() return true end

function lua_modifier_great_sage_somersault_cloud_act_cloudrun:DeclareFunctions()
    return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function lua_modifier_great_sage_somersault_cloud_act_cloudrun:GetActivityTranslationModifiers()
    return "cloudrun"
end




------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
lua_modifier_great_sage_somersault_cloud_act_arcana = class({})

function lua_modifier_great_sage_somersault_cloud_act_arcana:IsHidden() return true end
function lua_modifier_great_sage_somersault_cloud_act_arcana:IsDebuff() return false end
function lua_modifier_great_sage_somersault_cloud_act_arcana:IsPurgable() return false end
function lua_modifier_great_sage_somersault_cloud_act_arcana:IsPurgeException() return false end
function lua_modifier_great_sage_somersault_cloud_act_arcana:RemoveOnDeath() return false end
function lua_modifier_great_sage_somersault_cloud_act_arcana:AllowIllusionDuplicate() return true end

function lua_modifier_great_sage_somersault_cloud_act_arcana:DeclareFunctions()
    return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function lua_modifier_great_sage_somersault_cloud_act_arcana:GetActivityTranslationModifiers()
    return "arcana"
end




------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
lua_modifier_great_sage_somersault_cloud_act_run = class({})

function lua_modifier_great_sage_somersault_cloud_act_run:IsHidden() return true end
function lua_modifier_great_sage_somersault_cloud_act_run:IsDebuff() return false end
function lua_modifier_great_sage_somersault_cloud_act_run:IsPurgable() return false end
function lua_modifier_great_sage_somersault_cloud_act_run:IsPurgeException() return false end
function lua_modifier_great_sage_somersault_cloud_act_run:RemoveOnDeath() return false end
function lua_modifier_great_sage_somersault_cloud_act_run:AllowIllusionDuplicate() return true end

function lua_modifier_great_sage_somersault_cloud_act_run:DeclareFunctions()
    return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function lua_modifier_great_sage_somersault_cloud_act_run:GetActivityTranslationModifiers()
    return "run"
end



------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
lua_modifier_great_sage_somersault_cloud_bonus = class({})

function lua_modifier_great_sage_somersault_cloud_bonus:IsHidden() return true end
function lua_modifier_great_sage_somersault_cloud_bonus:IsDebuff() return false end
function lua_modifier_great_sage_somersault_cloud_bonus:IsPurgable() return false end
function lua_modifier_great_sage_somersault_cloud_bonus:IsPurgeException() return false end
function lua_modifier_great_sage_somersault_cloud_bonus:RemoveOnDeath() return false end
function lua_modifier_great_sage_somersault_cloud_bonus:AllowIllusionDuplicate() return true end


function lua_modifier_great_sage_somersault_cloud_bonus:DeclareFunctions()
    local dfuncs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return dfuncs
end


function lua_modifier_great_sage_somersault_cloud_bonus:GetModifierMoveSpeedBonus_Percentage()

    local ms = self:GetAbility():GetSpecialValueFor("ms_percent")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_great_sage_somersault_cloud_ms_bonus")
    if not talent == false then
        if talent:GetLevel() > 0 then
            ms = ms + talent:GetSpecialValueFor("value")
        end
    end

    return ms
end


function lua_modifier_great_sage_somersault_cloud_bonus:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen")
end


function lua_modifier_great_sage_somersault_cloud_bonus:GetModifierConstantHealthRegen()
    if self:GetParent():HasModifier("modifier_item_aghanims_shard") == false then
        return 0
    end
    return self:GetAbility():GetSpecialValueFor("mana_regen")
end
