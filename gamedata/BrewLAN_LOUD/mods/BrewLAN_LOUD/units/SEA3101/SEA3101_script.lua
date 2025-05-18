local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local scoutRadius = __blueprints.sea3101.Intel.VisionRadius + __blueprints.ses3324.Intel.VisionRadius

SEA3101 = Class(TAirUnit) {

    OnCreate = function(self)
        TAirUnit.OnCreate(self)
    end,

    SetParent = function(self, parent)
        self.Parent = parent
        self.PatrolDir = self.Parent.PatrolDir or 1
        self:ForkThread(self.ScoutThread)
    end,

    StartPatrolCircle = function(self)

        local pPosX, pPosY, pPosZ = self.Parent:GetPositionXYZ()
        local heading = self.Parent:GetHeading()

        IssueMove({self}, {
            pPosX+(scoutRadius*math.sin(heading)),
            pPosY,
            pPosZ+(scoutRadius*math.cos(heading)),
        })

        for i=1, 12 do
            local offset = math.pi*2/12*i*self.PatrolDir
            IssuePatrol({self}, {
                pPosX+(scoutRadius*math.sin(heading+offset)),
                pPosY,
                pPosZ+(scoutRadius*math.cos(heading+offset)),
            })
        end

        self.PatrolDir = self.PatrolDir==1 and -1 or 1
        self.Parent.PatrolDir = self.PatrolDir
    end,

    ScoutThread = function(self)

        local fuel

        coroutine.yield(3)

        while self do

            coroutine.yield(17)

            fuel = self:GetFuelRatio()

            if fuel==1 and not self.IsOnPatrol and not self.Parent:GetScriptBit'RULEUTC_GenericToggle' then
                self.IsOnPatrol = true
                self:StartPatrolCircle()
            elseif fuel<0.25 and self.IsOnPatrol then
                self.IsOnPatrol = nil
                IssueClearCommands{self}
            end
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)

        if self.Parent and not self.Parent.Dead and self.Parent.NotifyOfPodDeath then
            self.Parent:NotifyOfPodDeath()
            self.Parent = nil
        end

        TAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    OnDestroy = function(self)

        if self.Parent and not self.Parent.Dead and self.Parent.NotifyOfPodDeath then
            self.Parent:NotifyOfPodDeath()
            self.Parent = nil
        end

        TAirUnit.OnDestroy(self)
    end,
}

TypeClass = SEA3101
