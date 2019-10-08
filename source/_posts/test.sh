#!/bin/bash
## apt-get install pandoc
## npm install showdown --save

## apt-get install ruby-dev
## gem install asciidoctor-confluence
host='http://ubuntu-nas:8100'
api_host='http://ubuntu-nas:8100'
spaceKey='knowledge'
username='zhaoyu'
password='!!!dd6888599'

#files=($(ls ./*.adoc))
files="$1"
failed=()

for file in ${files[@]};do
    fileName="$file"
    q_fileName=$(printf %q "${fileName}")
    title="${fileName%.*}"
    title="${title#./*}"
    
    asciidoctor-confluence --host ${host} --spaceKey ${spaceKey} --title "${title}" --username ${username} --password ${password} "${fileName}"
    result=$?
    if [[ $result -ne 0 ]];then
        failed+=($fileName)
    fi
done

echo failed: ${failed[@]}
