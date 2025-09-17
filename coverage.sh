#!/bin/sh
# This script regenerates and displays the coverage report.

echo "Running tests and generating coverage data..."
flutter test --coverage

echo "Generating HTML report..."
genhtml coverage/lcov.info -o coverage/html

echo "Opening report..."
open coverage/html/index.html