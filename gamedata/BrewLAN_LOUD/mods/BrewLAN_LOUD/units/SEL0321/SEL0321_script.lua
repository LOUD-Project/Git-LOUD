local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TAMInterceptorWeapon = import('/lua/terranweapons.lua').TAMInterceptorWeapon

SEL0321 = Class(TLandUnit) {

    AmmoChange = function(self)

        local wep = self:GetWeaponByLabel('AntiMissile')

        if self:GetTacticalSiloAmmoCount() >= wep.bp.MuzzleSalvoSize then

            -- reset range to normal
            wep:ChangeMaxRadius(self:GetBlueprint().Weapon[1].MaxRadius )

        else

            wep:ChangeMaxRadius( 1 )
        end
    end,

    OnCreated = function(self)
        
        -- we create these here because they are not created by default
        self.EventCallbacks.OnTMLAmmoIncrease = {}
        self.EventCallbacks.OnTMLAmmoDecrease = {}

        self:AddUnitCallback( self.AmmoChange, 'OnTMLAmmoIncrease' )
        self:AddUnitCallback( self.AmmoChange, 'OnTMLAmmoDecrease' )

        -- this thread will watch the ammo count every 6 seconds and issue an event on any change
        -- this thread is what will trigger the TMLAmmo events
        self.AmmoCheckThread = self:ForkThread(self.CheckCountedMissileAmmo)

        TLandUnit.OnCreated(self)
    end,

    Weapons = {

        AntiMissile = Class(TAMInterceptorWeapon) {
        
            OnCreate = function(self)

                TAMInterceptorWeapon.OnCreate(self)
                
                self:ChangeMaxRadius( 1 )      -- set range to 1 by default
            end
        },
    },
    
}

TypeClass = SEL0321
