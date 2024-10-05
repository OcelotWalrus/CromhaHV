--[[
   Copyright 2021-2023 The OpeHV Developers (see CREDITS)
   This file is part of OpenHV, which is free software. It is made
   available to you under the terms of the GNU General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version. For more
   information, see COPYING.
]]

LightTrees = function ()
	if Difficulty ~= "easy" then  -- only when the difficulty is higher than easy
		Forest.Hit(CPos.New(52, 12), 30000)
		Forest.Hit(CPos.New(54, 11), 30000)
		Forest.Hit(CPos.New(54, 15), 30000)

		Forest.Hit(CPos.New(12, 44), 30000)
		Forest.Hit(CPos.New(13, 44), 30000)
		Forest.Hit(CPos.New(14, 44), 30000)
		Forest.Hit(CPos.New(12, 45), 30000)
		Forest.Hit(CPos.New(13, 45), 30000)
		Forest.Hit(CPos.New(14, 45), 30000)
		Forest.Hit(CPos.New(12, 46), 30000)
		Forest.Hit(CPos.New(13, 46), 30000)
		Forest.Hit(CPos.New(14, 46), 30000)

		Forest.Hit(CPos.New(26, 54), 30000)
		Forest.Hit(CPos.New(26, 55), 30000)
		Forest.Hit(CPos.New(27, 54), 30000)
		Forest.Hit(CPos.New(27, 55), 30000)
	end

	if Difficulty == "hard" then  -- only if the difficulty is set to hard
		Forest.Hit(CPos.New(56, 18), 30000)
		Forest.Hit(CPos.New(56, 17), 30000)
		Forest.Hit(CPos.New(55, 18), 30000)

		Forest.Hit(CPos.New(17, 51), 30000)
		Forest.Hit(CPos.New(17, 52), 30000)
		Forest.Hit(CPos.New(18, 51), 30000)
		Forest.Hit(CPos.New(18, 53), 30000)
		Forest.Hit(CPos.New(7, 46), 30000)
		Forest.Hit(CPos.New(8, 45), 30000)
		Forest.Hit(CPos.New(8, 44), 30000)

		Forest.Hit(CPos.New(45, 42), 30000)
		Forest.Hit(CPos.New(45, 44), 30000)
		Forest.Hit(CPos.New(51, 51), 30000)
	end

	Forest.Hit(CPos.New(18, 15), 30000)
	Forest.Hit(CPos.New(19, 15), 30000)
	Forest.Hit(CPos.New(20, 13), 30000)
	Forest.Hit(CPos.New(18, 18), 30000)
	Forest.Hit(CPos.New(19, 18), 30000)

	Forest.Hit(CPos.New(48, 11), 30000)
	Forest.Hit(CPos.New(48, 12), 30000)
	Forest.Hit(CPos.New(50, 14), 30000)

	Forest.Hit(CPos.New(54, 35), 30000)
	Forest.Hit(CPos.New(56, 34), 30000)

	Forest.Hit(CPos.New(56, 56), 30000)
	Forest.Hit(CPos.New(55, 55), 30000)
	Forest.Hit(CPos.New(53, 52), 30000)
	Forest.Hit(CPos.New(52, 51), 30000)
	Forest.Hit(CPos.New(43, 49), 30000)
	Forest.Hit(CPos.New(38, 52), 30000)
	Forest.Hit(CPos.New(40, 55), 30000)

	Forest.Hit(CPos.New(18, 38), 30000)
	Forest.Hit(CPos.New(13, 40), 30000)
	Forest.Hit(CPos.New(16, 41), 30000)

	Forest.Hit(CPos.New(45, 53), 30000)
	Forest.Hit(CPos.New(46, 53), 30000)
	Forest.Hit(CPos.New(47, 53), 30000)

	Forest.Hit(CPos.New(30, 20), 30000)
	Forest.Hit(CPos.New(30, 21), 30000)
	Forest.Hit(CPos.New(31, 20), 30000)
	Forest.Hit(CPos.New(31, 21), 30000)
end


Tick = function()
	if DateTime.GameTime > 5 then
		UpdateForestStatus()
	end
end

WorldLoaded = function()
	LightTrees()

	Human = Player.GetPlayer("FireBrigade")
	InitObjectives(Human)
	ForestObjective = AddPrimaryObjective(Human, "save-the-forests")
	FivePercentObjective = AddSecondaryObjective(Human, "save-95-percent")
	TenPercentObjective = AddSecondaryObjective(Human, "save-90-percent")
	FifteenPercentObjective = AddSecondaryObjective(Human, "save-85-percent")
	TwentyPercentObjective = AddSecondaryObjective(Human, "save-80-percent")
	TwentyFivePercentObjective = AddSecondaryObjective(Human, "save-75-percent")
	ThirtyPercentObjective = AddSecondaryObjective(Human, "save-70-percent")
end

CachedburnedPercentage = -1
UpdateForestStatus = function()
	local burnedPercentage = (1 - Forest.TreesLeft / Forest.TotalTrees) * 100
	if CachedburnedPercentage == burnedPercentage and Forest.TreesBurning > 0 then
		return
	end
	CachedburnedPercentage = burnedPercentage

	local currentColor = HSLColor.White
	if burnedPercentage > 30 then
		currentColor = HSLColor.DarkRed
		Human.MarkFailedObjective(ThirtyPercentObjective)
	elseif burnedPercentage > 25 then
		currentColor = HSLColor.Red
		Human.MarkFailedObjective(TwentyFivePercentObjective)
	elseif burnedPercentage > 20 then
		currentColor = HSLColor.OrangeRed
		Human.MarkFailedObjective(TwentyPercentObjective)
	elseif burnedPercentage > 15 then
		currentColor = HSLColor.DarkOrange
		Human.MarkFailedObjective(FifteenPercentObjective)
	elseif burnedPercentage > 10 then
		currentColor = HSLColor.Orange
		Human.MarkFailedObjective(TenPercentObjective)
	elseif burnedPercentage > 5 then
		currentColor = HSLColor.Yellow
		Human.MarkFailedObjective(FivePercentObjective)
	end

	local text = UserInterface.Translate("forest-destroyed", { ["percentage"] = math.floor(burnedPercentage) })
	UserInterface.SetMissionText(text, currentColor)

	if Forest.TreesLeft < 1 then
		Human.MarkFailedObjective(ForestObjective)
	end

	if Forest.TreesBurning == 0 then
		Human.MarkCompletedObjective(ForestObjective)
		if burnedPercentage < 30 then
			Human.MarkCompletedObjective(ThirtyPercentObjective)
		end
		if burnedPercentage < 25 then
			Human.MarkCompletedObjective(TwentyFivePercentObjective)
		end
		if burnedPercentage < 20 then
			Human.MarkCompletedObjective(TwentyPercentObjective)
		end
		if burnedPercentage < 15 then
			Human.MarkCompletedObjective(FifteenPercentObjective)
		end
		if burnedPercentage < 10 then
			Human.MarkCompletedObjective(TenPercentObjective)
		end
		if burnedPercentage < 5 then
			Human.MarkCompletedObjective(FivePercentObjective)
		end
	end
end
