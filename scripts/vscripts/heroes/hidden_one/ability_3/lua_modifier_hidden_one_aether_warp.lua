lua_modifier_hidden_one_aether_warp_invulnerable = class({})

function lua_modifier_hidden_one_aether_warp_invulnerable:IsDebuff() return false end
function lua_modifier_hidden_one_aether_warp_invulnerable:IsHidden() return true end
function lua_modifier_hidden_one_aether_warp_invulnerable:IsPurgable() return false end
function lua_modifier_hidden_one_aether_warp_invulnerable:IsPurgeException() return false end


function lua_modifier_hidden_one_aether_warp_invulnerable:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true
    }
end



function lua_modifier_hidden_one_aether_warp_invulnerable:OnCreated(kv)
    if not IsServer() then return end

    if not kv.tele_x then
        self:Destroy()
        return
    end

    self:GetParent():EmitSound("Hero_VoidSpirit.AstralStep.Target")

    self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3)

    self.tele_pos = Vector(kv.tele_x,kv.tele_y,kv.tele_z)

    self:StartIntervalThink(0.3)
end

function lua_modifier_hidden_one_aether_warp_invulnerable:OnIntervalThink()
    if not IsServer() then return end
    self:GetParent():AddNoDraw()
    self:StartIntervalThink(-1)
end



function lua_modifier_hidden_one_aether_warp_invulnerable:OnDestroy()
    if not IsServer() then return end

    self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3_END)

    FindClearSpaceForUnit(self:GetParent(),self.tele_pos,true)

    self:GetParent():RemoveNoDraw()

end











-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
lua_modifier_hidden_one_aether_warp_start = class({})

function lua_modifier_hidden_one_aether_warp_start:IsDebuff() return false end
function lua_modifier_hidden_one_aether_warp_start:IsHidden() return true end
function lua_modifier_hidden_one_aether_warp_start:IsPurgable() return false end
function lua_modifier_hidden_one_aether_warp_start:IsPurgeException() return false end




function lua_modifier_hidden_one_aether_warp_start:OnCreated(kv)
    if not IsServer() then return end

    --emit sound
    self:GetParent():EmitSound("Hero_VoidSpirit.AstralStep.Start")

    --destory tree
    GridNav:DestroyTreesAroundPoint(
        self:GetParent():GetAbsOrigin(),
        self:GetAbility():GetAOERadius(),
        true
    )


    --aoe damage
    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")
    local aoe_damage = self:GetAbility():GetSpecialValueFor("aoe_damage")

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),self:GetParent():GetAbsOrigin(),nil,
        self:GetAbility():GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )

    for i=1,#enemies do
        if not ult == false then
            if ult:GetLevel() > 0 then
                ult:ApplyVoidOutModifier(enemies[i],self:GetAbility())
            end
        end

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = aoe_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }

        ApplyDamage(dtable)
    end

    --particle
    local particle =  ParticleManager:CreateParticle(
        "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,1,Vector(self:GetAbility():GetAOERadius()-100,0,0))
    ParticleManager:ReleaseParticleIndex(particle)

end



function lua_modifier_hidden_one_aether_warp_start:OnDestroy()
    if not IsServer() then return end

    UTIL_Remove(self:GetParent())
end











-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
lua_modifier_hidden_one_aether_warp_end = class({})

function lua_modifier_hidden_one_aether_warp_end:IsDebuff() return false end
function lua_modifier_hidden_one_aether_warp_end:IsHidden() return true end
function lua_modifier_hidden_one_aether_warp_end:IsPurgable() return false end
function lua_modifier_hidden_one_aether_warp_end:IsPurgeException() return false end




function lua_modifier_hidden_one_aether_warp_end:OnCreated(kv)
    if not IsServer() then return end

    --particle

    self.particle =  ParticleManager:CreateParticle(
        "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(self.particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle,1,Vector(self:GetAbility():GetAOERadius(),0,0))

    local invulnerable_time = self:GetAbility():GetSpecialValueFor("invulnerable_time")
    self:StartIntervalThink(invulnerable_time)

end




function lua_modifier_hidden_one_aether_warp_end:OnIntervalThink()
    if not IsServer() then return end

    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil

    self:GetParent():EmitSound("Hero_VoidSpirit.AstralStep.Start")

    --destory tree
    GridNav:DestroyTreesAroundPoint(
        self:GetParent():GetAbsOrigin(),
        self:GetAbility():GetAOERadius(),
        true
    )


    --aoe damage
    local ult = self:GetCaster():FindAbilityByName("lua_ability_hidden_one_void_out")
    local aoe_damage = self:GetAbility():GetSpecialValueFor("aoe_damage")

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),self:GetParent():GetAbsOrigin(),nil,
        self:GetAbility():GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )

    for i=1,#enemies do
        if not ult == false then
            if ult:GetLevel() > 0 then
                ult:ApplyVoidOutModifier(enemies[i],self:GetAbility())
            end
        end

        local dtable = {
            victim = enemies[i],
            attacker = self:GetCaster(),
            damage = aoe_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
            ability = self
        }

        ApplyDamage(dtable)
    end


    --particle
    local particle =  ParticleManager:CreateParticle(
        "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf",
        PATTACH_ABSORIGIN,self:GetParent()
    )
    ParticleManager:SetParticleControl(particle,0,self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle,1,Vector(self:GetAbility():GetAOERadius()-100,0,0))
    ParticleManager:ReleaseParticleIndex(particle)


    self:StartIntervalThink(-1)
end




function lua_modifier_hidden_one_aether_warp_end:OnDestroy()
    if not IsServer() then return end
    UTIL_Remove(self:GetParent())
end
