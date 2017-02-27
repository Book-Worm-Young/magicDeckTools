#!/bin/bash
find ./ -name '*_en.txt' -exec rm -f {} \;
cat ./names | 
  awk 'BEGIN{FS="\t";OFS="\t"};{print length($2),$2,$1}' | 
    sort -nr | 
      cut -f 2-3 | 
        awk 'BEGIN{FS="\t"; print "sed \\";print "-e \"s#±¸ÅÆ#\"sideboard# \\"}
             {print "-e \"s#"$1"#"$2"#\" \\"}
             END{print "\"$1\" > \"$2\""}' >temp.sh
find ./ -name '*_cn.txt' | while read file ; do
	sh temp.sh "$file" "${file/_cn.txt/_en.txt}"
	unix2dos "${file/\_cn.txt/_en.txt}" 2>/dev/null
	old=`cat "${file/_cn}" | md5sum | cut -f 1 -d' '`
	new=`cat "${file/_cn.txt/_en.txt}" | md5sum | cut -f 1 -d' '`
	if [ "X"$old == "X"$new ] ; then
		rm -f "${file/_cn.txt/_en.txt}"
	fi
	if [ -f "${file/_cn.txt/_en.txt}" ] ; then
		mv "${file/_cn.txt/.txt}" "${file/_cn.txt/.old}"
		mv "${file/_cn.txt/_en.txt}" "${file/_cn.txt/.txt}"
	fi
done
rm -f temp.sh
