#!/bin/sh
#
# fmove.sh - An interactive file mover using a non-standard selector (fzy).
# Note: This script is POSIX-compliant but requires the external utility 'fzy'.
#
# Usage: ./fmove.sh <destination_directory>

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
# WARNING: 'fzy' is not a standard POSIX utility and breaks strict portability.
# It is included here as per user request for dmenu-like functionality.

echo "Use fzy to select the SOURCE file/directory to move. (Press ESC to cancel)" 1>&2
# Execute find and pipe the output to fzy for selection.
# The search now starts from the user's home directory ($HOME).
# Use command substitution to capture the user's selection
SOURCE=$(find "$HOME" | fzy)

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
echo "Moving file(s):"
echo "  From: '$SOURCE'"
echo "  To:   '$DEST'"
echo ""

# Execute the move command. 
# We use the standard 'mv' utility with -i to confirm.
mv -i "$SOURCE" "$DEST"

# --- Error Checking ---

# Check the exit status of the previous command ($?)
if [ "$?" -eq 0 ]; then
    echo "Successfully moved '$SOURCE' to '$DEST'."
    exit 0
else
    # The 'mv' command itself usually prints an error message to stderr.
    echo "Move failed. Check the error message above for details." 1>&2
    exit 3
fi

# Final newline just in case
echo
