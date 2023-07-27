local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TIFCruiseMissileUnpackingLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileUnpackingLauncher

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

            end,

            PlayFxRackReloadSequence = function(self)

                self:PlayFxWeaponPackSequence()

                self.Animator = CreateAnimator(self.unit)
        
                PlayAnim( self.Animator, self.bp.AnimationReload):SetRate( self.bp.AnimationReloadRate or 1)

                WaitFor(self.Animator)

            end,

            RackSalvoFiringState = State(TIFCruiseMissileUnpackingLauncher.RackSalvoFiringState) {

                OnLostTarget = function(self)
                    self:ForkThread( self.LostTargetThread )
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