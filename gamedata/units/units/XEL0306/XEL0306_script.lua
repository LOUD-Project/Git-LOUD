local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TIFCruiseMissileUnpackingLauncher = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

local ForkThread = ForkThread
local ChangeState = ChangeState

local PlayAnim = moho.AnimationManipulator.PlayAnim

local WaitTicks = coroutine.yield

XEL0306 = Class(TLandUnit) {
    Weapons = {
        MissileWeapon = Class(TIFCruiseMissileUnpackingLauncher) {

            FxMuzzleFlash = {'/effects/emitters/terran_mobile_missile_launch_01_emit.bp'},
           
            OnLostTarget = function(self)
                self:ForkThread( self.LostTargetThread )
            end,
            
            PlayFxRackSalvoChargeSequence = function(self)

                self:PlayFxWeaponUnpackSequence()
                
                TIFCruiseMissileUnpackingLauncher.PlayFxRackSalvoChargeSequence(self)

            end,

            PlayFxRackReloadSequence = function(self)

                self:PlayFxWeaponPackSequence()
                
                TIFCruiseMissileUnpackingLauncher.PlayFxRackReloadSequence(self)

            end,

            RackSalvoFiringState = State(TIFCruiseMissileUnpackingLauncher.RackSalvoFiringState) {

                OnLostTarget = function(self)
                    self:ForkThread( self.LostTargetThread )
                end,            
            },

            -- the launcher is raised in PlayFxRackSalvoChargeSequence, but a weapon that is
            -- already charged goes from IdleState.OnGotTarget straight to this state and skips
            -- the charge state - so raise it here if it is still down, before the weapon can fire
            RackSalvoFireReadyState = State(TIFCruiseMissileUnpackingLauncher.RackSalvoFireReadyState) {

                Main = function(self)

                    if not self.WeaponUnpacked then

                        -- OnFire events during the unpack must not start the firing state
                        self.WeaponCanFire = false

                        self:PlayFxWeaponUnpackSequence()
                    end

                    TIFCruiseMissileUnpackingLauncher.RackSalvoFireReadyState.Main(self)

                end,

                -- OnFire can arrive in the same tick as OnGotTarget, before Main has run
                -- (WeaponCanFire is still true from the last salvo) - only note it while the
                -- launcher is down, Main fires once it is raised
                OnFire = function(self)

                    if not self.WeaponUnpacked then

                        self.OnFireEvent = true
                        return
                    end

                    TIFCruiseMissileUnpackingLauncher.RackSalvoFireReadyState.OnFire(self)

                end,
            },

            -- changed so that it can pack the weapon
			-- just after lost target - no need to be complicated
			-- no reason it cant be moving & pack weapon at same time
            LostTargetThread = function(self)

                WaitTicks(5)

                if self.unit.Dead then
                    return
                end

                ChangeState(self, self.WeaponPackingState)

            end,
        },
    },
}

TypeClass = XEL0306