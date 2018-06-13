-- 
-- MpManager - Storage
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerStorage = {}
g_mpManager.mpManagerStorage = MpManagerStorage;

function MpManagerStorage:load()
	g_currentMission.environment:addHourChangeListener(MpManagerStorage);
	g_currentMission.environment:addDayChangeListener(MpManagerStorage);
end;

function MpManagerStorage:hourChanged()
	if g_mpManager.settings:getState("assignabelsBuildings") == 1 then
		MpManagerStorage:pay();
	end;
end;

function MpManagerStorage:dayChanged()
	if g_mpManager.settings:getState("assignabelsBuildings") == 2 then
		MpManagerStorage:pay();
	end;
end;

function MpManagerStorage:pay()
	if g_server == nil or not g_mpManager.isConfig then
		return;
	end;	
	local storage_tbl = g_mpManager.assignabels.assignabelsById[g_mpManager.assignabels.STORAGE];
	for _,storage in pairs(storage_tbl) do
		local farmname = storage.object.mpManagerFarm;
		local money = storage.object.mpManagerMoney;		
		if money ~= nil and money ~= 0 then
			local split = false;
			if farmname == g_mpManager.assignabels.notAssign or farmname == nil then
				split = true;
			end;
			if split then
				money = money / table.getn(g_mpManager.farm:getFarms());
				for i,farm in pairs(g_mpManager.farm:getFarms()) do
					g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "--", farm, "propertyMaintenance", g_i18n:getText("mpManager_moneyinput_automaticIncome2"), storage.name, "-", money);
					farm:addMoney(money);
				end;
			else
				local farm = g_mpManager.utils:getFarmTblFromFarmname(farmname);
				g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "--", farm, "propertyMaintenance", g_i18n:getText("mpManager_moneyinput_automaticIncome2"), storage.name, "-", money);
				farm:addMoney(money);
			end;
			storage.object.mpManagerMoney = 0;
		end;
	end;
end;

function Storage_load(org)
	return function(s, nodeId)
		local ret = org(s, nodeId);			
		local name = s.storageName;
		for _, trigger in pairs(s.siloTriggers) do
			name =  trigger.stationName;
		end;
		g_mpManager.assignabels:addAssignables(g_mpManager.assignabels.STORAGE, name, s);
		return ret;
	end;
end;

function Storage_loadFromAttributesAndNodes(org)
	return function(s, xmlFile, key)
		local ret = org(s, xmlFile, key);
		local farm = getXMLString(xmlFile, key.."#mpManagerFarm");
		if farm == nil then
			farm = g_mpManager.assignabels.notAssign;
		end;
		s.mpManagerFarm = farm;
		
		local money = getXMLInt(xmlFile, key.."#mpManagerMoney");
		if money == nil then
			money = 0;
		end;
		s.mpManagerMoney = money;
		
		return ret;
	end;
end;

function Storage_getSaveAttributesAndNodes(org)
	return function(s, nodeIdent)
		local attributes, nodes = org(s, nodeIdent);		
		if s.mpManagerFarm ~= nil then
			attributes = attributes .. ' mpManagerFarm="' .. s.mpManagerFarm .. '"';
		end;
		if s.mpManagerMoney ~= nil then
			attributes = attributes .. ' mpManagerMoney="' .. s.mpManagerMoney .. '"';
		end;
		return attributes, nodes;
	end;
end;

Storage.load = Storage_load(Storage.load);
Storage.loadFromAttributesAndNodes = Storage_loadFromAttributesAndNodes(Storage.loadFromAttributesAndNodes);
Storage.getSaveAttributesAndNodes = Storage_getSaveAttributesAndNodes(Storage.getSaveAttributesAndNodes);