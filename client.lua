local isMenuOpen = false
local isSpectating = false
local cam = nil
local targetPed = nil

-- دستور باز کردن منو
RegisterCommand('bodycam', function()
    TriggerServerEvent('bodycam:requestPlayers')
end)

RegisterNetEvent('bodycam:receivePlayers')
AddEventHandler('bodycam:receivePlayers', function(players)
    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "OPEN_MENU",
        players = players
    })
end)

-- بستن منو
RegisterNUICallback('close', function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- شروع اسپک (دیدن دوربین)
RegisterNUICallback('spectate', function(data, cb)
    local targetId = data.targetId
    local targetIdx = GetPlayerFromServerId(targetId)
    
    if targetIdx == -1 or targetIdx == nil then
        -- اگر پلیر در استریم نبود (نزدیک نبود)
        -- نکته: برای دیدن پلیرهای دور باید از روش‌های سمت سرور پیچیده‌تر استفاده کرد
        -- اما این روش برای پلیرهای داخل محدوده کار می‌کند
        print("Player not found in scope") 
        return
    end

    local ped = GetPlayerPed(targetIdx)
    targetPed = ped
    
    -- بستن منو و باز کردن اورلی
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "SHOW_OVERLAY",
        targetName = GetPlayerName(targetIdx)
    })
    
    -- ساخت دوربین
    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end

    -- اتصال دوربین به سینه (Spine3 = 24818)
    AttachCamToPedBone(cam, ped, 24818, 0.0, 0.2, 0.15, 0.0, 0.0, 0.0, true)
    SetCamFov(cam, 90.0) -- زاویه دید عریض مثل گوپرو
    RenderScriptCams(true, false, 0, true, true)
    
    -- افکت تصویری برای واقعی شدن
    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(1.0)
    
    isSpectating = true
    
    -- لوپ برای اطمینان از زنده بودن تارگت
    Citizen.CreateThread(function()
        while isSpectating do
            if not DoesEntityExist(targetPed) then
                StopSpectating()
            end
            
            -- چرخش دوربین همراه با بدن بازیکن
            local rot = GetEntityRotation(targetPed, 2)
            SetCamRot(cam, rot.x, rot.y, rot.z, 2)
            
            -- خروج با Backspace
            if IsControlJustPressed(0, 177) then -- Backspace / ESC
                StopSpectating()
            end
            Citizen.Wait(0)
        end
    end)
    
    cb('ok')
end)

RegisterNUICallback('stopSpectate', function(data, cb)
    StopSpectating()
    cb('ok')
end)

function StopSpectating()
    isSpectating = false
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
    cam = nil
    targetPed = nil
    ClearTimecycleModifier()
    
    SendNUIMessage({
        type = "HIDE_OVERLAY"
    })
    
    -- باز کردن مجدد منو
    TriggerServerEvent('bodycam:requestPlayers')
end
