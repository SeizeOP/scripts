#!/bin/bash
read -e -p "Enter the filename: " input_file
base_filename=$(basename "$input_file")
new_filename="${base_filename%.*}.org"
pandoc -f markdown $base_filename -t org -o $new_filename
echo "Input: $input_file"
echo "Output: $new_filename"   
