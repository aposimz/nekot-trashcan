local QBCore = exports['qb-core']:GetCoreObject()

local function debugPrint(...)
	if Config and Config.Debug then
		print('[nekot-trashcan][server]', ...)
	end
end

local function findBinById(binId)
	for _, b in ipairs(Config.TrashBins) do
		if b.id == binId then return b end
	end
	return nil
end

local function hasAccess(src, bin, player)
    if not bin then return false, 'notfound' end
    -- ACE名確認（Config.AdminAces が空/無効ならスキップ）
    if Config.AdminAces and type(Config.AdminAces) == 'table' then
        for _, ace in ipairs(Config.AdminAces) do
            if ace and IsPlayerAceAllowed(src, ace) then
                return true, 'ace_admin'
            end
        end
    end
    -- job/gradeチェック
    if bin.job and player and player.PlayerData and player.PlayerData.job then
        if player.PlayerData.job.name ~= bin.job then
            return false, 'wrongjob'
        end
        if bin.minGrade and (player.PlayerData.job.grade and player.PlayerData.job.grade.level or 0) < bin.minGrade then
            return false, 'lowgrade'
        end
    end
    return true
end

AddEventHandler('onResourceStart', function(res)
	if res ~= GetCurrentResourceName() then return end
	debugPrint('resource starting, registering stashes')
	for _, bin in ipairs(Config.TrashBins) do
		-- ox_inventory 側のグループ制限は使用しない
		local ok, err = pcall(function()
			exports.ox_inventory:RegisterStash(
				bin.id,
				bin.label or bin.id,
				bin.slots or 50,
				bin.weight or 400000,
				false,
				groups,
				bin.coords
			)
		end)
		if not ok then
			print(('[nekot-trashcan][server] RegisterStash failed for %s: %s'):format(bin.id, err))
		end
	end
end)

RegisterNetEvent('trash:requestOpen', function(data)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local binId = data and data.id
	local bin = findBinById(binId)
	local ok, reason = hasAccess(src, bin, player)
	if not ok then
		local msg = 'アクセスできません'
		if reason == 'noadmin' then msg = '権限がありません' end
		if reason == 'wrongjob' then msg = 'このゴミ箱は使えません' end
		if reason == 'lowgrade' then msg = 'ランクが足りません' end
		TriggerClientEvent('QBCore:Notify', src, msg, 'error')
		return
	end
	debugPrint(('open approved for %s by %s'):format(binId, GetPlayerName(src)))
	TriggerClientEvent('trash:_open', src, { id = binId })
end)

RegisterNetEvent("trash:clear", function(data)
	local src = source
	local player = QBCore.Functions.GetPlayer(src)
	local binId = data and data.id
	local bin = findBinById(binId)
	if not bin then return end

	local ok, reason = hasAccess(src, bin, player)
	if not ok then
		local msg = 'アクセスできません'
		if reason == 'noadmin' then msg = '権限がありません' end
		if reason == 'wrongjob' then msg = 'このゴミ箱は使えません' end
		if reason == 'lowgrade' then msg = 'ランクが足りません' end
		TriggerClientEvent("QBCore:Notify", src, msg, "error")
		return
	end

	local cleared = false
	local ok1, err1 = pcall(function()
		exports.ox_inventory:ClearInventory(binId)
	end)
	if ok1 then
		cleared = true
	else
		local ok2, err2 = pcall(function()
			exports.ox_inventory:ClearInventory('stash', binId)
		end)
		if ok2 then
			cleared = true
		else
			print(('[nekot-trashcan][server] ClearInventory failed for %s: %s | %s'):format(binId, tostring(err1), tostring(err2)))
		end
	end

	if cleared then
		TriggerClientEvent("QBCore:Notify", src, "ゴミ箱を空にしました", "success")
	end
end)
