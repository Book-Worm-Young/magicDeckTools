#!/bin/bash
rm -f needMore.txt
export LC_COLLATE='C'
export LC_CTYPE='C'
findName () {
	cat $1 | while read missWord ; do
		length=$(echo ${#missWord})
		if [ $length -ge 12 ] ; then
			prefix=$(echo ${missWord:0:4})
			suffix=$(echo ${missWord:$((length-4))})
		else
			prefix=$(echo ${missWord:0:3})
			suffix=$(echo ${missWord:$((length-3))})
		fi
		grep "^$prefix" $2 | sort >.pre
		grep "$suffix" $2 | sort >.suf
		echo $missWord >.temp
		sdiff .pre .suf | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >>.temp
		echo $missWord
		sort .temp | grep -B 1 -A 1 "$missWord" > filter.txt
		if [ $3 -ne 0 ] ; then
			cat filter.txt | grep -v "\W$missWord\W"
		else
			cat filter.txt | sort | uniq
		fi
		rm -f filter.txt
		num=$(cat .temp | wc -l)
		if [ $num -eq 1 ] ; then
			echo $missWord >>needMore.txt
		fi
	done
}
findName miss names.utf-8 1 >firstFound.txt
findName needMore.txt names_all 0 >secondFound.txt
