function conky_get_updates()
    local file = io.open('/tmp/update_count', 'rb')
    if not file then return '(syncing)' end
    local content = file:read "*a"
    file:close()
    return string.gsub(content, '^%s*(.-)%s*$', '%1')
end