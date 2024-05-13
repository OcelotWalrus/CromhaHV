--[[
   Copyright 2021-2023 The OpenHV Developers (see AUTHORS)
   This file is part of OpenHV, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

ReinforcementUnits = { "scout1", "scout1", "scout1", "scout2", "scout2", "tank3", "tank1", "tank15" }

Reminder = UserInterface.Translate("reminder")

Tick = function()

	if Enemy.HasNoRequiredUnits() then
		Human.MarkCompletedObjective(EnemyEliminatedObjective)
	end

    if DateTime.GameTime > DateTime.Seconds(90) and Random({0, 1, 2}) > 1 then  -- 33% chance of Synapol reinforcement, if the game is late of at least 1.5 mins
        SynapolReinforcements = Reinforcements.Reinforce(Enemy, ReinforcementUnits, { SpawningWaypoint.Location, DestinationWaypoint.Location })
        Media.DisplayMessage(UserInterface.Translate("reinforcements-incoming"), Reminder)
    end

    if DateTime.GameTime % DateTime.Seconds(1) == 0 and not Human.IsObjectiveCompleted(ResourcesClaimedObjective) and Human.GetActorsByType("miner2") == 17 then -- if the player has built every mining tower
        Human.MarkCompletedObjective(ResourcesClaimedObjective)
    end

end

WorldLoaded = function()
	Human = Player.GetPlayer("Yuruki Industries")
	Enemy = Player.GetPlayer("Synapol Corporation")

	InitObjectives(Human)

	EnemyEliminatedObjective = AddPrimaryObjective(Human, "claim-land")
    ResourcesClaimedObjective = AddPrimaryObjective(Human, "build-all-towers")

	Camera.Position = Base.CenterPosition
end
