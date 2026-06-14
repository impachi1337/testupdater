local requests = require 'requests'
local version = "1.0"

local json_url = "https://raw.githubusercontent.com/impachi1337/testupdater/refs/heads/main/update.json"

function main()
    repeat wait(0) until isSampAvailable()

    checkUpdate()

    while true do
        wait(0)
    end
end

function checkUpdate()
    lua_thread.create(function()
        local r = requests.get(json_url)

        if r.status_code == 200 then
            local data = decodeJson(r.text)

            if data.version ~= version then
                sampAddChatMessage("[Updater] New: " .. data.version, -1)
                sampAddChatMessage("[Updater] " .. data.changelog, -1)

                requests.get(data.url, function(res)
                    local f = io.open(thisScript().path, "wb")
                    f:write(res.text)
                    f:close()

                    thisScript():reload()
                end)
            else
                sampAddChatMessage("[Updater] OK", -1)
            end
        end
    end)
end