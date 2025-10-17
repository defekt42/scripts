#!/bin/sh
#
# fcp.sh - An interactive file copier using fzy, a fast, simple fuzzy text selector.
# Note: This script is POSIX-compliant but requires the external utility 'fzy'.
#
# Usage: ./fcp.sh <destination_directory>

# --- Function for clean error messages ---
usage() {
    echo "Error: Invalid number of arguments." 1>&2
    echo "Usage: $0 <destination_path>" 1>&2
    exit 1
}

# --- Argument Validation ---
# Check if exactly one argument (destination) was provided
if [ "$#" -ne 1 ]; then
    usage
fi

DEST="$1"

# --- Source Selection using fzy (Requires external dependency) ---
# Note: 'fzy' is not a standard POSIX utility and breaks strict portability..
# It is included here as per user request for dmenu-like functionality.

echo "Use fzy to select the SOURCE file/directory to copy. (Press ESC to cancel)" 1>&2
# Execute find and pipe the output to fzy for selection.
# The search starts from the user's home directory ($HOME).
# Use command substitution to capture the user's selection
SOURCE=$(find "$HOME" -type f | fzy --lines=5 -p 🢔🢔-:Select-File:-🢖🢖)

# Check if selection was cancelled (fzy returns empty string on ESC/cancel)
if [ -z "$SOURCE" ]; then
    echo "Selection cancelled or fzy failed. Exiting." 1>&2
    exit 4
fi

# Check if the selected source file/directory exists.
# We check again just in case 'find' listed a file that was deleted mid-selection.
if [ ! -e "$SOURCE" ]; then
    echo "Error: Selected source file not found: '$SOURCE'" 1>&2
    exit 2
fi

# --- Core Logic ---
# Inform the user about the operation
echo "Copying file:"
echo "  From: '$SOURCE'"
echo "  To:   '$DEST'"
echo ""

# Execute the copy command. 
# We use the standard 'cp' utility with -i to confirm.
cp -i "$SOURCE" "$DEST"

# --- Error Checking ---
# Check the exit status of the previous command ($?)
if [ "$?" -eq 0 ]; then
    echo "Successfully copied '$SOURCE' to '$DEST'."
    exit 0
else
    # The 'cp' command itself usually prints an error message to stderr.
    echo "Copy failed. Check the error message above for details." 1>&2
    exit 3
fi

# Final newline just in case
echo
