function action(draginfo, sDie, rTalisRoll)
	local rActor = ActorManager.getActor("", window.getDatabaseNode());
	TalisManager.performRoll(draginfo, rActor, sDie, rTalisRoll);
	return true;
end

function getDie()
	local sDie = "d8";
	if getName() == "card2_button" then
		sDie = "d6";
	elseif getName() == "card3_button" then
		sDie = "d4";
	end	
	return sDie;
end
	
function onDragStart(button, x, y, draginfo)
	sDie = getDie();
	return action(draginfo);
end
					
function onButtonPress()
	local sTalisUserNode = DB.getPath(window.getDatabaseNode());
	if DB.getValue(sTalisUserNode .. ".folded") == 1 then
		return;	
	end
	local rTalisRoll = {};
	if getName() == "card1_button" then
		rTalisRoll.nodeTalis = DB.findNode(sTalisUserNode .. ".card1_value");
	elseif getName() == "card2_button" then
		rTalisRoll.nodeTalis = DB.findNode(sTalisUserNode .. ".card2_value");
	else
		rTalisRoll.nodeTalis = DB.findNode(sTalisUserNode .. ".card3_value");
	end	
	if (getName() == "card1_button" and DB.getValue("talis.currentround") == 1 or getName() == "card2_button" and DB.getValue("talis.currentround") == 2 or getName() == "card3_button" and DB.getValue("talis.currentround") == 3) then
		sDie = getDie();
		return action(draginfo, sDie, rTalisRoll);
	end
end