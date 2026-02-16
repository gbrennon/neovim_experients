#!/bin/bash

# Test script to verify LSP auto-restart
echo "Creating test Python project to verify LSP auto-restart..."

# Create a simple Python file
cat > test_lsp.py << 'EOF'
# Test file for LSP
import json
import requests

def hello():
    print("Hello, world!")

if __name__ == "__main__":
    hello()
EOF

# Create initial requirements.txt
cat > requirements.txt << 'EOF'
requests==2.25.1
EOF

echo "Files created:"
echo "- test_lsp.py (Python file for LSP testing)"
echo "- requirements.txt (LSP config file)"
echo ""
echo "To test LSP auto-restart:"
echo "1. Open test_lsp.py in Neovim"
echo "2. Check LSP is running with :LspInfo"
echo "3. In another terminal, run: echo 'numpy==1.21.0' >> requirements.txt"
echo "4. Switch back to Neovim - you should see 'Restarting LSP...' notification"
echo "5. Alternatively, just switch focus to Neovim and it will detect the change"