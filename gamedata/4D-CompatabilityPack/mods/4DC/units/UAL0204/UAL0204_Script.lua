local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local EffectUtils = import('/lua/EffectUtilities.lua')
local EffectTemplate = import('/lua/effecttemplates.lua')

local CreateBoneEffects = EffectUtils.CreateBoneEffects

local Custom_4D_EffectTemplate = import('/mods/4DC/lua/4D_EffectTemplates.lua')

local SniperWeapon = import('/lua/aeonweapons.lua').ADFDisruptorCannonWeapon

-- Bones for weapon recoil effects 
local weaponBones = { 'sniper_rifle', 'sniper_barrel' } 

UAL0204 = Class(AWalkingLandUnit) {   

    Weapons = {        
        -- Shield Piercing Rifle
        Sniper_Piercing_Rifle = Class(SniperWeapon) {

            PlayFxMuzzleSequence = function(self, muzzle) 
            
                for k, v in weaponBones do 
                    CreateBoneEffects( self.unit, v, self.unit.Army, EffectTemplate.WeaponSteam01 ) 
                end
                
                CreateBoneEffects( self.unit, 'ual0204', self.unit.Army, Custom_4D_EffectTemplate.ConcussionRing )
                
                SniperWeapon.PlayFxMuzzleSequence(self)
            end,
        },                
    },
    
    OnCreate = function(self,builder,layer)
    
        AWalkingLandUnit.OnCreate(self)
        
        self:SetIntelRadius('Omni', 0)  
        self:DisableIntel('Omni')
        self:RequestRefreshUI()   
    end,    
    
    CreateEnhancement = function(self, enh)
    
        AWalkingLandUnit.CreateEnhancement(self, enh)
        
        local bp = __blueprints[self.BlueprintID].Enhancements[enh]
        
        if not bp then return end 
        
        if enh == 'EnhancedWeapon' then
            -- Add enhanced weapon range (25% improvement) & damage (25% improvement) 
            for i = 1, self:GetWeaponCount() do
            
                local wep = self:GetWeapon(i)
                
                wep:ChangeMaxRadius(wep:GetBlueprint().MaxRadius * 1.25)
                wep:AddDamageMod(wep:GetBlueprint().Damage * 0.25)       
            end 
            
        elseif enh == 'EnhancedWeaponRemove' then
            -- Remove enhanced weapon range & damage
            for i = 1, self:GetWeaponCount() do
            
                local wep = self:GetWeapon(i)
                
                wep:ChangeMaxRadius(wep:GetBlueprint().MaxRadius )
                wep:AddDamageMod(wep:GetBlueprint().Damage * -0.25)                   
            end 
            
        elseif enh == 'EnhancedSensors' then
        
            -- Enable Enhanced Sensors (50% improvement)
            local IntelMod = self:GetBlueprint().Intel.VisionRadius * 1.5
            
            self:SetIntelRadius('Vision', IntelMod)
            self:SetIntelRadius('Omni', IntelMod * 0.5) 
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