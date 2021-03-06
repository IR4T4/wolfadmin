
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- at your option any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local commands = require (wolfa_getLuaPath()..".commands.commands")

local util = require (wolfa_getLuaPath()..".util.util")

function commandClientCPM(command, clientId, text)
    local clientId = tonumber(clientId)

    if clientId and clientId ~= -1337 then -- -1337 because -1 is a magic number/broadcasted to all clients
        et.trap_SendServerCommand(clientId, "cpm \""..text.."\";")
    elseif clientId then
        et.G_Print(util.removeColors(text).."\n")
    end

    return true
end
commands.addserver("ccpm", commandClientCPM)
