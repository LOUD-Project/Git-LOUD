local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local MissileFlare = import('/lua/defaultunits.lua').BaseDirectionalAntiMissileFlare

local terranweapons = import('/lua/terranweapons.lua')

local TIFSmallYieldNuclearBombWeapon    = terranweapons.TIFSmallYieldNuclearBombWeapon
local TIFCruiseMissileLauncher          = terranweapons.TIFCruiseMissileLauncher
local TANTorpedoAngler                  = terranweapons.TANTorpedoAngler

terranweapons = nil

SEA0314 = Class(TAirUnit, MissileFlare) {

    Weapons = {

        Bomb = Class(TIFSmallYieldNuclearBombWeapon) {

            -- hooking the bomb firing in the hope of someday diverting
            -- the bomber immediately upon firing rather than breaking off
            -- only after having overflown the target
            OnWeaponFired = function(self)
            
                TIFSmallYieldNuclearBombWeapon.OnWeaponFired(self)

            end,
        
        },
        
        Missile = Class(TIFCruiseMissileLauncher) {},
        Torpedo = Class(TANTorpedoAngler) { FxMuzzleFlash = false },
    },

    FlareBones = {'Tail'},

    OnStopBeingBuilt = function(self,builder,layer)

        TAirUnit.OnStopBeingBuilt(self,builder,layer)

        self:SetScriptBit('RULEUTC_StealthToggle', true)

        self:CreateMissileDetector()

        self.WingRotors = {
            CreateRotator(self, 'Wing_Left', 'z'),
            CreateRotator(self, 'Wing_Right', 'z'),
        }
        
        self.LandRotors = {
            CreateRotator(self, 'Landing_Gear_Front', 'y'),
            CreateRotator(self, 'Landing_Gear_Left', 'y'),
            CreateRotator(self, 'Landing_Gear_Right', 'y'),
        }

        self:RotateSet(self.WingRotors, 53.5)
    end,

    RotateSet = function(self, rotors, angle)

        if not rotors then return false end

        for i, rotor in rotors do
            rotor:SetGoal(angle)
            rotor:SetSpeed(45)
        end
    end,

    OnMotionHorzEventChange = function(self, new, old)

        TAirUnit.OnMotionHorzEventChange(self, new, old)

        if new == 'TopSpeed' then
            self:RotateSet(self.WingRotors, 0)
        else
            self:RotateSet(self.WingRotors, 53.5)
        end
    end,

    OnMotionVertEventChange = function(self, new, old)

        TAirUnit.OnMotionVertEventChange(self, new, old)

        if new == 'Down' and old == 'Top' or new == 'Bottom' then
            self:RotateSet(self.LandRotors, 0)
        else
            self:RotateSet(self.LandRotors, 90)
        end
    end,
}

TypeClass = SEA0314
