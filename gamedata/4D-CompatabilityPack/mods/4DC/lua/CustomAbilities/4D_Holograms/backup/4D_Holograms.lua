--**************************************************************************** 
--**  File          :  /lua/CustomAbilities/4D_Holograms/4D_Holograms.lua 
--** 
--**  Author        :  Resin_Smoker 
--** 
--**  Co-Author(s)  :  Brute51 
--** 
--**  Special Thanks:  BulletMagnet, Mooilo, Sorian
--** 
--**  Summary       :  HologramEmitter script:  Creates realistic hologram units 
--**                   UnitHolograms script: Unit class used to create hologram units 
--** 
--**  Copyright � 2010 4DC  All rights reserved.
--**************************************************************************** 
--** 
--**  The following is required in the units script for Hologram Emitter 
--**  This calls into action the hologram scripts for TConstructionUnit 
--** 
--**  TConstructionUnit = import('/mods/4DC/lua/CustomAbilities/4D_Holograms/4D_Holograms.lua').HologramEmitter( TConstructionUnit ) 
--** 
--**************************************************************************** 
--** 
--**  The following is required in the unit blueprints for Advanced Jamming 
--**  This sets the parimeters of each jamming unit. 
--** 
--**  UNIT BP: 
--** 
--**    Intel = { 
--**        Holograms = { 
--**            DisabledInTransport = true,
--**            MaxDistance = 32,
--**            NumT1Engineer = 1,
--**            NumT2Engineer = 0,            
--**            NumT1Ground = 0,
--**            NumT2Ground = 0,                      
--**            StartEnabled = true,
--**        }, 
--**    }, 
--** 
--**    ToggleCaps = { 
--**        # abusing the intel toggle here, so we can use the onintelenabled events 
--**        RULEUTC_IntelToggle = true,
--**        # provide for intel toggle so the player can toggle off the view of their own holograms
--**        RULEUTC_SpecialToggle = true, 
--**    }, 
--** 
--**    OrderOverrides = { 
--**        # faking the jamming icon 
--**        RULEUTC_IntelToggle = { 
--**            bitmapId = 'advanced jamming', 
--**            helpText = 'toggle_jamming', 
--**        },
--**        RULEUTC_SpecialToggle = { 
--**            bitmapId = 'intel-counter',       
--**            helpText = 'View Holograms',
--**        },   
--**    }, 
--** 
--**************************************************************************** 
--** 
--**    This script snippet is required to be within the /lua/sim/Units.lua. This is borrowed from the CBFP. It 
--**    adds a unit event that's fired when the unit is picked up by a transport or when it's dropped from one. 
--** 
--**    OnTransportAttach = function(self, attachBone, unit) 
--**        oldUnit.OnTransportAttach(self, attachBone, unit) 
--**        unit:OnAttachedToTransport(self) 
--**    end, 
--** 
--**    OnAttachedToTransport = function(self, transport) 
--**    end, 
--** 
--**    OnTransportDetach = function(self, attachBone, unit) 
--**        oldUnit.OnTransportDetach(self, attachBone, unit) 
--**        unit:OnDetachedToTransport(self) 
--**    end, 
--** 
--**    OnDetachedToTransport = function(self, transport) 
--**    end,    
--** 
--**************************************************************************** 

