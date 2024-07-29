--  /lua/shield.lua
-- Added support for hunker shields

local Entity = import('/lua/sim/Entity.lua').Entity
local EffectTemplate = import('/lua/EffectTemplates.lua')

local ChangeState = ChangeState

local LOUDENTITY    = EntityCategoryContains
local LOUDMAX       = math.max
local LOUDMIN       = math.min
local LOUDPARSE     = ParseEntityCategory	
local LOUDPOW       = math.pow
local LOUDSQRT      = math.sqrt

local TrashBag      = TrashBag
local TrashAdd      = TrashBag.Add
local WaitTicks     = coroutine.yield
local Warp          = Warp

local ForkThread = ForkThread
local ForkTo = ForkThread

local IsEnemy = IsEnemy
local KillThread = KillThread

local CreateEmitterAtBone = CreateEmitterAtBone

local VectorCached = { 0, 0, 0 }
	
local AdjustHealth      = moho.entity_methods.AdjustHealth
local GetArmy           = moho.entity_methods.GetArmy        
local GetBlueprint      = moho.entity_methods.GetBlueprint
local GetHealth         = moho.entity_methods.GetHealth
local GetMaxHealth      = moho.entity_methods.GetMaxHealth
local SetMesh           = moho.entity_methods.SetMesh

local GetArmorMult      = moho.unit_methods.GetArmorMult
local GetStat           = moho.unit_methods.GetStat
local SetStat           = moho.unit_methods.SetStat
local SetShieldRatio    = moho.unit_methods.SetShieldRatio

