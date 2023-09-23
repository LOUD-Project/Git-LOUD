
local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local CAMEMPMissileWeapon = import('/lua/cybranweapons.lua').CAMEMPMissileWeapon
local CAntiNukeLaunch01 = import('/lua/EffectTemplates.lua').CAntiNukeLaunch01
local nukeFiredOnGotTarget = false

URB4302 = Class(CStructureUnit) {
    Weapons = {
        MissileRack = Class(CAMEMPMissileWeapon) {

            FxMuzzleFlash = CAntiNukeLaunch01,
            
            IdleState = State(CAMEMPMissileWeapon.IdleState) {

                OnGotTarget = function(self)

                    local bp = self:GetBlueprint()
					
                    -- only say we've fired if the parent fire conditions are met
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
        },

		MissileRack2 = Class(CAMEMPMissileWeapon) {
            FxMuzzleFlash = CAntiNukeLaunch01,
        },
    },
}

TypeClass = URB4302