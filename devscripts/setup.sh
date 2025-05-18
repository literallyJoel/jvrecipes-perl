#!/bin/bash

# Exit on error
set -e

# Install Carton if it's not already installed
if ! command -v carton &> /dev/null; then
  echo "Carton not found. Installing..."
  if ! command -v cpanm &> /dev/null; then
    echo "Error: cpanm is not installed. Please install App::cpanminus first."
    exit 1
  fi
  cpanm Carton
  if [ $? -ne 0 ]; then
    echo "Failed to install Carton. Exiting."
    exit 1
  fi
else
  echo "Carton is already installed."
fi

# Install dependencies using Carton
echo "Installing dependencies..."
carton install
if [ $? -ne 0 ]; then
  echo "Failed to install dependencies. Exiting."
  exit 1
fi

echo "Dependencies installed locally. Use 'carton exec' to run scripts with local dependencies."
