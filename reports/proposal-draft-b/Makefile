
proposal:
	pdflatex $@
	bibtex $@
	pdflatex $@
	pdflatex $@

spell:
	aspell -t check $file

cat:
	pdftk A=cover.pdf B=proposal.pdf cat A B output proposalDraftB.pdf keep_final_id

clean:
	rm -f *.aux *.log *.bbl *.blg *.lot *.lof *.toc *.out *.synctex.gz

