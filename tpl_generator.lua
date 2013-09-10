-- Source code used to generate lice-tpl.lua
-- Caution, ugly code :)

local lfs = require 'lfs'
local PATH = 'src/templates/templates/'
local TPL_NAME_PATTERN = '^([a-z0-9%_]+[%-header]*)%.txt$'

-- Serializes a given table
local function serialize(t)
	local out, buf = 'return {%s}', ''
	for k,v in pairs(t) do
		buf = buf .. ('\n\t[\'%s\'] = \n[[%s]],\n')
      :format(k:gsub('%.txt$',''),v)
	end
	return out:format(buf)
end

local t = {}

-- Collect all templates
for file in lfs.dir(PATH) do
  if file~='.' and file ~= '..' then
    if file:match(TPL_NAME_PATTERN) then
      local f = assert(io.open(PATH..file, 'r'),
        'Error opening file '..file)
        local lic = f:read('*a')
        f:close()
        t[file] = lic
    end
 end
end

-- Write package
local out = assert(io.open('src/lice-tpl.lua', 'w+'),
				'Error writing lice-tpl.lua')
out:write(serialize(t))
out:close()