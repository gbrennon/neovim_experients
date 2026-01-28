-- Tests for plugins/nvimtree.lua
local spec_helper = require("spec_helper")

describe("plugins.nvimtree", function()
  local nvimtree_config
  
  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.nvimtree"] = nil
    package.loaded["core.keymaps"] = nil
    nvimtree_config = require("plugins.nvimtree")
  end)
  
  it("should return a valid lazy.nvim plugin spec", function()
    assert.is_table(nvimtree_config)
    assert.equals("nvim-tree/nvim-tree.lua", nvimtree_config[1])
  end)
  
  it("should have nvim-web-devicons dependency", function()
    assert.is_table(nvimtree_config.dependencies)
    assert.equals("nvim-tree/nvim-web-devicons", nvimtree_config.dependencies[1])
  end)
  
  it("should load on command", function()
    assert.is_table(nvimtree_config.cmd)
    local expected_cmds = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen", "NvimTreeClose" }
    
    for _, cmd in ipairs(expected_cmds) do
      local found = false
      for _, actual_cmd in ipairs(nvimtree_config.cmd) do
        if actual_cmd == cmd then
          found = true
          break
        end
      end
      assert.is_true(found, "Command " .. cmd .. " should be in cmd list")
    end
  end)
  
  it("should have options configuration", function()
    assert.is_table(nvimtree_config.opts)
  end)
  
  describe("options", function()
    local opts
    
    before_each(function()
      opts = nvimtree_config.opts
    end)
    
    it("should set on_attach callback", function()
      assert.is_function(opts.on_attach)
    end)
    
    it("should configure view width", function()
      assert.is_table(opts.view)
      assert.equals(30, opts.view.width)
    end)
    
    it("should configure renderer icons", function()
      assert.is_table(opts.renderer)
      assert.is_table(opts.renderer.icons)
      assert.is_table(opts.renderer.icons.show)
      
      local show = opts.renderer.icons.show
      assert.is_true(show.git)
      assert.is_true(show.folder)
      assert.is_true(show.file)
      assert.is_true(show.folder_arrow)
    end)
    
    it("should configure filters", function()
      assert.is_table(opts.filters)
      assert.is_false(opts.filters.dotfiles)
    end)
  end)
end)