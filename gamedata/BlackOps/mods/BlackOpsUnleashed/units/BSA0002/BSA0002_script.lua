--Seraphim T3 Air Staging Platform Repair Drone script
--By the Blackops team, revisions by Mithy
local SConstructionUnit = import('/lua/seraphimunits.lua').SConstructionUnit
local EffectUtil = import('/lua/EffectUtilities.lua')

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local CreateAttachedEmitter = CreateAttachedEmitter

BSA0002 = Class(SConstructionUnit) {
    Parent = nil,
    ExhaustLaunch01 = '/effects/emitters/seraphim_inaino_launch_01_emit.bp',
    ExhaustLaunch02 = '/effects/emitters/seraphim_inaino_launch_02_emit.bp',
    ExhaustLaunch03 = '/effects/emitters/seraphim_inaino_launch_03_emit.bp',
    ExhaustLaunch04 = '/effects/emitters/seraphim_inaino_launch_04_emit.bp',
    ExhaustLaunch05 = '/effects/emitters/seraphim_inaino_launch_05_emit.bp',
    BeamLaunch = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',

    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
        --Mithy: Now has launch effects from XSA0001 drone - this function handles initial movement as well
        ### Start of launch special effects
        self.LaunchExhaustEffectsBag = {}
        self:ForkThread(self.LaunchEffects)
        --Mithy: Range limitation thread
        self.HeartBeatThread = self:ForkThread(self.DistanceHeartbeat)
    end,

	--Mithy: Extra checks now done within patrolplatform
    OnStopbuild = function(self, unitBeingBuilt)
        self:ForkThread(self.Patrolplatform)
        SConstructionUnit.OnStopBuild(self, unitBeingBuilt)
    end,

	--Mithy: Extra checks now done within patrolplatform
    OnMotionHorzEventChange = function(self, new, old)
        if new == 'Stopped' then
            self:ForkThread(self.Patrolplatform)
        end
        SConstructionUnit.OnMotionHorzEventChange(self, new, old)
    end,

    --Mithy: Added range heartbeat
    DistanceHeartbeat = function(self)
        self.CapTable = {
            'RULEUCC_Guard',
            'RULEUCC_Move',
            'RULEUCC_Patrol',
            'RULEUCC_Stop',
        }
        self.MoveToParent = false
        while self and not self:IsDead() do
            local dronePos = self:GetPosition()
            local parentPos = self.Parent:GetPosition()
            local parentDist = VDist2(dronePos[1], dronePos[3], parentPos[1], parentPos[3])
            if parentDist >= 80 and self.MoveToParent == false then
                self.MoveToParent = true
                --Increase return speed
                self:SetSpeedMult(2.0)
                self:SetAccMult(2.0)
                IssueClearCommands({self})
                IssueMove({self}, parentPos)
                --Disable command caps
                for k, cap in self.CapTable do
                    self:RemoveCommandCap(cap)
                end
            elseif parentDist <= 70 and self.MoveToParent == true then
                self.MoveToParent = false
                --Restore speed
                self:SetSpeedMult(1.0)
                self:SetAccMult(1.0)
                --Re-enable command caps
                self:RestoreCommandCaps()
                --This will auto-queue a patrol
                IssueStop({self})
            else
                --If we're idle and our movement check somehow failed, re-queue patrol
                if self:IsIdleState() then
                    self:ForkThread(self.Patrolplatform)
                end
            end
            WaitSeconds(1)
        end
    end,

    Patrolplatform = function(self, override)
        --Mithy: Now checks idle state, so drones can hover in place without being immediately told to patrol (often interrupting user orders)
        if override or ( not self:IsDead() and not self.Parent:IsDead() and self:IsIdleState() ) then
            ### Gets the current position of the parent platform in the game world
            local location = self.Parent:GetPosition()

            ###Repair drone patrol area if not currently building
            --Mithy: Now a larger-area octagon instead of a small square
            IssueClearCommands({self})
            local patroltable = {
	            {location[1]+15, location[2], location[3]-6},
	            {location[1]+15, location[2], location[3]+6},
	            {location[1]+6, location[2], location[3]+15},
	            {location[1]-6, location[2], location[3]+15},
	            {location[1]-15, location[2], location[3]+6},
	            {location[1]-15, location[2], location[3]-6},
	            {location[1]-6, location[2], location[3]-15},
	            {location[1]+6, location[2], location[3]-15},
	        }
            --Randomize drone's patrol startpoint
            local ppoint = math.random(1, 8)
            local pointsleft = 8
            while pointsleft > 0 do
            	IssuePatrol({self}, patroltable[ppoint])
            	if ppoint < 8 then
            		ppoint = ppoint + 1
            	else
            		ppoint = 1
            	end
            	pointsleft = pointsleft - 1
            end
       end
    end,

    OnDamage = function(self, instigator, amount, vector, damagetype)
        if self:IsDead() == false then
            ###Base script for this script function was developed by Gilbot_x
            ### sets the damage resistance of the rebuilder bot to 30%
            #local rebuilerBot_DLS = 0.3
            #amount = math.ceil(amount*rebuilerBot_DLS)
        end
        --Mithy: Run home to the platform if we take damage
        if not self:IsDead() and instigator and IsUnit(instigator) and not instigator:IsDead() and not self.EvadeThread then
            self.EvadeThread = self:ForkThread( function()
                self:SetSpeedMult(2.0)
                self:SetAccMult(2.0)
                IssueClearCommands({self})
                IssueMove({self}, self.Parent:GetPosition())
                WaitSeconds(2)
                self:SetSpeedMult(1.0)
                self:SetAccMult(1.0)
                self.EvadeThread = nil
            end )
        end
        SConstructionUnit.OnDamage(self, instigator, amount, vector, damagetype)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)

        ### Clears the current RebuilderBot commands if any
        IssueClearCommands({self})

        ### Notifies parent of RebuilderBot death and clears the dead unit from the parents table
        if not self.Parent:IsDead() then
            --Mithy: This table was mis-named
            for k,v in self.Parent.RepairDroneTable do
                if v == self then
                    self.Parent.RepairDroneTable[k] = nil
                    break
                end
            end
            #table.removeByValue(self.Parent.RepairDroneTable, self)
            --Likewise, this function was mis-named, and doesn't need the droneName parameter as the staging facility has no specified drone slots
            self.Parent:NotifyOfRepairDroneDeath()
        end
        ### Final command to finish off the drones death event
        SConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    --Mithy: Added launch effects from XSA0001 drone
    LaunchEffects = function(self)
        ### Are we dead?
        if not self:IsDead() then
            local army = self:GetArmy()
        	--Force patrol order
            self:ForkThread(self.Patrolplatform, true)
            ### Attaches effects to drone during launch
            table.insert(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'XSA0002', army, self.ExhaustLaunch01))
            table.insert(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'XSA0002', army, self.ExhaustLaunch02))
            table.insert(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'XSA0002', army, self.ExhaustLaunch03))
            table.insert(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'XSA0002', army, self.ExhaustLaunch04))
            table.insert(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'XSA0002', army, self.ExhaustLaunch05))
            WaitSeconds(2.5)
            EffectUtil.CleanupEffectBag(self,'LaunchExhaustEffectsBag')
        end
    end,
}
TypeClass = BSA0002