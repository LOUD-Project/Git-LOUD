--Seraphim T3 Air Staging Platform Combat Drone script
--By the Blackops team, revisions by Mithy
local SAirUnit = import('/lua/seraphimunits.lua').SAirUnit
local SAALosaareAutoCannonWeapon = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponAirUnit
local SANHeavyCavitationTorpedo = import('/lua/seraphimweapons.lua').SANHeavyCavitationTorpedo

local EffectUtil = import('/lua/EffectUtilities.lua')


local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local CreateAttachedEmitter = CreateAttachedEmitter
local CreateBeamEmitterOnEntity = CreateBeamEmitterOnEntity

BSA0001 = Class(SAirUnit) {
    Weapons = {
        AutoCannon1 = Class(SAALosaareAutoCannonWeapon) {},
        Bomb = Class(SANHeavyCavitationTorpedo) {},

    },

    Parent = nil,

    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    ### Thrust and exhaust effect pathing
    ExhaustLaunch01 = '/effects/emitters/seraphim_inaino_launch_01_emit.bp',
    ExhaustLaunch02 = '/effects/emitters/seraphim_inaino_launch_02_emit.bp',
    ExhaustLaunch03 = '/effects/emitters/seraphim_inaino_launch_03_emit.bp',
    ExhaustLaunch04 = '/effects/emitters/seraphim_inaino_launch_04_emit.bp',
    ExhaustLaunch05 = '/effects/emitters/seraphim_inaino_launch_05_emit.bp',
    BeamLaunch = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    BeamCruise = '/effects/emitters/aeon_nuke_exhaust_beam_02_emit.bp',
    BeamTopspeed = '/effects/emitters/aeon_nuke_exhaust_beam_01_emit.bp',
    BeamAfterBurner = '/effects/emitters/aeon_nuke_exhaust_beam_01_emit.bp',
    ExhaustSmoke = '/effects/emitters/missile_smoke_exhaust_02_emit.bp',

    OnCreate = function(self, builder, layer)
    SAirUnit. OnCreate(self,builder,layer)
        if not self:IsDead() then
            ### Disables weapons
            self:SetWeaponEnabledByLabel('AutoCannon1', false)
            self:SetWeaponEnabledByLabel('Bomb', false)
            self:SetScriptBit('RULEUCC_RetaliateToggle', false)

            ### Global Varibles
            self.BeamExhaustEffectsBag = {}
            self.LaunchExhaustEffectsBag = {}
            self.BurnerActive = false
            self.Evade = false
            self.MoveToParent = false
            self.Duration = 1
            self.MyWeapon = self:GetWeaponByLabel('AutoCannon1')
            self.MyMaxSpeed = self:GetBlueprint().Air.MaxAirspeed
            self.WepRng = self.MyWeapon:GetBlueprint().MaxRadius
            self.DmgMod = false

            ### Start of launch special effects
            self:ForkThread(self.LaunchEffects)
        end
    end,


    LaunchEffects = function(self)
        ### Are we dead?
        if not self:IsDead() then
            ### Set flag to true
            self.BurnerActive = true

            ### Kick off Afterburner multi and effects
            self:ForkThread(self.Afterburner)
            
            ### Attaches effects to drone during launch
            LOUDINSERT(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'Exhaust01', self:GetArmy(), self.ExhaustLaunch01))
            LOUDINSERT(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'Exhaust01', self:GetArmy(), self.ExhaustLaunch02))
            LOUDINSERT(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'Exhaust01', self:GetArmy(), self.ExhaustLaunch03))
            LOUDINSERT(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'Exhaust01', self:GetArmy(), self.ExhaustLaunch04))
            LOUDINSERT(self.LaunchExhaustEffectsBag, CreateAttachedEmitter(self, 'Exhaust01', self:GetArmy(), self.ExhaustLaunch05))
            LOUDINSERT(self.LaunchExhaustEffectsBag, CreateBeamEmitterOnEntity(self, 'XSA0001', self:GetArmy(), self.BeamLaunch))

            ### Duration of launch
            WaitSeconds(self.Duration)

            if not self:IsDead() and not self.Parent:IsDead() then

                ### Tells the drone to guard the carrier
                self:ForkThread(self.GuardCarrier)
                EffectUtil.CleanupEffectBag(self,'LaunchExhaustEffectsBag')

                ### Enables weapons
                self:SetWeaponEnabledByLabel('AutoCannon1', true)
                self:SetWeaponEnabledByLabel('Bomb', true)
                self:SetScriptBit('RULEUCC_RetaliateToggle', true)

                ### Heartbeat event to monitor the drones distance from the carrier, if the drone gets too far away it is recalled to the carrier
                self:ForkThread(self.HeartBeatDroneCheck)
            end
        end
    end,

    HeartBeatDroneCheck = function(self)
        self.CapTable = {
            'RULEUCC_Attack',
            'RULEUCC_Guard',
            'RULEUCC_Move',
            'RULEUCC_Patrol',
            'RULEUCC_RetaliateToggle',
            'RULEUCC_Stop',
        }
        while self and not self.Dead do
            ### Verify that we have fuel and get distance from parent carrier
            local dronePos = self:GetPosition()
            local parentPos = self.Parent:GetPosition()
            local parentDist = VDist2(dronePos[1], dronePos[3], parentPos[1], parentPos[3])


            if parentDist >= 80 and self.Evade == false and self.MoveToParent == false then
                ### Set flag to true
                self.MoveToParent = true

                ### Disables weapons and attempts to move drone back to parent
                self:SetWeaponEnabledByLabel('MainGun', false)
                self:SetWeaponEnabledByLabel('Bomb', false)
                self:SetScriptBit('RULEUCC_RetaliateToggle', false)
                IssueClearCommands({self})
                IssueMove({self}, parentPos)
                --Engage afterburner
                self.BurnerActive = true
                self:ForkThread(self.Afterburner)
                --Disable command caps
                for k, cap in self.CapTable do
                    self:RemoveCommandCap(cap)
                end
            elseif parentDist <= 80 then
                if parentDist <= 70 and self.MoveToParent == true then
                    --Mithy: moved all this stuff here and conditions added to prevent infinite multi-queueing
                    --as well as unnecessary weapon checks.

                    ### Set flag to false
                    self.MoveToParent = false

                    ### Enables weapons
                    self:SetWeaponEnabledByLabel('MainGun', true)
                    self:SetWeaponEnabledByLabel('Bomb', true)
                    --Re-enable command caps
                    self:SetScriptBit('RULEUCC_RetaliateToggle', true)
                    self:RestoreCommandCaps()

                    ### Tells the drone to guard the carrier
                    self:ForkThread(self.GuardCarrier)
                end

                if self.MyWeapon:GetCurrentTarget() then
                    local myTarget = self.MyWeapon:GetCurrentTarget()

                    ### Verify that our current target is a valid air target
                    if table.find(myTarget:GetBlueprint().Categories,'HIGHALTAIR') and not table.find(myTarget:GetBlueprint().Categories,'EXPERIMENTAL') then

                        ### Get the distance to our target
                        local tarPos = myTarget:GetPosition()
                        local distance = VDist2(dronePos[1], dronePos[3], tarPos[1], tarPos[3])
                        local myTargetSpeed = myTarget:GetBlueprint().Air.MaxAirspeed

                        ### Sets the fighter max speed to that of the target to help prevent overshoot.
                        if distance <= self.WepRng and self.Evade == false then
                            ### Compute the speed of the target and match it
                            self:SetSpeedMult(myTargetSpeed / self.MyMaxSpeed)
                            self:SetAccMult(1.0)
                            self:SetTurnMult(1.5)

                        ### If our target is out of weapons range then engage afterburner
                        elseif distance > self.WepRng and self.BurnerActive == false then

                            ### Set flag to true
                            self.BurnerActive = true

                            ### Kick off Afterburner multi and effects
                            self:ForkThread(self.Afterburner)
                        end
                    end
                end
            end
            ### Delay between checks
            --Mithy: lengthened to 1s from 0.25s, which is actually once per tick!
            WaitSeconds(1)
        end
    end,

    OnMotionHorzEventChange = function(self, new, old)
    	--Mithy: IdleState check, so drones don't re-guard unnecessarily
        if new == 'Stopped' or new == 'Stopping' and self:IsIdleState() then
            self:ForkThread(self.GuardCarrier)
        end
        SAirUnit.OnMotionHorzEventChange(self, new, old)
    end,

    GuardCarrier = function(self)
        if not self:IsDead() and not self.Parent:IsDead() then
            ### Tells the drone to guard the carrier
            --Mithy: Added brackets to clear commands.  Needs to be a table!
            IssueClearCommands({self})
            IssueGuard({self}, self.Parent)
        end
    end,

    OnDamage = function(self, instigator, amount, vector, damagetype)
        SAirUnit.OnDamage(self, instigator, amount, vector, damagetype)
        if self:IsDead() == false and instigator and IsUnit(instigator) then
            if self.BurnerActive == false then
                ### Set flags to true
                self.BurnerActive = true
                self.Evade = true
                ### Kick off Afterburner multi and effects
                self:ForkThread(self.Afterburner)
            end
        end
    end,

    Afterburner = function(self)
        if not self:IsDead() then
            if self.BeamExhaustEffectsBag then
                ### Engine effects clean up
                EffectUtil.CleanupEffectBag(self,'BeamExhaustEffectsBag')
            end
            ### Engage Afterburn speed and turn rates
            self:SetSpeedMult(1.5)
            self:SetAccMult(2.0)
            self:SetTurnMult(0.5)

            ### Afterburner sound effects
            self:PlayUnitSound('Launch')
            
            local army = self:GetArmy()

            ### Afterburn effects and smoke
            LOUDINSERT(self.BeamExhaustEffectsBag, CreateAttachedEmitter(self, 'XSA0001', army, self.ExhaustSmoke):ScaleEmitter(0.25))
            LOUDINSERT(self.BeamExhaustEffectsBag, CreateBeamEmitterOnEntity(self, 'XSA0001', army, self.BeamAfterBurner):ScaleEmitter(0.2))

            ### Play Afterburner sound effects
            self:PlayUnitSound('Afterburn')


            ### Duration of Afterburn
            WaitSeconds(self.Duration)

            ### Fuel calculations and Afterburn effect clean up
            if not self:IsDead() then

                if self.BeamExhaustEffectsBag then
                    ### Engine effects clean up
                    EffectUtil.CleanupEffectBag(self,'BeamExhaustEffectsBag')
                end

                ### Sets cruise thrust effect post afterburn
                LOUDINSERT(self.BeamExhaustEffectsBag, CreateBeamEmitterOnEntity( self, 'XSA0001', army, self.BeamCruise):ScaleEmitter(0.1))

                ### Resets the speed and turn rates
                self:SetSpeedMult(1.0)
                self:SetAccMult(1.0)
                self:SetTurnMult(1.0)

                ### Short cool down between Afterburns
                WaitSeconds(self.Duration)

                ### Resets Afterburn and Evade triggers
                if not self:IsDead() then
                    self.BurnerActive = false
                    self.Evade = false
                end
            end
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        ### Disables weapons
        self:SetWeaponEnabledByLabel('AutoCannon', false)
        self:SetWeaponEnabledByLabel('Bomb', false)

        ### Clears the current drone commands if any
        IssueClearCommands(self)

        ### Engine effects clean up
        EffectUtil.CleanupEffectBag(self,'BeamExhaustEffectsBag')

        ### Notifies parent of drone death and clears the offending drone from the parents table
        if not self.Parent:IsDead() then
        #LOG('*SINCE I JUST GOT MYSELF SHOT DOWN TELLING THE CARRIER TO MAKE ANOTHER DRONE')
            self.Parent:NotifyOfDroneDeath(self.Drone)
            for k,v in self.Parent.DroneTable do
                if self == v then
                    self.Parent.DroneTable[k] = nil
                end
            end
            #table.removeByValue(self.Parent.DroneTable, self)
            self.Parent = nil
        end

        ### Final command to finish off the drones death event
        SAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

}

TypeClass = BSA0001