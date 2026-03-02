local function enabled()
  local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok_parsers then
    return false
  end
  local langs = { "python", "lua", "rust", "go", "scala" }
  for _, lang in ipairs(langs) do
    local ok_has, has = pcall(parsers.has_parser, lang)
    if ok_has and has then
      return true
    end
  end
  return false
end

return {
  url = "https://codeberg.org/mraspaud/smellycat.nvim",
  enabled = enabled,
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local ok, smelly = pcall(require, "smellycat")
    if ok and smelly and type(smelly.setup) == "function" then
      pcall(smelly.setup)
    end
  end,
}
