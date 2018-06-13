-- 
-- MpManager - ConfigScreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerSelectionScreen = {};

local MpManagerSelectionScreen_mt = Class(MpManagerSelectionScreen, ScreenElement);

function MpManagerSelectionScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerSelectionScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerSelectionScreen:onCreate()
	self.gui_page_1:setVisible(false);
	self.gui_page_3:setVisible(false);
	self.gui_page_1_list:removeElement(self.gui_page_1_list_template);
	self.gui_page_3_list:removeElement(self.gui_page_3_list_template);
end;

function MpManagerSelectionScreen:onClose(element)
    MpManagerSelectionScreen:superClass().onClose(self);
end

function MpManagerSelectionScreen:onOpen()
    MpManagerSelectionScreen:superClass().onOpen(self);
end

function MpManagerSelectionScreen:setCallback(onOk, target, args)
	self.onOk = onOk;
	self.target = target;
	self.args = args;
end;

function MpManagerSelectionScreen:onClickBack()
	g_gui:closeDialogByName("MpManagerSelectionScreen");
end;

function MpManagerSelectionScreen:onClickOk()	
	g_gui:closeDialogByName("MpManagerSelectionScreen");
	if self.onOk ~= nil then
		num = nil;
		if self.num == 1 then
			_, num = self.gui_page_1_list:getSelectedElement();
		elseif self.num == 3 then
			_, num = self.gui_page_3_list:getSelectedElement();
		end;
		self.onOk(self.target, num, self.args);
	end;
end;

function MpManagerSelectionScreen:update(dt)
    MpManagerSelectionScreen:superClass().update(self, dt);
end;

function MpManagerSelectionScreen:setData(dataTable, num, title, header1, header2, header3)
	self.gui_header:setText(title);
	self.num = num;	
	self.gui_page_1_list:deleteListItems();
	self.gui_page_3_list:deleteListItems();
	if num == 1 then	
		self.gui_page_1:setVisible(true);
		self.gui_page_3:setVisible(false);			
		self.gui_page_1_header1:setText(header1);		
		for _,v in pairs(dataTable) do
			self.currentData = v;
			local newItem = self.gui_page_1_list_template:clone(self.gui_page_1_list);	
			newItem:updateAbsolutePosition();		
			self.gui_page_1_list:updateItemPositions();
			self.currentData = nil;
		end;		
	elseif num == 3 then
		self.gui_page_1:setVisible(false);
		self.gui_page_3:setVisible(true);	
		self.gui_page_3_header1:setText(header1);
		self.gui_page_3_header2:setText(header2);
		self.gui_page_3_header3:setText(header3);		
		for _,v in pairs(dataTable) do
			self.currentData = v;
			local newItem = self.gui_page_3_list_template:clone(self.gui_page_3_list);	
			newItem:updateAbsolutePosition();		
			self.gui_page_3_list:updateItemPositions();
			self.currentData = nil;
		end;		
	end;
end;

function MpManagerSelectionScreen:onCreateList1Text1(element)
	if self.currentData ~= nil then
		element:setText(self.currentData.row1);
	end;
end;

function MpManagerSelectionScreen:onCreateList3Text1(element)
	if self.currentData ~= nil then
		element:setText(self.currentData.row1);
	end;
end;

function MpManagerSelectionScreen:onCreateList3Text2(element)
	if self.currentData ~= nil then
		element:setText(self.currentData.row2);
	end;
end;

function MpManagerSelectionScreen:onCreateList3Text3(element)
	if self.currentData ~= nil then
		element:setText(self.currentData.row3);
	end;
end;