local TSeaUnit      = import('/lua/defaultunits.lua').SeaUnit
local WeaponFile    = import('/lua/terranweapons.lua')

local TDepthCharge  = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')

SES3324 = Class(TSeaUnit) {

    DestructionTicks = 200,

    Weapons = {

        SAM         = Class(WeaponFile.TSAMLauncher) { FxMuzzleFlash = import('/lua/EffectTemplates.lua').TAAMissileLaunchNoBackSmoke },
        Phalanx     = Class(WeaponFile.TAMPhalanxWeapon) {

            OnCreate = function(self)
                self.SpinManip = CreateRotator(self.unit, 'Phalanx_Muzzle', 'z', nil, nil, 180)
                self.SpinManip:SetPrecedence(10)
                self.unit.Trash:Add(self.SpinManip)
                WeaponFile.TAMPhalanxWeapon.OnCreate(self)
            end,

            PlayFxWeaponUnpackSequence = function(self)
                self.SpinManip:SetTargetSpeed(270)
                WeaponFile.TAMPhalanxWeapon.PlayFxWeaponUnpackSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                self.SpinManip:SetTargetSpeed(0)
                WeaponFile.TAMPhalanxWeapon.PlayFxWeaponPackSequence(self)
            end,

        },
        Torpedo     = Class(WeaponFile.TANTorpedoAngler) {},
        AntiTorpedo = Class(WeaponFile.TIFSmartCharge) {},
        DepthCharge = Class(TDepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                TDepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( TDepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(6)
                
                    TDepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( TDepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(15) self:ChangeMinRadius(15) WaitTicks(44) self:ChangeMinRadius(0) self:ChangeMaxRadius(12) end)
                    
                    TDepthCharge.RackSalvoReloadState.Main(self)

                end,
            },        
        },
    },

    RadarThread = function(self)

        local spinner = CreateRotator(self, 'Dish_Bottom', 'y', -80, 45)
        local spinner2 = CreateRotator(self, 'Dish_Top', 'X', -60, 16.875)

        while not self.Dead do
            if self:IsIntelEnabled('Omni') then
                WaitFor(spinner)
                spinner:SetGoal(80)
                spinner2:SetGoal(0)
            else
                coroutine.yield(31)
            end

            if self:IsIntelEnabled('Omni') then
                WaitFor(spinner)
                spinner:SetGoal(-80)
                spinner2:SetGoal(-60)
            else
                coroutine.yield(31)
            end
        end
    end,

    OnStopBeingBuilt = function(self, builder,layer)

        TSeaUnit.OnStopBeingBuilt(self, builder,layer)

        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_IntelToggle', true)

        if RadarRestricted then
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        else
            self:ForkThread(self.RadarThread)
        end

        self:RequestRefreshUI()

        local x,y,z = self:GetPositionXYZ'AttachSpecial'
        local qx,qy,qz,qw = unpack(self:GetOrientation())

        self.UAV = CreateUnit('sea3101', self:GetArmy(), x,y,z,qx,qy,qz,qw, 'Water')
        self.UAV:SetParent(self)
        self.UAV:SetCreator(self)
    end,

    RebuildUAVThread = function(self)
        self.UAV = CreateEconomyEvent(self,
            __blueprints.sea3101.Economy.BuildCostEnergy,
            __blueprints.sea3101.Economy.BuildCostMass,
            __blueprints.sea3101.Economy.BuildTime/(__blueprints.ses3324.Economy.BuildRate or 20),
            self.SetWorkProgress
        )
        WaitFor(self.UAV)
        RemoveEconomyEvent(self, self.UAV)
        self:SetWorkProgress(0.0)
        local x,y,z = self:GetPositionXYZ'AttachSpecial'
        local qx,qy,qz,qw = unpack(self:GetOrientation())
        self.UAV = CreateUnit('sea3101', self:GetArmy(), x,y,z,qx,qy,qz,qw, 'Water')
        self.UAV:SetParent(self)
        self.UAV:SetCreator(self)
    end,

    NotifyOfPodDeath = function(self)
        if not self:GetScriptBit('RULEUTC_ProductionToggle') then
            self:ForkThread(self.RebuildUAVThread)
        else
            self.UAV = nil
        end
    end,

    --[[OnScriptBitSet = function(self, bit) -- OFF
        TSeaUnit.OnScriptBitSet(self, bit)
        if bit==4 then -- RULEUTC_ProductionToggle
        elseif bit==6 then -- RULEUTC_GenericToggle
        end
        _ALERT(bit, "set")
    end,]]

    OnScriptBitClear = function(self, bit) -- ON
        TSeaUnit.OnScriptBitClear(self, bit)
        if bit==4 and not self.UAV then -- RULEUTC_ProductionToggle
            self:ForkThread(self.RebuildUAVThread)
        --elseif bit==6 then -- RULEUTC_GenericToggle
        end
        --_ALERT(bit, "clear")
    end,
}

TypeClass = SES3324
