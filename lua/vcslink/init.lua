local Job = require("plenary.job")

local function get_remote()
  local output, code = Job:new({
    command = "git",
    args = { "config", "--get", "remote.origin.url" },
  }):sync()

  if code ~= 0 then
    print("get_remote exit code " .. code)
    return
  end

  return table.concat(output, "")
end

local function get_branch()
  local output, code = Job:new({
    command = "git",
    args = { "rev-parse", "--abbrev-ref", "HEAD" },
  }):sync()

  if code ~= 0 then
    print("get_branch exit code " .. code)
    return
  end

  return table.concat(output, "")
end

function string.starts(s, target)
  return (string.sub(s, 1, #target) == target)
end

function string.ends(s, target)
  return (target == "") or (string.sub(s, - #target) == target)
end

local function parse_remote(remote)
  local result = ""

  if string.starts(remote, "git@") then
    result = string.gsub(string.sub(remote, 5), ":", "/", 1)
  end

  if string.starts(remote, "https://") then
    result = string.sub(remote, 9)
  end

  if string.starts(remote, "http://") then
    result = string.sub(remote, 8)
  end

  if string.ends(remote, ".git") then
    result = string.sub(result, 1, #result - 4)
  end

  return result
end

local function format(platform, url, branch, path, line)
  local vcs_url

  if platform == "github" then
    vcs_url = string.format("https://%s/blob/%s/%s", url, branch, path)
  end

  if platform == "gitlab" then
    vcs_url = string.format("https://%s/-/blob/%s/%s", url, branch, path)
  end

  if line ~= nil then
    vcs_url = vcs_url .. "#L" .. line
  end

  return vcs_url
end

local function detect_platform(s)
  if string.starts(s, "github") then
    return "github"
  end
  if string.starts(s, "gitlab") then
    return "gitlab"
  end
end

local function git_toplevel()
  local res, code = Job:new({
    command = "git",
    args = { "rev-parse", "--show-toplevel" },
  }):sync()

  if code ~= 0 then
    print("get_remote exit code " .. code)
    return
  end

  return res[1]
end

-- Returns the path of the current buffer, relative to the git repository root
local function get_buf_git_relative()
  local buf = vim.api.nvim_buf_get_name(0)
  local toplevel = git_toplevel() .. "/"

  return string.sub(buf, #toplevel + 1)
end

local function get_link(include_line)
  local remote = get_remote()
  local url = parse_remote(remote)
  local branch = get_branch()
  local path = get_buf_git_relative()
  local platform = detect_platform(url)
  if include_line then
    local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
    return format(platform, url, branch, path, line)
  end
  return format(platform, url, branch, path, nil)
end

local M = {}

M.copy = function(include_line)
  local link = get_link(include_line)
  print("Copied " .. link)
  vim.fn.setreg("+", link, '"')
end

M.browse = function(include_line)
  local link = get_link(include_line)

  Job:new({
    command = "xdg-open",
    args = { link },
  }):start()
end

return M
