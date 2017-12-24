#!/bin/bash
basedir=$(dirname "$0")
cd "$basedir"
export LC_COLLATE='C'
export LC_CTYPE='C'

searchText() {
	missWord=$1
	cardData=$2
	length="${#missWord}"
	halfLength=$((length / 2 ))
	if [ "$length" -ge 9 ] ; then
		prefix=${missWord:0:3}
		mid=${missWord:$((halfLength-1)):3}
		suffix=${missWord:$((length-3))}
	else
		prefix=${missWord:0:2}
		suffix=${missWord:$((length-2))}
		mid=XXXXXXXXXXXX
	fi
	grep -i "^$prefix" "$cardData" | sort >.pre
	grep -i "$mid" "$cardData" | sort >.mid
	grep -i "$suffix" "$cardData" | sort >.suf
	echo "$missWord" >.temp
	sdiff .pre .suf | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >.13
	getIt=$(wc -l <.13 | awk '{print $1}')
	if [ "$getIt" -eq 0 ] ; then
		sdiff .pre .mid | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >.12
		sdiff .mid .suf | grep -v '[<>|]' | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2}' >.23
	fi	

	cat .13 .12 .23 2>/dev/null | sort | uniq >>.temp
	lengthFilter "$missWord" .temp | sort | grep -B 1 -A 1 "^$missWord$" | grep -v "^$missWord$" 
	rm -f .temp .13 .12 .23  .pre .mid .suf
}

lengthFilter() {
	missWord="$1"
	dataFile=$2
	cardNameLength="${#missWord}"
	while read -r nameInfo ; do
		enName=$(echo "$nameInfo" | awk 'BEGIN{FS="\t"}{print $1}')
		enNameLength="${#enName}"
		lengthDiff=$((cardNameLength - enNameLength))
		if [ ${lengthDiff#-} -le 3 ] ; then
			echo "$nameInfo" 
		fi
	done < "$dataFile"
}

firstCharFilter() {
	cardName="$1"
	dataFile="$2"
	cardNameFirstChar=$(echo "$cardName" | cut -b 1 | tr '[:upper:]' '[:lower:]') 	
	token=0
	while read -r nameInfo ; do 
		nameFirstChar=$(echo "$nameInfo" | cut -b 1 | tr '[:upper:]' '[:lower:]')
		if [ "$cardNameFirstChar" = "$nameFirstChar" ] ; then
			echo "$nameInfo"
			token=1
			break
		fi
	done < "$dataFile"
	if [ $token -eq 0 ] ; then
		cat "$dataFile"
	fi	
}

search() {
	cardName="$*"
	exactMatch=$(grep "^$cardName\t" names.dat)
	length="${#exactMatch}"
	if [ "$length" -lt 1 ] ; then
		searchText "$cardName" names.dat >.results
		if [ -f .results ] ; then
			matchNum=$(wc -l <.results | awk '{print $1}')
			if [ "$matchNum" -le 1 ] ; then
				cat .results
			else
				firstCharFilter "$cardName" .results
			fi
		fi
		rm -f .results
	else
		echo "$exactMatch"
	fi
}

if [ $# -lt 1 ] ; then
	echo "需要输入一张牌名或包含牌名的文件名"
	exit -1
fi

if [ ! -f names.dat ] ; then
	echo "牌名数据文件<names.dat>不存在，请检查"
	exit -1
fi

if [ -f "$1" ] ; then
	while read -r cardName ; do
		search "$cardName"
	done < "$1"
else
	search "$*"
fi
cd - >/dev/null 2>&1
