-- 
-- MpManager - Event - Transfer
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - Transfer - get next id
MpManagement_Transfer_GetNextId = {};
MpManagement_Transfer_GetNextId_mt = Class(MpManagement_Transfer_GetNextId, Event);
InitEventClass(MpManagement_Transfer_GetNextId, "MpManagement_Transfer_GetNextId");
function MpManagement_Transfer_GetNextId:emptyNew()
	return Event:new(MpManagement_Transfer_GetNextId_mt);
end;
function MpManagement_Transfer_GetNextId:new()
	local self = MpManagement_Transfer_GetNextId:emptyNew();
	return self;
end;
function MpManagement_Transfer_GetNextId:readStream(streamId, connection)
	self:run(connection);
end;
function MpManagement_Transfer_GetNextId:writeStream(streamId, connection)
end;
function MpManagement_Transfer_GetNextId:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.transfer:getNextId(true);
end;
function MpManagement_Transfer_GetNextId.sendEvent(noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Transfer_GetNextId:new())
		else
			g_client:getServerConnection():sendEvent(MpManagement_Transfer_GetNextId:new())
		end
	end
end;

-- Synch for MpManager  - Transfer - new Transfer
MpManagement_Transfer_NewTransfer = {};
MpManagement_Transfer_NewTransfer_mt = Class(MpManagement_Transfer_NewTransfer, Event);
InitEventClass(MpManagement_Transfer_NewTransfer, "MpManagement_Transfer_NewTransfer");
function MpManagement_Transfer_NewTransfer:emptyNew()
	return Event:new(MpManagement_Transfer_NewTransfer_mt);
end;
function MpManagement_Transfer_NewTransfer:new(data)
	local self = MpManagement_Transfer_NewTransfer:emptyNew();
	self.data = data;
	return self;
end;
function MpManagement_Transfer_NewTransfer:readStream(streamId, connection)
	self.data = {};
	self.data.id = streamReadInt32(streamId);
	self.data.empf = streamReadString(streamId);
	self.data.zweck = streamReadString(streamId);
	self.data.zweckAdd = streamReadString(streamId);
	self.data.money = streamReadInt32(streamId);
	self.data.sender = streamReadString(streamId);
	self.data.date = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Transfer_NewTransfer:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.data.id);
	streamWriteString(streamId, self.data.empf);
	streamWriteString(streamId, self.data.zweck);
	streamWriteString(streamId, self.data.zweckAdd);
	streamWriteInt32(streamId, self.data.money);
	streamWriteString(streamId, self.data.sender);
	streamWriteString(streamId, self.data.date);
end;
function MpManagement_Transfer_NewTransfer:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.transfer:addTransfer(self.data, true);
end;
function MpManagement_Transfer_NewTransfer.sendEvent(data, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Transfer_NewTransfer:new(data))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Transfer_NewTransfer:new(data))
		end
	end
end;

-- Synch for MpManager  - Transfer - delete by id
MpManagement_Transfer_DeleteById = {};
MpManagement_Transfer_DeleteById_mt = Class(MpManagement_Transfer_DeleteById, Event);
InitEventClass(MpManagement_Transfer_DeleteById, "MpManagement_Transfer_DeleteById");
function MpManagement_Transfer_DeleteById:emptyNew()
	return Event:new(MpManagement_Transfer_DeleteById_mt);
end;
function MpManagement_Transfer_DeleteById:new(id)
	local self = MpManagement_Transfer_DeleteById:emptyNew();
	self.id = id;
	return self;
end;
function MpManagement_Transfer_DeleteById:readStream(streamId, connection)
	self.id = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_Transfer_DeleteById:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.id);
end;
function MpManagement_Transfer_DeleteById:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.transfer:deleteTransferById(self.id, true);
end;
function MpManagement_Transfer_DeleteById.sendEvent(id, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Transfer_DeleteById:new(id))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Transfer_DeleteById:new(id))
		end
	end
end;

-- Synch for MpManager  - Transfer - on farmname change
MpManagement_Transfer_OnFarmNameChange = {};
MpManagement_Transfer_OnFarmNameChange_mt = Class(MpManagement_Transfer_OnFarmNameChange, Event);
InitEventClass(MpManagement_Transfer_OnFarmNameChange, "MpManagement_Transfer_OnFarmNameChange");
function MpManagement_Transfer_OnFarmNameChange:emptyNew()
	return Event:new(MpManagement_Transfer_OnFarmNameChange_mt);
end;
function MpManagement_Transfer_OnFarmNameChange:new(oldName, newName)
	local self = MpManagement_Transfer_OnFarmNameChange:emptyNew();
	self.oldName = oldName;
	self.newName = newName;
	return self;
end;
function MpManagement_Transfer_OnFarmNameChange:readStream(streamId, connection)
	self.oldName = streamReadString(streamId);
	self.newName = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Transfer_OnFarmNameChange:writeStream(streamId, connection)
	streamWriteString(streamId, self.oldName);
	streamWriteString(streamId, self.newName);
end;
function MpManagement_Transfer_OnFarmNameChange:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.transfer:onFarmNameChange(self.oldName, self.newName, true);
end;
function MpManagement_Transfer_OnFarmNameChange.sendEvent(oldName, newName, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Transfer_OnFarmNameChange:new(oldName, newName))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Transfer_OnFarmNameChange:new(oldName, newName))
		end
	end
end;

-- Synch for MpManager  - Transfer - on playername change
MpManagement_Transfer_OnPlayerNameChange = {};
MpManagement_Transfer_OnPlayerNameChange_mt = Class(MpManagement_Transfer_OnPlayerNameChange, Event);
InitEventClass(MpManagement_Transfer_OnPlayerNameChange, "MpManagement_Transfer_OnPlayerNameChange");
function MpManagement_Transfer_OnPlayerNameChange:emptyNew()
	return Event:new(MpManagement_Transfer_OnPlayerNameChange_mt);
end;
function MpManagement_Transfer_OnPlayerNameChange:new(oldName, newName)
	local self = MpManagement_Transfer_OnPlayerNameChange:emptyNew();
	self.oldName = oldName;
	self.newName = newName;
	return self;
end;
function MpManagement_Transfer_OnPlayerNameChange:readStream(streamId, connection)
	self.oldName = streamReadString(streamId);
	self.newName = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Transfer_OnPlayerNameChange:writeStream(streamId, connection)
	streamWriteString(streamId, self.oldName);
	streamWriteString(streamId, self.newName);
end;
function MpManagement_Transfer_OnPlayerNameChange:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.transfer:onPlayerNameChange(self.oldName, self.newName, true);
end;
function MpManagement_Transfer_OnPlayerNameChange.sendEvent(oldName, newName, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Transfer_OnPlayerNameChange:new(oldName, newName))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Transfer_OnPlayerNameChange:new(oldName, newName))
		end
	end
end;