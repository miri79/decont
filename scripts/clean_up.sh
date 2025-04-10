#!/bin/bash
#!/bin/bash
#t should take zero or more of the following arguments: 
#"data", "resources", "output", "logs". If no arguments are passed then it should remove everything.
WD=$(pwd)

# Define paths
DATA_DIR="$WD/data"
RESOURCES_DIR="$WD/res"
OUTPUT_DIR="$WD/out"
LOGS_DIR="$WD/log"

# Parse arguments
TARGETS=("$@")

# If no arguments are passed, remove everything
if [ ${#TARGETS[@]} -eq 0 ]; then
    echo "No arguments passed. Removing all data, resources, output, and logs..."
    rm -rf "$DATA_DIR" "$RESOURCES_DIR" "$OUTPUT_DIR" "$LOGS_DIR"
    echo "Cleanup complete."
    exit 0
fi

# Function to check if a value is in the list
contains() {
    local match="$1"
    shift
    for item in "$@"; do
        if [[ "$item" == "$match" ]]; then
            return 0
        fi
    done
    return 1
}

# Remove selected components
if contains "data" "${TARGETS[@]}"; then
    echo "Removing data..."
    rm -rf "$DATA_DIR"
fi

if contains "resources" "${TARGETS[@]}"; then
    echo "Removing resources..."
    rm -rf "$RESOURCES_DIR"
fi

if contains "output" "${TARGETS[@]}"; then
    echo "Removing output..."
    rm -rf "$OUTPUT_DIR"
fi

if contains "logs" "${TARGETS[@]}"; then
    echo "Removing logs..."
    rm -rf "$LOGS_DIR"
fi

echo "Cleanup complete."