Shield = Class(moho.shield_methods,Entity) {

    ShieldVerticalOffset = -1,

    __init = function(self,spec)
        _c_CreateShield(self,spec)
    end,

    OnCreate = function( self, spec )

		self.Army = GetArmy(self)
		self.Dead = false
        
        if spec.ImpactEffects != '' then
			self.ImpactEffects = EffectTemplate[spec.ImpactEffects]
		else
			self.ImpactEffects = false
		end
        
        if spec.ImpactMesh != '' then
            self.ImpactMeshBp = spec.ImpactMesh
        else
            self.ImpactMeshBp = false
        end

        -- static table --
        self.ImpactEntitySpecs = { Owner = spec.Owner }
        
        self.MeshBp = spec.Mesh
        self.MeshZBp = spec.MeshZ

		self.OffHealth = -1
        
        self.Owner = spec.Owner
		self.PassOverkillDamage = spec.PassOverkillDamage
		
        self.ShieldRechargeTime = spec.ShieldRechargeTime or 5
        self.ShieldEnergyDrainRechargeTime = spec.ShieldEnergyDrainRechargeTime or 5
        
        self.ShieldVerticalOffset = spec.ShieldVerticalOffset

		self:SetSize(spec.Size)

        self:AttachBoneTo(-1,spec.Owner,-1)
		
        self:SetMaxHealth(spec.ShieldMaxHealth)

        self:SetHealth(self, spec.ShieldMaxHealth)

		SetShieldRatio( self.Owner, 1 )

        self:SetShieldRegenRate(spec.ShieldRegenRate)
        self:SetShieldRegenStartTime(spec.ShieldRegenStartTime)

        self:SetVizToFocusPlayer('Always')
        self:SetVizToEnemies('Intel')
        self:SetVizToAllies('Always')
        self:SetVizToNeutrals('Intel')
        
        GetStat( self.Owner,'SHIELDHP', 0 )
        GetStat( self.Owner,'SHIELDREGEN', 0 )
  
        SetStat( self.Owner,'SHIELDHP', spec.ShieldMaxHealth )
        SetStat( self.Owner,'SHIELDREGEN', spec.ShieldRegenRate)
		
		if ScenarioInfo.ShieldDialog then
			LOG("*AI DEBUG Shield created on "..__blueprints[self.Owner.BlueprintID].Description) 
		end

        ChangeState(self, self.EnergyDrainRechargeState)
    end,
	
    ForkThread = function(self, fn, ...)
        local thread = ForkThread(fn, self, unpack(arg))
        TrashAdd( self.Owner.Trash, thread )
		return thread
    end,
	
	SetRechargeTime = function(self, rechargeTime, energyRechargeTime)
        self.ShieldRechargeTime = rechargeTime
        self.ShieldEnergyDrainRechargeTime = energyRechargeTime
    end,

	SetVerticalOffset = function(self, offset)
        self.ShieldVerticalOffset = offset
    end,

    SetSize = function(self, size)
        self.Size = size
    end,

    SetShieldRegenRate = function(self, rate)
        self.RegenRate = rate
    end,

    SetShieldRegenStartTime = function(self, time)
        self.RegenStartTime = time
    end,

    UpdateShieldRatio = function(self, value)
	
        if value >= 0 then
		
            SetShieldRatio( self.Owner, value )
        else
		
            SetShieldRatio( self.Owner, GetHealth(self)/GetMaxHealth(self) )
        end
		
    end,

    GetCachePosition = function(self)
        return self:GetPosition()
    end,

    --# Note, this is called by native code to calculate spillover damage. The
    --# damage logic will subtract this value from any damage it does to units
    --# under the shield. The default is to always absorb as much as possible
    --# but the reason this function exists is to allow flexible implementations
    --# like shields that only absorb partial damage (like armor).
    OnGetDamageAbsorption = function(self,instigator,amount,type)
--[[
        #LOG('absorb: ', LOUDMIN( GetHealth(self), amount ))
        
        #-- Like armor damage, first multiply by armor reduction, then apply handicap
        #-- See SimDamage.cpp (DealDamage function) for how this should work
		
        amount = amount * (self.Owner:GetArmorMult(type))
        amount = amount * ( 1.0 - ArmyGetHandicap(GetArmy(self)) )
		
        return LOUDMIN( GetHealth(self), amount )
--]]
    end,

    OnCollisionCheckWeapon = function(self, firingWeapon)

		local GetArmy = GetArmy
	
		if IsAlly( self.Army, GetArmy(firingWeapon.unit) ) then
		
			return false
			
		end
	
		local weaponBP = firingWeapon.bp
	
        -- Check DNC list
        if weaponBP.DoNotCollideList then
			--LOG("*AI DEBUG Processing Shield DNC List "..repr(weaponBP.DoNotCollideList))
			
			local LOUDENTITY = LOUDENTITY
			local LOUDPARSE = LOUDPARSE
			
			for _, v in weaponBP.DoNotCollideList do
				if LOUDENTITY(LOUDPARSE(v), self) then
					return false
				end
			end
		end   
        
        return true
    end,
    
    GetOverkill = function(self,instigator,amount,type)
    end,    

    OnDamage =  function(self,instigator,amount,vector,type)
	
		local AdjustHealth = AdjustHealth
		local SetShieldRatio = SetShieldRatio
		local GetArmorMult = GetArmorMult
		local GetHealth = GetHealth
		local GetMaxHealth = GetMaxHealth
        
		local LOUDMIN = LOUDMIN
		local LOUDMAX = LOUDMAX

        local absorbed = amount * ( GetArmorMult( self.Owner, type ) )

        absorbed = LOUDMIN( GetHealth(self), absorbed )
		
		if ScenarioInfo.ShieldDialog then
			LOG("*AI DEBUG Shield on "..repr(__blueprints[self.Owner.BlueprintID].Description).." absorbs "..absorbed.." damage")
		end

        if self.PassOverkillDamage and (amount-absorbed) > 0 then

			local overkill = (amount-absorbed) * ( GetArmorMult( self.Owner, type ))

			overkill = LOUDMAX( overkill, 0 )
			
			if overkill > 0 then

				if self.Owner and IsUnit(self.Owner) then
				
					if ScenarioInfo.ShieldDialog then
						LOG("*AI DEBUG Shield Owner "..repr(__blueprints[self.Owner.BlueprintID].Description).." takes "..overkill.." damage")
					end
				
					self.Owner:DoTakeDamage(instigator, overkill, vector, type)
					
				end
            end
        end
        
        AdjustHealth( self, instigator, -absorbed) 
		
		SetShieldRatio( self.Owner, GetHealth(self)/GetMaxHealth(self) )
        
        if self.RegenThread then
           KillThread(self.RegenThread)
           self.RegenThread = nil
        end
		
        if GetHealth(self) <= 0 then
		
            ChangeState(self, self.DamageRechargeState)
			
        else
		
            if self.OffHealth < 0 then
			
                ForkTo(self.CreateImpactEffect, self, vector)
				
                if self.RegenRate > 0 then
				
                    self.RegenThread = self:ForkThread(self.RegenStartThread)

                end
				
            else
			
                self:UpdateShieldRatio(0)
				
            end
        end
    end,

    RegenStartThread = function(self)
	
		local AdjustHealth = AdjustHealth
		local GetHealth = GetHealth
		local GetMaxHealth = GetMaxHealth
		local SetShieldRatio = SetShieldRatio
        
		local WaitTicks = WaitTicks
		
		if ScenarioInfo.ShieldDialog then
			LOG("*AI DEBUG Shield Starts Regen Thread on "..repr(self.Owner.BlueprintID).." "..repr(__blueprints[self.Owner.BlueprintID].Description).." - start delay is "..repr(self.RegenStartTime) )
			
			if not self.Owner.BlueprintID then
				LOG("*AI DEBUG "..repr(self))
			end
		end
		
		-- shield takes a delay before regen starts
        WaitTicks( 10 + (self.RegenStartTime * 10) )
        
        while not self.Dead and GetHealth(self) < GetMaxHealth(self) do

			-- regen the shield
			if not self.Dead then
			
				AdjustHealth( self, self.Owner, self.RegenRate )
				
				SetShieldRatio( self.Owner, GetHealth(self)/GetMaxHealth(self) )
		
				-- wait one second
				WaitTicks(11)
			end
        end
		
    end,

    CreateImpactEffect = function(self, vector)

		if not self.Dead then
		
            local ImpactEffects = self.ImpactEffects
            
			local ImpactMesh = Entity( self.ImpactEntitySpecs )

			Warp( ImpactMesh, self:GetPosition())		
		
			if self.ImpactMeshBp then
                
                local vec = VectorCached
                vec[1] = -vector.x
                vec[2] = -vector.y
                vec[3] = -vector.z
                
				ImpactMesh:SetOrientation( OrientFromDir( vec ), true)			

				ImpactMesh:SetMesh(self.ImpactMeshBp)
				
				ImpactMesh:SetDrawScale(self.Size)

			end

			if ImpactEffects and not self.Dead then
            
                local Army = self.Army
                local CreateEmitterAtBone = CreateEmitterAtBone
                
				for k, v in ImpactEffects do
					CreateEmitterAtBone( ImpactMesh, -1, Army, v ):OffsetEmitter(0, 0, LOUDSQRT( LOUDPOW( vector[1], 2 ) + LOUDPOW( vector[2], 2 ) + LOUDPOW(vector[3], 2 ) )  )
				end
                
			end
			
			WaitTicks(17)
            
			ImpactMesh:Destroy()
		end
    end,

    OnDestroy = function(self)
	
		if ScenarioInfo.ShieldDialog then
			LOG("*AI DEBUG Shield OnDestroy for "..__blueprints[self.Owner.BlueprintID].Description )
		end
	
		self:SetMesh('')
		
		if self.MeshZ != nil then
			self.MeshZ:Destroy()
			self.MeshZ = nil
		end
        
        if self.RegenThread then
           KillThread(self.RegenThread)
           self.RegenThread = nil
        end
		
		self:UpdateShieldRatio(0)
		
		self.Dead = true
		
        ChangeState(self, self.DeadState)
		
    end,

    -- Return true to process this collision, false to ignore it.
    OnCollisionCheck = function(self,other)
	
		-- credit Balthazar and PhilipJFry for diagnosing and repairing
		if categories.SHIELDPIERCING then
			if LOUDENTITY( categories.SHIELDPIERCING, other ) then
				return false
			end
        end
		
		-- for rail guns from 4DC credit Resin_Smoker
		if other.LastImpact then
		
			-- if hit same unit twice
			if other.LastImpact == self.Owner.MyShield:GetEntityId() then
				return false
			end
		end
		
		if other.DamageData.DamageType == 'Railgun' then
			other.LastImpact = self.Owner.MyShield:GetEntityId()
		end
		
		local GetArmy = GetArmy
        return IsEnemy( self.Army, GetArmy(other) )
    end,

    TurnOn = function(self)
        ChangeState(self, self.OnState)
    end,

    TurnOff = function(self)
        ChangeState(self, self.OffState)
    end,

    IsOn = function(self)
        return false
    end,

    RemoveShield = function(self)
	
        self:SetCollisionShape('None')

		self:SetMesh('')
		
		if self.MeshZ != nil then
			self.MeshZ:Destroy()
			self.MeshZ = nil
		end

        self.Owner:OnShieldIsDown()
		
    end,

    CreateShieldMesh = function(self)
        
        local vec = VectorCached
        vec[1] = 0
        vec[2] = self.ShieldVerticalOffset
        vec[3] = 0
		
		self:SetParentOffset( vec )	

		self:SetCollisionShape( 'Sphere', 0, 0, 0, self.Size/2)

		self:SetMesh(self.MeshBp)

		self:SetDrawScale(self.Size)

		if self.MeshZ == nil then
		
			self.MeshZ = Entity { }

            Warp( self.MeshZ, self.Owner:GetPosition() )			

			self.MeshZ:AttachBoneTo(-1,self.Owner,-1)

            vec[1] = 0
            vec[2] = self.ShieldVerticalOffset
            vec[3] = 0
            
			self.MeshZ:SetParentOffset( vec )

			self.MeshZ:SetMesh(self.MeshZBp)

			self.MeshZ:SetDrawScale(self.Size)

			self.MeshZ:SetVizToFocusPlayer('Always')
			self.MeshZ:SetVizToEnemies('Intel')
			self.MeshZ:SetVizToAllies('Always')
			self.MeshZ:SetVizToNeutrals('Intel')
		end
		
        self.Owner:OnShieldIsUp()
    end,

    -- Basically run a timer, but with a visual bar
	-- The time value is in seconds but the charging up period can be slowed if resources are not available
    ChargingUp = function(self, curProgress, time)
	
        self.Owner:OnShieldIsCharging()
    
		local GetResourceConsumed = moho.unit_methods.GetResourceConsumed
		local SetShieldRatio = SetShieldRatio
		local WaitTicks = WaitTicks
        
        while not self.Dead and curProgress < time do
			
            curProgress = curProgress + GetResourceConsumed( self.Owner )
			
			SetShieldRatio( self.Owner, curProgress/time )
			
            WaitTicks(11)
        end    
    end,

    OnState = State {
	
        Main = function(self)
		
			local GetHealth = GetHealth
			local GetMaxHealth = GetMaxHealth
			local GetResourceConsumed = moho.unit_methods.GetResourceConsumed
            local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
			local SetShieldRatio = SetShieldRatio
			local WaitTicks = WaitTicks
			
			local aiBrain = self.Owner:GetAIBrain()
			
            -- If the shield was turned off; use the recharge time before turning back on
            if self.OffHealth >= 0 then
			
                self.Owner:SetMaintenanceConsumptionActive()
				
                self:ChargingUp( 0, self.ShieldEnergyDrainRechargeTime )
                
                -- If the shield has less than full health, allow the shield to begin regening
                if GetHealth(self) < GetMaxHealth(self) and self.RegenRate > 0 then
				
                    self.RegenThread = self:ForkThread(self.RegenStartThread)

                end
				
            end
            
            -- We are no longer turned off
            self.OffHealth = -1
			
            SetShieldRatio( self.Owner, GetHealth(self)/GetMaxHealth(self) )
			
            self.Owner:OnShieldEnabled()
			self:CreateShieldMesh()

            WaitTicks(10)
            
            -- Test in here if we have run out of power
            while true do
			
				WaitTicks(5)
				
				SetShieldRatio( self.Owner, GetHealth(self)/GetMaxHealth(self) )
				
                if GetResourceConsumed( self.Owner ) != 1 and GetEconomyStored(aiBrain, 'ENERGY') < 1 then
					
					break
				end
            end
            
            -- Record the amount of health on the shield here so when the unit tries to turn its shield
            -- back on and off it has the amount of health from before.

            ChangeState(self, self.EnergyDrainRechargeState)
        end,

        IsOn = function(self)
            return true
        end,
		
    },

    -- When manually turned off
    OffState = State {

        Main = function(self)
		
			-- No regen during off state
			if self.RegenThread then
				KillThread(self.RegenThread)
				self.RegenThread = nil
			end

            -- Set the offhealth - this is used basically to let the unit know the unit was manually turned off
      		self.OffHealth = GetHealth(self)

            -- Get rid of the shield bar
            self:UpdateShieldRatio(0)

            self:RemoveShield()
			
    		self.Owner:OnShieldDisabled()

            WaitTicks(10)
			
        end,
		
    },

    -- This state happens when the shield has been depleted due to damage
    DamageRechargeState = State {
	
        Main = function(self)

			-- No regen during off state
			if self.RegenThread then
				KillThread(self.RegenThread)
				self.RegenThread = nil
			end
			
            self:RemoveShield()
            
            -- make the unit charge up before gettings its shield back
            self:ChargingUp(0, self.ShieldRechargeTime)
            
            -- Fully charged, get full health
            self:SetHealth(self, GetMaxHealth(self))
            
            ChangeState(self, self.OnState)
			
        end,
		
        IsOn = function(self)
            return true
        end,
    },

    -- This state happens only when the army has run out of power
    EnergyDrainRechargeState = State {
	
        Main = function(self)

			-- No regen during off state
			if self.RegenThread then
				KillThread(self.RegenThread)
				self.RegenThread = nil
			end
			
            self:RemoveShield()
            
            self:ChargingUp(0, self.ShieldEnergyDrainRechargeTime)
            
            -- If the unit is attached to a transport, make sure the shield goes to the off state
            -- so the shield isn't turned on while on a transport
            if not self.Owner:IsUnitState('Attached') then
			
                ChangeState(self, self.OnState)
				
            else
			
                ChangeState(self, self.OffState)
				
            end
			
        end,
        
        IsOn = function(self)
            return true
        end,
		
    },

    DeadState = State {
	
        Main = function(self)
			self.Dead = true
        end,
		
    },
	
}

