--   /lua/sim/bufffield.lua
--  Author(s):  Brute51
--  Summary  :  Low level buff field class (version 3)
--  READ DOCUMENTATION BEFORE USING THIS!!
local ApplyBuff = import('/lua/sim/buff.lua').ApplyBuff
local RemoveBuff = import('/lua/sim/buff.lua').RemoveBuff

local Entity = import('/lua/sim/Entity.lua').Entity

local LOUDINSERT = table.insert
local type = type

BuffFieldBlueprints = {}

-- this function is for registering new buff fields. Don't remove.
function BuffFieldBlueprint( bpData )

    if not bpData.Name then
        WARN('BuffFieldBlueprint: Encountered blueprint with no name, ignoring it.')
		
    elseif bpData.Merge then
        -- Merging blueprints
        if not BuffFieldBlueprints[bpData.Name] then
            WARN('BuffFieldBlueprint: Trying to merge blueprint "'..bpData.Name..'" with a non-existing one.')
        else
            bpData.Merge = nil
            BuffFieldBlueprints[bpData.Name] = table.merged( BuffFieldBlueprints[bpData.Name], bpData )
        end
    else
        -- Adding new blueprint if it doesn't exist yet
        BuffFieldBlueprints[bpData.Name] = bpData
        
        --LOG("*AI DEBUG Registering BuffField BP "..repr(bpData.Name).." using Buff "..repr(bpData.Buffs) )
    end
end

