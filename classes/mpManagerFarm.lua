-- 
-- MpManager - Farm
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

Farm = {};
local Farm_mt = Class(Farm);

function Farm:new(id)
	local self = {};
	setmetatable(self, Farm_mt);
	
	self.FarmId = id;
	
	self.name = "defaultFarm";
	self.leader = "defaultLeader";
	self.money = 0;
	
	self.prices = {};
	-- for _, work in pairs(g_mpManager.data.works) do
		-- table.insert(self.prices, {name=work.name, price=work.price});
	-- end;
	
	return self;
end;

function Farm:setName(name, noEventSend)
	if name ~= nil and name ~= self.name then
		MpManagement_Farm_SetName.sendEvent(self.FarmId, name, noEventSend);
		self.name = name;
	end;
end;

function Farm:setLeader(leader, noEventSend)
	if leader ~= nil and leader ~= self.leader then
		MpManagement_Farm_SetLeader.sendEvent(self.FarmId, leader, noEventSend)
		self.leader = leader;
	end;
end;

function Farm:setMoney(money, noEventSend)
	if money ~= nil and money ~= self.money then
		MpManagement_Farm_SetMoney.sendEvent(self.FarmId, money, noEventSend)
		self.money = money;
	end;
end;

function Farm:addMoney(amount)
	if amount ~= nil then
		self:setMoney(self.money + amount);
	end;
end;

function Farm:setFarmData(name, leader, money)
	if name ~= nil and leader ~= nil and money ~= nil then
		self.name = name;
		self.leader = leader;
		self.money = money;
	end;
end;

function Farm:getName()
	return self.name;
end;

function Farm:getLeader()
	return self.leader;
end;

function Farm:getMoney()
	return self.money;
end;

function Farm:getFarmId()
	return self.FarmId;
end;

function Farm:getPrices()
	return self.prices;
end;

function Farm:setPrices(name, price, noEventSend)
	MpManagement_Farm_SetPrice.sendEvent(self.FarmId, price, name, noEventSend)
	for _, p in pairs(self:getPrices()) do
		if p.name == name then
			p.price = price;
			break;
		end;
	end;
end;

function Farm:getWorkpriceByName(name)
	for _, p in pairs(self:getPrices()) do
		if p.name == name then
			return p.price;
		end;
	end;
	return 0;
end;


MpManagerFarm = {};
g_mpManager.farm = MpManagerFarm;

function MpManagerFarm:load()
	MpManagerFarm.farmIds = 0;
	MpManagerFarm.farms = {};
	MpManagerFarm.defaultMoney = 0;
	g_mpManager.saveManager:addSave(MpManagerFarm.saveSavegame, MpManagerFarm);
	g_mpManager.loadManager:addLoad(MpManagerFarm.loadSavegame, MpManagerFarm);
end;

function MpManagerFarm:getFarms()
	return MpManagerFarm.farms;
end;

function MpManagerFarm:getNextFarmId()
	MpManagerFarm.farmIds = MpManagerFarm.farmIds + 1;
	return MpManagerFarm.farmIds;
end;

function MpManagerFarm:changeLeaderByName(oldName, newName)
	for _,farm in pairs(MpManagerFarm.farms) do
		if farm:getLeader() == oldName then
			farm:setLeader(newName);
			break;
		end;
	end;
end;

function MpManagerFarm:getFarmByIndex(index)
	return MpManagerFarm.farms[index];
end;

function MpManagerFarm:getUserIsLeader(name)
	local isLeader = false;
	for _,farm in pairs(MpManagerFarm.farms) do
		if farm:getLeader() == name then
			isLeader = true;
			break;
		end;
	end;
	return isLeader;
end;

function MpManagerFarm:newFarm(name, leader, money, noEventSend)
	if money == nil then
		money = MpManagerFarm.defaultMoney;
	end;	
	MpManagement_Farm_NewFarm.sendEvent(name, leader, money, noEventSend);
	local newFarm = Farm:new(MpManagerFarm:getNextFarmId());
	newFarm:setFarmData(name, leader, money, noEventSend);
	table.insert(MpManagerFarm.farms, newFarm);
	g_mpManager.husbandry:loadDefaultForFarm(name);
	newFarm.prices = g_mpManager.data:getDefaultPrices();
	return newFarm;
