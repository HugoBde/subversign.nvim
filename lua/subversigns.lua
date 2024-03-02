M = {
    highlight_name = "SubversignsSimpleHl",
    lines = {}
}

---@type string

--- Setup Subversigns
function M.setup()
    vim.print("M setup!")
    M.ns = vim.api.nvim_create_namespace("Subversigns")
    vim.api.nvim_set_hl(M.ns,
        M.highlight_name,
        {
            fg = "#FF00FF"
        })

    vim.fn.sign_define("SubversignsSimpleSign",
        {
            text = "│",
            texthl = M.highlight_name
        })

    vim.api.nvim_create_user_command("SubversignsToggle", M.toggle_sign, { desc = "toggle subversigns sign" })

    vim.keymap.set("n", "<leader>ls", "<cmd>SubversignsToggle<CR>", { desc = "toggle sign" })
end

--- Set a sign
function M.toggle_sign()
    local win_nr = vim.api.nvim_get_current_win()
    local buf_nr = vim.api.nvim_win_get_buf(win_nr)

    local lnum = unpack(vim.api.nvim_win_get_cursor(win_nr), 1, 1)


    if M.lines[tostring(lnum)] then
        vim.print("removing sign on line " .. tostring(lnum));
        vim.fn.sign_unplace("Subversigns", { lnum = lnum, id = lnum, buffer = buf_nr })
        M.lines[tostring(lnum)] = false
    else
        vim.print("Setting sign on line " .. tostring(lnum));
        vim.fn.sign_place(lnum,
            "Subversigns",
            "SubversignsSimpleSign",
            buf_nr,
            {
                lnum = lnum,
                priority = 10

            })
        M.lines[tostring(lnum)] = true
    end
end

return M
