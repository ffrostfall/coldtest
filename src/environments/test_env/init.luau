type Case = {
	name: string,
	f: () -> (),
}

type Test = {
	name: string,
	cases: { Case },
}

type TestApi = {
	TEST: (name: string) -> (),
	ENDTEST: () -> (),

	CASE: (name: string, body: () -> ()) -> (),
	CHECK: (value: unknown) -> (),
}

local test_env = {}
local metatable = { __index = test_env }
type Identity = setmetatable<{
	api: TestApi,

	_finalized_tests: { Test },
	_current_test: Test?,
}, typeof(metatable)>

local function constructor(): Identity
	local self = setmetatable({
		api = {},

		_finalized_tests = {},
	}, metatable)

	function self.api.TEST(name: string)
		self._current_test = {
			name = name,

			cases = {},
		} :: any
	end

	function self.api.ENDTEST()
		local current_test = self._current_test
		self._current_test = nil

		table.insert(self._finalized_tests, current_test)
	end

	function self.api.CASE(name: string, body: () -> ())
		(table.insert :: any)(self._current_test.cases, {
			name = name,
			f = body,
		})
	end

	function self.api.CHECK(val: boolean)
		if val then
			coroutine.yield(true)
		end

		local trace = debug.traceback()

		coroutine.yield(false, trace)
	end

	return self
end

function test_env.create_globals(self: Identity)
	local function require_f(str: string)
		if str == "@coldtest/test" then
			return self.api
		end

		return (require)(str)
	end

	return {
		require = require_f,
	}
end

function test_env.run_tests(self: Identity)
	for _, test in self._finalized_tests do
		print(`running test: {test.name}`)

		for _, case in test.cases do
			print(`\tcase: {case.name}`)
			local t = coroutine.create(case.f)
			local success, result, traceback = coroutine.resume(t)
			if not success then
				print("\t\ttest failed")
			else
				if not result then
					print("\t\ttest failed")
					print(traceback)
				else
					print("\t\tpassed")
				end
			end
		end
	end
end

function test_env.add_case(self: Identity, section: string, case: {}) end

return { new = constructor }
