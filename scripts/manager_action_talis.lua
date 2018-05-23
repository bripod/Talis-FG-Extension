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
	performRoll(draginfo, rActor, bSecretRoll);
end

function getRoll(rActor, bSecretRoll)
--	local bTest = DB;
--	Debug.chat(bTest);
	local rRoll = {};
	rRoll.sType = "talisRoll";
	rRoll.aDice = { "d8" };
	rRoll.sDesc = "Talis!";
	rRoll.bSecret = bSecretRoll;
	return rRoll;
end

-- Start the action process
function performRoll(draginfo, rActor, bSecretRoll)
	local rRoll = getRoll(rActor, bSecretRoll);
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