-- 
-- MpManager - Event - Bill
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - Bill - get next id
MpManagement_Bill_GetNextId = {};
MpManagement_Bill_GetNextId_mt = Class(MpManagement_Bill_GetNextId, Event);
InitEventClass(MpManagement_Bill_GetNextId, "MpManagement_Bill_GetNextId");
function MpManagement_Bill_GetNextId:emptyNew()
	return Event:new(MpManagement_Bill_GetNextId_mt);
end;
function MpManagement_Bill_GetNextId:new()
	local self = MpManagement_Bill_GetNextId:emptyNew();
	return self;
end;
function MpManagement_Bill_GetNextId:readStream(streamId, connection)
	self:run(connection);
end;
function MpManagement_Bill_GetNextId:writeStream(streamId, connection)
end;
function MpManagement_Bill_GetNextId:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.bill:getNextId(true);
end;
function MpManagement_Bill_GetNextId.sendEvent(noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Bill_GetNextId:new())
		else
			g_client:getServerConnection():sendEvent(MpManagement_Bill_GetNextId:new())
		end
	end
end;

-- Synch for MpManager  - Bill - new Bill
MpManagement_Bill_NewBill = {};
MpManagement_Bill_NewBill_mt = Class(MpManagement_Bill_NewBill, Event);
InitEventClass(MpManagement_Bill_NewBill, "MpManagement_Bill_NewBill");
function MpManagement_Bill_NewBill:emptyNew()
	return Event:new(MpManagement_Bill_NewBill_mt);
end;
function MpManagement_Bill_NewBill:new(data)
	local self = MpManagement_Bill_NewBill:emptyNew();
	self.data = data;
	return self;
end;
function MpManagement_Bill_NewBill:readStream(streamId, connection)
	self.data = {};
	self.data.num = streamReadInt32(streamId);
	self.data.address = streamReadString(streamId);
	self.data.sender = streamReadString(streamId);
	self.data.state = streamReadInt16(streamId);
	self.data.date = streamReadString(streamId);
	
	self.data.entries = {};
	local numC = streamReadInt32(streamId);
	for j=1, numC do
		local workId = streamReadInt32(streamId);
		local place = streamReadString(streamId);
		local numE = streamReadInt32(streamId);
		local price = streamReadInt32(streamId);
		table.insert(self.data.entries, {workId=workId, place=place, num=numE, price=price});	
	end;
	self:run(connection);
end;
function MpManagement_Bill_NewBill:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.data.num);
	streamWriteString(streamId, self.data.address);
	streamWriteString(streamId, self.data.sender);
	streamWriteInt16(streamId, self.data.state);
	streamWriteString(streamId, self.data.date);
	
	streamWriteInt32(streamId, table.getn(self.data.entries));
	for _,e in pairs(self.data.entries) do
		streamWriteInt32(streamId, e.workId);
		streamWriteString(streamId, e.place);
		streamWriteInt32(streamId, Utils.getNoNil(e.num, 0));
		streamWriteInt32(streamId, e.price);
	end;	
end;
function MpManagement_Bill_NewBill:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.bill:addBill(self.data, true);
end;
function MpManagement_Bill_NewBill.sendEvent(data, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Bill_NewBill:new(data))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Bill_NewBill:new(data))
		end
	end
end;

-- Synch for MpManager  - Bill - Set state
MpManagement_Bill_SetState = {};
MpManagement_Bill_SetState_mt = Class(MpManagement_Bill_SetState, Event);
InitEventClass(MpManagement_Bill_SetState, "MpManagement_Bill_SetState");
function MpManagement_Bill_SetState:emptyNew()
	return Event:new(MpManagement_Bill_SetState_mt);
end;
function MpManagement_Bill_SetState:new(billId, state)
	local self = MpManagement_Bill_SetState:emptyNew();
	self.billId = billId;
	self.state = state;
	return self;
end;
function MpManagement_Bill_SetState:readStream(streamId, connection)
	self.billId = streamReadInt32(streamId);
	self.state = streamReadInt32(streamId);
	
	self:run(connection);
end;
function MpManagement_Bill_SetState:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.billId);
	streamWriteInt32(streamId, self.state);
