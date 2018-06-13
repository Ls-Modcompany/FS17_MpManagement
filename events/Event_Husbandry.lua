-- 
-- MpManager - Event - Husbandry
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - Husbandry - Load default for farm
MpManagement_Husbandry_LoadDefaultForFarm = {};
MpManagement_Husbandry_LoadDefaultForFarm_mt = Class(MpManagement_Husbandry_LoadDefaultForFarm, Event);
InitEventClass(MpManagement_Husbandry_LoadDefaultForFarm, "MpManagement_Husbandry_LoadDefaultForFarm");
function MpManagement_Husbandry_LoadDefaultForFarm:emptyNew()
	return Event:new(MpManagement_Husbandry_LoadDefaultForFarm_mt);
end;
function MpManagement_Husbandry_LoadDefaultForFarm:new(farmname)
	local self = MpManagement_Husbandry_LoadDefaultForFarm:emptyNew();
	self.farmname = farmname;
	return self;
end;
function MpManagement_Husbandry_LoadDefaultForFarm:readStream(streamId, connection)
	self.farmname = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Husbandry_LoadDefaultForFarm:writeStream(streamId, connection)
	streamWriteString(streamId, self.farmname);
end;
function MpManagement_Husbandry_LoadDefaultForFarm:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.husbandry:loadDefaultForFarm(self.farmname, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Husbandry_LoadDefaultForFarm.sendEvent(farmname, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Husbandry_LoadDefaultForFarm:new(farmname))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Husbandry_LoadDefaultForFarm:new(farmname))
		end
	end
end;


-- Synch for MpManager  - Husbandry - Delete default for farm
MpManagement_Husbandry_DeleteDefaultForFarm = {};
MpManagement_Husbandry_DeleteDefaultForFarm_mt = Class(MpManagement_Husbandry_DeleteDefaultForFarm, Event);
InitEventClass(MpManagement_Husbandry_DeleteDefaultForFarm, "MpManagement_Husbandry_DeleteDefaultForFarm");
function MpManagement_Husbandry_DeleteDefaultForFarm:emptyNew()
	return Event:new(MpManagement_Husbandry_DeleteDefaultForFarm_mt);
end;
function MpManagement_Husbandry_DeleteDefaultForFarm:new(farmname)
	local self = MpManagement_Husbandry_DeleteDefaultForFarm:emptyNew();
	self.farmname = farmname;
	return self;
end;
function MpManagement_Husbandry_DeleteDefaultForFarm:readStream(streamId, connection)
	self.farmname = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Husbandry_DeleteDefaultForFarm:writeStream(streamId, connection)
	streamWriteString(streamId, self.farmname);
end;
function MpManagement_Husbandry_DeleteDefaultForFarm:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.husbandry:deleteDefaultForFarm(self.farmname, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Husbandry_DeleteDefaultForFarm.sendEvent(farmname, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Husbandry_DeleteDefaultForFarm:new(farmname))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Husbandry_DeleteDefaultForFarm:new(farmname))
		end
	end
end;

-- Synch for MpManager  - Husbandry - Set number
MpManagement_Husbandry_SetNumber = {};
MpManagement_Husbandry_SetNumber_mt = Class(MpManagement_Husbandry_SetNumber, Event);
InitEventClass(MpManagement_Husbandry_SetNumber, "MpManagement_Husbandry_SetNumber");
function MpManagement_Husbandry_SetNumber:emptyNew()
	return Event:new(MpManagement_Husbandry_SetNumber_mt);
end;
function MpManagement_Husbandry_SetNumber:new(farmname, name, value)
	local self = MpManagement_Husbandry_SetNumber:emptyNew();
	self.farmname = farmname;
	self.name = name;
	self.value = value;
	return self;
end;
function MpManagement_Husbandry_SetNumber:readStream(streamId, connection)
	self.farmname = streamReadString(streamId);
	self.name = streamReadString(streamId);
	self.value = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_Husbandry_SetNumber:writeStream(streamId, connection)
	streamWriteString(streamId, self.farmname);
	streamWriteString(streamId, self.name);
	streamWriteInt32(streamId, self.value);
end;
function MpManagement_Husbandry_SetNumber:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.husbandry:setNumber(self.farmname, self.name, self.value, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Husbandry_SetNumber.sendEvent(farmname, name, value, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Husbandry_SetNumber:new(farmname, name, value))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Husbandry_SetNumber:new(farmname, name, value))
		end
	end
end;