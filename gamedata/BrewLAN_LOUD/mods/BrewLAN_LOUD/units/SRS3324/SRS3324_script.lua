local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local CAAMissileNaniteWeapon    = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CAMZapperWeapon           = import('/lua/cybranweapons.lua').CAMZapperWeapon
local CANNaniteTorpedoWeapon    = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon
local CIFSmartCharge            = import('/lua/cybranweapons.lua').CIFSmartCharge

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')

SRS3324 = Class(CSeaUnit) {

    DestructionTicks = 200,

    Weapons = {

        SAM         = Class(CAAMissileNaniteWeapon) {},
        Zapper      = Class(CAMZapperWeapon) {},
        Torpedo     = Class(CANNaniteTorpedoWeapon) {},
        AntiTorpedo = Class(CIFSmartCharge) {},
    },

    RadarThread = function(self)
        --CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
        local spinner = CreateRotator(self, 'Big_Dish', 'y', -80, 15)
        local spinner2 = CreateRotator(self, 'Tower_Core', 'z', nil, 16.875)

        while not self.Dead do
            if self:IsIntelEnabled('Omni') then
                WaitFor(spinner)
                spinner:SetGoal(80)
                spinner2:SetSpeed(60)
            else
                spinner2:SetSpeed(0)
                coroutine.yield(31)
            end
            if self:IsIntelEnabled('Omni') then
                WaitFor(spinner)
                spinner:SetGoal(-80)
                spinner2:SetSpeed(60)
            else
                spinner2:SetSpeed(0)
                coroutine.yield(31)
            end
        end
    end,

    OnStopBeingBuilt = function(self, builder,layer)

        CSeaUnit.OnStopBeingBuilt(self, builder,layer)

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

        self.UAV = CreateUnit('sra3101', self:GetArmy(), x,y,z,qx,qy,qz,qw, 'Water')
        self.UAV:SetParent(self)
        self.UAV:SetCreator(self)
    end,

    RebuildUAVThread = function(self)

        self.UAV = CreateEconomyEvent(self,
            __blueprints.sra3101.Economy.BuildCostEnergy,
            __blueprints.sra3101.Economy.BuildCostMass,
            __blueprints.sra3101.Economy.BuildTime/(__blueprints.ses3324.Economy.BuildRate or 20),
            self.SetWorkProgress
        )
        WaitFor(self.UAV)
        RemoveEconomyEvent(self, self.UAV)

        self:SetWorkProgress(0.0)

        local x,y,z = self:GetPositionXYZ'AttachSpecial'
        local qx,qy,qz,qw = unpack(self:GetOrientation())

        self.UAV = CreateUnit('sra3101', self:GetArmy(), x,y,z,qx,qy,qz,qw, 'Water')
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
        CSeaUnit.OnScriptBitSet(self, bit)
        if bit==4 then -- RULEUTC_ProductionToggle
        elseif bit==6 then -- RULEUTC_GenericToggle
        end
        _ALERT(bit, "set")
    end,]]

    OnScriptBitClear = function(self, bit) -- ON
        CSeaUnit.OnScriptBitClear(self, bit)
        if bit==4 and not self.UAV then -- RULEUTC_ProductionToggle
            self:ForkThread(self.RebuildUAVThread)
        --elseif bit==6 then -- RULEUTC_GenericToggle
        end
        --_ALERT(bit, "clear")
    end,
}

TypeClass = SRS3324