end;

function MpManagerFarm:removeFarm(index, noEventSend)
	MpManagement_Farm_RemoveFarm.sendEvent(index, noEventSend);
	local ret = MpManagerFarm.farms[index]:getName();
	table.remove(MpManagerFarm.farms, index);
	g_mpManager.husbandry:deleteDefaultForFarm(ret);
	return ret;
end;

function MpManagerFarm:saveSavegame()
	g_mpManager.saveManager:setXmlInt("farms#defaultMoney", MpManagerFarm.defaultMoney);
	local index = 0;
	for _,farm in pairs(MpManagerFarm.farms) do
		g_mpManager.saveManager:setXmlString(string.format("farms.farm(%d)#name", index), farm:getName());
		g_mpManager.saveManager:setXmlString(string.format("farms.farm(%d)#leader", index), farm:getLeader());
		g_mpManager.saveManager:setXmlInt(string.format("farms.farm(%d)#money", index), farm:getMoney());
		
		local i=0;
		for _,p in pairs(farm:getPrices()) do
			g_mpManager.saveManager:setXmlString(string.format("farms.farm(%d).prices.price(%d)#name", index, i), p.name);
			g_mpManager.saveManager:setXmlInt(string.format("farms.farm(%d).prices.price(%d)#price", index, i), p.price);				
			i = i + 1;
		end;		
		index = index + 1;
	end;
end;

function MpManagerFarm:loadSavegame()
	MpManagerFarm.defaultMoney = g_mpManager.loadManager:getXmlInt("farms#defaultMoney");
	local index = 0;
	while true do
		local addKey = string.format("farms.farm(%d)", index);
		if not g_mpManager.loadManager:hasXmlProperty(addKey) then
			break;
		end;
		local name = g_mpManager.loadManager:getXmlString(addKey .. "#name");
		local leader = g_mpManager.loadManager:getXmlString(addKey .. "#leader");
		local money = g_mpManager.loadManager:getXmlInt(addKey .. "#money");
		
		local prices = {};
		local i = 0;
		while true do
			local addKey = string.format("farms.farm(%d).prices.price(%d)", index, i);
			if not g_mpManager.loadManager:hasXmlProperty(addKey) then
				break;
			end;
			local name = g_mpManager.loadManager:getXmlString(addKey .. "#name");
			local price = g_mpManager.loadManager:getXmlInt(addKey .. "#price");
			table.insert(prices, {name=name,price=price});			
			i = i + 1;
		end;
		local farm = g_mpManager.farm:newFarm(name, leader, money, true);
		farm.prices = prices;
		index = index + 1;
	end;
end;

function MpManagerFarm:writeStream(streamId, connection)
	streamWriteInt32(streamId, table.getn(g_mpManager.farm.farms));
	for _,farm in pairs(g_mpManager.farm.farms) do
		streamWriteString(streamId, farm:getName());
		streamWriteString(streamId, farm:getLeader());
		streamWriteInt32(streamId, farm:getMoney());
		
		local prices = farm:getPrices();
		streamWriteInt32(streamId, table.getn(prices));
		for _,p in pairs(prices) do
			streamWriteString(streamId, p.name);
			streamWriteInt32(streamId, p.price);
		end;		
	end;
end;

function MpManagerFarm:readStream(streamId, connection)
	local count = streamReadInt32(streamId);
	for i=1, count do
		local name = streamReadString(streamId);
		local leader = streamReadString(streamId);
		local money = streamReadInt32(streamId);
		
		local prices = {};
		local num = streamReadInt32(streamId);
		for j=1, num do
			local name = streamReadString(streamId);
			local price = streamReadInt32(streamId);
			table.insert(prices, {name=name, price=price});
		end;
		
		local farm = g_mpManager.farm:newFarm(name, leader, money, true);
		farm.prices = prices;
	end;
end;