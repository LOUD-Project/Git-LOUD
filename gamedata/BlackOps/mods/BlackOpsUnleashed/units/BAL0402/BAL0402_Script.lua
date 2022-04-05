local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFDisruptorWeapon = import('/lua/aeonweapons.lua').ADFDisruptorWeapon
local AIFMissileTacticalSerpentineWeapon = import('/lua/aeonweapons.lua').AIFMissileTacticalSerpentineWeapon
local AAMWillOWisp = import('/lua/aeonweapons.lua').AAMWillOWisp

local explosion = import('/lua/defaultexplosions.lua')
local Weapon = import('/lua/sim/Weapon.lua').Weapon

local LOUDINSERT = table.insert
local LOUDATTACHEMITTER = CreateAttachedEmitter

local Buff = import('/lua/sim/Buff.lua')
local AeonBuffField = import('/lua/aeonweapons.lua').AeonBuffField

BAL0402 = Class(AHoverLandUnit) {
    FxDamageScale = 2,
    DestructionTicks = 400,
	
	BuffFields = {
	
		RegenField = Class(AeonBuffField){
		
			OnCreate = function(self)
				AeonBuffField.OnCreate(self)
			end,
		},
	},

    Weapons = {
	
		MissileRack = Class(AIFMissileTacticalSerpentineWeapon) {},
		
        MainGun = Class(ADFDisruptorWeapon) {},
		
		LeftTurret = Class(import('/lua/aeonweapons.lua').ADFCannonOblivionWeapon) {
			FxMuzzleFlash = {
				'/effects/emitters/oblivion_cannon_flash_04_emit.bp',
				'/effects/emitters/oblivion_cannon_flash_05_emit.bp',				
				'/effects/emitters/oblivion_cannon_flash_06_emit.bp',
			},        
        },
		
		RightTurret = Class(import('/lua/aeonweapons.lua').ADFCannonOblivionWeapon) {
			FxMuzzleFlash = {
				'/effects/emitters/oblivion_cannon_flash_04_emit.bp',
				'/effects/emitters/oblivion_cannon_flash_05_emit.bp',				
				'/effects/emitters/oblivion_cannon_flash_06_emit.bp',
			},        
        },
		
        AntiMissile1 = Class(AAMWillOWisp) {},
		
    },
	
	OnStopBeingBuilt = function(self,builder,layer)

		self.MaelstromEffects01 = {}
		if self.MaelstromEffects01 then
				for k, v in self.MaelstromEffects01 do
					v:Destroy()
				end
			self.MaelstromEffects01 = {}
		end
        
        local army = self.Army
		local LOUDINSERT = table.insert
		local LOUDATTACHEMITTER = CreateAttachedEmitter
        
		LOUDINSERT( self.MaelstromEffects01, LOUDATTACHEMITTER( self, 'Maelstrom', army, '/mods/BlackopsUnleashed/effects/emitters/genmaelstrom_aura_02_emit.bp' ):ScaleEmitter(1):OffsetEmitter(0, -2.75, 0) )
		
		AHoverLandUnit.OnStopBeingBuilt(self,builder,layer)
		
		-- we're not really cloaking so turn this off
		-- we just use the CloakField radius to show the area of effect
		self:DisableUnitIntel('CloakField')
		
		-- turn it on to start
		self:SetScriptBit('RULEUTC_ShieldToggle',true)
	end,
	
	OnScriptBitSet = function(self, bit)
	
		if bit == 0 then
			self:GetBuffFieldByName('AeonMaelstromBuffField2'):Enable()
		end
	
	end,
	
	OnScriptBitClear = function(self, bit)
	
		if bit == 0 then
			self:GetBuffFieldByName('AeonMaelstromBuffField2'):Disable()
		end
	
	end,	
    
	DeathThread = function( self, overkillRatio , instigator)
    
        explosion.CreateDefaultHitExplosionAtBone( self, 'BAL0402', 4.0 )
        explosion.CreateDebrisProjectiles(self, explosion.GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})           
        WaitSeconds(0.8)
        explosion.CreateDefaultHitExplosionAtBone( self, 'TMD_Muzzle', 3.0 )
		explosion.CreateDefaultHitExplosionAtBone( self, 'Right_Barrel', 1.0 )
        WaitSeconds(0.1)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Wraith_Left_Recoil_01', 4.0 )
        WaitSeconds(0.1)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Wraith_Right_Recoil_02', 1.0 )
		explosion.CreateDefaultHitExplosionAtBone( self, 'Missile_Muzzle_6', 3.0 )
        WaitSeconds(0.3)
        explosion.CreateDefaultHitExplosionAtBone( self, 'Wraith_Turret_Barrel', 1.0 )
        explosion.CreateDefaultHitExplosionAtBone( self, 'Left_Barrel', 5.0 )

        WaitSeconds(0.5)
        explosion.CreateDefaultHitExplosionAtBone( self, 'BAL0402', 5.0 )        

        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
    
        local bp = __blueprints[self.BlueprintID]
        
        for i, numWeapons in bp.Weapon do
        
            if(bp.Weapon[i].Label == 'CollossusDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end

        self:DestroyAllDamageEffects()
        self:CreateWreckage( overkillRatio )

        if( self.ShowUnitDestructionDebris and overkillRatio ) then
            if overkillRatio <= 1 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 2 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 3 then
                self.CreateUnitDestructionDebris( self, true, true, true )
            else #VAPORIZED
                self.CreateUnitDestructionDebris( self, true, true, true )
            end
        end

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,

}

TypeClass = BAL0402