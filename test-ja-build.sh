#!/bin/bash
echo "Testing Japanese build..."
if [ -d "build" ]; then 
  rm -rf build
fi
bash ./build.sh
if [ -f "build/ja/actual-intelligence.epub" ]; then 
  echo "✅ Japanese EPUB found"
else 
  echo "❌ Japanese EPUB missing"
  exit 1
fi
echo "✅ All tests passed!"
