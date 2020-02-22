local TSubUnit = import('/lua/terranunits.lua').TSubUnit

local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

local CreateBuildCubeThread = import('/lua/EffectUtilities.lua').CreateBuildCubeThread

UES0401 = Class(TSubUnit) {

    Weapons = {
	
        Torpedo = Class(TANTorpedoAngler) {},
        AA = Class(TSAMLauncher) {},
	},

    OnCreate = function(self)
	
        TSubUnit.OnCreate(self)
		
        self.OpenAnimManips = {}
        self.OpenAnimManips[1] = CreateAnimator(self):PlayAnim('/units/ues0401/ues0401_aopen.sca'):SetRate(-1)
		
        for i = 2, 6 do
            self.OpenAnimManips[i] = CreateAnimator(self):PlayAnim('/units/ues0401/ues0401_aopen0' .. i .. '.sca'):SetRate(-1)
        end
		
        for k, v in self.OpenAnimManips do
            self.Trash:Add(v)
        end
		
        if self:GetCurrentLayer() == 'Water' then
            self:PlayAllOpenAnims(true)
        end
		
    end,


    StartBeingBuiltEffects = function(self, builder, layer)
	
		self:SetMesh(self:GetBlueprint().Display.BuildMeshBlueprint, true)
		
        if self:GetBlueprint().General.UpgradesFrom != builder:GetUnitId() then
			self:HideBone(0, true)        
            self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag ))
        end
		
    end,  

    PlayAllOpenAnims = function(self, open)
	
        for k, v in self.OpenAnimManips do
		
            if open then
			
                v:SetRate(1)
				
            else
			
                v:SetRate(-1)
				
            end
			
        end
		
    end,

    OnMotionVertEventChange = function( self, new, old )
	
        TSubUnit.OnMotionVertEventChange(self, new, old)
		
        if new == 'Down' then
		
            self:PlayAllOpenAnims(false)
			
        elseif new == 'Top' then
		
            self:PlayAllOpenAnims(true)
			
        end
		
    end,

    BuildAttachBone = 'UES0401',

    OnStopBeingBuilt = function(self,builder,layer)
	
        TSubUnit.OnStopBeingBuilt(self,builder,layer)
		
        ChangeState(self, self.IdleState)
		
    end,

    OnFailedToBuild = function(self)
	
        TSubUnit.OnFailedToBuild(self)
		
        ChangeState(self, self.IdleState)
		
    end,

    IdleState = State {
	
        Main = function(self)
		
            self:DetachAll(self.BuildAttachBone)
            self:SetBusy(false)
			
        end,

        OnStartBuild = function(self, unitBuilding, order)
		
            TSubUnit.OnStartBuild(self, unitBuilding, order)
			
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
		
            TSubUnit.OnStopBuild(self, unitBeingBuilt)
			
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

TypeClass = UES0401