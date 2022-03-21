local TSubUnit = import('/lua/defaultunits.lua').SubUnit

local CMobileKamikazeBombWeapon = import('/lua/cybranweapons.lua').CMobileKamikazeBombWeapon
local CMobileKamikazeBombDeathWeapon = import('/lua/cybranweapons.lua').CMobileKamikazeBombDeathWeapon

ues0206 = Class(TSubUnit) {
    DestroyOnKilled = false,
    Weapons = {
        DeathWeapon = Class(CMobileKamikazeBombDeathWeapon) {},   
        Suicide = Class(CMobileKamikazeBombWeapon) { 
            OnFire = function(self)			
                -- Disable death weapon after initial firing
                if not self.unit.AlreadyDetonated then
                    self.unit.AlreadyDetonated = true
                end
                self.unit:SetDeathWeaponEnabled(false)

                -- Detonation effects
                self.unit:MineDetonation()
                CMobileKamikazeBombWeapon.OnFire(self)
            end,
        },
    },

    OnCreate = function(self,builder,layer)
        TSubUnit.OnCreate(self)
        -- enable cloaking and stealth  
        self:EnableIntel('Cloak') 
        self:EnableIntel('RadarStealth')
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        TSubUnit.OnStopBeingBuilt(self,builder,layer)
        -- Allows the mine to sink if not already underwater
        if not self:IsDead() and self:GetCurrentLayer() == 'Water' then 
	    IssueDive({self})
            self:ForkThread(self.DiveEffects)
        end
    end,

    DiveEffects = function(self)
        if not self:IsDead() then
            local effects = CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/underwater_vent_bubbles_02_emit.bp'):ScaleEmitter(1.0)
            -- Short delay to allow the dive effects to complete
            WaitSeconds(2)
            if not self:IsDead() then
                -- Removes old dive effects
                effects:Destroy()
            end
        end
    end,

    DeathThread = function(self)
        -- Removes unused bones after the unit has detonated
        self:HideBone('ues0206', true)

        -- Disables cloaking and stealth
        self:DisableIntel('Cloak') 
        self:DisableIntel('RadarStealth')
        self:DisableIntel('SonarStealth')

        -- Short delay to allow detonation effects to complete
        WaitSeconds(2)

        -- Removes the unwanted damage effects and whats left of the mine after detonation
        self:DestroyAllDamageEffects() 
        self:Destroy()
    end,

    OnDamage = function(self, instigator, amount, vector, damagetype)
        -- Detonate our mine should it be hit with damage greater then its current hitpoint total
        if IsUnit(instigator) and damagetype == 'Normal' then
            if amount >= self:GetHealth() then 
                if not self.AlreadyDetonated then
                    self.AlreadyDetonated = true
                    self:GetWeaponByLabel('Suicide'):FireWeapon()
                end
            end
        end
        TSubUnit.OnDamage(self, instigator, amount, vector, damagetype)
    end,

    MineDetonation = function(self)
        -- Mine detonation and special effects
        self:ShakeCamera(6, 2.0, 1.0, 2)
        CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):ScaleEmitter(5.0)
        CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/destruction_underwater_explosion_flash_02_emit.bp'):ScaleEmitter(5.0)
        CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/water_splash_plume_01_emit.bp'):ScaleEmitter(5.0)
        CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/water_splash_plume_02_emit.bp'):ScaleEmitter(5.0)
        CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/water_splash_ripples_ring_01_emit.bp'):ScaleEmitter(5.0)
        CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/water_splash_ripples_ring_02_emit.bp'):ScaleEmitter(5.0)
        CreateAttachedEmitter(self, 'ues0206', self:GetArmy(), '/effects/emitters/underwater_bubbles_01_emit.bp'):ScaleEmitter(5.0) 
    end,
}
TypeClass = ues0206