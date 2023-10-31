# cfdufo.nvim

> just random generate
>
> `Cool Fashion Design UFO` maybe?
>
> The development progress of the plugin depends on time and may be stillborn.

This is a plugin for displaying some float windows. Although there have been plug-ins that have implemented similar functions for a long time, nui needs to be installed. I want to implement it through the API that comes with neovim.

## task

- [x] bufline
- [ ] cmdline

## setup

```lua
-- default
require("cfdufo").setup {
    buffline = {
        -- autocmd, when open two file, buffer change will display
        auto = true,
        -- if cursor on the top line, it will display on second line
        always_top = false,
        -- should filename be short?
        filename_mx = nil,
        keybind = nil,
        -- it's a UFO nerdfont, \u{00a0} makes nerdfont complete
        icon = "󱃅\u{00a0}",
        winblend = 100,
    }
}
```

