#!/bin/bash
for file in *.adoc;do
echo "[$file] -> [${file// /_}]"
mv "$file" ${file// /_}

done
