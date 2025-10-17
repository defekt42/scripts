#!/bin/ksh

# --- Configuration ---
DOWNLOADS_DIR="$HOME/Downloads/walls"
WALLS_DIR="$HOME/.walls"
# ---------------------

# 1. Ensure the destination directory exists
if [ ! -d "$WALLS_DIR" ]; then
print "Destination directory $WALLS_DIR does not exist. Creating it."
if ! mkdir -p "$WALLS_DIR"; then
print "Error: Could not create $WALLS_DIR. Exiting."
exit 1
fi
fi

# 2. Check if the source directory exists
if [ ! -d "$DOWNLOADS_DIR" ]; then
print "Source directory $DOWNLOADS_DIR not found. Exiting."
exit 1
fi

# 3. Use find to locate files and -exec mv to move them.
# We explicitly list all case variations (e.g., *.jpg, *.JPG) using OR logic (-o).
print "Searching for case-insensitive image files in $DOWNLOADS_DIR..."

find "$DOWNLOADS_DIR" -maxdepth 1 \
-type f \
\( \
-name "*.jpg" -o -name "*.JPG" -o \
-name "*.png" -o -name "*.PNG" -o \
-name "*.jpeg" -o -name "*.JPEG" \
\) \
-exec sh -c 'print " -> {}"; mv "$1" "$2"' sh {} "$WALLS_DIR" \;

# Check the exit status of the last command
if [ $? -eq 0 ]; then
print "Move operation completed."
else
print "Note: The move operation may have encountered minor errors."
fi

# 4. Optional: Report how many files were moved (approximate count of files now in .walls)
#COUNT=$(ls "$WALLS_DIR" | wc -l)
#print "Total files now in $WALLS_DIR: $COUNT"
