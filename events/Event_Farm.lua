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

-- Synch for MpManager  - Farm - New Farm
MpManagement_Farm_NewFarm = {};
MpManagement_Farm_NewFarm_mt = Class(MpManagement_Farm_NewFarm, Event);
InitEventClass(MpManagement_Farm_NewFarm, "MpManagement_Farm_NewFarm");
function MpManagement_Farm_NewFarm:emptyNew()
	return Event:new(MpManagement_Farm_NewFarm_mt);
end;
function MpManagement_Farm_NewFarm:new(name, leader, money)
	local self = MpManagement_Farm_NewFarm:emptyNew();
	self.name = name;
	self.leader = leader;
	self.money = money;
	return self;
end;
function MpManagement_Farm_NewFarm:readStream(streamId, connection)
	self.name = streamReadString(streamId);
	self.leader = streamReadString(streamId);
	self.money = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_Farm_NewFarm:writeStream(streamId, connection)
	streamWriteString(streamId, self.name);
	streamWriteString(streamId, self.leader);
	streamWriteInt32(streamId, self.money);
end;
function MpManagement_Farm_NewFarm:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.farm:newFarm(self.name, self.leader, self.money, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Farm_NewFarm.sendEvent(name, leader, money, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Farm_NewFarm:new(name, leader, money))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Farm_NewFarm:new(name, leader, money))
		end
	end
end;

-- Synch for MpManager  - Farm - remove Farm
MpManagement_Farm_RemoveFarm = {};
MpManagement_Farm_RemoveFarm_mt = Class(MpManagement_Farm_RemoveFarm, Event);
InitEventClass(MpManagement_Farm_RemoveFarm, "MpManagement_Farm_RemoveFarm");
function MpManagement_Farm_RemoveFarm:emptyNew()
	return Event:new(MpManagement_Farm_RemoveFarm_mt);
end;
function MpManagement_Farm_RemoveFarm:new(index)
	local self = MpManagement_Farm_RemoveFarm:emptyNew();
	self.index = index;
	return self;
end;
function MpManagement_Farm_RemoveFarm:readStream(streamId, connection)
	self.index = streamReadInt16(streamId);
	self:run(connection);
end;
function MpManagement_Farm_RemoveFarm:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.index);
end;
function MpManagement_Farm_RemoveFarm:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.farm:removeFarm(self.index, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Farm_RemoveFarm.sendEvent(index, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Farm_RemoveFarm:new(index))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Farm_RemoveFarm:new(index))
		end
	end
end;

-- Synch for MpManager  - Farm - Set Name
MpManagement_Farm_SetName = {};
MpManagement_Farm_SetName_mt = Class(MpManagement_Farm_SetName, Event);
InitEventClass(MpManagement_Farm_SetName, "MpManagement_Farm_SetName");
function MpManagement_Farm_SetName:emptyNew()
	return Event:new(MpManagement_Farm_SetName_mt);
end;
function MpManagement_Farm_SetName:new(id, name)
	local self = MpManagement_Farm_SetName:emptyNew();
	self.id = id;
	self.name = name;
	return self;
end;
function MpManagement_Farm_SetName:readStream(streamId, connection)
	self.id = streamReadInt16(streamId);
	self.name = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Farm_SetName:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.id);
	streamWriteString(streamId, self.name);
end;
function MpManagement_Farm_SetName:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	for _,farm in pairs(g_mpManager.farm:getFarms()) do
		if farm:getFarmId() == self.id then
			local oldName = farm:getName();
			farm:setName(self.name, true);			
			local oldHusbandry = g_mpManager.husbandry.sortByFarm[oldName];
			g_mpManager.husbandry.sortByFarm[oldName] = nil;
			g_mpManager.husbandry.sortByFarm[self.name] = oldHusbandry;
			break;
		end;
	end;
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Farm_SetName.sendEvent(id, name, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Farm_SetName:new(id, name))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Farm_SetName:new(id, name))
		end
	end
end;

