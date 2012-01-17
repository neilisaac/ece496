all: progress-2011017.pdf progress-2011017-NI.pdf progress-2011017-KS.pdf

progress-2011017.pdf: document.tex goals.tex progress.tex gantt.tex overview.tex title-page.tex
	pdflatex $<
	bibtex $(<:.tex=) || true
	pdflatex $<
	pdflatex $<
	mv $(<:.tex=.pdf) $@

progress-2011017-NI.pdf: neil.tex
	pdflatex $<
	bibtex $(<:.tex=) || true
	pdflatex $<
	pdflatex $<
	mv $(<:.tex=.pdf) $@

progress-2011017-KS.pdf: keyi.tex
	pdflatex $<
	bibtex $(<:.tex=) || true
	pdflatex $<
	pdflatex $<
	mv $(<:.tex=.pdf) $@

clean:
	rm -f *.aux *.log *.bbl *.blg *.lot *.lof *.toc *.out *.synctex.gz

