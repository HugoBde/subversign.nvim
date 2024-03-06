M = {}

--- @todo figure out a good prio, maybe make configurable
local signs_priority = 100

--- @enum HunkType
local HunkType = {
    ADD = "a",
    CHANGE = "c",
    DELETE = "d"
}

--- Executes a diff on the current buffer
--- @return string | nil diff output of the diff command or nothing if an error occured
local function run_diff()
    local buf_nr = vim.api.nvim_get_current_buf()
    local file_name = vim.api.nvim_buf_get_name(buf_nr)
    local ok, output = pcall(vim.fn.system, { "svn", "diff", "--diff-cmd=diff", "-x", "--normal", file_name })
    if (ok) then
        return output
    else
        return nil
    end
end


--- Display a add hunk
--- @param buf_nr integer
--- @param start_line integer
--- @param end_line integer
local function add_hunk_display(buf_nr, start_line, end_line)
    if (not end_line) then
        vim.fn.sign_place(0, nil, "SubversignsAdd", buf_nr, { lnum = start_line, priority = 100 })
    else
        for i = start_line, end_line, 1 do
            vim.fn.sign_place(0, nil, "SubversignsAdd", buf_nr, { lnum = i, priority = 100 })
        end
    end
end

--- Display a change hunk
--- @param buf_nr integer
--- @param start_line integer
--- @param end_line integer
local function change_hunk_display(buf_nr, start_line, end_line)
    if (not end_line) then
        vim.fn.sign_place(0, nil, "SubversignsChange", buf_nr, { lnum = start_line, priority = 100 })
    else
        for i = start_line, end_line, 1 do
            vim.fn.sign_place(0, nil, "SubversignsChange", buf_nr, { lnum = i, priority = 100 })
        end
    end
end

--- Display a delete hunk
--- @param buf_nr integer
--- @param line integer
local function delete_hunk_display(buf_nr, line)
    vim.fn.sign_place(0, nil, "SubversignsDelete", buf_nr, { lnum = line, priority = 100 })
end

--- Setup Subversigns
function M.setup()
    -- Define signs
    vim.fn.sign_define("SubversignsAdd",
        {
            text = "┃",
            texthl = "GitSignsAdd"
        })

    vim.fn.sign_define("SubversignsDelete",
        {
            text = "▁",
            texthl = "GitSignsDelete"
        })

    vim.fn.sign_define("SubversignsChange",
        {
            text = "┃",
            texthl = "GitSignsChange"
        })

    -- Create user command to init Subversigns in current buffer
    vim.api.nvim_create_user_command("SubversignsInit", M.subversign_my_buffer, { desc = "Init Subversigns in buffer" })

    -- Setup autocmd to execute SubversignsInit when opening a new file
    vim.api.nvim_create_autocmd("BufRead", { command = "SubversignsInit" })
end

--- Set signs for a buffer
function M.subversign_my_buffer()
    local buf_nr = vim.api.nvim_get_current_buf()

    -- clear existing signs
    vim.fn.sign_unplace("Subversigns", { buffer = buf_nr })

    -- run diff
    local diff = run_diff()

    if (not diff) then
        return
    end

    -- for each all hunks, apply signs
    for line in vim.gsplit(diff, "\n") do
        local hunk_type, start_line, end_line = string.match(line, "%d+,?%d*(.)(%d+),?(%d*)")

        if (not hunk_type) then
            goto continue
        end

        start_line = tonumber(start_line, 10)
        end_line = tonumber(end_line, 10)

        if (hunk_type == "a") then
            add_hunk_display(buf_nr, start_line, end_line)
        elseif (hunk_type == "c") then
            change_hunk_display(buf_nr, start_line, end_line)
        elseif (hunk_type == "d") then
            delete_hunk_display(buf_nr, start_line)
        else
            vim.notify("Invalid hunk type: " .. line, vim.log.levels.ERROR)
        end

        ::continue::
    end
end

return M
