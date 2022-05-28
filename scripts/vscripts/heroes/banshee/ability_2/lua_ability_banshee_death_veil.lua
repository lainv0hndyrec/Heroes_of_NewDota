LinkLuaModifier( "lua_modifier_banshee_death_veil_wall", "heroes/banshee/ability_2/lua_modifier_banshee_death_veil", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_modifier_banshee_death_veil_particle", "heroes/banshee/ability_2/lua_modifier_banshee_death_veil", LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier( "lua_modifier_whistlepunk_sawprise_vt", "heroes/whistlepunk/ability_4/lua_modifier_whistlepunk_sawprise", LUA_MODIFIER_MOTION_NONE )


lua_ability_banshee_death_veil = class({})


function lua_ability_banshee_death_veil:GetAOERadius()
    local aoe_radius = self:GetLevelSpecialValueFor("wall_length",0)
    local talent = self:GetCaster():FindAbilityByName("special_bonus_banshee_death_veil_length_up")
    if not talent == false then
        if talent:GetLevel() > 0 then
            aoe_radius = aoe_radius + talent:GetSpecialValueFor("value")
        end
    end
    return aoe_radius
end


function lua_ability_banshee_death_veil:GetCastRange(location,target)
    local cast_range = self:GetLevelSpecialValueFor("cast_range",0)
    return cast_range
end


function lua_ability_banshee_death_veil:GetCooldown(lvl)
    local ability_cd = self:GetLevelSpecialValueFor("ability_cd",lvl)
    return ability_cd
end


function lua_ability_banshee_death_veil:GetManaCost(lvl)
    local mana_cost = self:GetLevelSpecialValueFor("mana_cost",lvl)
    return mana_cost
end




function lua_ability_banshee_death_veil:OnUpgrade()
    self.cast_position = Vector(0,0,0)
    self.vector_position = Vector(0,0,0)
    self.vector_direction = Vector(0,0,0)

end



function lua_ability_banshee_death_veil:CastFilterResultLocation(pos)
    if not IsServer() then return end
    self.vector_position = self.cast_position
    self.cast_position = pos

    return UF_SUCCESS
end



function lua_ability_banshee_death_veil:OnAbilityPhaseStart()
    if not IsServer() then return end

    self.vector_direction = (self.vector_position - self.cast_position):Normalized()
    self.vector_direction.z = 0

    if self.vector_direction:Length2D() == 0 then
        return false
    end

    return true
end



function lua_ability_banshee_death_veil:OnSpellStart()
    if not IsServer() then return end

    local radius = self:GetAOERadius()
    local wall_width = self:GetSpecialValueFor("wall_width")
    local hwidth = wall_width*0.5
    radius = radius - hwidth

    local loop = math.ceil(radius/hwidth)
    local wall_time = self:GetSpecialValueFor("wall_duration")



    local center = self.cast_position
    local adjust = 0
    local adjust_otherside = 0


    for i=1, loop do

        adjust = center + (self.vector_direction*i*hwidth)
        adjust_otherside = center + (-self.vector_direction*i*hwidth)

        CreateModifierThinker(
            self:GetCaster(),self,"lua_modifier_banshee_death_veil_wall",
            {duration = wall_time, wall_radius = wall_width},
            adjust,self:GetCaster():GetTeam(),false
        )

        CreateModifierThinker(
            self:GetCaster(),self,"lua_modifier_banshee_death_veil_wall",
            {duration = wall_time,wall_radius = wall_width},
            adjust_otherside,self:GetCaster():GetTeam(),false
        )

    end

    --center
    CreateModifierThinker(
        self:GetCaster(),self,"lua_modifier_banshee_death_veil_wall",
        {duration = wall_time,wall_radius = wall_width},
        center,self:GetCaster():GetTeam(),false
    )



    --wall particle
    adjust = adjust + (self.vector_direction*hwidth)
    adjust_otherside = adjust_otherside + (-self.vector_direction*hwidth)
    CreateModifierThinker(
        self:GetCaster(),self,"lua_modifier_banshee_death_veil_particle",
        {
            duration = wall_time,
            end_x = adjust_otherside.x,
            end_y = adjust_otherside.y,
            end_z = adjust_otherside.z
        },
        adjust,self:GetCaster():GetTeam(),false
    )





    self.cast_position = Vector(0,0,0)
    self.vector_position = Vector(0,0,0)
    self.vector_direction = Vector(0,0,0)


end
