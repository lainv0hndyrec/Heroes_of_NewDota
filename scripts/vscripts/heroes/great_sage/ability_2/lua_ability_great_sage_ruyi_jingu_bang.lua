LinkLuaModifier( "lua_modifier_great_sage_ruyi_jingu_bang_timer", "heroes/great_sage/ability_2/lua_modifier_great_sage_ruyi_jingu_bang", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "lua_modifier_great_sage_ruyi_jingu_bang_vault", "heroes/great_sage/ability_2/lua_modifier_great_sage_ruyi_jingu_bang", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "lua_modifier_great_sage_ruyi_jingu_bang_pull", "heroes/great_sage/ability_2/lua_modifier_great_sage_ruyi_jingu_bang", LUA_MODIFIER_MOTION_HORIZONTAL)



lua_ability_great_sage_ruyi_jingu_bang = class({})


-- function lua_ability_great_sage_ruyi_jingu_bang:OnAbilityPhaseStart()
--     if self:GetCursorTarget():IsNull() then return end
--
--     if self:GetCursorTarget():IsAlive() == false  then return end
--
--     if self:GetCursorTarget() == self:GetCaster() then return false end
--     return true
-- end


function lua_ability_great_sage_ruyi_jingu_bang:CastFilterResultTarget(target)
    if not IsServer() then return end

    if target:IsCourier() then return UF_FAIL_COURIER end
    if target:IsOther() then return UF_FAIL_OTHER end
    if target:IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():IsAlive() == false then return UF_FAIL_DEAD end
    if self:GetCaster():CanEntityBeSeenByMyTeam(target) == false then return UF_FAIL_IN_FOW end
    if target:IsInvisible() then return UF_FAIL_INVISIBLE end
    if target:IsOutOfGame() then return UF_FAIL_OUT_OF_WORLD end
    if target == self:GetCaster() then return UF_FAIL_CUSTOM end

    return UF_SUCCESS
end


function lua_ability_great_sage_ruyi_jingu_bang:GetCustomCastErrorTarget(target)
    if target == self:GetCaster() then
        return "Invalid Target"
    end
end




function lua_ability_great_sage_ruyi_jingu_bang:OnSpellStart()
    if self:GetCursorTarget():IsNull() then return end

    if self:GetCursorTarget():IsAlive() == false  then return end

    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_ruyi_jingu_bang_timer")

    --Estimate the jump
    local jump = self:GetSpecialValueFor("unit_vault_distance")
    if self:GetCursorTarget():HasModifier("lua_modifier_great_sage_earth_driver_illu") then
        jump = self:GetSpecialValueFor("building_vault_distance")
    end
    if self:GetCursorTarget():IsBuilding() then
        jump = self:GetSpecialValueFor("building_vault_distance")
    end

    --Set Facing
    local diff = self:GetCursorTarget():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
    local facing = diff:Normalized()
    local length = diff:Length2D()


    if free_mod == false then

        if self:GetCursorTarget():TriggerSpellAbsorb(self) then return end


        --Apply Vault
        self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_great_sage_ruyi_jingu_bang_vault",
            {
                duration = self:GetSpecialValueFor("vault_animation"),
                vault_distance = jump+length,
                face_x = facing.x,
                face_y = facing.y,
                face_z = facing.z
            }
        )


        --Apply Pull
        if self:GetCursorTarget():IsBuilding() == false then
            if self:GetCursorTarget():GetTeam() ~= self:GetCaster():GetTeam() then
                self:GetCursorTarget():AddNewModifier(
                    self:GetCaster(),
                    self,
                    "lua_modifier_great_sage_ruyi_jingu_bang_pull",
                    {
                        duration = self:GetSpecialValueFor("pull_animation"),
                        unit_pull_distance = self:GetSpecialValueFor("enemy_pull_distance"),
                        face_x = -facing.x,
                        face_y = -facing.y,
                        face_z = facing.z
                    }
                )
            end
        end


        -- Create Free Cast Timer
        self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_great_sage_ruyi_jingu_bang_timer",
            {duration = self:GetSpecialValueFor("additional_cast_duration")}
        )

        --reset CD for another one
        self:EndCooldown()
        local cd = self:GetSpecialValueFor("vault_animation")
        self:StartCooldown(cd)

        return
    end



    --FREE CAST
    if free_mod == true then

        local timer_mod = self:GetCaster():FindModifierByName("lua_modifier_great_sage_ruyi_jingu_bang_timer")

        if self:GetCursorTarget():TriggerSpellAbsorb(self) then
            if not timer_mod then return end
            timer_mod:Destroy()
            return
        end


        --Apply Vault
        self:GetCaster():AddNewModifier(
            self:GetCaster(),
            self,
            "lua_modifier_great_sage_ruyi_jingu_bang_vault",
            {
                duration = self:GetSpecialValueFor("vault_animation"),
                vault_distance = jump+length,
                face_x = facing.x,
                face_y = facing.y,
                face_z = facing.z
            }
        )


        --Apply Pull
        if self:GetCursorTarget():IsBuilding() == false then
            if self:GetCursorTarget():GetTeam() ~= self:GetCaster():GetTeam() then
                self:GetCursorTarget():AddNewModifier(
                    self:GetCaster(),
                    self,
                    "lua_modifier_great_sage_ruyi_jingu_bang_pull",
                    {
                        duration = self:GetSpecialValueFor("pull_animation"),
                        unit_pull_distance = self:GetSpecialValueFor("enemy_pull_distance"),
                        face_x = -facing.x,
                        face_y = -facing.y,
                        face_z = facing.z
                    }
                )
            end
        end


        if not timer_mod then return end
        timer_mod:Destroy()

    end


end



function lua_ability_great_sage_ruyi_jingu_bang:GetCooldown(lvl)
    local cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_great_sage_ruyi_jingu_bang_cd_reduction")
    if not talent == false then
        if talent:GetLevel() > 0 then
            cd = cd - talent:GetSpecialValueFor("value")
        end
    end
    return cd
end



function lua_ability_great_sage_ruyi_jingu_bang:GetManaCost(lvl)
    local mana = self:GetLevelSpecialValueFor("ability_mana",lvl)
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_ruyi_jingu_bang_timer")
    if free_mod == true then
        mana = 0.0
    end

    return mana
end


function lua_ability_great_sage_ruyi_jingu_bang:GetCastRange(pos,target)
    local lvl = self:GetLevel()-1
    local range = self:GetLevelSpecialValueFor("cast_range",lvl)
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_ruyi_jingu_bang_timer")
    if free_mod == true then
        range = self:GetLevelSpecialValueFor("re_cast_range",lvl)
    end
    return range
end


function lua_ability_great_sage_ruyi_jingu_bang:GetAbilityTextureName()
    local free_mod = self:GetCaster():HasModifier("lua_modifier_great_sage_ruyi_jingu_bang_timer")
    if free_mod == true then
        return "great_sage_vault_free_cast"
    end
    return "monkey_king_jingu_mastery"
end
