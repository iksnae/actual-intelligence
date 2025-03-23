#!/bin/bash

# Fix code blocks in markdown files
# This script processes markdown files to ensure code blocks are properly
# formatted for line wrapping in PDF output

echo "Fixing code blocks for better PDF wrapping..."

# Find all markdown files in the book directory
find book -name "*.md" | while read -r file; do
  echo "Processing $file..."

  # Temporary file for processing
  temp_file=$(mktemp)
  
  # Process the file line by line
  started_code_block=false
  code_block_content=""
  code_block_lang=""
  
  while IFS= read -r line; do
    # Check if this is the start of a code block
    if [[ "$line" =~ ^(\s*)\`\`\`([a-zA-Z0-9]*)$ ]] && [ "$started_code_block" = false ]; then
      started_code_block=true
      code_block_lang="${BASH_REMATCH[2]}"
      code_block_content=""
      echo "$line" >> "$temp_file"
    # Check if this is the end of a code block
    elif [[ "$line" =~ ^(\s*)\`\`\`(\s*)$ ]] && [ "$started_code_block" = true ]; then
      started_code_block=false
      
      # Process the code block
      if [ -n "$code_block_content" ]; then
        # Write the processed code block to a temporary file
        code_temp=$(mktemp)
        echo "$code_block_content" > "$code_temp"
        
        # Use fold to wrap long lines, preserving indentation
        # This is a simplified version - for best results, use the Node.js script
        awk '{
          if (length($0) > 80) {
            # Get indentation
            match($0, /^[ \t]*/);
            indent = substr($0, 1, RLENGTH);
            
            # Wrap text preserving indentation
            cmd = "echo \"" $0 "\" | fold -s -w 80 | sed -e \"2,\\\$s/^/" indent "/\"";
            system(cmd);
          } else {
            print $0;
          }
        }' "$code_temp" >> "$temp_file"
        
        rm "$code_temp"
      fi
      
      echo "$line" >> "$temp_file"
    # Within a code block, collect the content
    elif [ "$started_code_block" = true ]; then
      code_block_content="$code_block_content$line
"
    # Outside a code block, just write the line as is
    else
      echo "$line" >> "$temp_file"
    fi
  done < "$file"
  
  # Only update the file if changes were made
  if ! cmp -s "$file" "$temp_file"; then
    mv "$temp_file" "$file"
    echo "Updated $file"
  else
    rm "$temp_file"
    echo "No changes needed for $file"
  fi
done

echo "All code blocks processed" 