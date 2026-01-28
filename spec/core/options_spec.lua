-- Tests for core/options.lua
local spec_helper = require("spec_helper")

describe("core.options", function()
  local options
  
  before_each(function()
    -- Reset mock before each test
    spec_helper.reset_vim_mock()
    -- Clear require cache to get fresh module
    package.loaded["core.options"] = nil
    options = require("core.options")
  end)
  
  describe("setup function", function()
    it("should exist", function()
      assert.is_function(options.setup)
    end)
    
    it("should configure line numbers", function()
      options.setup()
      assert.is_true(vim.opt.number._value)
      assert.is_true(vim.opt.relativenumber._value)
    end)
    
    it("should configure tabs and indentation", function()
      options.setup()
      assert.equals(2, vim.opt.tabstop._value)
      assert.equals(2, vim.opt.shiftwidth._value)
      assert.is_true(vim.opt.expandtab._value)
      assert.is_true(vim.opt.autoindent._value)
      assert.is_true(vim.opt.smartindent._value)
    end)
    
    it("should configure line wrapping", function()
      options.setup()
      assert.is_false(vim.opt.wrap._value)
    end)
    
    it("should configure search settings", function()
      options.setup()
      assert.is_true(vim.opt.ignorecase._value)
      assert.is_true(vim.opt.smartcase._value)
      assert.is_true(vim.opt.hlsearch._value)
      assert.is_true(vim.opt.incsearch._value)
    end)
    
    it("should configure cursor line", function()
      options.setup()
      assert.is_true(vim.opt.cursorline._value)
    end)
    
    it("should configure appearance", function()
      options.setup()
      assert.is_true(vim.opt.termguicolors._value)
      assert.equals("dark", vim.opt.background._value)
      assert.equals("yes", vim.opt.signcolumn._value)
    end)
    
    it("should configure backspace", function()
      options.setup()
      assert.equals("indent,eol,start", vim.opt.backspace._value)
    end)
    
    it("should configure clipboard", function()
      options.setup()
      assert.equals("unnamedplus", vim.opt.clipboard._value)
    end)
    
    it("should configure split windows", function()
      options.setup()
      assert.is_true(vim.opt.splitright._value)
      assert.is_true(vim.opt.splitbelow._value)
    end)
    
    it("should disable swap and backup", function()
      options.setup()
      assert.is_false(vim.opt.swapfile._value)
      assert.is_false(vim.opt.backup._value)
      assert.is_false(vim.opt.writebackup._value)
    end)
    
    it("should enable undo history", function()
      options.setup()
      assert.is_true(vim.opt.undofile._value)
    end)
    
    it("should configure update times", function()
      options.setup()
      assert.equals(250, vim.opt.updatetime._value)
      assert.equals(300, vim.opt.timeoutlen._value)
    end)
    
    it("should configure scroll offset", function()
      options.setup()
      assert.equals(8, vim.opt.scrolloff._value)
      assert.equals(8, vim.opt.sidescrolloff._value)
    end)
    
    it("should configure completion", function()
      options.setup()
      assert.equals("menuone,noselect", vim.opt.completeopt._value)
    end)
    
    it("should enable mouse", function()
      options.setup()
      assert.equals("a", vim.opt.mouse._value)
    end)
    
    it("should configure encoding", function()
      options.setup()
      assert.equals("utf-8", vim.opt.encoding._value)
      assert.equals("utf-8", vim.opt.fileencoding._value)
    end)
    
    it("should configure command line height", function()
      options.setup()
      assert.equals(1, vim.opt.cmdheight._value)
    end)
    
    it("should enable matching brackets", function()
      options.setup()
      assert.is_true(vim.opt.showmatch._value)
    end)
    
    it("should disable netrw", function()
      options.setup()
      assert.equals(1, vim.g.loaded_netrw)
      assert.equals(1, vim.g.loaded_netrwPlugin)
    end)
  end)
  
  it("should auto-run setup when loaded", function()
    -- This test verifies that setup() is called automatically
    -- when the module is required, which we can verify by checking
    -- that some options are set
    assert.is_true(vim.opt.number._value)
  end)
end)