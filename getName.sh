#!/bin/bash
cat T1.5Cards.txt| while read name ; do num=`grep "$name" names | tee temp | wc -l` ;
if [ $num -eq 1 ] ; then
	cat temp
else
	echo $name
fi
done
rm -f temp
