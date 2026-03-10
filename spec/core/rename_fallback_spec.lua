local helper = require('spec_helper')

describe('core.keymaps rename fallback', function()
  before_each(function()
    helper.before_each()
    package.loaded['core.keymaps'] = nil
  end)

  it('should fallback to references-based rename when LSP rename errors', function()
    local keymaps = require('core.keymaps')

    -- Simulate LSP rename failing
    vim.lsp.buf.rename = function() error('rename not supported') end

    -- Make expand return the current word and input return the new name
    vim.fn.expand = function(_) return 'oldName' end
    vim.fn.input = function(prompt) return 'newName' end

    -- Mock references returned by LSP
    vim.lsp.buf_request_sync = function(bufnr, method, params, timeout)
      return { { result = {
        { uri = 'file:///tmp/file1', range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 3 } } }
      } } }
    end

    -- Attach LSP keymaps for buffer 1
    keymaps.lsp_on_attach(1)

    local km = vim.keymap._get_keymap('n', '<leader>rn')
    assert.is_not_nil(km)

    -- Call the mapped function (the rename handler)
    local ok, err = pcall(km.rhs)
    if not ok then error(tostring(err)) end
    assert.is_true(ok)

    local state = helper.vim_mock.get_state()
    -- uri_to_bufnr assigns 2 for the first uri; applied edits should be recorded
    assert.is_table(state.applied_edits)
    assert.is_table(state.applied_edits[2])
    assert.equals('newName', state.applied_edits[2][1].newText)
  end)
end)
