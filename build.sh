pandoc introErlang.md Compiler.md  beam.md  ErlangCompile.md  -o IntroductionMakeCompilerWithErlang.tex --bibliography references.bib
platex manuscript.tex
dvipdfmx manuscript.dvi

