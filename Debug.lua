-- 
-- Debug
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 
-- Level informations:
--	-1: 	Errors
-- 	 0: 	Warnings, Important Informations
--	 1: 	Short additionals Informations
--	 2: 	Modding Informations
-- 	 3: 	Load Informations
-- 

Debug = {};
getfenv(0)["g_debug"] = Debug;

Debug.writeModdingInformations = false;
Debug.header = "MpManager";

Debug.START = 0;
Debug.TEXT = 1;

Debug.numLevels = 20;
Debug.ERROR = -1;
Debug.WARNING = 0;
Debug.INFORMATIONS = 1;
Debug.LOAD = 2;

Debug.printLevel = {};
for i = -1, Debug.numLevels do
	Debug.printLevel[i] = false;
end;

--set default Level
Debug.printLevel[-2] = true;
Debug.printLevel[-1] = true;
Debug.printLevel[0] = true;

function Debug.setLevel(level, value)
	if level ~= -1 and level ~= 0 then
		Debug.printLevel[level] = value;
	end;
end;

function Debug.write(level, message, ...)
	if Debug.printLevel[level] then
		local prefix = "";
		if level == Debug.ERROR then
			prefix = "ERROR: ";
		elseif level == Debug.WARNING then
			prefix = "WARNING: ";
		elseif level == Debug.INFORMATIONS then
			prefix = "INFO: ";
		end;
		print("[LSMC - " .. Debug.header .. "] " .. prefix .. string.format(message,...));
	end;
end;

function Debug.writeBlock(level, block, message, ...)
	if Debug.printLevel[level] then
		if block == Debug.START then
			print("[LSMC - " .. Debug.header .. "] " .. string.format(message,...));
		elseif block == Debug.TEXT then
			print("	   " .. string.format(message,...));
		end;
	end;
end;