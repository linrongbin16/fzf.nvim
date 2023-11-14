-- local log = require("fzfx.log")
local server = require("fzfx.server")

--- @param registry_id RpcRegistryId
--- @param params any
--- @return any
local function request(registry_id, params)
  local callback = server.get_rpc_server():get(registry_id)
  -- log.debug(
  --     "|fzfx.rpc_helpers - request| global_rpc_server:%s",
  --     vim.inspect(server.get_rpc_server())
  -- )
  -- log.debug(
  --     "|fzfx.rpc_helpers - request| registry_id:%s, params:%s, registry:%s",
  --     vim.inspect(registry_id),
  --     vim.inspect(params),
  --     vim.inspect(callback)
  -- )
  return callback(params)
end

--- @param registry_id RpcRegistryId
--- @param params any
local function notify(registry_id, params)
  local callback = server.get_rpc_server():get(registry_id)
  -- log.debug(
  --     "|fzfx.rpc_helpers - notify| global_rpc_server:%s",
  --     vim.inspect(server.get_rpc_server())
  -- )
  -- log.debug(
  --     "|fzfx.rpc_helpers - notify| registry_id:%s, params:%s, registry:%s",
  --     vim.inspect(registry_id),
  --     vim.inspect(params),
  --     vim.inspect(callback)
  -- )
  callback(params)
end

local M = {
  request = request,
  notify = notify,
}

return M
