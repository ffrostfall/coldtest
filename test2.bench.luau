local bench = require("@coldtest/bench")

bench("2", function()
	for i = 1, 10000 do
		coroutine.create(function() end)
	end
end)
