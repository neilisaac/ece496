all: final-2011017.pdf

final-2011017.pdf: document.tex *.tex
	pdflatex $<
	bibtex $(<:.tex=) || true
	pdflatex $<
	pdflatex $<
	mv $(<:.tex=.pdf) $@

clean:
	rm -f *.aux *.log *.bbl *.blg *.lot *.lof *.toc *.out *.synctex.gz

