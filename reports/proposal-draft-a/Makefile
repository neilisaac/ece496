
proposal:
	pdflatex $@
	bibtex $@
	pdflatex $@
	pdflatex $@

spell:
	aspell -t check $file

clean:
	rm -f *.aux *.pdf *.log *.bbl *.blg *.lot *.lof *.toc

