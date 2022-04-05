local TCivilianStructureUnit = import('/lua/defaultunits.lua').StructureUnit

UEC1401 = Class(TCivilianStructureUnit) {

	OnCreate = function(self)
		TCivilianStructureUnit.OnCreate(self)
        self.WindowEntity = import('/lua/sim/Entity.lua').Entity({Owner = self,})
        self.WindowEntity:AttachBoneTo( -1, self, 'UEC1401' )
        self.WindowEntity:SetMesh('/effects/Entities/UEC1401_WINDOW/UEC1401_WINDOW_mesh')
        self.WindowEntity:SetDrawScale(0.1)
        self.WindowEntity:SetVizToAllies('Intel')
        self.WindowEntity:SetVizToNeutrals('Intel')
        self.WindowEntity:SetVizToEnemies('Intel')        
        self.Trash:Add(self.WindowEntity)
	end,
	
}


TypeClass = UEC1401

