
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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local history = require (wolfa_getLuaPath()..".admin.history")
local mutes = require (wolfa_getLuaPath()..".admin.mutes")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local util = require (wolfa_getLuaPath()..".util.util")
local settings = require (wolfa_getLuaPath()..".util.settings")

function commandMute(clientId, command, victim, ...)
    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dmute usage: "..commands.getadmin("mute")["syntax"].."\";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dmute: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dmute: ^9no connected player by that name or slot #\";")

        return true
    end

    local args = {...}
    local duration, reason

    if args[1] and util.getTimeFromString(args[1]) and args[2] then
        duration = util.getTimeFromString(args[1])
        reason = table.concat(args, " ", 2)
    elseif args[1] and util.getTimeFromString(args[1]) then
        duration = util.getTimeFromString(args[1])
        reason = "muted by admin"
    elseif args[1] then
        duration = 600
        reason = table.concat(args, " ")
    elseif not auth.isPlayerAllowed(clientId, "8") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dmute usage: "..commands.getadmin("mute")["syntax"].."\";")

        return true
    end

    if players.isMuted(cmdClient) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is already muted.\";")

        return true
    elseif auth.isPlayerAllowed(cmdClient, "!") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")

        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dmute: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    end

    mutes.add(cmdClient, clientId, players.MUTE_CHAT + players.MUTE_VOICE, duration, reason)
    history.add(cmdClient, clientId, "mute", reason)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dmute: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9has been muted for "..duration.." seconds\";")

    return true
end
commands.addadmin("mute", commandMute, auth.PERM_MUTE, "mutes a player (text and voice chat)", "^9[^3name|slot#^9]", nil, (settings.get("g_standalone") == 0))
