#!/bin/bash
read -e -p "Enter the filename: " input_file
base_filename=$(basename "$input_file")
new_filename="${base_filename%.*}.pdf"
pandoc -f markdown $base_filename -t pdf -o $new_filename
echo "Input: $input_file"
echo "Output: $new_filename"   