-- Start of HologramEmitter(SuperClass)
function HologramEmitter(SuperClass) 
    return Class(SuperClass) {
    
    OnCreate = function(self,builder,layer)
        ### Sets up table to track the holograms 
        if not self.HologramTable then
            self.HologramTable = {}
        end 
        ### Initializes global variable for the jammers unit motion state         
        if not self.SpeedState then
           self.SpeedState = nil
           self.OldState = nil 
        end                                
        SuperClass.OnCreate(self,builder,layer)
    end,

    OnStopBeingBuilt = function(self,builder,layer)               
        ### Initializes global variable for the View of Holograms         
        if not self.ViewHolograms then
            self.ViewHolograms = true 
        end       
        ### Set the hologram visuals off as default        
        self:SetScriptBit('RULEUTC_SpecialToggle', true)         
        self:RequestRefreshUI()  
        
        ### Ensures the jammer comes on if specified within the units BP
        if self:GetBlueprint().Intel.Holograms.StartEnabled == true then
            if self.JammingActive == false or table.getn(self.HologramTable) <= 0 then
                self:SetJammingStatus(true)
            end
        end   
        self.Sync.Abilities = self:GetBlueprint().Abilities                 
        SuperClass.OnStopBeingBuilt(self,builder,layer)     
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self:GetJammingStatus() then 
            self:SetJammingStatus(false)
        end
        SuperClass.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnIntelEnabled = function(self)
        SuperClass.OnIntelEnabled(self)
        if not self:GetJammingStatus() then 
            self:SetJammingStatus(true)
        end
    end,

    OnIntelDisabled = function(self)   
        SuperClass.OnIntelDisabled(self)
        if self:GetJammingStatus() then      
            self:SetJammingStatus(false)
        end
    end,

    OnAttachedToTransport = function(self, transport) # new event, borrowed from CBFP v3 (and up)
        SuperClass.OnAttachedToTransport(self, transport)
        self.PrevJammingStatus = self:GetJammingStatus()
        if self:GetBlueprint().Intel.Holograms.DisabledInTransport then
            self:SetJammingStatus(false)
        end
    end,

    OnDetachedToTransport = function(self, transport) # new event, borrowed from CBFP v3 (and up)
        SuperClass.OnDetachedToTransport(self, transport)
        self:SetJammingStatus(self.PrevJammingStatus)
    end,
    
    GetJammingStatus = function(self)
        return self.JammingActive
    end,  
    
    OnScriptBitSet = function(self, bit)
        ### UI Toggle that turns Hologram visuals off
        if bit == 7 then
           self.ViewHolograms = false 
            if table.getn(self.HologramTable) > 0 then
                for k, v in self.HologramTable do           
                    v:SetVizToAllies('Never') 
                    v:SetVizToFocusPlayer('Never') 
                    v:SetVizToNeutrals('Never') 
                end
            end                              
        end
        SuperClass.OnScriptBitSet(self, bit)
    end,     
     
    OnScriptBitClear = function(self, bit)
       ### UI Toggle that turns Hologram visuals on    
       if bit == 7 then   
           self.ViewHolograms = true
            if table.getn(self.HologramTable) > 0 then
                for k, v in self.HologramTable do           
                    v:SetVizToAllies('Intel') 
                    v:SetVizToFocusPlayer('Intel') 
                    v:SetVizToNeutrals('Intel') 
                end
            end           
       end
       SuperClass.OnScriptBitClear(self, bit)
    end,      

    SetJammingStatus = function(self, enabled)
        self.JammingActive = enabled
        if enabled then
            ### Add holograms and economy on jammer enable      
            self:SetMaintenanceConsumptionActive()           
            self:CreateHolograms()
        else
            ### Remove holograms and economy on jammer disable      
            self:SetMaintenanceConsumptionInactive()
            if table.getn(self.HologramTable) > 0 then
                for k, v in self.HologramTable do
                    if v:GetParent() == self then
                       v:Destroy()
                    end
                end
            end 
            ### Reset hologram table
            self.HologramTable = {}
        end
    end,
 
    ### Add hologram BPs here
    HologramBPs = {
        ### Engineer Holograms
        engineerT1 = {
             'hologram_t1_engineer',
        },
        engineerT2 = {
             'hologram_t2_engineer',
        },        
        ### Ground holograms
        groundT1 = {
            'hologram_t1_antiair','hologram_t1_artillery','hologram_t1_bot','hologram_t1_scout','hologram_t1_tank',
        },
        groundT2 = {
            'hologram_t2_flak','hologram_t2_gatbot','hologram_t2_hovertank','hologram_t2_launcher','hologram_t2_tank',
        },               
    },      
    
    CreateHolograms = function(self)
        ### Local variables needed    
        local spawnHologram
        local basePos = self:GetPosition()
        local bp = self:GetBlueprint().Intel.Holograms
        local dist = bp.MaxDistance * 0.75 or 20
        local NumT1Engineer = bp.NumT1Engineer or 0
        local NumT2Engineer = bp.NumT2Engineer or 0        
        local NumT1Ground = bp.NumT1Ground or 0
        local NumT2Ground = bp.NumT2Ground or 0             
        local NumTotalHolograms = NumT1Engineer + NumT2Engineer +  NumT1Ground + NumT2Ground
                             
        ### This function determines what hologram should be created, creates it and then returns that unit
        local function CreateBlipUnit(HologramNum)
            local HologramBP
        ### T1 Engineer 
            if HologramNum <= NumT1Engineer then
                HologramBP = self.HologramBPs['engineerT1'][ Random( 1, table.getn( self.HologramBPs['engineerT1'] )) ]
        ### T2 Engineer
            elseif HologramNum <= (NumT1Engineer + NumT2Engineer) then
                HologramBP = self.HologramBPs['engineerT2'][ Random( 1, table.getn( self.HologramBPs['engineerT2'] )) ]  
        ### T1 ground              
            elseif HologramNum <= (NumT1Engineer + NumT2Engineer + NumT1Ground) then
                HologramBP = self.HologramBPs['groundT1'][ Random( 1, table.getn( self.HologramBPs['groundT1'] )) ]
        ### T2 ground
            elseif HologramNum <= (NumT1Engineer + NumT2Engineer + NumT1Ground + NumT2Ground) then
                HologramBP = self.HologramBPs['groundT2'][ Random( 1, table.getn( self.HologramBPs['groundT2'] )) ]                              
            else
                return nil
            end
            return CreateUnitHPR(HologramBP, self:GetArmy(), basePos[1]+Random(-dist, dist), basePos[2], basePos[3]+ Random(-dist, dist), 0, 0, 0)
        end
        
        ### Creates the holigrams 
        for i = 1, NumTotalHolograms do 
            ### Spawns the replacement Hologram and sets the jamming unit as its parent
            spawnHologram = CreateBlipUnit(i) 
            spawnHologram:SetCreator(self) 
            spawnHologram:SetParent(self) 
            
            ### Sets the visability options for the holograms dependant on the players toggle state
            ### Avalible options: 'Never','Intel','Always' 
                                                   
            if self.ViewHolograms == true then     
                spawnHologram:SetVizToAllies('Intel') 
                spawnHologram:SetVizToFocusPlayer('Intel') 
                spawnHologram:SetVizToNeutrals('Intel') 
            else
                spawnHologram:SetVizToAllies('Never') 
                spawnHologram:SetVizToFocusPlayer('Never') 
                spawnHologram:SetVizToNeutrals('Never')                 
            end
            spawnHologram:SetVizToEnemies('Intel') 
            
            ### Add the new Hologram to a table so we can manipulate it later on                                
            table.insert(self.HologramTable, spawnHologram)                      
            spawnHologram:SetUpPatrol() 
            self.Trash:Add(spawnHologram) 
        end          
    end,
    
    ReplaceHologram = function(self, hologram)
        if not self:IsDead() then
            local spawnHologram
            local bp = self:GetBlueprint().Intel.Holograms
            local basePos = self:GetPosition()
            local dist = bp.MaxDistance * 0.75 or 20
            ### Spawns the replacement Hologram and sets the jamming unit as its parent
            spawnHologram = CreateUnitHPR(hologram, self:GetArmy(), basePos[1]+Random(-dist, dist), basePos[2], basePos[3]+ Random(-dist, dist), 0, 0, 0)     
            spawnHologram:SetCreator(self)
            spawnHologram:SetParent(self) 
            
            ### Sets the visability options for the holograms dependant on the players toggle state
            ### Avalible options: 'Never','Intel','Always'            
            if self.ViewHolograms == true then          
                spawnHologram:SetVizToAllies('Intel') 
                spawnHologram:SetVizToFocusPlayer('Intel') 
                spawnHologram:SetVizToNeutrals('Intel') 
            else
                spawnHologram:SetVizToAllies('Never') 
                spawnHologram:SetVizToFocusPlayer('Never') 
                spawnHologram:SetVizToNeutrals('Never')                 
            end
            spawnHologram:SetVizToEnemies('Intel') 
            
            ### Add the new Hologram to a table so we can manipulate it later on                                  
            table.insert(self.HologramTable, spawnHologram)
            spawnHologram:SetUpPatrol()
            self.Trash:Add(spawnHologram)            
        end           
    end,
    
   OnMotionHorzEventChange = function(self,new,old)
       ### Updates the jammers movement state for later use by the holograms KeepCloseToParentThread
       if not self:IsDead() then
           self.SpeedState = new
       end
       SuperClass.OnMotionHorzEventChange(self,new,old)
   end,       
}
end 
-- End of HologramEmitter(SuperClass) ###

