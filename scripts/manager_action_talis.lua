---
--- Initialization
---

function onInit()
	GameSystem.actions["talisRoll"] = { };
	ActionsManager.registerResultHandler("talisRoll", onRoll);
end

function processRoll(sCommand, sParams)
	performRoll(draginfo, rActor);
end

function getRoll(rActor, sDie, rTalisRoll)
	local rRoll = {};
	rRoll.sType = "talisRoll";
	rRoll.aDice = { sDie };
	rRoll.sDesc = "Talis!";
	-- bSecret is for GM rolls, bTower is for player rolls, but neither of them work (die is still visible)
	--rRoll.bSecret = true;
	rRoll.bTower = true;
	rRoll.sNodeTalis = rTalisRoll.nodeTalis.getNodeName();
	return rRoll;
end


-- Start the action process
function performRoll(draginfo, rActor, sDie, rTalisRoll)
	local rRoll = getRoll(rActor, sDie, rTalisRoll);
	ActionsManager.performAction(draginfo, rActor, rRoll);	
end


function onRoll(rSource, rTarget, rRoll)
	-- update the current card value
	local sNodeTalis = rRoll.sNodeTalis;
	local talis_result = rRoll.aDice[1].result;
	DB.setValue(sNodeTalis,"number",talis_result);
	-- update the total hand value
	local sTalisUser = DB.getParent(sNodeTalis).getPath();
	local nHandTotal = DB.getValue(sTalisUser .. ".card1_value") + DB.getValue(sTalisUser .. ".card2_value") + DB.getValue(sTalisUser .. ".card3_value");
	DB.setValue(sTalisUser .. ".hand_total","number",nHandTotal);
end