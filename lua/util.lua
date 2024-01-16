local M = {}

function M.print_table(t, indent)
  indent = indent or 0
  local toIndent = string.rep("  ", indent)
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(toIndent .. k .. ": ")
      M.print_table(v, indent + 1)
    else
      print(toIndent .. k .. ": " .. tostring(v))
    end
  end
end

return M
