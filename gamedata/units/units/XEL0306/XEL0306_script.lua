
local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local TIFCruiseMissileUnpackingLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileUnpackingLauncher

local ForkThread = ForkThread
local ChangeState = ChangeState
local WaitTicks = coroutine.yield

XEL0306 = Class(TLandUnit) {
    Weapons = {
        MissileWeapon = Class(TIFCruiseMissileUnpackingLauncher) 
        {
            FxMuzzleFlash = {'/effects/emitters/terran_mobile_missile_launch_01_emit.bp'},
            
            
            OnLostTarget = function(self)
                self:ForkThread( self.LostTargetThread )
            end,
            
            RackSalvoFiringState = State(TIFCruiseMissileUnpackingLauncher.RackSalvoFiringState) {
                OnLostTarget = function(self)
                    self:ForkThread( self.LostTargetThread )
                end,            
            },            

			#-- changed so that it can pack the weapon
			#-- just after lost target - no need to be complicated
			#-- no reason it cant be moving & pack weapon at same time
            LostTargetThread = function(self)
			
--                local bp = self:GetBlueprint().Weapon[1]			
				
--                while not self.unit.Dead and self.unit:IsUnitState('Busy') do
                    WaitTicks(5)
--                end

                if self.unit.Dead then
                    return
                end

--                if bp.WeaponUnpacks then
                    ChangeState(self, self.WeaponPackingState)
--               else
--                    ChangeState(self, self.IdleState)
--                end
            end,
        },
    },
}

TypeClass = XEL0306