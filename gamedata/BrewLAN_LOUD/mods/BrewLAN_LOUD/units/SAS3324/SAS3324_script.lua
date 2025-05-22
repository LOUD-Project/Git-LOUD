local ASeaUnit                  = import('/lua/defaultunits.lua').SeaUnit

local FxAmbient = import('/lua/effecttemplates.lua').AResourceGenAmbient

local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing

ASeaUnit = RemoteViewing( ASeaUnit )

local WeaponsFile               = import('/lua/aeonweapons.lua')

local AAMWillOWisp              = WeaponsFile.AAMWillOWisp

local ADFAlchemistPhasonLaser   = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/weapons.lua').ADFAlchemistPhasonLaser

local ADepthCharge              = WeaponsFile.AANDepthChargeBombWeapon
local AANChronoTorpedoWeapon    = WeaponsFile.AANChronoTorpedoWeapon
local AntiTorpedoWeapon         = WeaponsFile.AIFQuasarAntiTorpedoWeapon

local WeaponsFile = nil

local RadarRestricted = type(ScenarioInfo.Options.RestrictedCategories) == 'table' and table.find(ScenarioInfo.Options.RestrictedCategories, 'INTEL')


SAS3324 = Class(ASeaUnit) {

    Weapons = {
        AAGun       = Class(ADFAlchemistPhasonLaser) {},
        AntiMissile = Class(AAMWillOWisp) {},
        Torpedo     = Class(AANChronoTorpedoWeapon) {},
        AntiTorpedo = Class(AntiTorpedoWeapon) {},
        DepthCharge = Class(ADepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                ADepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( ADepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(6)
                
                    ADepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( ADepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(15) self:ChangeMinRadius(15) WaitTicks(44) self:ChangeMinRadius(0) self:ChangeMaxRadius(12) end)
                    
                    ADepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
    },

    RadarThread = function(self)

        local dish      = CreateRotator(self, 'Dish', 'y', 0, 5)
        local antennae  = CreateRotator(self, 'Antennae', 'z', nil, 0, 45, 0)

        while not self.Dead do

            if self:IsIntelEnabled('Omni') then
                dish:SetGoal(Random(-80, 80))
                antennae:SetSpinDown(false):SetTargetSpeed((-1 + 2 * math.random(0,1) ) * 30)
            else
                antennae:SetSpinDown(true)
                coroutine.yield(31)
            end

            WaitFor(dish)
            coroutine.yield(Random(30, 60))
        end
    end,

    OnStopBeingBuilt = function(self,builder,layer)

        ASeaUnit.OnStopBeingBuilt(self,builder,layer)
        
        -- AA weapon emitter
        self.Trash:Add( CreateAttachedEmitter( self, 'Ring', self:GetArmy(), FxAmbient[1] ):ScaleEmitter(.25) )

        self.rotators = {}

        for _, bone in {'Cage', 'Longitude', 'Sphere'} do

            for _, ori in {'x','y','z'} do

                if (ori == 'x' or ori =='y') and (bone == 'Cage' or bone == 'Longitude') then
                    table.insert(self.rotators, CreateRotator(self, bone, ori, math.random(-30, 30) ) )
                else
                    local mult = 45
                    if bone == 'Rule' then mult = 25 elseif bone == 'Sphere' then mult = 35 end
                    table.insert(self.rotators, CreateRotator(self, bone, ori, nil, 0, 45, (-1 + 2 * math.random(0,1) ) * mult) )
                end
            end
        end

        self:SetMaintenanceConsumptionInactive()

        self:SetScriptBit('RULEUTC_IntelToggle', true)

        if RadarRestricted then
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        else
            self:ForkThread(self.RadarThread)
        end

        self:RequestRefreshUI()
    end,

}

TypeClass = SAS3324
