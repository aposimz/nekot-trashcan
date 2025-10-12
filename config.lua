-- config.lua
Config = {}

Config.Debug = false

-- nil または空にすると ACE 判定無効　trashcan.admin
Config.AdminAces = { 'trashcan.admin' }

Config.TrashBins = {
	-- {
	-- 	id = "pd_bin0",
	-- 	label = "PD不用品ゴミ箱",
	-- 	coords = vector3(421.17, -1002.81, 29.15),
	-- 	prop = `prop_recyclebin_04_b`,
	-- 	propHeading = 180.0,
    --     -- ターゲット
	-- 	length = 1.0,
	-- 	width = 1.0,
	-- 	heading = 0.0,
	-- 	minZ = 29.69,
	-- 	maxZ = 31.69,
	-- 	distance = 2.0,
	-- 	job = "police",
	-- 	minGrade = 3,
	-- 	-- スタッシュ（ox_inventory）
	-- 	slots = 200,
	-- 	weight = 1000000
	-- },
	{
		id = "pd_bin01",
		label = "警察不用品箱",
		coords = vector3(413.5, -1001.98, 29.47),
		prop = `prop_recyclebin_01a`,
		propHeading = 90.0,
        -- ターゲット
		length = 1.0,
		width = 1.0,
		heading = 0.0,
		minZ = 29.69,
		maxZ = 31.69,
		distance = 2.0,
		job = "police",
		minGrade = 8,
		-- スタッシュ（ox_inventory）
		slots = 200,
		weight = 1000000
	}
}


