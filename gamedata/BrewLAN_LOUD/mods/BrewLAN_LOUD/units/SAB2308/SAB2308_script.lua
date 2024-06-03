local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

SAB2308 = Class(AStructureUnit) {

    Weapons = {
        TorpedoLauncher = Class(AANChronoTorpedoWeapon) {},
    },

	OnCreate = function(self)

		AStructureUnit.OnCreate(self)

        for i, v in {0.85, 0.45} do
            self.DomeEntity = import('/lua/sim/Entity.lua').Entity({Owner = self,})
            self.DomeEntity:AttachBoneTo( -1, self, 'UAB2205' )
            self.DomeEntity:SetMesh('/effects/Entities/UAB2205_Dome/UAB2205_Dome_mesh')
            self.DomeEntity:SetDrawScale(v)
            self.DomeEntity:SetVizToAllies('Intel')
            self.DomeEntity:SetVizToNeutrals('Intel')
            self.DomeEntity:SetVizToEnemies('Intel')
            self.Trash:Add(self.DomeEntity)
        end
	end,
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		AStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

	end,	    
}

TypeClass = SAB2308
