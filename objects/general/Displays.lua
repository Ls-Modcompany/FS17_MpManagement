-- 
-- MpManager - Displays
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

local function onMoneyChanged(old)
	return function(s)
		if s.isOpen and g_mpManager.isConfig then
			s:updateBalanceText()
			if g_currentMission ~= nil then
				s.lastMoney = g_mpManager.utils:getMoneyFromUsername(g_currentMission.missionInfo.playerName);
			end
		end
	end;
end;

local function updateBalanceText(old)
	return function(s)
		if g_mpManager.isConfig then
			local money = g_mpManager.utils:getMoneyFromUsername(g_currentMission.missionInfo.playerName);
			if money ~= nil then
				g_i18n:setMoneyUnit(g_gameSettings:getValue("moneyUnit"));
				s.shopMoney:setText(g_i18n:formatMoney(money, 0, true, true), true);
				if money > 0 then
					s.shopMoney:applyProfile("shopMoney")
				else
					s.shopMoney:applyProfile("shopMoneyNeg")
				end
				s.shopMoneyBox:invalidateLayout()
			end;
		end;
	end;
end;

-- local function updateBalanceText2(old)
	-- return function(s)
		-- if g_mpManager.isConfig then
			-- local money = g_mpManager.utils:getMoneyFromUsername(g_currentMission.missionInfo.playerName);
			-- if money ~= nil then
				-- g_i18n:setMoneyUnit(g_gameSettings:getValue("moneyUnit"));
				-- s.shopMoney:setText(g_i18n:formatMoney(money, 0, true, true), true);
				-- if money > 0 then
					-- s.shopMoney:applyProfile("shopMoney")
				-- else
					-- s.shopMoney:applyProfile("shopMoneyNeg")
				-- end
				-- s.shopMoneyBox:invalidateLayout()
			-- end;
		-- end;
	-- end;
-- end;

ShopScreen.updateBalanceText = updateBalanceText(ShopScreen.updateBalanceText);
ShopScreen.onMoneyChanged = onMoneyChanged(ShopScreen.onMoneyChanged);
FieldJobMissionScreen.updateBalanceText = updateBalanceText(FieldJobMissionScreen.updateBalanceText);
