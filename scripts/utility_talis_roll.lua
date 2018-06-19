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
--	local talisUserNode = window.getDatabaseNode();
	local sTalisUserNode = DB.getPath(window.getDatabaseNode());
--	Debug.chat("sTalisUserNode: ",sTalisUserNode);
--	Debug.chat("talisUserNode: ",talisUserNode);
	local rTalisRoll = {};
	if getName() == "card1_button" then
		rTalisRoll.nodeTalis = DB.findNode(sTalisUserNode .. ".card1_value");
		Debug.chat(rTalisRoll);
	elseif getName() == "card2_button" then
		rTalisRoll.nodeTalis = DB.findNode(sTalisUserNode .. ".card2_value");
	else
		rTalisRoll.nodeTalis = DB.findNode(sTalisUserNode .. ".card3_value");
	end	
	sDie = getDie();
	return action(draginfo, sDie, rTalisRoll);
end