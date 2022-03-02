-- Generated from template

if HeroesOfNewdota == nil then
	HeroesOfNewdota = class({})
end

require("game_setup")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
		PrecacheResource( "model", "*.vmdl", context )
		PrecacheResource( "soundfile", "*.vsndevts", context )
		PrecacheResource( "particle", "*.vpcf", context )
		PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	--PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context )
end


-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = HeroesOfNewdota()
	GameRules.AddonTemplate:InitGameMode()

end


--------------------------------------
--------------------------------------
--------------------------------------
--Initialize the game
function HeroesOfNewdota:InitGameMode()
	GameSetup:ready()
end
