#!/bin/bash
# First check that Leo is installed.
if ! command -v leo &> /dev/null
then
    echo "leo is not installed."
    exit
fi
# Create a new organizer.
echo "
###############################################################################
########                                                               ########
########          STEP 0: Register a new organizer                     ########
########                                                               ########
###############################################################################
"
leo execute register_organizer || exit
