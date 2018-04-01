#****************************************************************************
#**
#**  File     :  /lua/shield.lua
#**  Author(s):  John Comes, Gordon Duclos
#**
#**  Summary  : Shield lua module
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

do

local Entity = import('/lua/sim/Entity.lua').Entity
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Util = import('utilities.lua')

PersonalHunkerShield = Class(Shield) {

    OnCreate = function(self,spec)
		
	LOG('sheild spec' .. repr(spec))
		

        self.Trash = TrashBag()
        self.Owner = spec.Owner       
        self.CollisionSizeX = spec.CollisionSizeX or 1
		self.CollisionSizeY = spec.CollisionSizeY or 1
		self.CollisionSizeZ = spec.CollisionSizeZ or 1
		self.CollisionCenterX = spec.CollisionCenterX or 0
		self.CollisionCenterY = spec.CollisionCenterY or 0
		self.CollisionCenterZ = spec.CollisionCenterZ or 0
		self.OwnerShieldMesh = spec.OwnerShieldMesh or ''

		self:SetSize(spec.Size or 20)
		
        self:SetMaxHealth(spec.ShieldMaxHealth)
        self:SetHealth(self,spec.ShieldMaxHealth)

        # Show our 'lifebar'
        self:UpdateShieldRatio(-1)
        
        self:SetRechargeTime(spec.ShieldRechargeTime or 5, spec.ShieldEnergyDrainRechargeTime or 5)

				
        self:SetVizToFocusPlayer('Always')
        self:SetVizToEnemies('Intel')
        self:SetVizToAllies('Always')
        self:SetVizToNeutrals('Always')

        self:AttachBoneTo(-1,spec.Owner,-1)
		
		self:SetVerticalOffset(spec.ShieldVerticalOffset)

        self:SetShieldRegenRate(spec.ShieldRegenRate)
        self:SetShieldRegenStartTime(spec.ShieldRegenStartTime)

        self.PassOverkillDamage = spec.PassOverkillDamage
        
        ChangeState(self, self.OnState)

		
    end,
	
	OnDamage =  function(self,instigator,amount,vector,type)
	
	end, 

    CreateImpactEffect = function(self, vector)
        
    end,

    CreateShieldMesh = function(self)
		self:SetCollisionShape( 'Box', self.CollisionCenterX, self.CollisionCenterY, self.CollisionCenterZ, self.CollisionSizeX, self.CollisionSizeY, self.CollisionSizeZ)
		self.Owner:SetMesh(self.OwnerShieldMesh,true)
    end,

    RemoveShield = function(self)
        self:SetCollisionShape('None')
		self.Owner:SetMesh(self.Owner:GetBlueprint().Display.MeshBlueprint, true)
    end,

    OnDestroy = function(self)
        if not self.Owner.MyShield or self.Owner.MyShield:GetEntityId() == self:GetEntityId() then
	        self.Owner:SetMesh(self.Owner:GetBlueprint().Display.MeshBlueprint, true)
		end
		self:UpdateShieldRatio(0)
        ChangeState(self, self.DeadState)
    end,
        
}

DomeHunkerShield = Class(Shield) {

	OnCreate = function(self,spec)

		self.Trash = TrashBag()
		self.Owner = spec.Owner
		self.MeshBp = spec.Mesh
		self.MeshZBp = spec.MeshZ
		self.ImpactMeshBp = spec.ImpactMesh
		
		if spec.ImpactEffects and EffectTemplate[spec.ImpactEffects] then
			self.ImpactEffects = EffectTemplate[spec.ImpactEffects]
		else
			self.ImpactEffects = {}
		end

		self:SetSize(spec.Size)
		self:SetMaxHealth(spec.ShieldMaxHealth)
		self:SetHealth(self,spec.ShieldMaxHealth)

		# Show our 'lifebar'
		self:UpdateShieldRatio(-1)

		self:SetRechargeTime(spec.ShieldRechargeTime or 5, spec.ShieldEnergyDrainRechargeTime or 5)
		self:SetVerticalOffset(spec.ShieldVerticalOffset)

		self:SetVizToFocusPlayer('Always')
		self:SetVizToEnemies('Intel')
		self:SetVizToAllies('Always')
		self:SetVizToNeutrals('Intel')

		self:AttachBoneTo(-1,spec.Owner,-1)

		self:SetShieldRegenRate(spec.ShieldRegenRate)
		self:SetShieldRegenStartTime(spec.ShieldRegenStartTime)

		self.OffHealth = -1
		
		self.PassOverkillDamage = spec.PassOverkillDamage

		ChangeState(self, self.OnState)
	end,
	
	OnCollisionCheckWeapon = function(self, firingWeapon)
		return true
	end,

	OnCollisionCheck = function(self,other)
		if other:GetArmy() == -1 then
			return true
		end

		return true
	end,
}

end
