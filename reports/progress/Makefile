default: document

spell:
	@echo aspell -t check $file

cat:
	@echo pdftk A=cover.pdf B=document.pdf cat A B output progress.pdf keep_final_id

clean:
	rm -f *.aux *.log *.bbl *.blg *.lot *.lof *.toc *.out *.synctex.gz

%:
	pdflatex $@
	bibtex $@
	pdflatex $@
	pdflatex $@

