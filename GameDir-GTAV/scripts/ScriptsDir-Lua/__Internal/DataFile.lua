local assert = assert
local type = type
local io_open = io.open

local Scripts_Path = Scripts_Path
local DataFilePath = Scripts_Path.."__DataFiles//"

local Read = function(File,InDataPath,InScriptsPath)
	local FileHandle = assert(type(File)=='string' and io_open((InDataPath~=false and DataFilePath..File) or (InScriptsPath~=false and Scripts_Path..File) or File, "rb"), "Invalid file path or name.")
	local FileData = FileHandle:read '*a'
	FileHandle:close()
	return FileData
end

local Write = function(File,Data,InDataPath,InScriptsPath)
	assert(type(Data)=='string', "Invalid file data.")
	local FileHandle = assert(type(File)=='string' and io_open((InDataPath~=false and DataFilePath..File) or (InScriptsPath~=false and Scripts_Path..File) or File, "wb"), "Invalid file path or name.")
	FileHandle:write(Data)
	FileHandle:close()
end

DataFile =
{
	Read = Read,
	read = Read,
	Write = Write,
	write = write
}