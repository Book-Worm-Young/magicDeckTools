ls -p | grep '/$' | while read dir; 
do 
cd "$dir"
find -name '*.txt' | grep -v '_cn.txt' | while read file ; do 
	cat "$file" | grep -v sideboard | sed 's/ \+/\t/'  | awk 'BEGIN{FS="\t";OFS="\t"}{print $2,$1}'
done | sort  | sed 's/[ ]\+\t/\t/g' | awk 'BEGIN{FS="\t";OFS="\t"}{temp[$1]+=$2}END{for(i in temp)print i,temp[i]}' | sort -nrk 2 -t"	" >allCards
cd -
done
