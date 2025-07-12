local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AA = import('/lua/aeonweapons.lua').AAATemporalFizzWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashAdd = TrashBag.Add

BAB2304 = Class(AStructureUnit) {

    Weapons = {
        AntiMissile = Class(AA) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)

        AStructureUnit.OnStopBeingBuilt(self,builder,layer)

        -- create MissileTorp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

	end,

}

TypeClass = BAB2304