-- 
-- MpManager - Bga
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerBga = {}
g_mpManager.mpManagerBga = MpManagerBga;

function MpManagerBga:load()
	g_currentMission.environment:addHourChangeListener(MpManagerBga);
	g_currentMission.environment:addDayChangeListener(MpManagerBga);
end;

function MpManagerBga:hourChanged()
	if g_mpManager.settings:getState("assignabelsBuildings") == 1 then
		MpManagerBga:pay();
	end;
end;

function MpManagerBga:dayChanged()
	if g_mpManager.settings:getState("assignabelsBuildings") == 2 then
		MpManagerBga:pay();
	end;
end;

function MpManagerBga:pay()
	if g_server == nil or not g_mpManager.isConfig then
		return;
	end;	
	local bga_tbl = g_mpManager.assignabels.assignabelsById[g_mpManager.assignabels.BGA];
	if bga_tbl == nil then
		return;
	end;
	for _,bga in pairs(bga_tbl) do
		local farmname = bga.object.mpManagerFarm;
		local money = bga.object.mpManagerMoney;
		local num = bga.object.mpManagerNum;
		if money ~= nil and money ~= 0 then
			local split = false;
			if farmname == g_mpManager.assignabels.notAssign or farmname == nil then
				split = true;
			end;
			if num == nil then
				num = "--";
			end;
			if split then
				money = money / table.getn(g_mpManager.farm:getFarms());
				num = g_i18n:formatNumber((num / table.getn(g_mpManager.farm:getFarms())),0)
				for i,farm in pairs(g_mpManager.farm:getFarms()) do
					g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "--", farm, "incomeBga", g_i18n:getText("mpManager_moneyinput_automaticIncome"), bga.name, num, money);
					farm:addMoney(money);
				end;
			else
				num = g_i18n:formatNumber(num,0)
				local farm = g_mpManager.utils:getFarmTblFromFarmname(farmname);
				g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "--", farm, "incomeBga", g_i18n:getText("mpManager_moneyinput_automaticIncome"), bga.name, num, money);
				farm:addMoney(money);
			end;
			bga.object.mpManagerMoney = 0;
			bga.object.mpManagerNum = 0;
		end;
	end;
end;

function Bga_load(org)
	return function(s, nodeId)
		local ret = org(s, nodeId);
		local name = "";
		for _,tipTrigger in pairs(s.tipTriggers) do
			if tipTrigger.appearsOnPDA or name == "" then
				local fullViewName = tipTrigger.stationName;
				if g_i18n:hasText(fullViewName) then
					fullViewName = g_i18n:getText(fullViewName)
				end
				name = fullViewName;
			end;
		end;		
		g_mpManager.assignabels:addAssignables(g_mpManager.assignabels.BGA, name, s);
		return ret;
	end;
end;

function Bga_loadFromAttributesAndNodes(org)
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
		
		local num = getXMLInt(xmlFile, key.."#mpManagerNum");
		if num == nil then
			num = 0;
		end;
		s.mpManagerNum = num;
		
		return ret;
	end;
end;

function Bga_getSaveAttributesAndNodes(org)
	return function(s, nodeIdent)
		local attributes, nodes = org(s, nodeIdent);
		if s.mpManagerFarm ~= nil then
			attributes = attributes .. ' mpManagerFarm="' .. s.mpManagerFarm .. '"';
		end;
		if s.mpManagerMoney ~= nil then
			attributes = attributes .. ' mpManagerMoney="' .. s.mpManagerMoney .. '"';
		end;
		if s.mpManagerNum ~= nil then
			attributes = attributes .. ' mpManagerNum="' .. s.mpManagerNum .. '"';
		end;
		return attributes, nodes;
	end;
end;
Bga.load = Bga_load(Bga.load);
Bga.loadFromAttributesAndNodes = Bga_loadFromAttributesAndNodes(Bga.loadFromAttributesAndNodes);
Bga.getSaveAttributesAndNodes = Bga_getSaveAttributesAndNodes(Bga.getSaveAttributesAndNodes);