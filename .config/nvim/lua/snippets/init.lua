--[[
Main snippets loader for LuaSnip
This file loads all custom snippets for different languages
--]]

local ls = require('luasnip')

-- Load Python snippets
ls.add_snippets('python', require('snippets.python'))

-- Load Verilog snippets (works for both .v and .sv files)
ls.add_snippets('verilog', require('snippets.verilog'))
ls.add_snippets('systemverilog', require('snippets.verilog'))

-- Load C/C++ snippets (we can extend this later)
-- ls.add_snippets('c', require('snippets.c'))
-- ls.add_snippets('cpp', require('snippets.cpp'))

return {}