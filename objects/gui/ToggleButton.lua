-- 
-- MpManager -  Toggle Button
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerToggleButton = {};

function MpManagerToggleButton.onButtonClicked(old)
	return function(s)
		if s.target.name == "MpManagerScreen" then
			s:setIsChecked(not s.isChecked);
			if s.onClickCallback ~= nil then
				if s.target ~= nil then
					s.onClickCallback(s.target, s, s.isChecked);
				else
					s.onClickCallback(s.isChecked);
				end;
			end;
		else
			old(s);
		end;
	end;
  
end;

ToggleButtonElement.onButtonClicked = MpManagerToggleButton.onButtonClicked(ToggleButtonElement.onButtonClicked);