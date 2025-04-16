export type BenchItem = {
	averaged_ms: number,
	call_count: number,
}

export type BenchResult = {
	interpreted: BenchItem?,
	codegen: BenchItem?,
}

local bench_env = {}
local metatable = { __index = bench_env }
export type Identity = typeof(setmetatable(
	{} :: {
		benches: {
			[string]: BenchResult,
		},

		create_bench_func: (codegen: boolean) -> (name: string, f: () -> ()) -> (),
	},
	metatable
))

local function constructor(): Identity
	local self = setmetatable({
		benches = {},
	}, metatable)

	function self.create_bench_func(codegen: boolean)
		local function bench_func(bench_name: string, f: () -> ())
			local times: { number } = {}
			local cpu_total = 0

			while true do
				local start = os.clock()

				f()

				local stop = os.clock()

				table.insert(times, stop - start)
				cpu_total += stop - start

				if cpu_total > 0.5 then
					break
				end
			end

			local total = 0
			for _, time in times do
				total += time
			end

			if not self.benches[bench_name] then
				self.benches[bench_name] = {} :: any
			end

			local res = {
				averaged_ms = total / #times * 1000,
				call_count = #times,
			}

			if codegen then
				self.benches[bench_name].codegen = res :: any
			else
				self.benches[bench_name].interpreted = res :: any
			end
		end

		return bench_func
	end

	return self
end

function bench_env.create_globals(self: Identity, codegen_enabled: boolean)
	local function require_f(str: string)
		if str == "@coldtest/bench" then
			return self.create_bench_func(codegen_enabled)
		end

		return (require)(str)
	end

	return {
		require = require_f,
	}
end

function bench_env.results(self: Identity)
	print(self.benches)
end

return {
	new = constructor,
}
