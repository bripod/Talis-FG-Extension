function action(draginfo,sDie)
	local rActor = ActorManager.getActor("", window.getDatabaseNode());
	ActionTalis.performRoll(draginfo, rActor, sDie);
	return true;
end

function getDie()
	local sDie = "d8";
	if self.getName() == "button_roll_d6" then
		sDie = "d6";
	elseif self.getName() == "button_roll_d4" then
		sDie = "d4";
	end	
	return sDie;
end
	
function onDragStart(button, x, y, draginfo)
	sDie = getDie();
	return action(draginfo);
end
					
function onButtonPress()
	sDie = getDie();
	return action(draginfo, sDie);
end