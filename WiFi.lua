local Credentials = require('Credentials')
local Logging = require('Logging')

local WiFi = {}

local WIFI_ALARM_ID = 5

WiFi.ready = false

function WiFi.configure()
    Logging.log('WiFi', 'Connecting/reconnecting...')

    WiFi.ready = false

    wifi.setmode(wifi.STATION)
    wifi.sta.config(Credentials.WIFI_CONFIG)
    wifi.sta.connect()
end

function WiFi.watch()
    local status = wifi.sta.status()

    if status == wifi.STA_CONNECTING then
        Logging.log('WiFi', 'Still connecting...')
    elseif status == wifi.STA_GOTIP then
        if not WiFi.ready then
            WiFi.ready = true
            Logging.log('WiFi', 'Connected. IP is: ' .. wifi.sta.getip())
        end
    else
        Logging.log('WiFi', 'Reconnecting on WiFi status: ' .. status)
        WiFi.configure()
    end
end

function WiFi.init()
    Logging.log('WiFi', 'Initializing...')

    tmr.alarm(WIFI_ALARM_ID, 500, tmr.ALARM_AUTO, WiFi.watch)
end

return WiFi
