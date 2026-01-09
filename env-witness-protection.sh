#!/bin/bash
# Env Vars Witness Protection Program
# Because your secrets deserve a second chance at life

# Colors for dramatic effect (like witness protection should have)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# The witness (your .env file)
WITNESS_FILE=".env"

# The safehouse (where we hide the witness)
SAFEHOUSE_FILE=".env.example"

# Check if witness exists
if [[ ! -f "$WITNESS_FILE" ]]; then
    echo -e "${RED}✗ Witness not found!${NC} No .env file to protect."
    echo "Maybe your secrets are already in hiding? Or you're just reckless?"
    exit 1
fi

# Create safehouse if it doesn't exist
if [[ ! -f "$SAFEHOUSE_FILE" ]]; then
    echo -e "${YELLOW}⚠ Building safehouse...${NC}"
    cp "$WITNESS_FILE" "$SAFEHOUSE_FILE"
fi

# The protection process: replace actual values with placeholders
# Because real witnesses get new identities

echo -e "${YELLOW}🚨 Initiating witness protection protocol...${NC}"
echo "Your secrets are going into hiding (but we'll keep examples)"

# Process each line in the witness file
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        echo "$line" >> "${SAFEHOUSE_FILE}.tmp"
        continue
    fi
    
    # Extract variable name and value
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value="${BASH_REMATCH[2]}"
        
        # Remove quotes if present
        var_value=$(echo "$var_value" | sed "s/^['\"]//; s/['\"]$//")
        
        # Generate new identity (placeholder)
        if [[ "$var_value" =~ ^[0-9]+$ ]]; then
            # Numbers become 12345
            new_value="12345"
        elif [[ "$var_value" =~ ^[A-Za-z0-9+/]+={0,2}$ ]] && (( ${#var_value} % 4 == 0 )); then
            # Looks like base64? Use placeholder
            new_value="base64_encoded_secret_here"
        elif [[ ${#var_value} -gt 20 ]]; then
            # Long strings get truncated
            new_value="very_long_secret_string_here"
        else
            # Everything else gets a generic placeholder
            new_value="your_${var_name,,}_here"
        fi
        
        echo "${var_name}=${new_value}" >> "${SAFEHOUSE_FILE}.tmp"
    else
        echo "$line" >> "${SAFEHOUSE_FILE}.tmp"
    fi
done < "$SAFEHOUSE_FILE"

# Replace old safehouse with new protected version
mv "${SAFEHOUSE_FILE}.tmp" "$SAFEHOUSE_FILE"

# Check if witness is already in git (uh oh!)
if git ls-files --error-unmatch "$WITNESS_FILE" >/dev/null 2>&1; then
    echo -e "${RED}🚨 CODE RED!${NC} Witness is already in git!"
    echo "Add '$WITNESS_FILE' to .gitignore IMMEDIATELY!"
    echo "Suggested .gitignore entry:"
    echo "# Protected witnesses (aka your secrets)"
    echo "$WITNESS_FILE"
else
    echo -e "${GREEN}✅ Witness is safe from git!${NC}"
fi

echo -e "${GREEN}✅ Protection complete!${NC}"
echo "The witness '$WITNESS_FILE' is safe."
echo "Their new identity '$SAFEHOUSE_FILE' is ready for public viewing."
echo "Remember: Friends don't let friends commit .env files"