-- Start of UnitHolograms(SuperClass) ### 
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat 
function UnitHolograms(SuperClass) 
    return Class(SuperClass) { 

    OnCreate = function(self,builder,layer) 
        ### Disables weapons and selectability 
        self:SetAllWeaponsEnabled(false) 
        self:SetUnSelectable(true)
        SuperClass.OnCreate(self,builder,layer) 
    end, 

    SetParent = function(self, parent) 
        self.Parent = parent 
    end, 

    GetParent = function(self) 
        return self.Parent or nil 
    end, 

    SetUpPatrol = function(self) 
        self.ParentBP = self.Parent:GetBlueprint().Intel.Holograms 
        self.PrtMaxDist = self.ParentBP.MaxDistance 
        
        ### Notes the parents speed values for later comparison          
        if EntityCategoryContains(categories.AIR, self.Parent) then 
            self.ParentSpeed = self.Parent:GetBlueprint().Air.MaxAirspeed 
        else  
            self.ParentSpeed = self.Parent:GetBlueprint().Physics.MaxSpeed 
        end        
        
        ### Notes the holograms speed values for later comparison 
        if EntityCategoryContains(categories.AIR, self) then 
            self.MyMaxSpeed = self:GetBlueprint().Air.MaxAirspeed 
        else  
            self.MyMaxSpeed = self:GetBlueprint().Physics.MaxSpeed 
        end 
                
        ### Choose the right speed multi for the units involved            
        if self.ParentSpeed > self.MyMaxSpeed then 
            self.SpeedMulti = self.ParentSpeed / self.MyMaxSpeed
        else 
            self.SpeedMulti = 1 
        end 
              
        ### Multi-purpuse booleans, used to prevent issuing same orders twice                                              
        self.Patrol = false 
        
        ### Start first patrol sequence 
        self:IssueRandomPatrol()    
        
        ### Periodically issues random patrol to holigrams   
        self:ForkThread(self.KeepPatrolingThread)                                                      
        
        ### periodically checks distance to parent    
        self:ForkThread(self.KeepCloseToParentThread) 
    end, 
    
    KeepPatrolingThread = function(self)                              
        while not self:IsDead() and not self.Parent:IsDead() do        
            if self.Parent.SpeedState != 'TopSpeed' then
                ### Start a new patrol
                self:IssueRandomPatrol()
            end
            
            ### Random delay before checking again          
            WaitSeconds(Random(15 , 60)) 
        end
    end,    
 
    KeepCloseToParentThread = function(self)                                                                  
        while not self:IsDead() and not self.Parent:IsDead() do 
            ### Calculate the offset factor to ensure hologram can travel in parallel formation with jammer 
            local myX, myY, myZ = unpack(self:GetPosition())              
            local prtX, prtY, prtZ = unpack(self.Parent:GetPosition())        
            local dist = VDist2(myX, myZ, prtX, prtZ)            
            local offSet = myX - prtX    

            if dist >= (self.PrtMaxDist * 1.25) then 
                self.Patrol = false    
                local warpPos = self.Parent:CalculateWorldPositionFromRelative({offSet, 0, Random(self.ParentBP.MaxDistance * 0.3, self.ParentBP.MaxDistance * 0.6)})            
                Warp(self, warpPos) 
                if self.Parent.SpeedState == 'TopSpeed' and not EntityCategoryContains(categories.AIR, self) then 
                    IssueClearCommands({self}) 
                    local parentPos = self.Parent:CalculateWorldPositionFromRelative({offSet, 0, Random(self.ParentBP.MaxDistance * 0.5, self.ParentBP.MaxDistance)}) 
                    IssueMove({self}, parentPos) 
                    self:SetHologramSpeed(dist)            
                else                            
                    self:IssueRandomPatrol() 
                end                                                                              
            elseif dist < self.PrtMaxDist and self.Parent.SpeedState == 'TopSpeed' and not EntityCategoryContains(categories.AIR, self) then          
                ### Unit too far from parent and parent is hauling arse                                                        
                IssueClearCommands({self})                
                local parentPos = self.Parent:CalculateWorldPositionFromRelative({offSet, 0, Random(self.ParentBP.MaxDistance * 0.5, self.ParentBP.MaxDistance)}) 
                IssueMove({self}, parentPos) 
                self:SetHologramSpeed(dist) 
                self.Patrol = false                                                  
            elseif dist < self.ParentBP.MaxDistance and self.Parent.SpeedState != 'TopSpeed' and self.Parent.OldState == self.Parent.SpeedState then 
                ### when unit comes back in range issue a new patrol                
                if self.Patrol == false then                            
                    self:IssueRandomPatrol()        
                end                
            end 
            
            ### Remember the past movement state
            if not self:IsDead() and self.Parent.SpeedState then
                self.Parent.OldState = self.Parent.SpeedState
            end                    
            
            ### Time between checks in seconds             
            WaitSeconds(Random(3 , 5))           
        end 
    end,
         
    IssueRandomPatrol = function(self) 
        ### Randomly determines hologram patrol 
        if not self:IsDead() and not self.Parent:IsDead() then                
            IssueClearCommands({self}) 
            if EntityCategoryContains(categories.AIR, self) then 
                IssueGuard({self}, self.Parent) 
            else            
                local basePos = self.Parent:GetPosition()              
                local numPatrols = Random(4, 8)          
                for k=1,numPatrols do 
                    local ranNum = RandomFloat(0.5, 0.75) 
                    local dist = self.PrtMaxDist * ranNum            
                    IssuePatrol({self}, Vector( (basePos[1]+Random(-dist, dist)), basePos[2], (basePos[3]+Random(-dist, dist)) ) ) 
                end 
            end 
            self:SetHologramSpeed() 
            self.Patrol = true 
        end 
    end, 
    
    SetHologramSpeed = function(self, distance) 
        if not self:IsDead() and not self.Parent:IsDead() then 
            if EntityCategoryContains(categories.AIR, self) then
                self:SetSpeedMult(1.0) 
                self:SetAccMult(1.0) 
                self:SetTurnMult(1.0)
            else 
                if self.Parent.SpeedState == 'TopSpeed' and distance >= (self.PrtMaxDist * 0.75) then 
                    self:SetSpeedMult(self.SpeedMulti * 2 ) 
                    self:SetAccMult(1.5) 
                    self:SetTurnMult(1.5)  
                elseif self.Parent.SpeedState == 'TopSpeed' then 
                    self:SetSpeedMult(self.SpeedMulti * 1.5) 
                    self:SetAccMult(1.25) 
                    self:SetTurnMult(1.25)                           
                else 
                    self:SetSpeedMult(self.SpeedMulti) 
                    self:SetAccMult(1.0) 
                    self:SetTurnMult(1.0)                        
                end 
            end 
        end   
    end,
     
    OnDamage = function(self, instigator, amount, vector, damagetype) 
        self:Destroy() 
    end, 

    OnCollisionCheck = function(self, other, firingWeapon) 
        if not self.Parent:IsDead() then 
            self:Destroy()      
        end 
    end,          
    
    OnDestroy = function(self, instigator, type, overkillRatio)
        ### Clears the current hologram commands if any
        IssueClearCommands(self)       
        ### Clears the offending hologram from the parents table
        if not self.Parent:IsDead() and self.Parent:GetJammingStatus() then
            table.removeByValue(self.Parent.HologramTable, self)
            local hologram = self:GetUnitId() 
            self.Parent:ReplaceHologram(hologram)
            self.Parent = nil
        end
    end,                  
                     
}
end 
-- End of UnitHolograms(SuperClass)