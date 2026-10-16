vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- View
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight LineNr guifg=#9ca3af guibg=NONE
  highlight CursorLineNr guifg=#facc15 guibg=NONE gui=bold
]])

-- Basic Configuration
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.clipboard:append("unnamedplus")
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })


-- Git
local function update_git_branch()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()

  local result = vim.system(
    { "git", "-C", dir, "branch", "--show-current" },
    { text = true }
  ):wait()

  vim.b.git_branch = result.code == 0
      and vim.trim(result.stdout)
      or ""
end

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "FocusGained" }, {
  callback = update_git_branch,
})

function _G.git_branch_statusline()
  local branch = vim.b.git_branch or ""
  return branch ~= "" and (" " .. branch .. " ") or ""
end

vim.opt.statusline = table.concat({
  "%f",
  "%m",
  "%=",
  "%{v:lua.git_branch_statusline()}",
  "%l,%c",
  " %P",
})

vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>dn", function()
  vim.diagnostic.jump({ count = 1 })
end)
vim.keymap.set("n", "<leader>dp", function()
  vim.diagnostic.jump({ count = -1 })
end)

-- Go Debugger (Delve + nvim-dap)
vim.keymap.set("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "Debug: Step over" })
vim.keymap.set("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "Debug: Step into" })
vim.keymap.set("n", "<F12>", function()
  require("dap").step_out()
end, { desc = "Debug: Step out" })
vim.keymap.set("n", "<leader>b", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle breakpoint" })
vim.keymap.set("n", "<leader>B", function()
  require("dap").clear_breakpoints()
end, { desc = "Debug: Clear breakpoints" })
vim.keymap.set("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug: Toggle UI" })

local function setup_dap_ui()
  local dap = require("dap")
  local dapui = require("dapui")

  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

-- plugins
require("lazy").setup({
  -- mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- mason + lsp
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls"},
      })
    end,
  },

  -- LSP
  { "neovim/nvim-lspconfig" },

  -- 補完
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- カッコ自動挿入
  {
    "windwp/nvim-autopairs",
  },

  -- ファイラ
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Go debugger (Delve)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require("dap-go").setup()
      setup_dap_ui()
    end,
  },
  -- Git
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = function()
      require("neogit").setup({
        integrations = {
          diffview = true,
        },
        disable_commit_confirmation = true,
        kind = "tab",
      })
    end,
  },
})

-- ===== LSP (Shell Script) =====
vim.lsp.config("bashls", {
  filetypes = {
    "sh",
    "bash",
    "zsh",
  },
})
vim.lsp.enable("bashls")

-- ===== Shell Script Indentation =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "sh",
    "bash",
    "zsh",
  },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ===== LSP (pyright) =====
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})
vim.lsp.enable("pyright")

-- ===== Python Indentation  =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- ===== LSP (gopls) =====
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})
vim.lsp.enable("gopls")

-- ===== Go Indentation =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})


-- ===== Json Indentation  =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ===== Config Indentation  =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "dosini" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})


-- ===== LSP (TypeScript / JavaScript) =====
vim.lsp.config("ts_ls", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
})
vim.lsp.enable("ts_ls")

-- ===== TypeScript Indentation  =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
  },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ===== LSP (Dockerfile) =====
vim.lsp.config("dockerls", {
  filetypes = {
    "dockerfile",
  },
})

vim.lsp.enable("dockerls")

-- ===== Docker Compose LSP =====
vim.lsp.config("docker_compose_language_service", {
  filetypes = {
    "yaml.docker-compose",
  },
})

vim.lsp.enable("docker_compose_language_service")

-- ===== Dockerfile Filetype =====
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = {
    "Dockerfile",
    "Dockerfile.*",
    "*.Dockerfile",
    "Containerfile",
    "Containerfile.*",
  },
  callback = function()
    vim.bo.filetype = "dockerfile"
  end,
})

-- ===== Docker Compose Filetype =====
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = {
    "docker-compose*.yml",
    "docker-compose*.yaml",
    "compose*.yml",
    "compose*.yaml",
  },
  callback = function()
    vim.bo.filetype = "yaml.docker-compose"
  end,
})

-- ===== Docker Indentation =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "dockerfile",
    "yaml.docker-compose",
  },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})


-- ===== LSP (Terraform) =====
vim.lsp.config("terraformls", {
  filetypes = {
    "terraform",
    "terraform-vars",
  },
})
vim.lsp.enable("terraformls")

-- ===== Terraform Indentation =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "terraform",
    "terraform-vars",
    "hcl",
  },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})


-- ===== LSP (yamlls) =====
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      schemaStore = {
        enable = true,
      },
    },
  },
})
vim.lsp.enable("yamlls")

-- ===== YAML Indentation =====
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- ===== nvim-cmp =====
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),

  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- ===== autopairs =====
local autopairs = require("nvim-autopairs")
autopairs.setup({
  check_ts = true, -- treesitter があれば賢くなる
})

-- nvim-cmp と連携（関数補完で () を自動追加）
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- ===== nvim-tree =====
require("nvim-tree").setup({
  view = {
    width = 30,
    side = "left",
  },
})

vim.keymap.set("n", "<leader>e", ":NvimTreeFocus<CR>", { silent = true })
