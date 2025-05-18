#!/bin/bash

echo "Starting development server on http://localhost:5000"
carton exec -- plackup -r -p 5000 bin/app.psgi
