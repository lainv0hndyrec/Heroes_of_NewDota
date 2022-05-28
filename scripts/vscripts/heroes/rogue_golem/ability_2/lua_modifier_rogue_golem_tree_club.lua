


lua_modifier_rogue_golem_tree_club_buff = class({})


function lua_modifier_rogue_golem_tree_club_buff:IsDebuff() return false end
function lua_modifier_rogue_golem_tree_club_buff:IsHidden() return false end
function lua_modifier_rogue_golem_tree_club_buff:IsPurgable() return false end
function lua_modifier_rogue_golem_tree_club_buff:IsPurgeException() return false end


function lua_modifier_rogue_golem_tree_club_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
    }
end


function lua_modifier_rogue_golem_tree_club_buff:OnCreated(kv)
    if not IsServer() then return end

    if not kv.got_tree then return end

    local attacks = self:GetAbility():GetSpecialValueFor("max_attacks")
    local talent = self:GetParent():FindAbilityByName("special_bonus_rogue_golem_tree_club_max_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            attacks = attacks + talent:GetSpecialValueFor("value")
        end
    end

    self:SetStackCount(attacks)

    if not self.tree == false then return end
    self.tree = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny/tiny_tree/tiny_tree.vmdl"})
    self.tree:FollowEntity(self:GetCaster(), true)

end


function lua_modifier_rogue_golem_tree_club_buff:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_rogue_golem_tree_club_buff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_atk_damage")
end



function lua_modifier_rogue_golem_tree_club_buff:OnAttackLanded(event)
    if not IsServer() then return end

    if event.attacker ~= self:GetParent() then return end
    if event.target:IsBaseNPC() == false then return end
    self:DecrementStackCount()


    local debri = ParticleManager:CreateParticle(
        "particles/econ/items/tiny/tiny_prestige/tiny_prestige_tree_melee_flek.vpcf",
        PATTACH_POINT,event.target
    )
    ParticleManager:SetParticleControlEnt(debri,0,event.target,PATTACH_POINT,"attach_hitloc",Vector(0,0,0),false)
    ParticleManager:SetParticleControlEnt(debri,2,event.target,PATTACH_POINT,"attach_hitloc",Vector(0,0,0),false)



    if self:GetStackCount() >= 1 then return end

    if event.target:IsAlive() then
        if event.target:IsBuilding() == false then
            if event.target:IsMagicImmune() == false then

                local chuck = self:GetCaster():FindAbilityByName("lua_ability_rogue_golem_tree_chuck")
                if not chuck == false then

                    local mini_stun = chuck:GetSpecialValueFor("mini_stun")
                    local slow_duration = chuck:GetSpecialValueFor("slow_duration")
                    local shard = self:GetParent():HasModifier("modifier_item_aghanims_shard")
                    if shard == true then
                        mini_stun = chuck:GetSpecialValueFor("shard_stun")
                        slow_duration = slow_duration + chuck:GetSpecialValueFor("slow_duration")
                    end

                    event.target:AddNewModifier(
                        self:GetParent(),chuck,"modifier_stunned",
                        {duration = mini_stun}
                    )

                    event.target:AddNewModifier(
                        self:GetParent(),chuck,"lua_modifier_rogue_golem_tree_chuck_slow",
                        {duration = slow_duration}
                    )

                end
            end
        end
    end

    self:Destroy()
end



function lua_modifier_rogue_golem_tree_club_buff:GetActivityTranslationModifiers()
    return "tree"
end



function lua_modifier_rogue_golem_tree_club_buff:GetAttackSound()
    return "Hero_Tiny.Tree.Target"
end


function lua_modifier_rogue_golem_tree_club_buff:OnDestroy()
    if not IsServer() then return end

    local chuck = self:GetCaster():FindAbilityByName("lua_ability_rogue_golem_tree_chuck")
    if not chuck == false then
        if chuck:IsHidden() == false then
            chuck:SetHidden(true)
        end
    end

    if not self.tree == false then
		UTIL_Remove(self.tree)
        self.tree = nil
    end
end

















-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

lua_modifier_rogue_golem_tree_chuck_slow = class({})

function lua_modifier_rogue_golem_tree_chuck_slow:IsDebuff() return true end
function lua_modifier_rogue_golem_tree_chuck_slow:IsHidden() return false end
function lua_modifier_rogue_golem_tree_chuck_slow:IsPurgable() return true end
function lua_modifier_rogue_golem_tree_chuck_slow:IsPurgeException() return true end


function lua_modifier_rogue_golem_tree_chuck_slow:GetEffectName()
    return "particles/units/heroes/hero_primal_beast/primal_beast_slow_debuff.vpcf"
end


function lua_modifier_rogue_golem_tree_chuck_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end


function lua_modifier_rogue_golem_tree_chuck_slow:OnCreated(kv)

    if not IsServer() then return end

    local slow  = self:GetAbility():GetSpecialValueFor("tapering_slow_percent")

    self:SetStackCount(slow)

    self.interval  = (self:GetStackCount()/self:GetDuration())*0.1

    self:StartIntervalThink(0.1)

end


function lua_modifier_rogue_golem_tree_chuck_slow:OnRefresh(kv)
    self:OnCreated(kv)
end


function lua_modifier_rogue_golem_tree_chuck_slow:OnIntervalThink()
    local stacks = self:GetStackCount() - self.interval
    self:SetStackCount(stacks)
end


function lua_modifier_rogue_golem_tree_chuck_slow:GetModifierMoveSpeedBonus_Percentage()
    return -self:GetStackCount()
end
