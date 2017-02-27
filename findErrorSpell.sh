#!/bin/bash
find ./ -name '*_cn.txt' -exec grep -l '[a-zA-Z]' {} \; | while read name ; do
	echo $name
	grep '[a-zA-Z]' "$name"
done
