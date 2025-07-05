local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local Torpedo = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XRS0204 = Class(CSubUnit) {

    Weapons = {
        Torpedo = Class(Torpedo) {

            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)

                    self:ForkThread( function() self:ChangeMaxRadius(50) self:ChangeMinRadius(50) WaitTicks(32) self:ChangeMinRadius(8) self:ChangeMaxRadius(48) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },
        },
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
        
        self.DeathWeaponEnabled = true
		
    end,
}

TypeClass = XRS0204