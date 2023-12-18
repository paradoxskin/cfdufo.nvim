local M = {}
local bf_win = nil
local timer = vim.loop.new_timer() local waiter = vim.loop.new_timer()

local opt = {
    bufline = {
        auto = true,
        always_top = false,
        filename_mx = nil,
        keybind = nil,
        icon = "󱃅\u{00a0}",
        winblend = 100,
    },
    fcitx5_support = false
}

local close_win = function()
    if bf_win then
	  vim.api.nvim_win_close(bf_win, true)
	  bf_win = nil
    end
end

local bufline = function()
    if timer:is_active() then
        timer:stop()
    end
    close_win()
    local buflist = vim.api.nvim_list_bufs()
    local bufline = opt.bufline.icon
    local echo = false
    for _, idx in ipairs(buflist) do
	  if vim.api.nvim_buf_get_option(idx, "buflisted") then
		if _ ~= 1 then
		    bufline = bufline .. "|"
                echo = true
		end

            if vim.fn.bufnr("%") == idx then
                bufline = bufline .. "*"
            else
                bufline = bufline .. " "
            end

		local fn = string.match(vim.api.nvim_buf_get_name(idx), "/?([^/]*)$")
            if fn == "" then
                fn = "{}"
            elseif opt.bufline.filename_mx and string.len(fn) > opt.bufline.filename_mx then
		    fn = string.sub(fn, 1, opt.bufline.filename_mx) .. ">"
            end

		bufline = bufline .. fn

		if vim.api.nvim_buf_get_option(idx, "modified") then
		    bufline = bufline .. "+"
            else
		    bufline = bufline .. " "
		end
	  end
    end

    if not echo then
        return
    end

    local pos = 0

    if not opt.bufline.always_top then
        local winid = vim.fn.win_getid()
        if vim.api.nvim_win_get_position(winid)[1] == 0 then
            local winfo = vim.fn.getwininfo(winid)[1]
            if math.max(1, winfo.botline - winfo.height + 1) == vim.fn.line(".") then
                pos = 1
            end
        end
    end

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buffer, "filetype", "bufline")
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {bufline})
    local win = vim.api.nvim_open_win(buffer, false, {
	  relative = "editor",
	  row = pos,
	  col = 0,
	  width = vim.api.nvim_get_option("columns"),
	  height = 1,
	  focusable = false,
	  border = "none",
	  noautocmd = true,
	  zindex = 250
    })

    vim.api.nvim_win_set_option(win, 'number',  false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_win_set_option(win, 'wrap',  false)
    vim.api.nvim_win_set_option(win, 'cursorline',  false)
    vim.api.nvim_win_set_option(win, 'winblend',  opt.bufline.winblend)
    vim.api.nvim_win_set_option(win, 'winhighlight',  'NormalFloat:Normal')
    bf_win = win
    timer:start(2000, 0, vim.schedule_wrap(close_win))
end

function M.setup(user_opt)
    if user_opt then
        opt = vim.tbl_deep_extend("force", opt, user_opt)
    end
    if opt.bufline.auto then
        vim.api.nvim_create_autocmd(
            "BufWinEnter", -- buf enter before cusor move to position from line 1
            {
                pattern = "*",
                callback = function()
                    waiter:start(10, 0,
                        vim.schedule_wrap(function()
                            bufline()
                        end)
                    )
                end
            }
        )
    end
    if opt.bufline.keybind then
        vim.keymap.set('n', opt.bufline.keybind, function()
            bufline()
        end )
    end
    if opt.fcitx5_support then
        local remote = 1
        vim.api.nvim_create_autocmd("InsertEnter", {pattern = "*", callback = function()
            if remote == "2" then
                vim.fn.system("fcitx5-remote -o")
            end
        end})
        vim.api.nvim_create_autocmd("InsertLeave", {pattern = "*", callback = function()
            remote = string.match(vim.fn.system("fcitx5-remote"), "%d")
            if remote == "2" then
                vim.fn.system("fcitx5-remote -c")
            end
        end})
    end
end

return M