-- Unit shields typically hug the shape of the unit
UnitShield = Class(Shield){

    OnCreate = function(self,spec)

        self.Trash = TrashBag()
        self.Owner = spec.Owner
        self.ImpactEffects = EffectTemplate[spec.ImpactEffects]        
        self.CollisionSizeX = spec.CollisionSizeX or 1
		self.CollisionSizeY = spec.CollisionSizeY or 1
		self.CollisionSizeZ = spec.CollisionSizeZ or 1
		self.CollisionCenterX = spec.CollisionCenterX or 0
		self.CollisionCenterY = spec.CollisionCenterY or 0
		self.CollisionCenterZ = spec.CollisionCenterZ or 0
		self.OwnerShieldMesh = spec.OwnerShieldMesh or ''

		Shield.OnCreate(self,spec)

    end,

    -- I've turned off impact effects on skin shields simply for performance 
    -- the effect is so small, and only lasts .3 seconds, it seemed an easy choice
    CreateImpactEffect = function(self, vector)
    end,

    CreateShieldMesh = function(self)
	
  		self:SetCollisionShape( 'Box', self.CollisionCenterX, self.CollisionCenterY, self.CollisionCenterZ, self.CollisionSizeX, self.CollisionSizeY, self.CollisionSizeZ)
		
		self.Owner:SetMesh(self.OwnerShieldMesh,true)
		
        self.Owner:OnShieldIsUp()
		
    end,
	
    RemoveShield = function(self)
	
        self:SetCollisionShape('None')
		
		self.Owner:SetMesh(self.Owner:GetBlueprint().Display.MeshBlueprint, true)
		
        self.Owner:OnShieldIsDown()
		
    end,

    OnDestroy = function(self)
	
        if not self.Owner.MyShield or self.Owner.MyShield:GetEntityId() == self:GetEntityId() then
		
	        self.Owner:SetMesh(self.Owner:GetBlueprint().Display.MeshBlueprint, true)
			
		end
		
		self:UpdateShieldRatio(0)
        ChangeState(self, self.DeadState)
    end,

}

