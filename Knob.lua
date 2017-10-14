local Credentials = require('Credentials')
local Logging = require('Logging')

local Knob = {}

local MQTT_CLIENT_ID = "iVolume-" .. node.chipid()
local MQTT_KEEPALIVE = 120

local SAMPLING_ALARM_ID = 4
local POT_PIN = 0
local REPORT_THRESHOLD = 0.05

function Knob.connect()
    Knob.mqtt:connect(Credentials.MQTT_SERVER, Credentials.MQTT_PORT, 0, function (client)
        -- Connection success callback
        Logging.log('MQTT', 'Client is connected.')
        Knob.connected = true

        -- Re-publish last reported value upon (re)connections
        if Knob.lastReportedValue ~= nil then
            Knob.publish(Knob.lastReportedValue)
        end
    end, function (client, reason)
        -- Connection failure callback
        Logging.log('MQTT', 'Client failed to connect: ' .. reason)
    end)
end

function Knob.init()
    Knob.mqtt = mqtt.Client(MQTT_CLIENT_ID, MQTT_KEEPALIVE)

    Knob.mqtt:on("offline", function (client)
        Logging.log('MQTT', 'Client is offline. ')
        Knob.connected = false
        Knob.connect()
    end)

    tmr.alarm(SAMPLING_ALARM_ID, 10, tmr.ALARM_AUTO, Knob.sample)

    Knob.connect()
end

local distance = function (a, b)
    return math.min(math.abs(b - a), 1.0 - math.abs(b - a))
end

function Knob.publish(value)
    Knob.lastReportedValue = value
    Logging.log('Knob', 'Volume: ' .. value)

    if Knob.connected then
        Knob.mqtt:publish(Credentials.MQTT_TOPIC_PREFIX .. "/value", value, 0, 0)
    end
end

function Knob.sample()
    local value = adc.read(POT_PIN) / 1024.0

    if Knob.lastReportedValue == nil or distance(value, Knob.lastReportedValue) >= REPORT_THRESHOLD then
        Knob.publish(value)
    end
end

return Knob
