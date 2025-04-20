local COLDTEST_API = require("@coldtest/test")
local TEST, CASE, CHECK, ENDTEST = COLDTEST_API.TEST, COLDTEST_API.CASE, COLDTEST_API.CHECK, COLDTEST_API.ENDTEST

TEST("THING")

CASE("1 == 1", function()
	CHECK(1 == 1)
	CHECK(2 == 2)
end)

CASE("1 == 2", function()
	CHECK(1 == 2)
end)

ENDTEST()
