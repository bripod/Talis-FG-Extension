---
--- Initialization
---

function onInit()
	GameSystem.actions["talisRoll"] = { };
	ActionsManager.registerResultHandler("talisRoll", onRoll);
	
	-- Used for testing - register a chat window slash handler to start the action
	Comm.registerSlashHandler("talisRoll", processRoll);
end

function processRoll(sCommand, sParams)
	performRoll(draginfo, rActor);
end

function getRoll(rActor, sDie)
--	local bTest = DB;
--	Debug.chat(bTest);
	local rRoll = {};
	rRoll.sType = "talisRoll";
	rRoll.aDice = { sDie };
	rRoll.sDesc = "Talis!";
	rRoll.bSecret = true;
	return rRoll;
end

-- Start the action process
function performRoll(draginfo, rActor, sDie)
	local rRoll = getRoll(rActor, sDie);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function onRoll(rSource, rTarget, rRoll)
--	local sTest = databasecontrol.getDatabaseNode();
--	Debug.chat(sTest);	
--	Debug.console(rRoll);
--	Debug.console(rRoll.aDice[1].result);
--	talis_d8_result = rRoll.aDice[1].result;
--	Debug.console('talis_d8_result: ');
--	Debug.console(talis_d8_result);
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);
end