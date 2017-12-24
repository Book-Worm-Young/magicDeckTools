#!/bin/bash
basedir=$(pwd)
find ./ -name '*.txt' | while read filePath; do
	dir="$(dirname $filePath)"
	cd "$dir"
	ls *.txt | grep -v '_cn' | grep -v '\.bak' | while read -r deck; do
		if [ ! -f "${deck/.txt/.bak}" ] ; then
			mv "$deck" "${deck/.txt/.bak}"
		else
			sed -i '/^[ \t]*$/d' "$deck"
		fi
		dos2unix "${deck/.txt/.bak}" 2>/dev/null
		sed -n '1,2p' "${deck/.txt/.bak}" >head
		sed '1,2d' "${deck/.txt/.bak}" | gsed 's/[Ss]ideboard:*//' | gsed 's/ \+/ /' >content
		cat head > "${deck}"
		cat head > "${deck/.txt/_cn.txt}"
		while read -r line ; do
			if [ "${#line}" -gt 1 ] ; then
				cardNum=$(echo "$line" | cut -f 1 -d' ' | sed 's/^[ \t]*//')
				name=$(echo "$line" | cut -f 2- -d' ')
				if [ "X$name" != "X" ]; then
					"$basedir/spellCorrector.sh" "$name" >.searchResult
					searchNum=$(wc -l < .searchResult | sed 's/^[ \t]*//')
					if [ "$searchNum" -ne 1 ] ; then
						echo "$cardNum $name-* miss" >>"$deck"
						echo "$cardNum $name-* miss" >>"${deck/.txt/_cn.txt}"
					else
						enName=$(awk 'BEGIN{FS="\t"}{print $1}' .searchResult)
						cnName=$(awk 'BEGIN{FS="\t"}{print $2}' .searchResult)
						echo "$cardNum $enName" >>"$deck"
						echo "$cardNum $cnName" >>"${deck/.txt/_cn.txt}"
					fi
					rm -f .searchResult
				fi
			else
				echo "Sideboard" >>"$deck"
				echo "备牌" >>"${deck/.txt/_cn.txt}"
			fi	
		done < content
	done
	rm -f head content
	cd "$basedir" >/dev/null 2>&1
done
