-- 
-- MpManager - Placeables
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

Placeables = {}
g_mpManager.placeables = Placeables;

function Placeables:load()
	g_currentMission.environment:addHourChangeListener(Placeables);
	g_currentMission.environment:addDayChangeListener(Placeables);
end;

function Placeables:hourChanged()
	if g_mpManager.settings:getState("assignabelsBuildings") == 1 then
		Placeables:pay();
	end;
end;

function Placeables:dayChanged()
	if g_mpManager.settings:getState("assignabelsBuildings") == 2 then
		Placeables:pay();
	end;
end;

function Placeables:pay()
	if g_server == nil or not g_mpManager.isConfig then
		return;
	end;	
	local placeable_tbl = g_mpManager.assignabels.assignabelsById[g_mpManager.assignabels.PLACEABLE];
	if placeable_tbl == nil then
		return;
	end;
	
	local pay = {};
	
	for _,placeable in pairs(placeable_tbl) do
		local farmname = placeable.object.mpManagerFarm;
		local money = placeable.object.mpManagerMoney;
		if placeable.object.mpManagerMoney == nil then
			money = 0;
		end;
		local split = false;
		if farmname == g_mpManager.assignabels.notAssign or farmname == nil then
			split = true;
		end;
		if split then
			money = money / table.getn(g_mpManager.farm:getFarms());
			for i,farm in pairs(g_mpManager.farm:getFarms()) do
				if pay[farm] == nil then
					pay[farm] = {};
				end;
				local hasInsert = false;
				for _, p in pairs(pay[farm]) do
					if p.name == placeable.name then
						p.money = p.money + money;
						hasInsert = true;
						break;
					end;
				end;
				if not hasInsert then
					table.insert(pay[farm], {name=placeable.name, money=money});
				end;
			end;
		else
			local farm = g_mpManager.utils:getFarmTblFromFarmname(farmname);			
			if pay[farm] == nil then
				pay[farm] = {};
			end;
			local hasInsert = false;
			for _, p in pairs(pay[farm]) do
				if p.name == placeable.name then
					p.money = p.money + money;
					hasInsert = true;
					break;
				end;
			end;
			if not hasInsert then
				table.insert(pay[farm], {name=placeable.name, money=money});
			end;
		end;
		placeable.object.mpManagerMoney = 0;
	end;
	
	for farm, t in pairs(pay) do
		for _,p in pairs(t) do		
			local statType = "propertyIncome";
			if p.money < 0 then
				statType = "vehicleRunningCost";
			end;
			g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "--", farm, statType, g_i18n:getText("mpManager_moneyinput_automaticIncome"), p.name, "--", p.money);
			farm:addMoney(p.money);		
		end;
	end;	
end;

function Placeable_finalizePlacement(org)
	return function(s, ...)
		local ret = org(s, ...);
		local storeItem = StoreItemsUtil.storeItemsByXMLFilename[s.configFileName:lower()]
		
		if storeItem.incomePerHour ~= 0 or storeItem.dailyUpkeep ~= nil then
			g_mpManager.assignabels:addAssignables(g_mpManager.assignabels.PLACEABLE, storeItem.name, s);
		end;
		return ret;
	end;
end;
function Placeable_loadFromAttributesAndNodes(org)
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
function Placeable_getSaveAttributesAndNodes(org)
	return function(s, nodeIdent)
		local attributes, nodes = org(s, nodeIdent);
		if s.storage == nil then	
			if s.mpManagerFarm ~= nil then
				attributes = attributes .. ' mpManagerFarm="' .. s.mpManagerFarm .. '"';
			end;
			if s.mpManagerMoney ~= nil then
				attributes = attributes .. ' mpManagerMoney="' .. s.mpManagerMoney .. '"';
			end;
		end;
		return attributes, nodes;
	end;
end;
Placeable.finalizePlacement = Placeable_finalizePlacement(Placeable.finalizePlacement);
Placeable.loadFromAttributesAndNodes = Placeable_loadFromAttributesAndNodes(Placeable.loadFromAttributesAndNodes);
Placeable.getSaveAttributesAndNodes = Placeable_getSaveAttributesAndNodes(Placeable.getSaveAttributesAndNodes);