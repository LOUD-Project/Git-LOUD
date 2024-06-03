local SSonarUnit = import('/lua/seraphimunits.lua').SSonarUnit

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

XSS0305 = Class(SSonarUnit) {

    TimedSonarTTIdleEffects = {
        { Bones = {0}, Type = 'SonarBuoy01' },
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        SSonarUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitters
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
    end,
}

TypeClass = XSS0305