BuffField = Class(Entity) {

    -- change these in an inheriting class if you want
    AmbientEffects = '',        -- an effect on the unit
    FieldVisualEmitter = '',    -- the FX on the unit that carries the buff field
    
    -- this can now be passed in from the field blueprint
    AttachBone = 0,
    -- this can now be passed in from the field blueprint
	VisualScale = 1.5,
	
    __init = function(self, spec)

        Entity.__init(self, spec)
        
        self.Name = spec.Name or 'NoName'
        self.Owner = spec.Owner.EntityID
    end,

    OnCreate = function(self, spec)

        local Owner = self:GetOwner()
        
        local bp = self:GetBlueprint()

        if bp.AmbientEffects then
            self.AmbientEffects = bp.AmbientEffects
        end
        
        if bp.AttachBone then
            self.AttachBone = bp.AttachBone
        end
        
        if bp.FieldVisualEmitter then
            self.FieldVisualEmitter = bp.FieldVisualEmitter
        end
        
        if bp.VisualScale then
            self.VisualScale = bp.VisualScale
        end
		
        if type(bp.AffectsUnitCategories) == 'string' then
			bp.AffectsUnitCategories = ParseEntityCategory(bp.AffectsUnitCategories)
		end
		
        if type(bp.Buffs) == 'string' then
			bp.Buffs = { bp.Buffs }
		end

        for k, v in bp.Buffs do
            if not Buffs[v] then
                WARN('BuffField: [..repr(bp.Name)..] the field uses a buff that doesn\'t exist! '..repr(v))
                return
            end
        end
		
        if not bp.Radius or bp.Radius <= 0 then
            WARN('BuffField: [..repr(bp.Name)..] Invalid radius or radius not set! default to zero')
        end
        
        self.Radius = bp.Radius or 0

        -- event stuff
        Entity.OnCreate(self)
		
		-- store the entity on its owner
		LOUDINSERT(Owner.MyBuffFields, self)

        if bp.DisableInTransport then
            Owner:AddUnitCallback(self.DisableInTransport, 'OnAttachedToTransport')
            Owner:AddUnitCallback(self.EnableOutTransport, 'OnDetachedToTransport')
        end
		
        self:OnCreated( bp )
    end,

    OnCreated = function(self,bp)
	
        if bp.InitiallyEnabled then
            self:Enable()
        end
		
    end,
	
    GetBlueprint = function(self)
        return BuffFieldBlueprints[self.Name]
    end,

    IsEnabled = function(self)
        return self.Enabled or false
    end,

    GetBuffs = function(self)
        return self:GetBlueprint().Buffs or nil
    end,

    GetOwner = function(self)
        return GetEntityById(self.Owner)
    end,

    Enable = function(self)

        if ScenarioInfo.BuffDialog then        
            LOG("*AI DEBUG enabling BuffField "..repr(self))
		end
		
        if not self.Enabled then
			
            local Owner = self:GetOwner()
            local bp = self:GetBlueprint()

            self.ThreadHandle = Owner:ForkThread( self.FieldThread, self, bp)
			
			if bp.MaintenanceConsumptionPerSecondEnergy then
			
				Owner:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
				Owner:SetMaintenanceConsumptionActive()
				
				if not self.WatchPower then
					self.WatchPower = Owner:ForkThread(self.WatchPowerThread, self)
				end
			end

            self.Enabled = true
            self:OnEnabled(bp)

            if ScenarioInfo.BuffDialog then        
                LOG("*AI DEBUG BuffField ENABLED "..repr(self))
            end
        end
    end,

	-- fires when the field begins to work -- show field FX and Ambient FX
    OnEnabled = function(self, bp)
        
		local Owner = self:GetOwner()
		local Army = Owner.Army
        
        if self.FieldVisualEmitter and type(self.FieldVisualEmitter) == 'string' and self.FieldVisualEmitter != '' then

            if not Owner.BuffFieldEffectsBag then
                Owner.BuffFieldEffectsBag = {}
            end

            LOUDINSERT( Owner.BuffFieldEffectsBag, CreateAttachedEmitter(Owner, bp.AttachBone, Army, self.FieldVisualEmitter):ScaleEmitter(bp.VisualScale or self.VisualScale) )
        end
		
		if self.AmbientEffects and type(self.AmbientEffects) == 'string' and self.AmbientEffects != '' then

			if not Owner.BuffFieldEffectsBag then
                Owner.BuffFieldEffectsBag = {}
            end

            LOUDINSERT( Owner.BuffFieldEffectsBag, CreateAttachedEmitter(Owner, 0, Army, self.AmbientEffects):ScaleEmitter(bp.VisualScale or self.VisualScale) )
		end
    end,

    -- okay - this was originally tripping the shield toggle - which is not where bufffields should be
	WatchPowerThread = function( Owner, self )
	
        local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetResourceConsumed = moho.unit_methods.GetResourceConsumed
        local WaitTicks = coroutine.yield

		local aiBrain = Owner:GetAIBrain()
        
        local MaintenanceConsumption = __blueprints[self.BlueprintID].MaintenanceConsumptionPerSecondEnergy
		
        local on = true

        while true do
			
            WaitTicks(10)

            if on and ( GetResourceConsumed(Owner) != 1 and GetEconomyStored(aiBrain,'ENERGY') < 1 ) then
				
				Owner:SetScriptBit('RULEUTC_SpecialToggle',false)
				Owner:RemoveToggleCap('RULEUTC_SpecialToggle')
				on = false
			end
			
			if not on and (GetEconomyStored(aiBrain, 'ENERGY') > MaintenanceConsumption ) then
				
				Owner:AddToggleCap('RULEUTC_SpecialToggle')
				Owner:SetScriptBit('RULEUTC_SpecialToggle',true)
				on = true
			end
        end	
	end,
	
    Disable = function(self)
		
        if self:IsEnabled() then
		
			local Owner = self:GetOwner()
			
			if self:GetBlueprint().MaintenanceConsumptionPerSecondEnergy then

				Owner:SetMaintenanceConsumptionInactive()
			end
			
            KillThread(self.ThreadHandle)
			self.ThreadHandle = nil
			
            self.Enabled = false
			
            self:OnDisabled(Owner)

            if ScenarioInfo.BuffDialog then        
                LOG("*AI DEBUG BuffField DISABLE "..repr(self))
            end

        end
    end,

    OnDisabled = function( self, Owner )
	
        -- fires when the field stops working - remove field and Ambient FX
        if Owner.BuffFieldEffectsBag then
		
            for k, v in Owner.BuffFieldEffectsBag do
                v:Destroy()
            end
			
			Owner.BuffFieldEffectsBag = {}
        end
    end,

    OnNewUnitsInFieldCheck = function(self)
        -- fires when another check is done to find new units in range that aren't yet under the influence of the
        -- field. This happens approximately every 4.9 seconds.
    end,

    OnPreUnitEntersField = function(self, unit)
        -- fired before unit receives the buffs, but it will. Any data returned by this event function is used as an
        -- argument for OnUnitEntersField, OnPreUnitLeavesField and OnUnitLeavesField
    end,

    OnUnitEntersField = function(self, unit, OnPreUnitEntersFieldData)
        -- fired when a new unit begins being affected by the field. the unit argument contains the newly affected 
        -- unit. The OnPreUnitEntersFieldData argument is the data (if any) returned by OnPreUnitEntersField. Any
        -- data returned by this event function is used as an argument for OnPreUnitLeavesField and
        -- OnUnitLeavesField
    end,

    OnPreUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData)
        -- fired when a unit leaves the field, just before the field buffs are removed. The OnPreUnitEntersFieldData
        -- argument is the data (if any) returned by OnPreUnitEntersField and the OnUnitEntersFieldData argument
        -- is the data (if any) returned by OnUnitEntersField. Any data returned by this event function is used as 
        -- an argument for OnUnitLeavesField.
    end,

    OnUnitLeavesField = function(self, unit, OnPreUnitEntersFieldData, OnUnitEntersFieldData, OnPreUnitLeavesField)
        -- fired after a unit left the field and the field buffs have been removed. the last 3 arguments contain
        -- data returned by the other events.
    end,

    -- applies the buff to any unit in range each 3.8 seconds
    -- Owner is the unit that carries the field. This is a bit weird to have it like this but its the result of
    -- of the forkthread in the enable function.
    FieldThread = function( Owner, Field, bp )

		local GetAlliedUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetAlliedUnitsAroundPoint
		local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
        local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint    -- only picks up units actually detected
       
        local LOUDCOPY = table.copy
		local LOUDMERGE = table.merged
        local WaitTicks = coroutine.yield
		
		local aiBrain = Owner:GetAIBrain()
		
		local units = {}
        local pos
		local count = 0
		local mastercount = 0
        
        local AffectsAllies = bp.AffectsAllies
        local AffectsOwnUnits = bp.AffectsOwnUnits
        local AffectsUnitCategories = bp.AffectsUnitCategories
        local AffectsVisibleEnemies = bp.AffectsVisibleEnemies
        local Name = bp.Name
        local Radius = bp.Radius
        local RadiusOffsetY = bp.RadiusOffsetY

		local function GetNearbyAffectableUnits()
        
            local GetAlliedUnitsAroundPoint = GetAlliedUnitsAroundPoint
            local GetOwnUnitsAroundPoint = GetOwnUnitsAroundPoint
            local GetUnitsAroundPoint = GetUnitsAroundPoint
		
			units = {}

			pos = LOUDCOPY(Owner:GetPosition()) or false

			if pos then
            
                if RadiusOffsetY then
                    pos[2] = pos[2] + RadiusOffsetY
                end
			
				if AffectsOwnUnits and not AffectsAllies then
					units = GetOwnUnitsAroundPoint( aiBrain, AffectsUnitCategories, pos, Radius)
				end
			
				if AffectsAllies then
					units = GetAlliedUnitsAroundPoint( aiBrain, AffectsUnitCategories, pos, Radius)
				end
			
				if AffectsVisibleEnemies then
					units = GetUnitsAroundPoint( aiBrain, AffectsUnitCategories, pos, Radius, 'Enemy' )
				end
				
			end

			return units
			
		end

		while Field.Enabled and not Owner.Dead do

			units = GetNearbyAffectableUnits()
			
			count = 0
			mastercount = 0

			for k, unit in units do

				if (not unit.Dead) then
				
					if not unit.BuffFieldThreadHandle then
						unit.BuffFieldThreadHandle = {}
					end
                    
                    -- apply the BuffField if it isn't already active --
					if not unit.BuffFieldThreadHandle[Name] then
						
						-- all bufffields (atm) don't affect themselves
						if Owner and IsUnit(unit) and Field and bp and unit != Owner then
						
							-- this is here just to trap odd situation where a unit
							-- no longer appears to be a valid unit ?
							if unit.ForkThread then

								unit.BuffFieldThreadHandle[Name] = unit.ForkThread( unit, Field.UnitBuffFieldThread, Owner, Field, bp )
							
								count = count + 1
							
								if count == 5 then
							
									WaitTicks(1)
									count = 0
									mastercount = mastercount + 1
								end
							end
						end
					end
				end
			end

			WaitTicks( 38 - mastercount ) -- this should be anything but 5 (of the other wait) to help spread the cpu load
		end
    end,

	-- this will be run on the units affected by the field
	UnitBuffFieldThread = function( unit, Owner, Field, bp )

        local Buffs = bp.Buffs

		if Buffs != nil then

            local FieldPosition
            local Name = bp.Name
            local Radius = bp.Radius
            local RadiusOffsetY = bp.RadiusOffsetY

			local GetPosition = moho.entity_methods.GetPosition
            local VDist3 = VDist3
            local WaitTicks = coroutine.yield

			while (not unit.Dead) and (not Owner.Dead) and Field.Enabled do
            
                FieldPosition = GetPosition(Owner)
                
                --LOG("*AI DEBUG Field is at "..repr(FieldPosition))
                
                if RadiusOffsetY then
                    FieldPosition[2] = FieldPosition[2] + RadiusOffsetY
                end

                --LOG("*AI DEBUG Field distance is "..repr(VDist3( GetPosition(unit), FieldPosition )).. " Radius is "..Radius )

				if VDist3( GetPosition(unit), FieldPosition ) > Radius then
					break -- ideally we should check for another nearby buff field emitting unit but it doesn't really matter (no more than 5 sec anyway)
				end

				for _, buff in Buffs do
					
					-- if the buff is no longer applied - reapply --
					if not unit.Buffs.BuffTable[Buffs[buff].BuffType][buff] then					
						ApplyBuff( unit, buff )
					end

				end
	
				WaitTicks(38)
			end

			if not unit.Dead and Buffs then
            
                --LOG("*AI DEBUG Attempting to remove buffs "..repr(Buffs).." Unit is "..repr(unit) )

				for _, buffname in Buffs do

                    --LOG("*AI DEBUG Removing bufffield "..repr(buffname))

                    local switch

                    switch = unit.BuffFieldThreadHandle[Name]

                    unit.BuffFieldThreadHandle[Name] = nil

					RemoveBuff( unit, buffname )

                    KillThread( switch )

				end

			end
		end
		
	end,

    -- these 2 are a bit weird. they are supposed to disable the enabled fields when on a transport and re-enable the
    -- fields that were enabled and leave the disabled fields off.
    DisableInTransport = function(Owner, Transport)
	
        for k, field in Owner.MyBuffFields do
		
            if not field.DisabledForTransporting then
			
                local Enabled = field:IsEnabled()
				
                field.WasEnabledBeforeTransporting = Enabled
				
                if Enabled then
                    field:Disable()
                end
				
                field.DisabledForTransporting = true -- to make sure the above is done once even if we have 2 fields or more
            end
        end
    end,

    EnableOutTransport = function(Owner, Transport)
	
        for k, field in Owner.MyBuffFields do
		
            if field.DisabledForTransporting then
			
                if field.WasEnabledBeforeTransporting then
                    field:Enable()
                end
				
                field.DisabledForTransporting = false
            end
        end
    end,
}