-- Synch for MpManager  - Farm - Set Leader
MpManagement_Farm_SetLeader = {};
MpManagement_Farm_SetLeader_mt = Class(MpManagement_Farm_SetLeader, Event);
InitEventClass(MpManagement_Farm_SetLeader, "MpManagement_Farm_SetLeader");
function MpManagement_Farm_SetLeader:emptyNew()
	return Event:new(MpManagement_Farm_SetLeader_mt);
end;
function MpManagement_Farm_SetLeader:new(id, leader)
	local self = MpManagement_Farm_SetLeader:emptyNew();
	self.id = id;
	self.leader = leader;
	return self;
end;
function MpManagement_Farm_SetLeader:readStream(streamId, connection)
	self.id = streamReadInt16(streamId);
	self.leader = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Farm_SetLeader:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.id);
	streamWriteString(streamId, self.leader);
end;
function MpManagement_Farm_SetLeader:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	for _,farm in pairs(g_mpManager.farm:getFarms()) do
		if farm:getFarmId() == self.id then
			farm:setLeader(self.leader, true);
		end;
	end;	
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Farm_SetLeader.sendEvent(id, leader, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Farm_SetLeader:new(id, leader))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Farm_SetLeader:new(id, leader))
		end
	end
end;

-- Synch for MpManager  - Farm - Set money
MpManagement_Farm_SetMoney = {};
MpManagement_Farm_SetMoney_mt = Class(MpManagement_Farm_SetMoney, Event);
InitEventClass(MpManagement_Farm_SetMoney, "MpManagement_Farm_SetMoney");
function MpManagement_Farm_SetMoney:emptyNew()
	return Event:new(MpManagement_Farm_SetMoney_mt);
end;
function MpManagement_Farm_SetMoney:new(id, money)
	local self = MpManagement_Farm_SetMoney:emptyNew();
	self.id = id;
	self.money = money;
	return self;
end;
function MpManagement_Farm_SetMoney:readStream(streamId, connection)
	self.id = streamReadInt16(streamId);
	self.money = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_Farm_SetMoney:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.id);
	streamWriteInt32(streamId, self.money);
end;
function MpManagement_Farm_SetMoney:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	for _,farm in pairs(g_mpManager.farm:getFarms()) do
		if farm:getFarmId() == self.id then
			farm:setMoney(self.money, true);
		end;
	end;	
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Farm_SetMoney.sendEvent(id, money, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Farm_SetMoney:new(id, money))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Farm_SetMoney:new(id, money))
		end
	end
end;

-- Synch for MpManager  - Farm - Set price
MpManagement_Farm_SetPrice = {};
MpManagement_Farm_SetPrice_mt = Class(MpManagement_Farm_SetPrice, Event);
InitEventClass(MpManagement_Farm_SetPrice, "MpManagement_Farm_SetPrice");
function MpManagement_Farm_SetPrice:emptyNew()
	return Event:new(MpManagement_Farm_SetPrice_mt);
end;
function MpManagement_Farm_SetPrice:new(id, price, name)
	local self = MpManagement_Farm_SetPrice:emptyNew();
	self.id = id;
	self.price = price;
	self.name = name;
	return self;
end;
function MpManagement_Farm_SetPrice:readStream(streamId, connection)
	self.id = streamReadInt16(streamId);
	self.price = streamReadInt32(streamId);
	self.name = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_Farm_SetPrice:writeStream(streamId, connection)
	streamWriteInt16(streamId, self.id);
	streamWriteInt32(streamId, self.price);
	streamWriteString(streamId, self.name);
end;
function MpManagement_Farm_SetPrice:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	for _,farm in pairs(g_mpManager.farm:getFarms()) do
		if farm:getFarmId() == self.id then
			farm:setPrices(self.name, self.price, true);
		end;
	end;	
	g_mpManager.reloadScreen = true;
end;
function MpManagement_Farm_SetPrice.sendEvent(id, price, name, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Farm_SetPrice:new(id, price, name))
		else
			g_client:getServerConnection():sendEvent(MpManagement_Farm_SetPrice:new(id, price, name))
		end
	end
end;