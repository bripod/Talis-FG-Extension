function action(draginfo, sDie, rTalisRoll)
	local rActor = ActorManager.getActor("", window.getDatabaseNode());
	TalisManager.performRoll(draginfo, rActor, sDie, rTalisRoll);
	return true;
end

function getDie()
	local sDie = "d8";
	if getName() == "button_roll_d6" then
		sDie = "d6";
	elseif getName() == "button_roll_d4" then
		sDie = "d4";
	end	
	return sDie;
end
	
function onDragStart(button, x, y, draginfo)
	sDie = getDie();
	return action(draginfo);
end
					
function onButtonPress()
	local rTalisRoll = {};
	if getName() == "button_roll_d8" then
		rTalisRoll.nodeTalis = DB.findNode("Talis_Window.talisCard1");
	elseif getName() == "button_roll_d6" then
		rTalisRoll.nodeTalis = DB.findNode("Talis_Window.talisCard2");
	else
		rTalisRoll.nodeTalis = DB.findNode("Talis_Window.talisCard3");
	end	
	sDie = getDie();
	return action(draginfo, sDie, rTalisRoll);
end