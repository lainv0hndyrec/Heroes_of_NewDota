LinkLuaModifier( "lua_modifier_pope_of_pestilence_exorcismus_stacks", "heroes/pope_of_pestilence/ability_1/lua_modifier_pope_of_pestilence_exorcismus", LUA_MODIFIER_MOTION_NONE )



lua_ability_pope_of_pestilence_exorcismus = class({})



function lua_ability_pope_of_pestilence_exorcismus:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_pope_of_pestilence_exorcismus:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_pope_of_pestilence_exorcismus:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end


function lua_ability_pope_of_pestilence_exorcismus:OnUnStolen()
    local stack_mod = self:GetCaster():FindModifierByName("lua_modifier_pope_of_pestilence_exorcismus_stacks")
    if not stack_mod == false then
        stack_mod:Destroy()
    end
end





function lua_ability_pope_of_pestilence_exorcismus:OnUpgrade()
    if not IsServer() then return end

    if self:GetCaster():HasAbility("lua_ability_pope_of_pestilence_exorcismus") == false then return end

    if self:GetLevel() <= 0 then return end

    local stack_mod = self:GetCaster():FindModifierByName("lua_modifier_pope_of_pestilence_exorcismus_stacks")
    if not stack_mod then
        stack_mod = self:GetCaster():AddNewModifier(
            self:GetCaster(),self,
            "lua_modifier_pope_of_pestilence_exorcismus_stacks",
            {duration = 0.1}
        )
        stack_mod:SetStackCount(1)
    end

    stack_mod:SetStackCount(stack_mod:GetStackCount())

end




function lua_ability_pope_of_pestilence_exorcismus:OnSpellStart()
    if not IsServer() then return end

    local stack_mod = self:GetCaster():FindModifierByName("lua_modifier_pope_of_pestilence_exorcismus_stacks")
    if not stack_mod == false then

        stack_mod:DecrementStackCount()

        self:EndCooldown()

        if stack_mod:GetStackCount() <= 0 then
            self:StartCooldown(stack_mod:GetRemainingTime())
        end
    end


    self:GetCaster():EmitSound("DOTA_Item.VeilofDiscord.Activate")

    local ptable = {
        vSourceLoc = self:GetCaster():GetAbsOrigin(),
        Target = self:GetCursorTarget(),
        iMoveSpeed = self:GetSpecialValueFor("proj_speed"),
        flExpireTime = GameRules:GetGameTime() + 10.0,
        bDodgeable = true,
        bIsAttack = false,
        bReplaceExisting = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
        bDrawsOnMinimap = false,
        bVisibleToEnemies = true,
        EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        bProvidesVision = false
    }

    ProjectileManager:CreateTrackingProjectile(ptable)
end



function lua_ability_pope_of_pestilence_exorcismus:OnProjectileHit(target,pos)
    if not IsServer() then return end

    if not target then return true end

    if target:IsMagicImmune() then return true end

    if target:TriggerSpellAbsorb(self) then return true end

    if target:IsAlive() == false then return true end

    local dmg = self:GetSpecialValueFor("ability_damage")
    local dtable = {
        victim = target,
        attacker = self:GetCaster(),
        damage = dmg,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = self
    }
    ApplyDamage(dtable)

    target:AddNewModifier(
        self:GetCaster(),self,
        "modifier_stunned",
        {duration = self:GetSpecialValueFor("ability_stun")}
    )

    if self:GetCaster():IsAlive() then

        local skull_mod = self:GetCaster():FindModifierByName("lua_modifier_pope_of_pestilence_banish_skull")
        if not skull_mod == false then

            local normal = self:GetCaster():GetAbsOrigin() - target:GetAbsOrigin()
            local add_pos = normal:Normalized()*100
            add_pos.z = 0
            skull_mod:CreateASkull(target:GetAbsOrigin()+add_pos)
        end

    end

    return true
end