-- AntiArtillery shields are typical bubbles but only intercept certain projectiles
AntiArtilleryShield = Class(Shield){

    OnCollisionCheckWeapon = function(self, firingWeapon)

        local bp = firingWeapon.bp
		
        if not bp.CollideFriendly then
		
            if self.Army == firingWeapon.unit.Army then
			
                return false
				
            end
			
        end
		
        -- Check DNC list
		if bp.DoNotCollideList then
		
			for _,v in bp.DoNotCollideList do
			
				if LOUDENTITY( LOUDPARSE(v), self) then
				
					return false
					
				end
				
			end
			
		end
		
        if bp.ArtilleryShieldBlocks then
		
            return true
			
        end
		
        return false
		
    end,

    -- Return true to process this collision, false to ignore it.
    OnCollisionCheck = function(self,other)
	
		local otherArmy = GetArmy(other)
	
        if otherArmy == -1 then
            return false
        end
		
        if other.DamageData.ArtilleryShieldBlocks and IsEnemy( self.Army, otherArmy ) then
            return true
        end
		
        if other:GetBlueprint().Physics.CollideFriendlyShield and other.DamageData.ArtilleryShieldBlocks then
            return true
        end
		
        return false
		
    end,
	
}

-- Hunker Shields take no damage while on --
DomeHunkerShield = Class(Shield) {
	
	OnCollisionCheckWeapon = function(self, firingWeapon)
		return true
	end,

	OnCollisionCheck = function(self,other)
		if GetArmy(other) == -1 then
			return true
		end

		return true
	end,
}

