#!/bin/bash

# Actual Intelligence Book Builder
# Main entry point for building the book

# Forward all arguments to the build script
exec tools/scripts/build.sh "$@"
