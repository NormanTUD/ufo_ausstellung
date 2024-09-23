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
