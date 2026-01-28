-- Test helper and configuration
local vim_mock = require("helpers.vim_mock")

-- Set up the mock vim environment
vim_mock.setup()

-- Helper function to reset vim mock state between tests
function reset_vim_mock()
    vim_mock.reset()
end

return {
  reset_vim_mock = reset_vim_mock,
  vim_mock = require("helpers.vim_mock")
}