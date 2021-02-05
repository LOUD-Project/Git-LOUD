function StopAllExceptCurrentProduction()

	local units = GetSelectedUnits()

	for k,v in units do
		local queue = SetCurrentFactoryForQueueDisplay(v)
		clearQueue(v, queue)
	end

end

function clearQueue(unit, queue)
	-- Stolen from hotbuild
	if (queue) then
		for index = table.getn(queue), 1, -1  do
			local count = queue[index].count
			if index == 1 and unit:GetWorkProgress() > 0 then
				count = count - 1
			end
			DecreaseBuildCountInQueue(index, count)
		end
	end
end

function UndoLastQueueOrder()

	local units = GetSelectedUnits()
	if (units ~= nil) then
		local u = units[1]
		local queue = SetCurrentFactoryForQueueDisplay(u);
		if queue ~= nil then
			local lastIndex = table.getn(queue)
			local count = 1
			if IsKeyDown('Shift') then
				count = 5
			end
			DecreaseBuildCountInQueue(lastIndex, count)
		end
	end

end
