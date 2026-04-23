#! /usr/bin/env sh

# Exit in case of error
set -e

pytest; mypy src; mypy tests; flake8 src; flake8 tests;