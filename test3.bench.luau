local bench = require("@coldtest/bench")

bench("3", function()
	for i = 1, 100000 do
		local _ = math.random() + math.random()
	end
end)
