#!/bin/bash

# Install Carton if it's not already installed
cpanm Carton

# Install dependencies using Carton
carton install

echo "Dependencies installed locally. Use 'carton exec' to run scripts with local dependencies."
