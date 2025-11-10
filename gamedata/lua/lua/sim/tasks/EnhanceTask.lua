-- File: lua/modules/EnhanceTask.lua

local ScriptTask    = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS    = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT      = import('/lua/sim/ScriptTask.lua').AIRESULT

local GetBuildRate          = moho.unit_methods.GetBuildRate
local GetResourceConsumed   = moho.unit_methods.GetResourceConsumed

EnhanceTask = Class(ScriptTask) {

    OnCreate = function(self,commandData)

        ScriptTask.OnCreate(self,commandData)

        self:GetUnit():SetWorkProgress(0.0)

        self:GetUnit():SetUnitState('Enhancing',true)
        self:GetUnit():SetUnitState('Upgrading',true)

        self.LastProgress = 0
        ChangeState(self, self.Stopping)
    end,
    
    OnDestroy = function(self)

        self:GetUnit():SetUnitState('Enhancing',false)
        self:GetUnit():SetUnitState('Upgrading',false)
        self:GetUnit():SetWorkProgress(0.0)

        if self.Success then
            self:SetAIResult(AIRESULT.Success)
            self.Success = nil
        else
            self:SetAIResult(AIRESULT.Fail)
            self:GetUnit():OnWorkFail(self.CommandData.Enhancement)
        end
    end,
    
    Stopping = State {

        TaskTick = function(self)

            local unit = self:GetUnit()

            if unit:IsMobile() and unit:IsMoving() then

                unit:GetNavigator():AbortMove()

                return TASKSTATUS.Wait

            else

                local result = unit:OnWorkBegin(self.CommandData.Enhancement)
             
                if result == false then
                
                    --LOG("*AI DEBUG OnWorkBegin result is "..repr(result) )
                    
                    self:OnDestroy()

                    return TASKSTATUS.Done
                    
                else
                
                    ChangeState(self, self.Enhancing)
                    return TASKSTATUS.Repeat
                end
                
            end

        end,
    },
    
    Enhancing = State {

        TaskTick = function(self)

            local unit = self:GetUnit()

            if unit:IsPaused() then
                return TASKSTATUS.Wait
            end
            
            local current = unit.WorkProgress or 0
            
            local obtained = GetResourceConsumed(unit)
			
            if obtained > 0 and unit.WorkItemBuildTime then

                current = current + ( 1 / ( unit.WorkItemBuildTime / GetBuildRate(unit)) ) * obtained * SecondsPerTick()

                unit.WorkProgress = current
            end
            
            -- if( ( self.LastProgress < 0.25 and current >= 0.25 ) or
                -- ( self.LastProgress < 0.50 and current >= 0.50 ) or
                -- ( self.LastProgress < 0.75 and current >= 0.75 ) ) then
                -- unit:OnBuildProgress(self.LastProgress,current)
            -- end
            
            self.LastProgress = current
            unit:SetWorkProgress(current)
            
            if( current < 1.0 ) then
                
                if current < 0.5 then
                  return TASKSTATUS.Wait + 1
                else
                    return TASKSTATUS.Wait
                end
            end
            
            unit:OnWorkEnd(self.CommandData.Enhancement)
            self.Success = true

            return TASKSTATUS.Done            
        end,
    },
}