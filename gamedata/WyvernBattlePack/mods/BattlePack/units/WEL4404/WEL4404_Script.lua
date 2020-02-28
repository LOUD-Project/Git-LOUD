local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local WeaponsFile = import('/lua/terranweapons.lua')

local BPPPlasmaPPCProj = import('/Mods/BattlePack/lua/BattlePackweapons.lua').BPPPlasmaPPCProj
local CybranFlameThrower = import('/Mods/BattlePack/lua/BattlePackweapons.lua').CybranFlameThrower
local StarAdderLaser = import('/Mods/BattlePack/lua/BattlePackweapons.lua').StarAdderLaser

WEL4404 = Class(TWalkingLandUnit) {

    Weapons = {
		FlameThrower = Class(CybranFlameThrower) {},
        BeamCannon = Class(StarAdderLaser) {},
        PlasmaPPC = Class(BPPPlasmaPPCProj) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetScriptBit('RULEUTC_StealthToggle', true)

    end,
    
}

TypeClass = WEL4404