local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

UAB2205 = Class(AStructureUnit) {

    Weapons = {
        TorpedoLauncher = Class(AANChronoTorpedoWeapon) {},
    },
    
	OnCreate = function(self)
		AStructureUnit.OnCreate(self)

        self.DomeEntity = import('/lua/sim/Entity.lua').Entity({Owner = self,})
        self.DomeEntity:AttachBoneTo( -1, self, 'UAB2205' )
        self.DomeEntity:SetMesh('/effects/Entities/UAB2205_Dome/UAB2205_Dome_mesh')
        self.DomeEntity:SetDrawScale(0.45)
        self.DomeEntity:SetVizToAllies('Intel')
        self.DomeEntity:SetVizToNeutrals('Intel')
        self.DomeEntity:SetVizToEnemies('Intel')         
        self.Trash:Add(self.DomeEntity)
	end,    
}

TypeClass = UAB2205