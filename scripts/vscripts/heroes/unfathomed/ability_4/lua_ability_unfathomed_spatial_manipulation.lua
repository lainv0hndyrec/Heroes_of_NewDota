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
    return self:GetSpecialValueFor("ability_range")
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

    local effect_distance = self:GetSpecialValueFor("effect_distance")
    if self:GetCaster():HasScepter() then
        effect_distance = effect_distance+self:GetSpecialValueFor("scepter_distance")
    end

    local vision_range = self:GetSpecialValueFor("vision_range")
    local vision_time = self:GetSpecialValueFor("vision_time")
    local is_push = false --pull if false
    local eorder_ability = self:GetCaster():FindAbilityByName("lua_ability_unfathomed_ethereal_order")
    if not eorder_ability == false then
        is_push = eorder_ability:GetToggleState()
    end


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
        if enemy:IsMagicImmune() == false then
            if enemy:TriggerSpellAbsorb(self) == false then

                local e_pos = enemy:GetAbsOrigin()
                local diff = e_pos - origin_pos
                local distance = diff:Length2D()
                local normal = diff:Normalized()
                local direction = effect_distance*normal
                local new_pos = e_pos
                local fdistance = 0

                if is_push == true then
                    normal = -1*normal
                    new_pos = normal*effect_distance
                    fdistance = effect_distance
                else
                    if effect_distance < distance then
                        new_pos = normal*effect_distance
                        fdistance = effect_distance
                    else
                        new_pos = normal*distance
                        fdistance = distance
                    end
                end

                --particle
                local particle = ParticleManager:CreateParticle("particles/units/heroes/unfathomed/ability_2/yield_preimage.vpcf", PATTACH_ABSORIGIN, enemy)
            	ParticleManager:SetParticleControl(particle, 0, e_pos)
            	ParticleManager:SetParticleControl(particle, 1, e_pos-new_pos)
            	ParticleManager:SetParticleControlEnt(particle, 2, enemy, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", enemy:GetForwardVector(), true)
                if is_push == true then
                    ParticleManager:SetParticleControl(particle,60,Vector(255,0,255))
                else
                    ParticleManager:SetParticleControl(particle,60,Vector(0,255,255))
                end
                ParticleManager:ReleaseParticleIndex(particle)

                --destroy trees
                local hull = enemy:GetHullRadius()*3
                local loop = math.ceil(fdistance/hull)
                local valid_pos = e_pos
                for i=0,loop,1 do
                    local g_pos = e_pos - (i*normal*hull)
                    GridNav:DestroyTreesAroundPoint(
                        g_pos,
                        hull*2,
                        false
                    )

                    if GridNav:IsTraversable(g_pos) then
                        valid_pos = g_pos
                    end
                end


                --teleport
                FindClearSpaceForUnit(
                    enemy,
                    valid_pos,
                    false
                )


                AddFOWViewer(
                    self:GetCaster():GetTeamNumber(),
                    valid_pos,
                    vision_range,
                    vision_time,
                    false
                )


                self:GetCaster():EmitSound("Hero_Enigma.Black_Hole.Stop")

            end
        end
    end

end


--createhero npc_dota_hero_axe enemy
