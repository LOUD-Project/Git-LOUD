--   /lua/sim/bufffield.lua
--  Author(s):  Brute51
--  Summary  :  Low level buff field class (version 3)
--  READ DOCUMENTATION BEFORE USING THIS!!

local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint

local ApplyBuff = import('/lua/sim/buff.lua').ApplyBuff
local HasBuff = import('/lua/sim/buff.lua').HasBuff
local RemoveBuff = import('/lua/sim/buff.lua').RemoveBuff

local Entity = import('/lua/sim/Entity.lua').Entity

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
    end
end

BuffField = Class(Entity) {

    -- change these in an inheriting class if you want
    FieldVisualEmitter = '',   -- the FX on the unit that carries the buff field
	VisualScale = 1.5,
	
    __init = function(self, spec)
        Entity.__init(self, spec)
        self.Name = spec.Name or 'NoName'
        self.Owner = spec.Owner
        self.Enabled = false
        self.DisabledForTransporting = false
        self.ThreadHandle = false
    end,

    OnCreate = function(self)

        local Owner = self:GetOwner()
        local bp = self:GetBlueprint()
		
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
            WARN('BuffField: [..repr(bp.Name)..] Invalid radius or radius not set!')
            return
        end

        -- event stuff
        Entity.OnCreate(self)
		
		-- store the entity on its owner
		table.insert(Owner.MyBuffFields, self)

        if bp.DisableInTransport then
            Owner:AddUnitCallback(self.DisableInTransport, 'OnAttachedToTransport')
            Owner:AddUnitCallback(self.EnableOutTransport, 'OnDetachedToTransport')
        end
		
        self:OnCreated()
    end,

    OnCreated = function(self)
	
        if self:GetBlueprint().InitiallyEnabled then
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
        return self.Owner
    end,

    Enable = function(self)
		
        if not self:IsEnabled() then
			
            local Owner = self:GetOwner()
            local bp = self:GetBlueprint()

            self.ThreadHandle = self.Owner:ForkThread(self.FieldThread, self)
			
			if bp.MaintenanceConsumptionPerSecondEnergy then
			
				Owner:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
				Owner:SetMaintenanceConsumptionActive()
				
				if not self.WatchPower then
					self.WatchPower = Owner:ForkThread(self.WatchPowerThread, self)
				end
			end

            self.Enabled = true
            self:OnEnabled()
        end
    end,

	-- fires when the field begins to work -- show field FX and Ambient FX
    OnEnabled = function(self)
        
		local Owner = self:GetOwner()
		local Army = Owner:GetArmy()
		
        if self.FieldVisualEmitter and type(self.FieldVisualEmitter) == 'string' and self.FieldVisualEmitter != '' then

            if not Owner.BuffFieldEffectsBag then
                Owner.BuffFieldEffectsBag = {}
            end

            table.insert( Owner.BuffFieldEffectsBag, CreateAttachedEmitter(Owner, 0, Army, self.FieldVisualEmitter):ScaleEmitter(self.VisualScale) )
        end
		
		if self.AmbientEffects and type(self.AmbientEffects) == 'string' and self.AmbientEffects != '' then

			if not Owner.BuffFieldEffectsBag then
                Owner.BuffFieldEffectsBag = {}
            end

            table.insert( Owner.BuffFieldEffectsBag, CreateAttachedEmitter(Owner, 0, Army, self.AmbientEffects):ScaleEmitter(self.VisualScale) )
		end
    end,
	
	WatchPowerThread = function( Owner, self )
	
        local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetResourceConsumed = moho.unit_methods.GetResourceConsumed

		local aiBrain = Owner:GetAIBrain()
		
        local on = true

        while true do
			
            WaitTicks(10)

            if on and ( GetResourceConsumed(Owner) != 1 and GetEconomyStored(aiBrain,'ENERGY') < 1 ) then
				
				Owner:SetScriptBit('RULEUTC_ShieldToggle',false)
				Owner:RemoveToggleCap('RULEUTC_ShieldToggle')
				on = false
			end
			
			if not on and (GetEconomyStored(aiBrain, 'ENERGY') > self:GetBlueprint().MaintenanceConsumptionPerSecondEnergy) then
				
				Owner:AddToggleCap('RULEUTC_ShieldToggle')
				Owner:SetScriptBit('RULEUTC_ShieldToggle',true)
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
			
            self.Enabled = false
			
            self:OnDisabled(Owner)
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

    -- applies the buff to any unit in range each 3.3 seconds
    -- Owner is the unit that carries the field. This is a bit weird to have it like this but its the result of
    -- of the forkthread in the enable function.
    FieldThread = function(Owner, self)
		
		local aiBrain = Owner:GetAIBrain()
        local bp = self:GetBlueprint()

        local function GetNearbyAffectableUnits()
		
            local units = {}
            local pos = Owner:GetPosition()
			
            if bp.AffectsOwnUnits then
                units = table.merged(units, GetOwnUnitsAroundPoint( aiBrain, bp.AffectsUnitCategories, pos, bp.Radius))
            end
			
            if bp.AffectsAllies then
                units = table.merged(units, aiBrain:GetUnitsAroundPoint( bp.AffectsUnitCategories, pos, bp.Radius, 'Ally' ))
            end
			
            if bp.AffectsVisibleEnemies then
                units = table.merged(units, aiBrain:GetUnitsAroundPoint( bp.AffectsUnitCategories, pos, bp.Radius, 'Enemy' ))
            end
			
            return units
        end

        while self:IsEnabled() and not Owner.Dead do
		
            local units = GetNearbyAffectableUnits()
			
            for k, unit in units do
			
                if unit == Owner and not bp.AffectsSelf then
                   continue
                end
				
                if not unit.Dead and not unit.HasBuffFieldThreadHandle[bp.Name] then
				
                    if type(unit.HasBuffFieldThreadHandle) != 'table' then
                        unit.HasBuffFieldThreadHandle = {}
                        unit.BuffFieldThreadHandle = {}
                    end
					
                    unit.BuffFieldThreadHandle[bp.Name] = unit:ForkThread(self.UnitBuffFieldThread, Owner, self)
                    unit.HasBuffFieldThreadHandle[bp.Name] = true
                end
            end
			
            self:OnNewUnitsInFieldCheck()
            WaitSeconds(3.3) -- this should be anything but 5 (of the other wait) to help spread the cpu load
        end
    end,


    -- this will be run on the units affected by the field so self means the unit that is affected by the field
    UnitBuffFieldThread = function(self, instigator, BuffField)
	
        local bp = BuffField:GetBlueprint()
        local PreEnterData = BuffField:OnPreUnitEntersField(self)
		
        for _, buff in bp.Buffs do
            ApplyBuff(self, buff)
        end
		
        local EnterData = BuffField:OnUnitEntersField(self, PreEnterData)
		
        while not self.Dead and not instigator.Dead and BuffField:IsEnabled() do
			
            dist = VDist3( self:GetPosition(), instigator:GetPosition() )
			
            if dist > bp.Radius then
                break -- ideally we should check for another nearby buff field emitting unit but it doesn't really matter (no more than 5 sec anyway)
            end
			
            WaitSeconds(5)
        end
		
        local PreLeaveData = BuffField:OnPreUnitLeavesField(self, PreEnterData, EnterData)
		
        for _, buff in bp.Buffs do
		
            if HasBuff(self, buff) then
                RemoveBuff( self, buff)
            end
        end
		
        BuffField:OnUnitLeavesField(self, PreEnterData, EnterData, PreLeaveData)
        self.HasBuffFieldThreadHandle[bp.Name] = false
    end,

	
--[[	
    FieldThread = function(Owner, self)
		
		local aiBrain = Owner:GetAIBrain()
        local bp = self:GetBlueprint()
		local units = {}
		local pos

        local function GetNearbyAffectableUnits()
		
            units = {}
            pos = Owner:GetPosition()
			
            if bp.AffectsOwnUnits then
                units = table.merged(units, GetOwnUnitsAroundPoint( aiBrain, bp.AffectsUnitCategories, pos, bp.Radius))
            end
			
            if bp.AffectsAllies then
                units = table.merged(units, aiBrain:GetUnitsAroundPoint( bp.AffectsUnitCategories, pos, bp.Radius, 'Ally' ))
            end
			
            if bp.AffectsVisibleEnemies then
                units = table.merged(units, aiBrain:GetUnitsAroundPoint( bp.AffectsUnitCategories, pos, bp.Radius, 'Enemy' ))
            end
			
            return units
        end

        while self.Enabled and not Owner.Dead do
		
            units = GetNearbyAffectableUnits()
			
			local count = 0
			
            for k, unit in units do
			
                if unit == Owner and not bp.AffectsSelf then
                   continue
                end
				
                if not unit.Dead and not unit.HasBuffFieldThreadHandle[bp.Name] then
				
                    if not unit.HasBuffFieldThreadHandle then
                        unit.HasBuffFieldThreadHandle = {}
                        unit.BuffFieldThreadHandle = {}
                    end

                    unit.BuffFieldThreadHandle[bp.Name] = unit:ForkThread( self.UnitBuffFieldThread, Owner, self, bp )
                    unit.HasBuffFieldThreadHandle[bp.Name] = true
					
					count = count + 1
                end
				
				if count > 10 then
					WaitTicks(1)
					count = 0
				end
            end
			
            --self:OnNewUnitsInFieldCheck()
			
            WaitSeconds(3.3) -- this should be anything but 5 (of the other wait) to help spread the cpu load
        end
    end,


    -- this will be run on the units affected by the field so self means the unit that is affected by the field
	
    UnitBuffFieldThread = function(self, instigator, BuffField, bp)
	
        --local bp = BuffField:GetBlueprint()
		
        --local PreEnterData = BuffField:OnPreUnitEntersField(self)
		
        for _, buff in bp.Buffs do
            ApplyBuff(self, buff)
        end
		
        --local EnterData = BuffField:OnUnitEntersField(self, PreEnterData)
		
        while (not self.Dead) and (not instigator.Dead) and BuffField:IsEnabled() do
			
            dist = VDist3( self:GetPosition(), instigator:GetPosition() )
			
            if dist > bp.Radius then
                break -- ideally we should check for another nearby buff field emitting unit but it doesn't really matter (no more than 5 sec anyway)
            end
			
            WaitSeconds(4)
        end
		
        --local PreLeaveData = BuffField:OnPreUnitLeavesField(self, PreEnterData, EnterData)
		
        for _, buff in bp.Buffs do
		
            if HasBuff(self, buff) then
                RemoveBuff( self, buff)
            end
        end
		
        --BuffField:OnUnitLeavesField(self, PreEnterData, EnterData, PreLeaveData)
		
        self.HasBuffFieldThreadHandle[bp.Name] = nil
    end,
--]]
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


