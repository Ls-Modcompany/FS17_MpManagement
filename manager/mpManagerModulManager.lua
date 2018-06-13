-- 
-- MpManager - ModulManager
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

ModulManager = {};
g_mpManager.modulManager = ModulManager;

ModulManager.modul = {};

function ModulManager:addModul(target, call)
	table.insert(ModulManager.modul, {call=call, target=target});
end;

function ModulManager:controllMoney(statType, amount)
	for _,modul in pairs(ModulManager.modul) do
		if modul.call(modul.target, statType, amount) then
			return true;		
		end;
	end;	
	return false;		
end;