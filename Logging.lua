local Logging = {}

function Logging.log(tag, message)
    print("[" .. tag .. "] " .. message)
end

return Logging
