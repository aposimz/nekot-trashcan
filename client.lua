local QBCore = exports['qb-core']:GetCoreObject()

local function debugPrint(...)
	if Config and Config.Debug then
		print('[nekot-trashcan][client]', ...)
	end
end

local SpawnedTrashProps = {}
local CreatedZones = {}

local function cleanupProps()
	for id, ent in pairs(SpawnedTrashProps) do
		if ent and DoesEntityExist(ent) then
			pcall(function()
				exports['qb-target']:RemoveTargetEntity(ent)
			end)
			DeleteObject(ent)
		end
		SpawnedTrashProps[id] = nil
	end
end

local function cleanupZones()
	for zoneId, _ in pairs(CreatedZones) do
		pcall(function()
			exports['qb-target']:RemoveZone(zoneId)
		end)
		CreatedZones[zoneId] = nil
	end
end

AddEventHandler('onResourceStop', function(res)
	if res ~= GetCurrentResourceName() then return end
	cleanupProps()
    cleanupZones()
end)

local function deleteExistingPropsNear(bin)
    if not bin.prop then return end
    local modelHash = (type(bin.prop) == 'string') and joaat(bin.prop) or bin.prop
    local tries = 0
    while tries < 5 do
        local obj = GetClosestObjectOfType(bin.coords.x, bin.coords.y, bin.coords.z, 1.5, modelHash, false, false, false)
        if obj ~= 0 and DoesEntityExist(obj) then
            DeleteObject(obj)
            tries = tries + 1
            Wait(0)
        else
            break
        end
    end
end

local function registerZones()
    cleanupProps()
    cleanupZones()
    for _, bin in ipairs(Config.TrashBins) do
        if bin.prop then
            deleteExistingPropsNear(bin)
            local modelHash = (type(bin.prop) == 'string') and joaat(bin.prop) or bin.prop
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do Wait(0) end
            local obj = CreateObject(modelHash, bin.coords.x, bin.coords.y, bin.coords.z - 1.0, false, false, false)
            if DoesEntityExist(obj) then
                SetEntityHeading(obj, (bin.propHeading ~= nil) and bin.propHeading or (bin.heading or 0.0))
                FreezeEntityPosition(obj, true)
                SetEntityInvincible(obj, true)
                SpawnedTrashProps[bin.id] = obj
                exports['qb-target']:AddTargetEntity(obj, {
                    options = {
                        {
                            type = 'server',
                            event = 'trash:clear',
                            icon = 'fa-solid fa-trash',
                            label = '削除',
                            id = bin.id
                        },
                        {
                            type = 'server',
                            event = 'trash:requestOpen',
                            icon = 'fa-solid fa-box',
                            label = '開く',
                            id = bin.id
                        }
                    },
                    distance = bin.distance or 2.0
                })
            end
        else
            -- プロップ未指定時はボックスゾーン
            pcall(function()
                exports['qb-target']:RemoveZone(bin.id)
            end)
            exports['qb-target']:AddBoxZone(
                bin.id,
                bin.coords,
                bin.length or 1.0,
                bin.width or 1.0,
                {
                    name = bin.id,
                    heading = bin.heading or 0.0,
                    debugPoly = Config.Debug or false,
                    minZ = bin.minZ or (bin.coords.z - 1.0),
                    maxZ = bin.maxZ or (bin.coords.z + 1.0)
                },
                {
                    options = {
                        {
                            type = 'server',
                            event = 'trash:clear',
                            icon = 'fa-solid fa-trash',
                            label = '削除',
                            id = bin.id
                        },
                        {
                            type = 'server',
                            event = 'trash:requestOpen',
                            icon = 'fa-solid fa-box',
                            label = '開く',
                            id = bin.id
                        }
                    },
                    distance = bin.distance or 2.0
                }
            )
            CreatedZones[bin.id] = true
        end
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', registerZones)
CreateThread(function()
	registerZones()
end)

RegisterNetEvent('trash:_open', function(data)
	local binId = data and data.id
	if not binId then return end
	debugPrint('opening stash', binId)
	exports.ox_inventory:openInventory('stash', { id = binId })
end)
