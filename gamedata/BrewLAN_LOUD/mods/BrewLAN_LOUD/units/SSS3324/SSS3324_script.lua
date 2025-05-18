local SSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing

SSeaUnit = RemoteViewing( SSeaUnit )

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SAAShleoCannonWeapon          = SeraphimWeapons.SAAShleoCannonWeapon
local SAMElectrumMissileDefense     = SeraphimWeapons.SAMElectrumMissileDefense
local SANAnaitTorpedo               = SeraphimWeapons.SANAnaitTorpedo
local SDFAjelluAntiTorpedoDefense   = SeraphimWeapons.SDFAjelluAntiTorpedoDefense

local SeraphimWeapons = nil

local DishAnimation = import('/lua/effectutilities.lua').IntelDishAnimationThread

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')

SSS3324 = Class(SSeaUnit) {

    Weapons = {
        AAGun           = Class(SAAShleoCannonWeapon) {},
		AntiMissile     = Class(SAMElectrumMissileDefense) {},
		Torpedo         = Class(SANAnaitTorpedo) {},
        AntiTorpedo     = Class(SDFAjelluAntiTorpedoDefense) {},
    },

    OnStopBeingBuilt = function(self, ...)

        SSeaUnit.OnStopBeingBuilt(self, unpack(arg) )

        self:SetMaintenanceConsumptionInactive()

        self:SetScriptBit('RULEUTC_IntelToggle', true)

        if RadarRestricted then
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        else
            self:ForkThread( DishAnimation, {{'Intel_Base_ORB','Intel_Base_ORB', bounds = {-180,180,-15,50}, speed = 3 }} )
        end

        self:RequestRefreshUI()

    end,

    OnIntelEnabled = function(self)

        SSeaUnit.OnIntelEnabled(self)

        self.Intel = true
--[[
        if not self.Rotors then

            self.Rotors = {}

            for i, v in {'Intel_Ring_Big','Intel_Ring_Mid'} do

                --CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
                self.Rotors[i] = CreateRotator(self, v, 'x', 0, 20, 0.024):SetAccel(0.00001)

                self.Trash:Add(self.Rotors[i])

                self:ForkThread(
                    function(self, rotor)
                        while not self.Dead do
                            if self.Intel then
                                rotor:SetGoal(math.random(-59, 59))
                            end
                            coroutine.yield(math.random(30, 90))
                        end
                    end,
                    self.Rotors[i]
                )
            end
        end
--]]
    end,

    OnIntelDisabled = function(self)

        SSeaUnit.OnIntelDisabled(self)

        self.Intel = nil
    end,

    OnTargetLocation = function(self, location) 

        local aiBrain = self:GetAIBrain()            

        if self:AntiTeleportBlock( aiBrain, location) then
            return
        end

        --LOG("*AI DEBUG BEFORE creation data is "..repr(self.RemoteViewingData))

        -- find a target unit 
        local targettable = aiBrain:GetUnitsAroundPoint(categories.SELECTABLE, location, 10)
        local targetunit = targettable[1]

        if table.getn(targettable) > 1 then

            local dist = 100

            for i, target in targettable do    

                if IsUnit(target) then

                    local cdist = VDist2Sq(target:GetPosition()[1], target:GetPosition()[3], location[1], location[3])

                    if cdist < dist then
                        dist = cdist
                        targetunit = target
                    end
                end
            end   
        end

        if targetunit and IsUnit(targetunit) then

            self.RemoteViewingData.VisibleLocation = location
            self.RemoteViewingData.TargetUnit = targetunit

            self:CreateVisibleEntity()
        else
            
            self.RemoteViewingData.VisibleLocation = false

        end

    end,

    DeathThread = function(self)

        --Destroy the custom anim rotors
        if self.Rotors then
            for i, v in self.Rotors do
                v:Destroy()
            end
        end

        --Destroy the pitch control rotor from the effect util anims
        if self.Rotators and self.Rotators[1] and self.Rotators[1][2] and self.Rotators[1][2].Destroy then
            self.Rotators[1][2]:Destroy()
            self.Rotators[1][1]:SetGoal(self.Rotators[1][1]:GetCurrentAngle())
        end

        SSeaUnit.DeathThread(self)
    end,
}

TypeClass = SSS3324
