-- 
-- MpManager - Assignables
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

Assignables = {};
g_mpManager.assignabels = Assignables;

Assignables.notAssign = "notAssign";

local counter = 0;
function Assignables:getNextNumber() counter = counter + 1; return counter; end;

Assignables.BGA = Assignables:getNextNumber();
Assignables.PLACEABLE = Assignables:getNextNumber();
Assignables.MILKSELL = Assignables:getNextNumber();
Assignables.STORAGE = Assignables:getNextNumber();

function Assignables:load()
	if not Assignables.loaded then	
		
		Assignables.assignabels = {};
		Assignables.assignabelsById = {};
		Assignables.loaded = true;
		
		Assignables:milkSell();
		
		g_mpManager.saveManager:addSave(Assignables.saveSavegame, Assignables);
		g_mpManager.loadManager:addLoad(Assignables.loadSavegame, Assignables);
	end;
end;

function Assignables:addAssignables(id, name, s)
	if Assignables.assignabels == nil then
		Assignables:load();
	end;
	if Assignables.assignabelsById[id] == nil then
		Assignables.assignabelsById[id] = {};
	end;
	table.insert(Assignables.assignabelsById[id], {name=name, object=s});
	table.insert(Assignables.assignabels, {name=name, object=s});	
end;

function Assignables:setAssignables(index, newFarm, noEventSend)
	MpManagement_Assignables_SetAssignables.sendEvent(index, newFarm, noEventSend)
	if Assignables:getAllAsignables()[index] ~= nil then
		Assignables:getAllAsignables()[index].object.mpManagerFarm = newFarm;
	end;
end;

function Assignables:getAllAsignables()
	return Assignables.assignabels;	
end;

function Assignables:milkSell()
	Assignables.assignabels_milkSell = {mpManagerFarm=Assignables.notAssign};		
	Assignables:addAssignables(Assignables.MILKSELL, g_i18n:getText("Assignables_milkSell"), Assignables.assignabels_milkSell);
end;


function Assignables:saveSavegame() 
	g_mpManager.saveManager:setXmlString(string.format("assignabels.milkSell#mpManagerFarm"), Assignables.assignabels_milkSell.mpManagerFarm);
end;

function Assignables:loadSavegame()
	local f = g_mpManager.loadManager:getXmlString(string.format("assignabels.milkSell#mpManagerFarm"));
	if f ~= nil then
		Assignables.assignabels_milkSell.mpManagerFarm = f;
	end;
end;

function Assignables:writeStream(streamId, connection)	
	streamWriteString(streamId, Utils.getNoNil(Assignables.assignabels_milkSell.mpManagerFarm, ""));
	streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(Assignables:getAllAsignables()));
	for index, d in pairs(Assignables:getAllAsignables()) do
		streamWriteInt32(streamId, index);
		streamWriteString(streamId, Utils.getNoNil(d.object.mpManagerFarm, Assignables.notAssign));
	end;
end;

function Assignables:readStream(streamId, connection)
	Assignables.assignabels_milkSell.mpManagerFarm = streamReadString(streamId);
	local num = streamReadInt32(streamId);
	for i=1, num do
		local index = streamReadInt32(streamId);
		local mpManagerFarm = streamReadString(streamId);
		Assignables:setAssignables(index, mpManagerFarm, true);
	end;
end;