end;
function MpManagement_Bill_SetState:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.bill:setState(self.billId, self.state, true);
end;
function MpManagement_Bill_SetState.sendEvent(billId, state, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Bill_SetState:new(billId, state))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Bill_SetState:new(billId, state))
		end
	end
end;

-- Synch for MpManager  - Bill - delete by id
MpManagement_Bill_DeleteById = {};
MpManagement_Bill_DeleteById_mt = Class(MpManagement_Bill_DeleteById, Event);
InitEventClass(MpManagement_Bill_DeleteById, "MpManagement_Bill_DeleteById");
function MpManagement_Bill_DeleteById:emptyNew()
	return Event:new(MpManagement_Bill_DeleteById_mt);
end;
function MpManagement_Bill_DeleteById:new(billId)
	local self = MpManagement_Bill_DeleteById:emptyNew();
	self.billId = billId;
	return self;
end;
function MpManagement_Bill_DeleteById:readStream(streamId, connection)
	self.billId = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_Bill_DeleteById:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.billId);
end;
function MpManagement_Bill_DeleteById:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.bill:deleteBillById(self.billId, true);
end;
function MpManagement_Bill_DeleteById.sendEvent(billId, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Bill_DeleteById:new(billId))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Bill_DeleteById:new(billId))
		end
	end
end;

-- Synch for MpManager  - Bill - on farmname change
MpManagement_Bill_OnFarmNameChange = {};
MpManagement_Bill_OnFarmNameChange_mt = Class(MpManagement_Bill_OnFarmNameChange, Event);
InitEventClass(MpManagement_Bill_OnFarmNameChange, "MpManagement_Bill_OnFarmNameChange");
function MpManagement_Bill_OnFarmNameChange:emptyNew()
	return Event:new(MpManagement_Bill_OnFarmNameChange_mt);
end;
function MpManagement_Bill_OnFarmNameChange:new(oldName, newName)
	local self = MpManagement_Bill_OnFarmNameChange:emptyNew();
	self.oldName = oldName;
	self.newName = newName;
	return self;
end;
function MpManagement_Bill_OnFarmNameChange:readStream(streamId, connection)
	self.oldName = streamReadString(streamId);
	self.newName = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Bill_OnFarmNameChange:writeStream(streamId, connection)
	streamWriteString(streamId, self.oldName);
	streamWriteString(streamId, self.newName);
end;
function MpManagement_Bill_OnFarmNameChange:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.bill:onFarmNameChange(self.oldName, self.newName, true);
end;
function MpManagement_Bill_OnFarmNameChange.sendEvent(oldName, newName, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Bill_OnFarmNameChange:new(oldName, newName))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Bill_OnFarmNameChange:new(oldName, newName))
		end
	end
end;

-- Synch for MpManager  - Bill - on playername change
MpManagement_Bill_OnPlayerNameChange = {};
MpManagement_Bill_OnPlayerNameChange_mt = Class(MpManagement_Bill_OnPlayerNameChange, Event);
InitEventClass(MpManagement_Bill_OnPlayerNameChange, "MpManagement_Bill_OnPlayerNameChange");
function MpManagement_Bill_OnPlayerNameChange:emptyNew()
	return Event:new(MpManagement_Bill_OnPlayerNameChange_mt);
end;
function MpManagement_Bill_OnPlayerNameChange:new(oldName, newName)
	local self = MpManagement_Bill_OnPlayerNameChange:emptyNew();
	self.oldName = oldName;
	self.newName = newName;
	return self;
end;
function MpManagement_Bill_OnPlayerNameChange:readStream(streamId, connection)
	self.oldName = streamReadString(streamId);
	self.newName = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Bill_OnPlayerNameChange:writeStream(streamId, connection)
	streamWriteString(streamId, self.oldName);
	streamWriteString(streamId, self.newName);
end;
function MpManagement_Bill_OnPlayerNameChange:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.bill:onPlayerNameChange(self.oldName, self.newName, true);
end;
function MpManagement_Bill_OnPlayerNameChange.sendEvent(oldName, newName, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Bill_OnPlayerNameChange:new(oldName, newName))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Bill_OnPlayerNameChange:new(oldName, newName))
		end
	end
end;