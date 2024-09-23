#!/bin/bash

if [[ -e "$1" ]]; then
	i=$1
	if [[ -d $i ]]; then
		if [[ -e $i/$i.tex ]]; then
			cd $i
			pdflatex $i.tex && pdflatex $i.tex
			cd -
		else
			echo "No $i/$i.tex found"
		fi
	else
		echo "$i is not a directory"
	fi
else
	for i in $(ls); do
		if [[ -d $i ]]; then
			echo "$i"
			if [[ -e $i/$i.tex ]]; then
				cd "$i"
				pdflatex $i.tex && pdflatex $i.tex
				cd -
			fi
		fi
	done
fi
