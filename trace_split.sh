#!/bin/bash
LINE=1000000
if [ $# -ne 1 ]; then
    echo Usage: trace_split input_file
    exit 0
fi

input_file=$1
if [ ! -f $input_file ]; then
    echo $input_file not found
    exit 0
fi

header_end=$(grep -n '# *| *| *| *| *| *| *| *| *|' ${input_file} | head -n 1 | sed 's/:.*//g')
echo "header_end: ${header_end}"
echo "sed -n '1,${header_end}p' > header.html"
sed -n "1,${header_end}p" ${input_file} > header.html
tail -n 4 ${input_file} > footer.html

total_lines=$(wc -l ${input_file} | awk '{print $1}')
total_lines=$((total_lines-header_end-4))
mtotal_lines=$((total_lines+header_end))
echo "total: total_lines: $total_lines"

part_num=$(((total_lines+LINE-1)/LINE))
echo "split to part_num ${part_num}"

i=0
while [ $i -lt $part_num ]; do
    start=$((header_end+LINE*i+1))
    end=$((header_end+LINE*(i+1)))
    if [ $end -gt $mtotal_lines ]; then
        end=$mtotal_lines
    fi
    echo "sed -n '${start},${end}p' ${input_file} > trace_split_${i}.html"
    cat header.html > trace_split_${i}.html
    sed -n "${start},${end}p" ${input_file} >> trace_split_${i}.html
    cat footer.html >> trace_split_${i}.html
    let i=i+1
done

echo 'split ok'
rm -f header.html
rm -f footer.html
