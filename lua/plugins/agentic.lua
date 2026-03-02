return {
  "carlos-algms/agentic.nvim",
  enabled = false,
  opts = {
    provider = "cline-acp",
    acp_providers = {
      ["cline-acp"] = {
        command = "cline",
        args = {"--acp"},
      },
    },
  },
  keys = {
    {"<leader>a", function() require("agentic").toggle() end, mode={"n","v","i"}, desc="Toggle Cline Chat"},
  },
}
