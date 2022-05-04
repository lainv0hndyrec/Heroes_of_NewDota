LinkLuaModifier( "lua_modifier_unfathomed_spatial_manipulation", "heroes/unfathomed/ability_4/lua_modifier_unfathomed_spatial_manipulation", LUA_MODIFIER_MOTION_HORIZONTAL)

lua_ability_unfathomed_spatial_manipulation = class({})




function lua_ability_unfathomed_spatial_manipulation:GetCooldown(lvl)

    local cd = 0

    local caster = self:GetCaster()

    if not caster then return cd end

    cd = self:GetSpecialValueFor("ability_cd")

    if self:GetCaster():HasScepter() then
        cd = cd - self:GetSpecialValueFor("scepter_cd")
    end

    return cd

end



function lua_ability_unfathomed_spatial_manipulation:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("scepter_range")
    end
    return self:GetLevelSpecialValueFor("ability_range",0)
end




function lua_ability_unfathomed_spatial_manipulation:GetCastRange(location,target)

    local range = 0

    local caster = self:GetCaster()

    if not caster then return range end

    range = self:GetAOERadius()

    return range

end




function lua_ability_unfathomed_spatial_manipulation:OnSpellStart()

    local origin_pos = self:GetCaster():GetAbsOrigin()

    self:GetCaster():EmitSound("Hero_Enigma.Black_Hole.Stop")

    local enemies = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),
        origin_pos,
        nil,
        self:GetAOERadius(),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )



    for _,enemy in pairs(enemies) do

        enemy:EmitSound("Hero_Enigma.Black_Hole.Stop")

        if enemy:IsMagicImmune() == false then
            if enemy:TriggerSpellAbsorb(self) == false then
                enemy:AddNewModifier(
                    self:GetCaster(),
                    self,
                    "lua_modifier_unfathomed_spatial_manipulation",
                    {duration = 0.1}
                )
            end
        end

    end

end


--createhero npc_dota_hero_axe enemy
