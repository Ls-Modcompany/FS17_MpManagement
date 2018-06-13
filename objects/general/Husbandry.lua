-- 
-- MpManager - Husbandry
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

Husbandry = {};
g_mpManager.husbandry = Husbandry;

function Husbandry:load()
	Husbandry.sortByFarm = {};
	
	g_mpManager.saveManager:addSave(Husbandry.saveSavegame, Husbandry);
	g_mpManager.loadManager:addLoad(Husbandry.loadSavegame, Husbandry);
end;

function Husbandry:loadDefault()	
	Husbandry.sortByFarm = {};
	for _, farm in pairs(g_mpManager.farm:getFarms()) do
		local farmname = farm:getName();
		Husbandry.sortByFarm[farmname] = {};
		for name, _ in pairs(g_currentMission.husbandries) do
			Husbandry.sortByFarm[farmname][name] = 0;
		end;		
	end;
end;

function Husbandry:checkAnimals()
	local needChange = false;
	for _, farm in pairs(g_mpManager.farm:getFarms()) do
		local farmname = farm:getName();
		for name, _ in pairs(g_currentMission.husbandries) do
			if Husbandry.sortByFarm[farmname][name] == nil then
				Husbandry.sortByFarm[farmname][name] = 0;
				needChange = true;
			end;
		end;	
	end;
	return needChange;
end;

function Husbandry:loadDefaultForFarm(farmname, noEventSend)	
	MpManagement_Husbandry_LoadDefaultForFarm.sendEvent(farmname, noEventSend);
	Husbandry.sortByFarm[farmname] = {};
	for name, _ in pairs(g_currentMission.husbandries) do
		Husbandry.sortByFarm[farmname][name] = 0;
	end;		
end;

function Husbandry:deleteDefaultForFarm(farmname, noEventSend)	
	MpManagement_Husbandry_DeleteDefaultForFarm.sendEvent(farmname, noEventSend);
	Husbandry.sortByFarm[farmname] = nil;	
end;

function Husbandry:getHusbandryByFarmName(farmname)
	return Husbandry.sortByFarm[farmname];
end;

function Husbandry:setNumber(farmname, name, value, noEventSend)
	MpManagement_Husbandry_SetNumber.sendEvent(farmname, name, value, noEventSend);
	local successfull = false;
	if Husbandry.sortByFarm[farmname] ~= nil and Husbandry.sortByFarm[farmname][name] ~= nil then
		Husbandry.sortByFarm[farmname][name] = value;
		successfull = true;
	end;
	return successfull;
end;

function Husbandry:saveSavegame() 
	local index = 0;
	for farmname,husbandries in pairs(Husbandry.sortByFarm) do
		g_mpManager.saveManager:setXmlString(string.format("husbandry.farm(%d)#name", index), farmname);		
		local index2 = 0;
		for name, value in pairs(husbandries) do
			g_mpManager.saveManager:setXmlInt(string.format("husbandry.farm(%d)#%s", index, name), value);
			index2 = index2 + 1;
		end;
		index = index + 1;
	end;
end;

function Husbandry:loadSavegame()
	Husbandry:loadDefault();
	local index = 0;
	while true do
		if not g_mpManager.loadManager:hasXmlProperty(string.format("husbandry.farm(%d)", index)) then
			break;
		end;		
		local farmname = g_mpManager.loadManager:getXmlString(string.format("husbandry.farm(%d)#name", index));
		for name, _ in pairs(g_currentMission.husbandries) do
			Husbandry.sortByFarm[farmname][name] = g_mpManager.loadManager:getXmlInt(string.format("husbandry.farm(%d)#%s", index,name));
		end;
		index = index + 1;
	end;
end;

function Husbandry:writeStream(streamId, connection)	
	streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(Husbandry.sortByFarm));
	for farmname,husbandries in pairs(Husbandry.sortByFarm) do
		streamWriteString(streamId, farmname);
		streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(husbandries));
		for name, value in pairs(husbandries) do
			streamWriteString(streamId, name);
			streamWriteInt32(streamId, value);
		end;
	end;
end;

function Husbandry:readStream(streamId, connection)
	local num = streamReadInt32(streamId);
	for i=1, num do
		local farmname = streamReadString(streamId);
		local num2 = streamReadInt32(streamId);
		for i=1, num2 do
			local name = streamReadString(streamId);
			local value = streamReadInt32(streamId);
			Husbandry:setNumber(farmname, name, value, true)
		end;
	end;
end;