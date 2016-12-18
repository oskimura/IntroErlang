pandoc preamble.md introErlang.md Compiler.md  beam.md  ErlangCompile.md  Ulang.md UlangMmake.md -o IntroductionMakeCompilerWithErlang.tex --bibliography references.bib \
&& platex manuscript.tex \
&& dvipdfmx manuscript.dvi
