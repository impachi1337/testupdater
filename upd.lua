local requests = require 'requests'

local VERSION = "1.0"
local UPDATE_URL = "https://raw.githubusercontent.com/impachi1337/testupdater/main/update.json"

function main()
    repeat wait(0) until isSampAvailable()

    checkUpdate()

    while true do
        wait(0)
    end
end

function checkUpdate()
    lua_thread.create(function()

        sampAddChatMessage("[Updater] Проверка обновлений...", -1)

        local response = requests.get(UPDATE_URL)

        if not response then
            sampAddChatMessage("[Updater] Нет ответа от сервера", 0xFF0000)
            return
        end

        if response.status_code ~= 200 then
            sampAddChatMessage("[Updater] HTTP "..tostring(response.status_code), 0xFF0000)
            return
        end

        local ok, data = pcall(decodeJson, response.text)

        if not ok or not data then
            sampAddChatMessage("[Updater] Ошибка JSON", 0xFF0000)
            return
        end

        if tostring(data.version) == tostring(VERSION) then
            sampAddChatMessage("[Updater] Последняя версия", 0x00FF00)
            return
        end

        sampAddChatMessage("[Updater] Найдено обновление "..data.version, 0xFFFF00)

        local tempFile = getWorkingDirectory() .. "\\update.tmp"

        downloadUrlToFile(data.url, tempFile,
            function(id, status)

                if status == 3 then
                    sampAddChatMessage("[Updater] Ошибка скачивания", 0xFF0000)
                end

                if status == 6 then
                    local f = io.open(tempFile, "rb")

                    if not f then
                        sampAddChatMessage("[Updater] Файл не скачан", 0xFF0000)
                        return
                    end

                    local content = f:read("*a")
                    f:close()

                    os.remove(tempFile)

                    local script = io.open(thisScript().path, "wb")

                    if not script then
                        sampAddChatMessage("[Updater] Нет доступа к файлу скрипта", 0xFF0000)
                        return
                    end

                    script:write(content)
                    script:close()

                    sampAddChatMessage("[Updater] Обновление установлено", 0x00FF00)

                    wait(1000)
                    thisScript():reload()
                end
            end
        )
    end)
end