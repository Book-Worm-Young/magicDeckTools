#!/bin/bash
ls -p | grep '/$' | while read dir ; do
	cd "$dir"
	find ./ -name '*.txt' | grep -v '_cn.txt' | xargs -i basename "{}" | sort | uniq -c | sort -nr >types
	cd -
done
