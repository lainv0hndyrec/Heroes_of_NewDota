lua_modifier_generic_change_projectile_speed= class({})

function lua_modifier_generic_change_projectile_speed:IsHidden() return true end
function lua_modifier_generic_change_projectile_speed:IsDebuff() return false end
function lua_modifier_generic_change_projectile_speed:IsPurgable() return false end
function lua_modifier_generic_change_projectile_speed:IsPurgeException() return false end
function lua_modifier_generic_change_projectile_speed:RemoveOnDeath() return false end
function lua_modifier_generic_change_projectile_speed:AllowIllusionDuplicate() return true end


function lua_modifier_generic_change_projectile_speed:DeclareFunctions()
    return {MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS}
end


function lua_modifier_generic_change_projectile_speed:OnCreated(kv)
    if not IsServer() then return end
    self.original_proj_speed = self:GetParent():GetProjectileSpeed()
end



function lua_modifier_generic_change_projectile_speed:GetModifierProjectileSpeedBonus()
    if IsServer() then

        if not self.original_proj_speed then return end

        local new_proj_speed = self:GetAbility().Projectile_Speed
        local diff = new_proj_speed - self.original_proj_speed

        if self:GetParent():IsIllusion() then
            local original_hero = self:GetParent():GetReplicatingOtherHero()
            if not original_hero then return end

            local original_modifier = original_hero:FindModifierByName("lua_modifier_generic_change_projectile_speed")
            if not original_modifier then return end

            diff = original_modifier:GetStackCount()
        end

        self:SetStackCount(diff)
    end

    return self:GetStackCount()
end
