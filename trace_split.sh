#!/bin/bash

if [ $# -ne 1 ]; then
    echo Usage: trace_split input_file
    exit 0
fi

input_file=$1
if [ ! -f $input_file ]; then
    echo $input_file not found
    exit 0
fi

if [ ! -f trace_only.html ]; then
    grep '\[...\] .... [0-9]\+\.[0-9]\+:' ${intput_file} > trace_only.html
fi

header_end=$(grep -n '  <script class="trace-data" type="application/text">' ${input_file} | sed 's/:.*//g')
echo "header_end: ${header_end}"
echo "sed -n '1,${header_end}p' > header.html"
sed -n "1,${header_end}p" ${input_file} > header.html
tail -n 4 ${input_file} > footer.html

total_lines=$(wc -l trace_only.html | awk '{print $1}')
echo "total: total_lines: $total_lines"

part_num=$(((total_lines+999999)/1000000))
echo "split to part_num ${part_num}"

i=0
while [ $i -lt $part_num ]; do
    start=$((1000000*i+1))
    end=$((1000000*(i+1)))
    if [ $end -gt $total_lines ]; then
        end=$total_lines
    fi
    echo "sed -n '${start},${end}p' trace_only.html > trace_split_${i}.html"
    cat header.html > trace_split_${i}.html
    sed -n "${start},${end}p" ${input_file} >> trace_split_${i}.html
    cat footer.html >> trace_split_${i}.html
    let i=i+1
done

echo 'split ok'
rm -f header.html
rm -f footer.html
