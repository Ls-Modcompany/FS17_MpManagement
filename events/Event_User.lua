-- 
-- MpManager - Event - Farm
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - User - New User
MpManagement_User_NewUser = {};
MpManagement_User_NewUser_mt = Class(MpManagement_User_NewUser, Event);
InitEventClass(MpManagement_User_NewUser, "MpManagement_User_NewUser");
function MpManagement_User_NewUser:emptyNew()
	return Event:new(MpManagement_User_NewUser_mt);
end;
function MpManagement_User_NewUser:new(name, farm)
	local self = MpManagement_User_NewUser:emptyNew();
	self.name = name;
	self.farm = farm;
	return self;
end;
function MpManagement_User_NewUser:readStream(streamId, connection)
	self.name = streamReadString(streamId);
	self.farm = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_User_NewUser:writeStream(streamId, connection)
	streamWriteString(streamId, self.name);
	streamWriteString(streamId, self.farm);
end;
function MpManagement_User_NewUser:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.user:newUser(self.name, self.farm, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_User_NewUser.sendEvent(name, farm, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_User_NewUser:new(name, farm))
		else
			g_client:getServerConnection():sendEvent(MpManagement_User_NewUser:new(name, farm))
		end
	end
end;

-- Synch for MpManager  - User - remove User
MpManagement_User_RemoveUser = {};
MpManagement_User_RemoveUser_mt = Class(MpManagement_User_RemoveUser, Event);
InitEventClass(MpManagement_User_RemoveUser, "MpManagement_User_RemoveUser");
function MpManagement_User_RemoveUser:emptyNew()
	return Event:new(MpManagement_User_RemoveUser_mt);
end;
function MpManagement_User_RemoveUser:new(index)
	local self = MpManagement_User_RemoveUser:emptyNew();
	self.index = index;
	return self;
end;
function MpManagement_User_RemoveUser:readStream(streamId, connection)
	self.index = streamReadInt16(streamId);
	self:run(connection);
end;
function MpManagement_User_RemoveUser:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.index);
end;
function MpManagement_User_RemoveUser:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.user:removeUser(self.index, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_User_RemoveUser.sendEvent(index, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_User_RemoveUser:new(index))
		else
			g_client:getServerConnection():sendEvent(MpManagement_User_RemoveUser:new(index))
		end
	end
end;

-- Synch for MpManager  - User - Set Name
MpManagement_User_SetName = {};
MpManagement_User_SetName_mt = Class(MpManagement_User_SetName, Event);
InitEventClass(MpManagement_User_SetName, "MpManagement_User_SetName");
function MpManagement_User_SetName:emptyNew()
	return Event:new(MpManagement_User_SetName_mt);
end;
function MpManagement_User_SetName:new(id, name)
	local self = MpManagement_User_SetName:emptyNew();
	self.id = id;
	self.name = name;
	return self;
end;
function MpManagement_User_SetName:readStream(streamId, connection)
	self.id = streamReadInt16(streamId);
	self.name = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_User_SetName:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.id);
	streamWriteString(streamId, self.name);
end;
function MpManagement_User_SetName:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	for _,user in pairs(g_mpManager.user:getUsers()) do
		if user:getUserId() == self.id then
			user:setName(self.name, true);			
			break;
		end;
	end;	
	g_mpManager.reloadScreen = true;
end;
function MpManagement_User_SetName.sendEvent(id, name, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_User_SetName:new(id, name))
		else
			g_client:getServerConnection():sendEvent(MpManagement_User_SetName:new(id, name))
		end
	end
end;

-- Synch for MpManager  - Farm - Set Farm
MpManagement_User_SetFarm = {};
MpManagement_User_SetFarm_mt = Class(MpManagement_User_SetFarm, Event);
InitEventClass(MpManagement_User_SetFarm, "MpManagement_User_SetFarm");
function MpManagement_User_SetFarm:emptyNew()
	return Event:new(MpManagement_User_SetFarm_mt);
end;
function MpManagement_User_SetFarm:new(id, farm)
	local self = MpManagement_User_SetFarm:emptyNew();
	self.id = id;
	self.farm = farm;
	return self;
end;
function MpManagement_User_SetFarm:readStream(streamId, connection)
	self.id = streamReadInt16(streamId);
	self.farm = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_User_SetFarm:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.id);
	streamWriteString(streamId, self.farm);
end;
function MpManagement_User_SetFarm:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	for _,user in pairs(g_mpManager.user:getUsers()) do
		if user:getUserId() == self.id then
			user:setFarm(self.farm, true);			
			break;
		end;
	end;		
	g_mpManager.reloadScreen = true;
end;
function MpManagement_User_SetFarm.sendEvent(id, farm, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_User_SetFarm:new(id, farm))
		else
			g_client:getServerConnection():sendEvent(MpManagement_User_SetFarm:new(id, farm))
		end
	end
end;