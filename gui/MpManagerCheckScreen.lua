-- 
-- MpManager - CheckScreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerCheckScreen = {};
local MpManagerCheckScreen_mt = Class(MpManagerCheckScreen, ScreenElement);

function MpManagerCheckScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerCheckScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerCheckScreen:onCreate()	

end;

function MpManagerCheckScreen:onClose(element)
    MpManagerCheckScreen:superClass().onClose(self);
end

function MpManagerCheckScreen:onOpen()
    MpManagerCheckScreen:superClass().onOpen(self);
end

function MpManagerCheckScreen:update(dt)
    MpManagerCheckScreen:superClass().update(self, dt);
end

function MpManagerCheckScreen:onClickBack()
    g_gui:closeDialogByName("MpManagerCheckScreen");
	if self.onBreak ~= nil then
		self.onBreak(self.target, self.args);
	end;
end;

function MpManagerCheckScreen:onClickOk()
    g_gui:closeDialogByName("MpManagerCheckScreen");
	if self.onOk ~= nil then
		self.onOk(self.target, self.args);
	end;
end;

function MpManagerCheckScreen:setInfoText(newText)
	if newText ~= nil then
		self.infoText:setText(newText);
	end;
end;

function MpManagerCheckScreen:setCallback(onOk, onBreak, target, args)
	self.onOk = onOk;
	self.onBreak = onBreak;
	self.target = target;
	self.args = args;
end;