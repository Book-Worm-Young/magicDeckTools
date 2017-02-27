#!/bin/bash
find ./ -name '*_cn.txt' -exec rm -f {} \;
find ./ -name '*_en.txt' -exec rm -f {} \;
cat ./names ./types | 
  awk 'BEGIN{FS="\t";OFS="\t"};{print length($1),$1,$2}' | 
    sort -nr | 
      cut -f 2-3 | 
        awk 'BEGIN{FS="\t"; print "sed \\";print "-e \"s#sideboard#±¸ÅÆ#\" \\"}
             {print "-e \"s#"$1"#"$2"#\" \\"}
             END{print "\"$1\" > \"$2\""}' >temp.sh
find ./ -name '*.txt' | while read file ; do
	sh temp.sh "$file" "${file/\.txt/_cn.txt}"
	unix2dos "${file/\.txt/_cn.txt}" 2>/dev/null
done
rm -f temp.sh
