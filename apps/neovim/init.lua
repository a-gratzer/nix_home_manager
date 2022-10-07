local cmd = vim.cmd
local g = vim.g

g.mapleader = " "


-- misc utils
local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= "o" then
        scopes["o"][key] = value
    end
end

local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

opt("w", "number", true)
opt("w", "relativenumber", true)
opt("b", "tabstop", 4)
opt("b", "shiftwidth", 4)
opt("o", "autoindent", true)
opt("o", "mouse", "a")
opt("b", "autoindent", true)
opt("o", "numberwidth", 2)
opt("w", "cursorline", true)
opt("b", "spelllang", "en,de")

vim.cmd('colorscheme darkblue')

require("colorizer").setup()
