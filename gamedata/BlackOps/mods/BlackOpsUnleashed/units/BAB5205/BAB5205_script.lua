local AAirStagingPlatformUnit = import('/lua/aeonunits.lua').AAirStagingPlatformUnit

local AAATemporalFizzWeapon = import('/lua/aeonweapons.lua').AAATemporalFizzWeapon
local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

local CreateRotator = CreateRotator

BAB5205 = Class(AAirStagingPlatformUnit) {

	Weapons = {
	
        AAGun01 = Class(AAATemporalFizzWeapon)
        {        
        
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                AAATemporalFizzWeapon.PlayFxWeaponPackSequence(self)
            end,
            PlayFxRackSalvoChargeSequence = function(self)
			
				local CreateRotator = CreateRotator
				
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'GunTurret01_Spinner_01', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                if not self.SpinManip2 then 
                    self.SpinManip2 = CreateRotator(self.unit, 'GunTurret01_Spinner_02', 'z', nil, -270, -180, -60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(300)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-300)
                end
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            
            PlayFxRackSalvoReloadSequence = function(self)
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-100)
                end

                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            
        },
        AAGun02 = Class(AAATemporalFizzWeapon)
        {        
        
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                AAATemporalFizzWeapon.PlayFxWeaponPackSequence(self)
            end,
            PlayFxRackSalvoChargeSequence = function(self)
				
				local CreateRotator = CreateRotator
				
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'GunTurret02_Spinner_01', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                if not self.SpinManip2 then 
                    self.SpinManip2 = CreateRotator(self.unit, 'GunTurret02_Spinner_02', 'z', nil, -270, -180, -60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(300)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-300)
                end
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,            
            PlayFxRackSalvoReloadSequence = function(self)
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-100)
                end

                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            
        },
        AAGun03 = Class(AAATemporalFizzWeapon)
        {        
        
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                AAATemporalFizzWeapon.PlayFxWeaponPackSequence(self)
            end,
            PlayFxRackSalvoChargeSequence = function(self)
			
				local CreateRotator = CreateRotator
				
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'GunTurret03_Spinner_01', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                if not self.SpinManip2 then 
                    self.SpinManip2 = CreateRotator(self.unit, 'GunTurret03_Spinner_02', 'z', nil, -270, -180, -60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(300)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-300)
                end
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,            
            PlayFxRackSalvoReloadSequence = function(self)
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-100)
                end

                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
            
        },
        AAGun04 = Class(AAATemporalFizzWeapon)
        {        
        
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                AAATemporalFizzWeapon.PlayFxWeaponPackSequence(self)
            end,
            PlayFxRackSalvoChargeSequence = function(self)
			
				local CreateRotator = CreateRotator
				
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'GunTurret04_Spinner_01', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                if not self.SpinManip2 then 
                    self.SpinManip2 = CreateRotator(self.unit, 'GunTurret04_Spinner_02', 'z', nil, -270, -180, -60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(300)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-300)
                end
                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,            
            PlayFxRackSalvoReloadSequence = function(self)
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-100)
                end

                AAATemporalFizzWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
        },
        Turret01 = Class(AANChronoTorpedoWeapon) {},
        Turret02 = Class(AANChronoTorpedoWeapon) {},
        Turret03 = Class(AANChronoTorpedoWeapon) {},
        Turret04 = Class(AANChronoTorpedoWeapon) {},
    },
    
	OnCreate = function(self)
	
		AAirStagingPlatformUnit.OnCreate(self)

        self.DomeEntity1 = import('/lua/sim/Entity.lua').Entity({Owner = self,})
        self.DomeEntity1:AttachBoneTo( -1, self, 'Torp_Turret01' )
        self.DomeEntity1:SetMesh('/effects/Entities/UAB2205_Dome/UAB2205_Dome_mesh')
        self.DomeEntity1:SetDrawScale(0.30)
        self.DomeEntity1:SetVizToAllies('Intel')
        self.DomeEntity1:SetVizToNeutrals('Intel')
        self.DomeEntity1:SetVizToEnemies('Intel')  
        
        self.DomeEntity2 = import('/lua/sim/Entity.lua').Entity({Owner = self,})
        self.DomeEntity2:AttachBoneTo( -1, self, 'Torp_Turret02' )
        self.DomeEntity2:SetMesh('/effects/Entities/UAB2205_Dome/UAB2205_Dome_mesh')
        self.DomeEntity2:SetDrawScale(0.30)
        self.DomeEntity2:SetVizToAllies('Intel')
        self.DomeEntity2:SetVizToNeutrals('Intel')
        self.DomeEntity2:SetVizToEnemies('Intel')
        
        self.DomeEntity3 = import('/lua/sim/Entity.lua').Entity({Owner = self,})
        self.DomeEntity3:AttachBoneTo( -1, self, 'Torp_Turret03' )
        self.DomeEntity3:SetMesh('/effects/Entities/UAB2205_Dome/UAB2205_Dome_mesh')
        self.DomeEntity3:SetDrawScale(0.30)
        self.DomeEntity3:SetVizToAllies('Intel')
        self.DomeEntity3:SetVizToNeutrals('Intel')
        self.DomeEntity3:SetVizToEnemies('Intel')
        
        self.DomeEntity4 = import('/lua/sim/Entity.lua').Entity({Owner = self,})
        self.DomeEntity4:AttachBoneTo( -1, self, 'Torp_Turret04' )
        self.DomeEntity4:SetMesh('/effects/Entities/UAB2205_Dome/UAB2205_Dome_mesh')
        self.DomeEntity4:SetDrawScale(0.30)
        self.DomeEntity4:SetVizToAllies('Intel')
        self.DomeEntity4:SetVizToNeutrals('Intel')
        self.DomeEntity4:SetVizToEnemies('Intel')       
        self.Trash:Add(self.DomeEntity1)
        self.Trash:Add(self.DomeEntity2)
        self.Trash:Add(self.DomeEntity3)
        self.Trash:Add(self.DomeEntity4)
		
		self.EventCallbacks.OnTransportAttach = {}
		self.EventCallbacks.OnTransportDetach = {}
	end,  
}

TypeClass = BAB5205