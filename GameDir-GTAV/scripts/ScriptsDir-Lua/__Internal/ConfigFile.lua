local assert = assert
local io_open = io.open
local io_lines = io.lines
local pairs = pairs
local tostring = tostring
local type = type

local Scripts_Path = Scripts_Path

function configFileRead(file,sep) -- Read simple config file
	file = Scripts_Path..file;sep = sep or "="
	local configFile = assert(io_open(file), "Invalid File Path");local config = {}
	if configFile then
		for line in io_lines(file) do
			if not (line:startsWith("[") and line:endsWith("]")) then
				line = line:gsub("\n","");line = line:gsub("\r","")
				if line ~= "" then
					line = line:split(sep)
					config[line[1]] = line[2]
				end
			end
		end
		configFile:close()
	end
	return config
end

function configFileWrite(configFile, config, sep) -- Write simple config file
	configFile, sep = assert(io_open(Scripts_Path..configFile, "w"), "Invalid File Path"), sep or "="
	for k,v in pairs(config) do
		configFile:write(("%s%s%s\n"):format(k, sep, tostring(v)))
	end
	configFile:close()
end

function configFileWriteLine(File, Line, Data)
	local FileLines, FileLinesCount, _File = {}, 0
	File = Scripts_Path..File
	
	_File = assert(io_open(File, "r"), "Invalid File Path")
	for line in _File:lines() do
		FileLinesCount = FileLinesCount + 1
		FileLines[FileLinesCount] = line
	end
	_File:close()
	
	FileLines[Line] = Data
	
	_File = assert(io_open(File, "w+"))
	for i=1, FileLinesCount do
		_File:write(FileLines[i]..(i ~= FileLinesCount and "\n" or "")) -- No newlines at end of config file (every write would increase the length)
	end
	_File:close()
end

configFileFindLineFromText = setmetatable
(
	{
		["nil"]     =   function(configFile, text --[[, occurence]])
							local RetVal, LineNum = 0, 0
							for line in configFile:lines() do
								LineNum = LineNum + 1
								if line:find(text) then
									RetVal = LineNum
								end
							end
							return RetVal
						end,
		["number"]  =   function(configFile, text, occurence)
							local RetVal, LineNum, OccurenceCurrent = 0, 0, 0
							for line in configFile:lines() do
								LineNum = LineNum + 1
								if line:find(text) then
									RetVal = LineNum
									OccurenceCurrent = OccurenceCurrent + 1;if OccurenceCurrent == occurence then break end
								end
							end
							return RetVal, OccurenceCurrent ~= occurence and OccurenceCurrent -- Second return is truthy "failed"; second return will be "false" if we found and returned the requested occurence, otherwise will be the occurence number.
						end,
		["boolean"] =   function(configFile, text --[[, occurence]])
							local RetVal, LineNum = {}, 0
							for line in configFile:lines() do
								local RetValFnd = line:find(text)
								LineNum = LineNum + 1
								RetVal[LineNum] = RetValFnd ~= nil and RetValFnd
							end
							return RetVal
						end,
	},
	{
		__index =   function(Self --[[, Key]])
						return Self["nil"]
					end,
		__call  =   function(Self, file, text, occurence)
						local configFile = assert(io_open(Scripts_Path.. file, "r"), "Invalid File Path")
						local line, failed = Self[type(occurence)](configFile, text, occurence)
						configFile:close()
						return line, failed
					end,
	}
)



ConfigFile =
{
	ReadSimple = configFileRead,
	WriteSimple = configFileWrite,
	WriteLine = configFileWriteLine,
	FindLineFromText = configFileFindLineFromText,
}
