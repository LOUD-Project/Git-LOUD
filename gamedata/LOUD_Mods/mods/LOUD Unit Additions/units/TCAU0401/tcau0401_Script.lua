local TAirUnit = import('/lua/terranunits.lua').TAirUnit

local TWeapons = import('/lua/terranweapons.lua')
local TIFSmallYieldNuclearBombWeapon = TWeapons.TIFSmallYieldNuclearBombWeapon
local TSAMLauncher = TWeapons.TSAMLauncher

tcau0401 = Class(TAirUnit) {

    BeamExhaustCruise = '/effects/emitters/transport_thruster_beam_01_emit.bp',
    BeamExhaustIdle = '/effects/emitters/transport_thruster_beam_02_emit.bp',

    Weapons = {
	
        Bomb = Class(TIFSmallYieldNuclearBombWeapon) {},
        Missile = Class(TSAMLauncher) {},

    },
}

TypeClass = tcau0401