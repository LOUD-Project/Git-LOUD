local AAirUnit = import('/lua/defaultunits.lua').AirUnit
local aWeapons = import('/lua/aeonweapons.lua')
local AQuantumBeamGenerator = aWeapons.AQuantumBeamGenerator
local AAAZealotMissileWeapon = aWeapons.AAAZealotMissileWeapon
local AANDepthChargeBombWeapon = aWeapons.AANDepthChargeBombWeapon
local AAATemporalFizzWeapon = aWeapons.AAATemporalFizzWeapon

local explosion = import('/lua/defaultexplosions.lua')

local LOUDSTATE = ChangeState

UAA0310 = Class(AAirUnit) {
    DestroyNoFallRandomChance = 1.1,
    Weapons = {

        QuantumBeamGeneratorWeapon = Class(AQuantumBeamGenerator){},
		
        AA_Missile = Class(AAAZealotMissileWeapon) {},
		
        DepthCharge = Class(AANDepthChargeBombWeapon) {},
		
        AAFizz = Class(AAATemporalFizzWeapon) {},
    },

    OnKilled = function(self, instigator, type, overkillRatio)
	
        local wep = self:GetWeaponByLabel('QuantumBeamGeneratorWeapon')
		
        for k, v in wep.Beams do
            v.Beam:Disable()
        end

        self.detector = CreateCollisionDetector(self)
		
        self.Trash:Add(self.detector)
		
        self.detector:WatchBone('Left_Turret01_Muzzle')
        self.detector:WatchBone('Right_Turret01_Muzzle')
        self.detector:WatchBone('Left_Turret02_WepFocus')
        self.detector:WatchBone('Right_Turret02_WepFocus')
        self.detector:WatchBone('Left_Turret03_Muzzle')
        self.detector:WatchBone('Right_Turret03_Muzzle')
        self.detector:WatchBone('Attachpoint01')
        self.detector:WatchBone('Attachpoint02')
		
        self.detector:EnableTerrainCheck(true)
		
        self.detector:Enable()

        AAirUnit.OnKilled(self, instigator, type, overkillRatio)
		
        if self.UnitBeingBuilt and not self.UnitBeingBuilt:BeenDestroyed() and self.UnitBeingBuilt:GetFractionComplete() != 1 then
            self.UnitBeingBuilt:Destroy()
        end
    end,

    OnAnimTerrainCollision = function(self, bone,x,y,z)
	
        DamageArea(self, {x,y,z}, 5, 1000, 'Default', true, false)
		
        explosion.CreateDefaultHitExplosionAtBone( self, bone, 5.0 )
		
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})
    end,

    BuildAttachBone = 'UAA0310',

    OnStopBeingBuilt = function(self,builder,layer)
        AAirUnit.OnStopBeingBuilt(self,builder,layer)
        LOUDSTATE(self, self.IdleState)
    end,

    OnFailedToBuild = function(self)
        AAirUnit.OnFailedToBuild(self)
        LOUDSTATE(self, self.IdleState)
    end,

    IdleState = State {
        Main = function(self)
            self:DetachAll(self.BuildAttachBone)
            self:SetBusy(false)
        end,

        OnStartBuild = function(self, unitBuilding, order)
            AAirUnit.OnStartBuild(self, unitBuilding, order)
            self.UnitBeingBuilt = unitBuilding
            LOUDSTATE(self, self.BuildingState)
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

        OnStopBuild = function(self, UnitBeingBuilt)
            AAirUnit.OnStopBuild(self, UnitBeingBuilt)
            LOUDSTATE(self, self.FinishedBuildingState)
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
			self.UnitBeingBuilt = false
            LOUDSTATE(self, self.IdleState)
        end,
    },
}

TypeClass = UAA0310