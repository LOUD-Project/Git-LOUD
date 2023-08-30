local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CAMEMPMissileWeapon = import('/lua/cybranweapons.lua').CAMEMPMissileWeapon

SAL0321 = Class(AWalkingLandUnit) {

    Weapons = {

        AntiNuke = Class(CAMEMPMissileWeapon) {
--[[        
            IdleState = State(CAMEMPMissileWeapon.IdleState) {

                OnGotTarget = function(self)
                    local bp = self:GetBlueprint()

                    --only say we've fired if the parent fire conditions are met
                    if (bp.WeaponUnpackLockMotion != true or (bp.WeaponUnpackLocksMotion == true and not self.unit:IsUnitState('Moving'))) then

                        if (bp.CountedProjectile == false) or self:CanFire() then
                            nukeFiredOnGotTarget = true
                        end
                    end

                    CAMEMPMissileWeapon.IdleState.OnGotTarget(self)
                end,
   
                -- uses OnGotTarget, so we shouldn't do this.
                OnFire = function(self)

                    if not nukeFiredOnGotTarget then
                        CAMEMPMissileWeapon.IdleState.OnFire(self)
                    end

                    nukeFiredOnGotTarget = false
       
                    self:ForkThread(function()
                        self.unit:SetBusy(true)
                        WaitSeconds(1/self.unit:GetBlueprint().Weapon[1].RateOfFire + .2)
                        self.unit:SetBusy(false)
                    end)
                end,
            },
--]]
        },
    },
}

TypeClass = SAL0321
