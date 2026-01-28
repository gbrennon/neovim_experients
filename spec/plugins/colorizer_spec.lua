-- Tests for plugins/colorizer.lua
local spec_helper = require("spec_helper")

describe("plugins.colorizer", function()
  local colorizer_config
  local colorizer_module
  
  before_each(function()
    spec_helper.reset_vim_mock()
    package.loaded["plugins.colorizer"] = nil
    package.loaded["colorizer"] = nil
    colorizer_config = require("plugins.colorizer")
    colorizer_module = colorizer_config._module
  end)
  
  it("should return a valid lazy.nvim plugin spec", function()
    assert.is_table(colorizer_config)
    assert.equals("NvChad/nvim-colorizer.lua", colorizer_config[1])
  end)
  
  it("should set lazy to false", function()
    assert.is_false(colorizer_config.lazy)
  end)
  
  it("should have a config function", function()
    assert.is_function(colorizer_config.config)
  end)
  
  it("should expose the module", function()
    assert.is_table(colorizer_module)
  end)
  
  describe("module", function()
    it("should have default_options", function()
      assert.is_table(colorizer_module.default_options)
    end)
    
    it("should have config function", function()
      assert.is_function(colorizer_module.config)
    end)
    
    describe("default_options", function()
      local opts
      
      before_each(function()
        opts = colorizer_module.default_options
      end)
      
      it("should enable RGB", function()
        assert.is_true(opts.RGB)
      end)
      
      it("should enable RRGGBB", function()
        assert.is_true(opts.RRGGBB)
      end)
      
      it("should disable names", function()
        assert.is_false(opts.names)
      end)
      
      it("should enable RRGGBBAA", function()
        assert.is_true(opts.RRGGBBAA)
      end)
      
      it("should enable AARRGGBB", function()
        assert.is_true(opts.AARRGGBB)
      end)
      
      it("should enable rgb_fn", function()
        assert.is_true(opts.rgb_fn)
      end)
      
      it("should enable hsl_fn", function()
        assert.is_true(opts.hsl_fn)
      end)
      
      it("should enable css", function()
        assert.is_true(opts.css)
      end)
      
      it("should enable css_fn", function()
        assert.is_true(opts.css_fn)
      end)
      
      it("should set mode to background", function()
        assert.equals("background", opts.mode)
      end)
      
      it("should disable tailwind", function()
        assert.is_false(opts.tailwind)
      end)
      
      it("should configure sass", function()
        assert.is_table(opts.sass)
        assert.is_false(opts.sass.enable)
      end)
      
      it("should set virtualtext", function()
        assert.equals("â– ", opts.virtualtext)
      end)
      
      it("should set always_update to false", function()
        assert.is_false(opts.always_update)
      end)
    end)
    
    describe("config function", function()
      it("should setup colorizer with correct options", function()
        local setup_called = false
        local setup_config = nil
        
        -- Mock colorizer
        package.loaded["colorizer"] = {
          setup = function(config)
            setup_called = true
            setup_config = config
          end
        }
        
        colorizer_module.config()
        
        assert.is_true(setup_called, "colorizer.setup should be called")
        assert.is_table(setup_config)
        assert.is_table(setup_config.filetypes)
        assert.equals("*", setup_config.filetypes[1])
        assert.same(colorizer_module.default_options, setup_config.user_default_options)
      end)
    end)
  end)
end)