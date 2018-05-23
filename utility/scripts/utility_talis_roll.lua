function action(draginfo)
	local rActor = ActorManager.getActor("", window.getDatabaseNode());
	local bSecretRoll = true;
	ActionTalis.performRoll(draginfo, rActor, bSecretRoll);
	return true;
end

function onDragStart(button, x, y, draginfo)
	return action(draginfo);
end
					
function onButtonPress()
	return action();
end