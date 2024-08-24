local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Buff = import('/lua/sim/Buff.lua')

local CreateBoneEffects         = import('/lua/EffectUtilities.lua').CreateBoneEffects
local ConcussionRing            = import('/mods/4DC/lua/4D_EffectTemplates.lua').ConcussionRing
local WeaponSteam               = import('/lua/effecttemplates.lua').WeaponSteam01

local SniperWeapon = import('/lua/aeonweapons.lua').ADFDisruptorCannonWeapon

-- Bones for weapon recoil effects 
local weaponBones = { 'sniper_rifle', 'sniper_barrel' } 

UAL0204 = Class(AWalkingLandUnit) {   

    Weapons = {        

        Piercing_Rifle = Class(SniperWeapon) {

            PlayFxMuzzleSequence = function(self, muzzle) 
            
                for k, v in weaponBones do 
                    CreateBoneEffects( self.unit, v, self.unit.Army, WeaponSteam ) 
                end
   
                CreateBoneEffects( self.unit, 'ual0204', self.unit.Army, ConcussionRing )
   
                SniperWeapon.PlayFxMuzzleSequence(self)
            end,
        },

    },
    
    OnCreate = function(self,builder,layer)
    
        AWalkingLandUnit.OnCreate(self)

        self:DisableIntel('Omni')

        self:RequestRefreshUI()   
    end,    
	
    OnStopBeingBuilt = function(self,builder,layer)
	
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

    end,

    CreateEnhancement = function(self, enh)
    
        AWalkingLandUnit.CreateEnhancement(self, enh)
       
        if enh == 'EnhancedWeapon' then

            local wep = self:GetWeaponByLabel('Piercing_Rifle')
            
            wep.damageTable.DamageAmount = math.floor(wep.damageTable.DamageAmount * 1.2)
            wep:ChangeMaxRadius(50)

            local SetFiringArc = moho.AimManipulator.SetFiringArc

            SetFiringArc( wep.AimControl, -180, 180, 18, -48, 48, 20)
            
            wep.bp.EnergyRequired = 1400
            wep.bp.EnergyDrainPerSecond = 280
            
            Buff.ApplyBuff(self,'MobilityPenalty')
         
        elseif enh == 'EnhancedWeaponRemove' then

            local wep = self:GetWeaponByLabel('Piercing_Rifle')
            
            wep.damageTable.DamageAmount = wep:GetBlueprint().Damage
            wep:ChangeMaxRadius(42)

            local SetFiringArc = moho.AimManipulator.SetFiringArc

            SetFiringArc( wep.AimControl, -180, 180, 22, -48, 48, 24)
            
            wep.bp.EnergyRequired = 1100
            wep.bp.EnergyDrainPerSecond = 220
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
   
        elseif enh == 'EnhancedSensors' then
        
            -- Enable Enhanced Sensors (50% improvement)
            local IntelMod = self:GetBlueprint().Intel.VisionRadius * 1.3
            
            self:SetIntelRadius('Vision', IntelMod)
            self:SetIntelRadius('Omni', IntelMod * 0.3) 
            self:EnableIntel('Omni') 
            self:RequestRefreshUI() 
            
        elseif enh == 'EnhancedSensorsRemove' then
            -- Disable Enhanced Sensors
            local bpIntel = self:GetBlueprint().Intel
            
            self:SetIntelRadius('Vision', bpIntel.VisionRadius)
            self:SetIntelRadius('Omni', 0)  
            self:DisableIntel('Omni')
            self:RequestRefreshUI()                                                                            
        end
    end,                  
}

TypeClass = UAL0204