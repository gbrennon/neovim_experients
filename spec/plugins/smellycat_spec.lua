local spec_helper = require("spec_helper")

describe("plugins.smellycat", function()
  local spec

  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.smellycat"] = nil
    spec = require("plugins.smellycat")
  end)

  after_each(function()
    package.loaded["plugins.smellycat"] = nil
  end)

  it("should return a valid lazy.nvim spec", function()
    assert.is_table(spec)
    assert.equals("https://codeberg.org/mraspaud/smellycat.nvim", spec.url)
  end)

  it("should depend on nvim-treesitter", function()
    assert.is_table(spec.dependencies)
    assert.is_true(vim.tbl_contains(spec.dependencies, "nvim-treesitter/nvim-treesitter") or vim.tbl_contains(spec.dependencies, "nvim-treesitter"))
  end)

  it("should expose a safe config function", function()
    assert.is_function(spec.config)
    -- calling config should not error even if parsers are not present (our config guards require calls)
    local ok, err = pcall(spec.config)
    assert.is_true(ok, tostring(err))
  end)
end)
