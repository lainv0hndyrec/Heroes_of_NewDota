lua_modifier_boogeyman_devour_stacks = class({})


function lua_modifier_boogeyman_devour_stacks:IsDebuff() return false end
function lua_modifier_boogeyman_devour_stacks:IsHidden() return false end
function lua_modifier_boogeyman_devour_stacks:IsPurgable() return false end
function lua_modifier_boogeyman_devour_stacks:IsPurgeException() return false end
function lua_modifier_boogeyman_devour_stacks:AllowIllusionDuplicate() return true end
function lua_modifier_boogeyman_devour_stacks:RemoveOnDeath()
    if self:GetParent():IsIllusion() then
        return true
    end
    return false
end



function lua_modifier_boogeyman_devour_stacks:OnCreated(kv)
    if not IsServer() then return end
    self.vampire = false
    self.orbs = {}

    if self:GetParent():IsIllusion() == false then return end

    local original = self:GetParent():GetReplicatingOtherHero()
    local same_mod = original:FindModifierByName("lua_modifier_boogeyman_devour_stacks")
    if not same_mod then return end
    self:SetStackCount(same_mod:GetStackCount())
end


function lua_modifier_boogeyman_devour_stacks:DeclareFunctions()
    local dfunc ={
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_EVENT_ON_DEATH
    }
    return dfunc
end


function lua_modifier_boogeyman_devour_stacks:OnTakeDamage(event)
    if not IsServer() then return end
    if event.attacker ~= self:GetParent() then return end
    if not event.inflictor then return end
    if event.inflictor:GetName() ~= "lua_ability_boogeyman_devour" then return end

    self:GetParent():Heal(event.damage,self:GetAbility())
end


function lua_modifier_boogeyman_devour_stacks:OnDeath(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end
    self:SetStackCount(0)
end


function lua_modifier_boogeyman_devour_stacks:OnStackCountChanged(count)
    if not IsServer() then return end

    self:CreateOrbs()

    if self:GetStackCount() >= 3 then
        self:VampireMode(true)
        return
    end

    self:VampireMode(false)

end


function lua_modifier_boogeyman_devour_stacks:VampireMode(bool)
    if not IsServer() then return end

    if self.vampire == bool then return end

    self.vampire = bool

    --vamp
    if self.vampire == true then
        self:GetCaster():SetModel("models/heroes/nightstalker/nightstalker_night.vmdl")
    	self:GetCaster():SetOriginalModel("models/heroes/nightstalker/nightstalker_night.vmdl")

        if self.wings then
    		UTIL_Remove(self.wings)
            self.wings = nil
        end

        if self.legs then
    		UTIL_Remove(self.legs)
            self.legs = nil
        end

        if self.tail then
    		UTIL_Remove(self.tail)
            self.tail = nil
        end

    	self.wings = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/nightstalker/nightstalker_wings_night.vmdl"})
    	self.legs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/nightstalker/nightstalker_legarmor_night.vmdl"})
    	self.tail = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/nightstalker/nightstalker_tail_night.vmdl"})

    	self.wings:FollowEntity(self:GetCaster(), true)
    	self.legs:FollowEntity(self:GetCaster(), true)
    	self.tail:FollowEntity(self:GetCaster(), true)

        return
    end

    --normal
    self:GetCaster():SetModel("models/heroes/nightstalker/nightstalker.vmdl")
    self:GetCaster():SetOriginalModel("models/heroes/nightstalker/nightstalker.vmdl")

    if self.wings then
        UTIL_Remove(self.wings)
        self.wings = nil
    end

    if self.legs then
        UTIL_Remove(self.legs)
        self.legs = nil
    end

    if self.tail then
        UTIL_Remove(self.tail)
        self.tail = nil
    end

    self.wings = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/nightstalker/nightstalker_wings.vmdl"})
    self.legs = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/nightstalker/nightstalker_legarmor.vmdl"})
    self.tail = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/nightstalker/nightstalker_tail.vmdl"})

    self.wings:FollowEntity(self:GetCaster(), true)
    self.legs:FollowEntity(self:GetCaster(), true)
    self.tail:FollowEntity(self:GetCaster(), true)

end


function lua_modifier_boogeyman_devour_stacks:CreateOrbs()
    if not IsServer() then return end

    local stacks = self:GetStackCount()

    if stacks > #self.orbs then
        local diff = stacks - #self.orbs
        for i=1, diff do
            local orb = ParticleManager:CreateParticle(
                "particles/units/heroes/boogeyman/ability_4/blood_shard.vpcf",
                PATTACH_POINT_FOLLOW,self:GetParent()
            )

            local array = {-1,1}
            local ri = RandomInt(1,2)

            ParticleManager:SetParticleControl(orb,0,Vector(0,0,0))
            ParticleManager:SetParticleControl(orb,1,Vector(RandomFloat(-0.2,0.2),RandomFloat(-0.2,0.2),array[ri]))
            table.insert(self.orbs,orb)
        end
    end

    if stacks < #self.orbs then
        local diff = #self.orbs - stacks
        for i=1, diff do
            local orb = table.remove(self.orbs)
            ParticleManager:DestroyParticle(orb,false)
            ParticleManager:ReleaseParticleIndex(orb)
        end
    end
end


function lua_modifier_boogeyman_devour_stacks:OnDestroy()
    if not IsServer() then return end

    if self.wings then
        UTIL_Remove(self.wings)
        self.wings = nil
    end

    if self.legs then
        UTIL_Remove(self.legs)
        self.legs = nil
    end

    if self.tail then
        UTIL_Remove(self.tail)
        self.tail = nil
    end
end






















---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

lua_modifier_boogeyman_devour_debuff = class({})

function lua_modifier_boogeyman_devour_debuff:IsDebuff() return true end
function lua_modifier_boogeyman_devour_debuff:IsHidden() return true end
function lua_modifier_boogeyman_devour_debuff:IsPurgable() return false end
function lua_modifier_boogeyman_devour_debuff:IsPurgeException() return false end

function lua_modifier_boogeyman_devour_debuff:DeclareFunctions()
    local dfunc ={
        MODIFIER_EVENT_ON_DEATH
    }
    return dfunc
end

function lua_modifier_boogeyman_devour_debuff:OnDeath(event)
    if not IsServer() then return end
    if event.unit ~= self:GetParent() then return end

    local mod = self:GetCaster():FindModifierByName("lua_modifier_boogeyman_devour_stacks")
    if not mod then return end

    local cur_stacks = mod:GetStackCount()+1
    local max_stacks = self:GetAbility():GetSpecialValueFor("max_devour_stack")
    if self:GetCaster():HasScepter() then
        max_stacks = max_stacks + self:GetAbility():GetSpecialValueFor("scepter_devour_stack")
    end

    mod:SetStackCount(math.min(cur_stacks,max_stacks))

    if self:GetParent():IsHero() then
        if self:GetParent():IsIllusion() == false then
            mod:SetStackCount(max_stacks)
        end
    end

end
