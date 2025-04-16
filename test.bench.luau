local bench = require("@coldtest/bench")

print(coroutine.create)

bench("1", function()
	for i = 1, 1000 do
		coroutine.create(function() end)
	end
end)
