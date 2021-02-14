
function Invoke()
	local a, b = pcall( function()

		local units = GetSelectedUnits()
		if (units ~= nil) then

			local fu = units[1]
			LOG(fu)

			for k,v in fu do
				LOG(k,v)
			end

		end

	end )

	if not a then 
		WARN("UI PARTY RESULT: ", a, b)
	end
end

Invoke()

