#!/bin/bash
export LC_COLLATE='C'
export LC_CTYPE='C'

searchInData () {
	missWord=$1
	cardData=$2
	length=$(echo "${#missWord}")
	halfLength=$((length / 2 ))
	if [ $length -ge 12 ] ; then
		prefix=$(echo ${missWord:0:4})
		mid=$(echo ${missWord:$((halfLength-2)):4})
		suffix=$(echo ${missWord:$((length-4))})
	elif [ $length -ge 9 ] ; then
		prefix=$(echo ${missWord:0:3})
		mid=$(echo ${missWord:$((halfLength-1)):3})
		suffix=$(echo ${missWord:$((length-3))})
	else
		prefix=$(echo ${missWord:0:2})
		suffix=$(echo ${missWord:$((length-2))})
		mid=XXXXXXXXXXXX
	fi
	grep -i "^$prefix" $cardData | sort >.pre
	grep "$mid" $cardData | sort >.mid
	grep "$suffix" $cardData | sort >.suf
	echo $missWord >.temp
	sdiff .pre .suf | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >13
	getIt=$(cat 13 | wc -l)
	if [ $getIt -eq 0 ] ; then
		sdiff .pre .mid | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >12
		sdiff .mid .suf | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >23
	fi	

	cat 13 12 23 2>/dev/null | sort | uniq >>.temp
	rm -f 13 12 23
	sort .temp | grep -B 1 -A 1 "^$missWord$" > filter
	cat filter | grep -v "^$missWord$" 
	rm -f filter
	num=$(cat .temp | wc -l)
	if [ $num -eq 1 ] ; then
		echo $missWord >>.needMoreSearch
	fi
}

search () {
	cardName="$*"
	cardNameLength=$(echo "${#cardName}")
	exactMatch=$(grep "^$cardName\t" names_all)
	length=$(echo ${#exactMatch})
	if [ $length -lt 1 ] ; then
		searchInData "$cardName" names_all >.results
		cat .results | while read nameInfo ; do
			enName=$(echo "$nameInfo" | awk 'BEGIN{FS="\t"}{print $1}')
			enNameLength=$(echo ${#enName})
			lengthDiff=$((cardNameLength - enNameLength))
			if [ ${lengthDiff#-} -le 3 ] ; then
				echo "$nameInfo"
			fi
		done
	else
		echo "$exactMatch"
	fi
}

if [ $# -lt 1 ] ; then
	echo "Need error spell names file or name."
	exit -1
fi

if [ -f "$1" ] ; then
	cat "$1" | while read cardName ; do
		search $cardName
	done
else
	search "$*"
fi

rm -f .needMoreSearch
