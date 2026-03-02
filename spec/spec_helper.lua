-- Test helper and configuration
local vim_mock = require("helpers.vim_mock")

-- Set up the mock vim environment
vim_mock.setup()

-- Helper function to reset vim mock state between tests
local function reset_vim_mock()
    vim_mock.reset()
    -- Ensure modules are reloaded so they use the fresh vim mock on next require
    for k,_ in pairs(package.loaded) do
        if k:match("^core%.") or k:match("^plugins%.") then
            package.loaded[k] = nil
        end
    end
end

-- Compatibility: provide before_each alias used by some specs
local function before_each()
  reset_vim_mock()
end

return {
  before_each = before_each,
  reset_vim_mock = reset_vim_mock,
  vim_mock = require("helpers.vim_mock")
}