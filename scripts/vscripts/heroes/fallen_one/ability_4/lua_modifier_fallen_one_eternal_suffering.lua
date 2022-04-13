lua_modifier_fallen_one_eternal_suffering = class({})


function lua_modifier_fallen_one_eternal_suffering:IsHidden() return false end
function lua_modifier_fallen_one_eternal_suffering:IsDebuff() return true end
function lua_modifier_fallen_one_eternal_suffering:IsPurgable() return false end
function lua_modifier_fallen_one_eternal_suffering:IsPurgeException() return true end
function lua_modifier_fallen_one_eternal_suffering:GetDisableHealing() return 1 end


function lua_modifier_fallen_one_eternal_suffering:DeclareFunctions()
    return {MODIFIER_PROPERTY_DISABLE_HEALING}
end


function lua_modifier_fallen_one_eternal_suffering:CheckState()
    return {[MODIFIER_STATE_SPECIALLY_UNDENIABLE] = true}
end


function lua_modifier_fallen_one_eternal_suffering:OnCreated(kv)

    if not IsServer() then return end

    self:GetParent():EmitSound("Hero_DoomBringer.Doom")

    if not self.doom then
        self.doom = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,self:GetParent()
        )
        ParticleManager:SetParticleControl(self.doom,0,self:GetParent():GetAbsOrigin())
    end

    if not self.burn then
        self.burn = ParticleManager:CreateParticle(
            "particles/units/heroes/fallen_one/ability_4/fallen_one_eternal_suffering.vpcf",
            PATTACH_POINT_FOLLOW,self:GetParent()
        )
        ParticleManager:SetParticleControl(self.burn,0,self:GetParent():GetAbsOrigin())
    end

    self:StartIntervalThink(1.0)
    self:OnIntervalThink()
end


function lua_modifier_fallen_one_eternal_suffering:OnIntervalThink()

    if not IsServer() then return end

    local pure_dot = self:GetAbility():GetSpecialValueFor("pure_dot")

    if self:GetCaster():HasScepter() then
        local scepter_stack = self:GetCaster():FindModifierByName("lua_modifier_fallen_one_eternal_suffering_scepter")
        if not scepter_stack == false then
            pure_dot = pure_dot + scepter_stack:GetStackCount()
        end
    end

    local dtable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = pure_dot,
        damage_type = DAMAGE_TYPE_PURE,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self:GetAbility()
    }
    ApplyDamage(dtable)

end


function lua_modifier_fallen_one_eternal_suffering:OnDestroy()

    if not IsServer() then return end

    self:GetParent():StopSound("Hero_DoomBringer.Doom")

    if not self.doom == false then
        ParticleManager:DestroyParticle(self.doom,false)
        ParticleManager:ReleaseParticleIndex(self.doom)
        self.doom = nil
    end

    if not self.burn == false then
        ParticleManager:DestroyParticle(self.burn,false)
        ParticleManager:ReleaseParticleIndex(self.burn)
        self.burn = nil
    end
end















--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
lua_modifier_fallen_one_eternal_suffering_scepter = class({})


function lua_modifier_fallen_one_eternal_suffering_scepter:IsDebuff() return false end
function lua_modifier_fallen_one_eternal_suffering_scepter:IsPurgable() return false end
function lua_modifier_fallen_one_eternal_suffering_scepter:IsPurgeException() return false end
function lua_modifier_fallen_one_eternal_suffering_scepter:RemoveOnDeath() return false end


function lua_modifier_fallen_one_eternal_suffering_scepter:IsHidden()
    if self:GetParent():HasScepter() then
        return false
    end
    return true
end


function lua_modifier_fallen_one_eternal_suffering_scepter:DeclareFunctions()
    local dfunc = {
        MODIFIER_EVENT_ON_HERO_KILLED,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return dfunc
end


function lua_modifier_fallen_one_eternal_suffering_scepter:OnHeroKilled(event)
    if not IsServer() then return end

    if self:GetParent():HasScepter() == false then return end

    if event.target:HasModifier("lua_modifier_fallen_one_eternal_suffering") then
        self:IncrementStackCount()
    end

end



function lua_modifier_fallen_one_eternal_suffering_scepter:OnTakeDamage(event)
    if not IsServer() then return end

    if self:GetParent():HasScepter() == false then return end

    if event.attacker ~= self:GetParent() then return end

    if event.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        if event.inflictor:GetName() == "lua_ability_fallen_one_eternal_suffering" then return end
    end

    local doom = event.unit:FindModifierByName("lua_modifier_fallen_one_eternal_suffering")
    if not doom then return end

    doom:ForceRefresh()
end
