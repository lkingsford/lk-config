-- Plugins
require("config.lazy")


-- Mason Setup
require("mason").setup({
})
require("mason-lspconfig").setup()


local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

-- LSP Diagnostics Options Setup 
local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

--sign({name = 'DiagnosticSignError', text = ''})
--sign({name = 'DiagnosticSignWarn', text = ''})
--sign({name = 'DiagnosticSignHint', text = ''})
--sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Completion Plugin Setup
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})

local dap = require('dap')
dap.adapters.codelldb = {
  type = "executable",
  command = "codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"

  -- On windows you may have to uncomment this:
  -- detached = false,
}

require("nvim-dap-projects").search_project_config()

-- Debugging keys
local dap = require('dap')

vim.keymap.set('n', '<F5>', function()
  dap.continue()
end, { desc = 'Start/Continue Debugging' })

vim.keymap.set('n', '<F10>', function()
  dap.step_over()
end, { desc = 'Step Over' })

vim.keymap.set('n', '<F11>', function()
  dap.step_into()
end, { desc = 'Step Into' })

vim.keymap.set('n', '<F12>', function()
  dap.step_out()
end, { desc = 'Step Out' })

vim.keymap.set('n', '<leader>b', function()
  dap.toggle_breakpoint()
end, { desc = 'Toggle Breakpoint' })

vim.keymap.set('n', '<leader>B', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Set Conditional Breakpoint' })

vim.keymap.set('n', '<leader>dr', function()
  dap.repl.open()
end, { desc = 'Open Debug Console' })

vim.keymap.set('n', '<leader>dl', function()
  dap.run_last()
end, { desc = 'Run Last Debug Session' })

-- Replacement codium keys (due to clashes)
vim.g.codeium_disable_bindings = 1
vim.keymap.set("i", "<C-CR>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
vim.keymap.set("i", "<M-]>", function() return vim.fn end, { expr = true, silent = true })
vim.keymap.set("i", "<M-[>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, silent = true })
vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true })


-- Format on save (courtesy of https://www.mitchellhanberg.com/modern-format-on-save-in-neovim/)
-- 1
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    -- 2
    vim.api.nvim_create_autocmd("BufWritePre", {
      -- 3
      buffer = args.buf,
      callback = function()
        -- 4 + 5
        vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})


-- My setup
vim.cmd([[
set rnu
]])
