local MobileUnit = import('/lua/defaultunits.lua').MobileUnit

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashAdd = TrashBag.Add

SSS0306 = Class(MobileUnit) {

    Weapons = {
        TorpedoTurrets = Class(import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		MobileUnit.OnStopBeingBuilt(self,builder,layer)
--[[        
        -- create Torp Defense/TMD emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
--]]
	end,	
}

TypeClass = SSS0306
