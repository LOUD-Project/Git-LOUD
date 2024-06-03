local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XRS0204 = Class(CSubUnit) {

    Weapons = {
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
    },
	
    OnCreate = function(self)
	
        CSubUnit.OnCreate(self)
		
        self:SetMaintenanceConsumptionActive()

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end
		
    end,
}

TypeClass = XRS0204