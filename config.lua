-- config.lua
Config = {}

Config.Debug = false

-- nil または空にすると ACE 判定無効　trashcan.adminを使う場合
-- server.cfgにadd_ace group.admin trashcan.admin allowを追加
Config.AdminAces = { 'trashcan.admin' }

Config.TrashBins = {

	{
		id = "pd_bin01",
		label = "警察不用品箱",
		coords = vector3(464.75, -1001.62, 27.94),
		prop = `prop_recyclebin_01a`,
		propHeading = 90.0,
		distance = 2.0,

		-- AddBoxZone （prop未指定時のみ使用）
		-- length = 1.0,
		-- width = 1.0,
		-- heading = 0.0,
		-- minZ = 29.69,
		-- maxZ = 31.69,

		job = "police",
		minGrade = 8,
		-- スタッシュ（ox_inventory）
		slots = 200,
		weight = 1000000
	}
}


