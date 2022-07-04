vim.api.nvim_create_user_command("VcsLinkCopy", function()
  require("vcslink").copy()
end, {})

vim.api.nvim_create_user_command("VcsLinkBrowse", function()
  require("vcslink").browse()
end, {})
