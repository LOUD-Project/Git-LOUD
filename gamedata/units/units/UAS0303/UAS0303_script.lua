local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local WeaponsFile = import('/lua/aeonweapons.lua')
local AAAZealotMissileWeapon = WeaponsFile.AAAZealotMissileWeapon

UAS0303 = Class(ASeaUnit) {

    Weapons = {
	
        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
		
    },

    BuildAttachBone = 'UAS0303',

    OnStopBeingBuilt = function(self,builder,layer)
	
        ASeaUnit.OnStopBeingBuilt(self,builder,layer)
		
        ChangeState(self, self.IdleState)
		
    end,

    OnFailedToBuild = function(self)
	
        ASeaUnit.OnFailedToBuild(self)
		
        ChangeState(self, self.IdleState)
		
    end,

    IdleState = State {
	
        Main = function(self)
            self:DetachAll(self.BuildAttachBone)
            self:SetBusy(false)
        end,

        OnStartBuild = function(self, unitBuilding, order)
		
            ASeaUnit.OnStartBuild(self, unitBuilding, order)
			
            self.UnitBeingBuilt = unitBuilding
			
            ChangeState(self, self.BuildingState)
			
        end,
    },

    BuildingState = State {
	
        Main = function(self)
		
            local unitBuilding = self.UnitBeingBuilt
			
            self:SetBusy(true)
			
            local bone = self.BuildAttachBone
			
            self:DetachAll(bone)
			
            unitBuilding:HideBone(0, true)
            self.UnitDoneBeingBuilt = false
			
        end,

        OnStopBuild = function(self, unitBeingBuilt)
		
            ASeaUnit.OnStopBuild(self, unitBeingBuilt)
			
            ChangeState(self, self.FinishedBuildingState)
			
        end,
    },

    FinishedBuildingState = State {
	
        Main = function(self)
		
            self:SetBusy(true)
			
            local unitBuilding = self.UnitBeingBuilt
			
            unitBuilding:DetachFrom(true)
			
            self:DetachAll(self.BuildAttachBone)
			
            if self:TransportHasAvailableStorage() then
			
                self:AddUnitToStorage(unitBuilding)
				
            else
			
                local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
				
                IssueMoveOffFactory({unitBuilding}, worldPos)
				
                unitBuilding:ShowBone(0,true)
				
            end
			
            self:SetBusy(false)
			
            self:RequestRefreshUI()
			
            ChangeState(self, self.IdleState)
			
        end,
		
    },
}

TypeClass = UAS0303