-- Hunker Shields are time limited shields that take no damage --
PersonalHunkerShield = Class(Shield) {

	OnDamage =  function(self,instigator,amount,vector,type)
	end, 

    CreateImpactEffect = function(self, vector)
    end,

    CreateShieldMesh = function(self)
	
		self:SetCollisionShape( 'Box', self.CollisionCenterX, self.CollisionCenterY, self.CollisionCenterZ, self.CollisionSizeX, self.CollisionSizeY, self.CollisionSizeZ)
		
		SetMesh( self.Owner, self.OwnerShieldMesh, true )
    end,

    RemoveShield = function(self)
	
        self:SetCollisionShape('None')
		
		SetMesh( self.Owner, self.Owner:GetBlueprint().Display.MeshBlueprint, true )
    end,

    OnDestroy = function(self)
	
        if not self.Owner.MyShield or self.Owner.MyShield:GetEntityId() == self:GetEntityId() then
		
	        SetMesh( self.Owner, self.Owner:GetBlueprint().Display.MeshBlueprint, true)
		end
		
		self:UpdateShieldRatio(0)
        ChangeState(self, self.DeadState)
    end,

}

ProjectedShield = Class(Shield){

    OnDamage =  function(self,instigator,amount,vector,type)
	
        --Count how many projectors are going to be receiving the damage.
        local pCount = self:CheckProjectors()
		
        --If there are none, then something has happened and we need to kill the shield.
        if pCount == 0 then
            self.Owner:DestroyShield()
        else
            
			ForkThread(self.CreateImpactEffect, self, vector)

            --Calculate the damage now, once, and before we fuck with the numbers.
            self:DistributeDamage(instigator,amount,vector,type)
        end
    end,

    CheckProjectors = function(self)
	
        local pCount = 0
		
        for i, projector in self.Owner.Projectors do
		
            if IsUnit(projector) and projector.MyShield and projector.MyShield:GetHealth() > 0 then
                pCount = pCount + 1
            end
        end
		
        return pCount
    end,

    DistributeDamage = function(self,instigator,amount,vector,type)
	
        local pCount = self:CheckProjectors()
		
        if pCount == 0 and not self.Owner.Dead then
            self.Owner:OnDamage(instigator,amount,vector,type)
        end
		
        local damageToDeal = amount / pCount
        local overKillDamage, ProjectorHealth = 0,0
		
        for i, projector in self.Owner.Projectors do
		
            ProjectorHealth = projector.MyShield:GetHealth()
			
            projector.MyShield:OnDamage(instigator,damageToDeal,vector,type)
			
            --If it looked like too much damage, remove it from the projector list, and count the overkill
            if ProjectorHealth <= damageToDeal then
                overKillDamage = overKillDamage + LOUDMAX(damageToDeal - ProjectorHealth, 0)
                projector.ShieldProjectionEnabled = false
                projector:ClearShieldProjections()
            end
        end
		
        if overKillDamage > 0 then
            self:DistributeDamage(instigator,overKillDamage,vector,type)
        end
		
    end,

    CreateImpactEffect = function(self, vector)

        local AttachBeamEntityToEntity = AttachBeamEntityToEntity
        local CreateEmitterAtBone = CreateEmitterAtBone
        local WaitTicks = coroutine.yield

        if not self.Dead then
        
            local army = self.Army
            
            local OffsetLength = LOUDSQRT( LOUDPOW( vector[1], 2 ) + LOUDPOW( vector[2], 2 ) + LOUDPOW(vector[3], 2 ) )
            
            local ImpactMesh = Entity( self.ImpactEntitySpecs )
		
            Warp( ImpactMesh, self:GetPosition())
		
            if self.ImpactMeshBp then
                
                local vec = VectorCached

                vec[1] = -vector.x
                vec[2] = -vector.y
                vec[3] = -vector.z
                
                ImpactMesh:SetOrientation(OrientFromDir( vec ),true)            

                ImpactMesh:SetMesh(self.ImpactMeshBp)
                ImpactMesh:SetDrawScale(self.Size)

            end
            
            local beams = {}
	
            for i, Pillar in self.Owner.Projectors do

                if self:IsValidBone(0) and Pillar:IsValidBone('Gem') then
                    beams[i] = AttachBeamEntityToEntity(self, 0, Pillar, 'Gem', army, Pillar:GetBlueprint().Defense.Shield.ShieldTargetBeam)
                end
            end
            
            if self.ImpactEffects and not self.Dead then
		
                for k, v in self.ImpactEffects do
                    CreateEmitterAtBone( ImpactMesh, -1, army, v ):OffsetEmitter(0,0,OffsetLength)
                end
            end
		
            WaitTicks(5)
		
            for i, v in beams do
                v:Destroy()
            end
		
            WaitTicks(45)
        
            ImpactMesh:Destroy()
            
        end
        
    end,

    OnCollisionCheck = function(self,other)
    
        if self:CheckProjectors() == 0 then
            return false
        end
        
        return Shield.OnCollisionCheck(self,other)
    end,
}

