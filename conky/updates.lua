---@diagnostic disable: lowercase-global

-- commands
_checkupdates = "/usr/bin/checkupdates"
_auracle = "/usr/bin/auracle outdated";

-- ts, count (indexed 1, 2)
_store = {
    [_checkupdates] = { 0, nil },
    [_auracle] = { 0, nil }
}

-- public
function conky_pacman(interval)
    _exec(interval, _checkupdates, 0, 2)
    return _store[_checkupdates][2] or "reading"
end

function conky_aur(interval)
    _exec(interval, _auracle, 0, 1)
    return _store[_auracle][2] or "reading"
end

-- private
function _exec(interval, command, sc1, sc2)
    if (_store[command][1] + interval < os.time())
    then
        local handle = io.popen(command.." 2>&1")
        local stdout = handle:read("*a")
        local rc = { handle:close() }
        local code = rc[3]
        io.write(command, " exited with ", code, "\n")
        if (code == sc1 or (code == sc2 and stdout == ''))
        then
            _store[command][1] = os.time()
            _store[command][2] = select(2, stdout:gsub('\n', '\n'))
        else
            local retry = 60
            io.write("Retrying in ", retry, "s\n")
            _store[command][1] = os.time() - interval + retry
        end
    end
end

-- notes:
-- auracle returns 1 when check is successful and no packages are upgradable, with empty stdout + stderr
-- auracle also returns 1 when check failed, with non-empty stdout+stderr
-- so if return code is non-zero, stdour+stderr should be empty, otherwise it should be handles as a failure
