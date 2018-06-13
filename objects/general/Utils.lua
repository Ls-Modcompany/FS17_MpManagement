-- 
-- MpManager -  Utils
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerUtils = {};
g_mpManager.utils = MpManagerUtils;

function MpManagerUtils:getTableLenght(tbl)
	local count = 0;
	for _,_ in pairs(tbl) do
		count = count + 1;
	end;
	return count;
end;

function MpManagerUtils:getFarmFromUsername(username)
	for _,user in pairs(g_mpManager.user.users) do
		if user:getName() == username then
			return user:getFarm();
		end;
	end;
end;

function MpManagerUtils:getUserFromUsername(username)
	for _,user in pairs(g_mpManager.user.users) do
		if user:getName() == username then
			return user;
		end;
	end;
end;

function MpManagerUtils:getFarmTblFromUsername(username)
	local farmname = MpManagerUtils:getFarmFromUsername(username);
	for _,farm in pairs(g_mpManager.farm.farms) do
		if farm:getName() == farmname then
			return farm;
		end;
	end;
end;

function MpManagerUtils:getFarmTblFromFarmname(farmname)
	for _,farm in pairs(g_mpManager.farm.farms) do
		if farm:getName() == farmname then
			return farm;
		end;
	end;
end;

function MpManagerUtils:getUsernameIsLeader(username)
	for _,farm in pairs(g_mpManager.farm.farms) do
		if farm:getLeader() == username then
			return true;
		end;
	end;
	return false;
end;

function MpManagerUtils:getMoneyFromFarm(farmname)
	for _,farm in pairs(g_mpManager.farm.farms) do
		if farm:getName() == farmname then
			return farm:getMoney();
		end;
	end;
end;

function MpManagerUtils:getMoneyFromUsername(username)
	return g_mpManager.utils:getMoneyFromFarm(g_mpManager.utils:getFarmFromUsername(username));
end;

function MpManagerUtils:getNumUserFromFarmname(farmname)
	local count = 0;
	for _,user in pairs(g_mpManager.user.users) do
		if user:getFarm() == farmname then
			count = count + 1;
		end;
	end;
	return count
end;

function MpManagerUtils:getFarmNamesAndIndex()
	local t = {};
	local index = 1;
	local farm = g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName);
	for k,v in pairs(g_mpManager.farm:getFarms()) do
		local name = v:getName();
		table.insert(t, name);
		if farm ~= nil then
			if name == farm then
				index = k;
			end;
		end;
	end;
	return t, index;
end;

function MpManagerUtils:getPlaces()
	local tabl = {}
	for _, farm in pairs(g_mpManager.farm:getFarms()) do	
		table.insert(tabl, {name=farm:getName()});
	end;	
	if table.getn(g_currentMission.fieldDefinitionBase.fieldDefs) > 0 then
		for _,field in pairs(g_currentMission.fieldDefinitionBase.fieldDefs) do
			if field.ownedByPlayer then
				table.insert(tabl, {name=string.format(g_i18n:getText("fieldJob_number"), field.fieldNumber), number=field.fieldNumber, area=field.fieldArea});
			end;
		end;
	end;	
	return tabl;
end;