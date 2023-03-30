vim.api.nvim_create_user_command("VcsLinkLineCopy", function()
  require("vcslink").copy(true)
end, {})

vim.api.nvim_create_user_command("VcsLinkLineBrowse", function()
  require("vcslink").browse(true)
end, {})

vim.api.nvim_create_user_command("VcsLinkBufCopy", function()
  require("vcslink").copy(false)
end, {})

vim.api.nvim_create_user_command("VcsLinkBufBrowse", function()
  require("vcslink").browse(false)
end, {})
