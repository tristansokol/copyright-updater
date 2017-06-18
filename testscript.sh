#!/bin/bash

# A simple script
echo "looking in " $1

#get the current directory
cd $1
#check what git branch we are on
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
#if we are on master, switch to a new branch
if [[ $branch=='master' ]]; then
	git checkout -b updating-copyrights
fi

# search for each file that has the word copyright in it. 
grep copyright ./ -lir | while read -r filename ; do
	
	numCommits=$(git log --oneline ${filename} | wc -l)

	if [[ "$numCommits" -eq 1 ]]; then
		echo $filename
		printf '\e[1;33m%-6s\e[m\n' "Has a copyright notice, but only the inital commit"
	else


		# check to see if the file is being tracked in git.
		lastupdated=$(git log -1 --date=format:'%Y' --pretty=format:"%cd"  $filename)
		if [[ $lastupdated ]]; then
			#echo -------------------------------------------
			#echo "file $filename was last updated on $lastupdated"
			#grep -ri 'copyright' $filename
			nextword=$(awk '{for(i=1;i<=NF;i++) if ($i=="copyright"||$i=="Copyright") print $(i+1)}' $filename)

			if [[ $nextword == '(c)' || $nextword == '(C)' ]]; then
				nextword=$(awk '{for(i=1;i<=NF;i++) if ($i=="(C)"||$i=="(c)") print $(i+1)}' $filename)
			fi
			if [[ $nextword =~ ^-?[0-9]+$ ]]; then
				if [[ $nextword -eq $lastupdated ]]; then
					printf '\e[1;32m%-6s\e[m\n' $filename


				fi
				if [[ $nextword -ne $lastupdated ]]; then
					printf '\e[1;31m%-6s\e[m %s vs %s\n' $filename $lastupdated  $nextword
					sed -i '' -e "s@Copyright $nextword@Copyright $nextword - $lastupdated@g" $filename
					sed -i '' -e "s@Copyright (c) $nextword@Copyright $nextword - $lastupdated@g" $filename
					sed -i '' -e "s@Copyright (C) $nextword@Copyright $nextword - $lastupdated@g" $filename
				fi
			else
				echo $filename
				grep -B 1 -A 1  -i copyright $filename

				printf '\e[1;33m%-6s\e[m\n' "None of these were determined to be real copyright notices"

			fi

		fi

	fi
    #result_string="${original_string/Suzi/$string_to_replace_Suzi_with}"
	#get the year of the last commit git log -1  --date=format:'%Y' --pretty=format:"%cd"  LICENSE.txt



	# echo "$(git log -1 --format="%ad" -- $filename) $filename"

done
