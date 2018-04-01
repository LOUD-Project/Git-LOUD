
local TSeaUnit = import('/lua/terranunits.lua').TSeaUnit
local WeaponFile = import('/lua/terranweapons.lua')
local TSAMLauncher = WeaponFile.TSAMLauncher
local TDFGaussCannonWeapon = WeaponFile.TDFGaussCannonWeapon
local TAMPhalanxWeapon = WeaponFile.TAMPhalanxWeapon
local TIFCruiseMissileLauncher = WeaponFile.TIFCruiseMissileLauncher

local TAAMissileLaunchNoBackSmoke = import('/lua/EffectTemplates.lua').TAAMissileLaunchNoBackSmoke

UES0202 = Class(TSeaUnit) {
    DestructionTicks = 200,

    Weapons = {
        FrontTurret01 = Class(TDFGaussCannonWeapon) {},
        
        BackTurret02 = Class(TSAMLauncher) { FxMuzzleFlash = TAAMissileLaunchNoBackSmoke, },
        
        PhalanxGun01 = Class(TAMPhalanxWeapon) {
            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Center_Turret_Barrel', 'z', nil, 270, 180, 60)
                    self.SpinManip:SetPrecedence(10)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(270)
                end
                TAMPhalanxWeapon.PlayFxWeaponUnpackSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                TAMPhalanxWeapon.PlayFxWeaponPackSequence(self)
            end,
        },
        
        CruiseMissile = Class(TIFCruiseMissileLauncher) {

			CurrentRack = 1,

            CreateProjectileAtMuzzle = function(self, muzzle)
                self:ForkThread(self.CreateCruiseMissile, muzzle)
            end,

            CreateCruiseMissile = function(self, muzzle)
                muzzle = self:GetBlueprint().RackBones[self.CurrentRack].MuzzleBones[1]
				
                #Weapons.CruiseMissile.PlayFxMuzzleSequence(self, muzzle)
				#PlayFxMuzzleSequence(self, muzzle)
				
                if self.CurrentRack < 8 then
					self.CurrentRack = self.CurrentRack + 1
				else
					self.CurrentRack = 1
				end
				
                WaitSeconds(1)   # the pre-firing animation takes 1 second to play
				
                if self.unit:IsDead() then return end

                TIFCruiseMissileLauncher.CreateProjectileAtMuzzle(self, muzzle)
            end,

            PlayFxMuzzleSequence = function(self, muzzle)
                # preventing the generic weapon system from playing the muzzle FX: it creates smoke at the wrong
                # muzzles. Doing it manually, see 2nd line in CreateCruiseMissile()
            end,
            },
    },

    RadarThread = function(self)
        local spinner = CreateRotator(self, 'Spinner04', 'x', nil, 0, 30, -45)
        while true do
            WaitFor(spinner)
            spinner:SetTargetSpeed(-45)
            WaitFor(spinner)
            spinner:SetTargetSpeed(45)
        end
    end,

    OnStopBeingBuilt = function(self, builder,layer)
        TSeaUnit.OnStopBeingBuilt(self, builder,layer)
        #self:ForkThread(self.RadarThread)
        #self.Trash:Add(CreateRotator(self, 'Spinner01', 'y', nil, 45, 0, 0))
        #self.Trash:Add(CreateRotator(self, 'Spinner03', 'y', nil, -30, 0, 0))
    end,

}

TypeClass = UES0202
