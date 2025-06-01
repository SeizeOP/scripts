#!bin/bash
#
# Reporting success and error in a Bash script is accomplished using status codes. By convention success is reported by exiting with the number 0. Any number greater than 0 indicates an error.
#
# Using the exit keyword
# The following demonstrates a Bash code that returns an error code 22 when the script is executed without a parameter.

if [ -z "$1" ]; then
  echo "No parameter";
  exit 22;
fi
