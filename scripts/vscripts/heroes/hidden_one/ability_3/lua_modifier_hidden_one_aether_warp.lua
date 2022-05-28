lua_modifier_hidden_one_aether_warp_invulnerable = class({})

function lua_modifier_hidden_one_aether_warp_invulnerable:IsDebuff() return false end
function lua_modifier_hidden_one_aether_warp_invulnerable:IsHidden() return true end
function lua_modifier_hidden_one_aether_warp_invulnerable:IsPurgable() return false end
function lua_modifier_hidden_one_aether_warp_invulnerable:IsPurgeException() return false end


function lua_modifier_hidden_one_aether_warp_invulnerable:CheckState()
    if self:GetStackCount() <= 0 then return end

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

    print(kv.tele_x)

    if not kv.tele_x then
        self:Destroy()
        return
    end

    if not kv.delay_damage then
        self:Destroy()
        return
    end

    self.delay_damage = kv.delay_damage

    self.tele_pos = Vector(kv.tele_x,kv.tele_y,kv.tele_z)

    --self:GetParent():AddNoDraw()

    self:SetStackCount(1)

    --particle
    if not self.start_particle then
        self.start_particle =  ParticleManager:CreateParticle(
            "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate.vpcf",
            PATTACH_ABSORIGIN,self:GetParent()
        )
        ParticleManager:SetParticleControl(self.start_particle,0,self.tele_pos)
        ParticleManager:SetParticleControl(self.start_particle,1,Vector(self:GetAbility():GetAOERadius(),0,0))
    end

    local invul_time = self:GetAbility():GetSpecialValueFor("invulnerable_time")
    self:StartIntervalThink(invul_time)
end




function lua_modifier_hidden_one_aether_warp_invulnerable:OnIntervalThink()
    if not IsServer() then return end

    self:SetStackCount(0)

    if not self.start_particle == false then
        ParticleManager:DestroyParticle(self.start_particle,false)
        ParticleManager:ReleaseParticleIndex(self.start_particle)
        self.start_particle = nil
    end

    --self:GetParent():RemoveNoDraw()

    --teleport
    FindClearSpaceForUnit(self:GetParent(),self.tele_pos,true)

    --aoe damage
    local ult = self:GetParent():FindAbilityByName("lua_ability_hidden_one_void_out")

    local enemies = FindUnitsInRadius(
        self:GetParent():GetTeam(),self.tele_pos,nil,
        self:GetAbility():GetAOERadius(),DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false
    )

    for i=1,#enemies do

        if not ult == false then
            if ult:GetLevel() > 0 then
                ult:ApplyVoidOutModifier(enemies[i],self)
            end
        end

        local dtable = {
            victim = enemies[i],
            attacker = self:GetParent(),
            damage = self.delay_damage,
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
    ParticleManager:SetParticleControl(particle,0,self.tele_pos)
    ParticleManager:SetParticleControl(particle,1,Vector(self:GetAbility():GetAOERadius()-100,0,0))

    self:StartIntervalThink(-1)
end
