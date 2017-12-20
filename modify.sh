#!/bin/bash
rm -f needMore
export LC_COLLATE='C'
export LC_CTYPE='C'
findName () {
	cat $1 | while read missWord ; do
		length=$(echo ${#missWord})
		halfLength=$((length / 2 ))
		if [ $length -ge 12 ] ; then
			prefix=$(echo ${missWord:0:4})
			mid=$(echo ${missWord:$((half-2)):$((half+2))})
			suffix=$(echo ${missWord:$((length-4))})
		elif [ $length -ge 9 ] ; then
			prefix=$(echo ${missWord:0:3})
			mid=$(echo ${missWord:$((half-1)):$((half+2))})
			suffix=$(echo ${missWord:$((length-3))})
		else
			prefix=$(echo ${missWord:0:2})
			suffix=$(echo ${missWord:$((length-2))})
		fi
		grep "^$prefix" $2 | sort >.pre
		grep "$mid" $2 | sort >.mid
		grep "$suffix" $2 | sort >.suf
		echo $missWord >.temp
		sdiff .pre .suf | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >>.temp
		sort .temp | grep -B 1 -A 1 "^$missWord$" > filter
		if [ $3 -ne 0 ] ; then
			cat filter | grep -v "^$missWord$" 
		else
			cat filter | sort | uniq 
		fi
		rm -f filter
		num=$(cat .temp | wc -l)
		if [ $num -eq 1 ] ; then
			echo $missWord >>needMore
		fi
	done
}
findName miss names.utf-8 1 >firstFound
if [ -f needMore ] ; then
	findName needMore names_all 0 >secondFound
fi
rm -f needMore
