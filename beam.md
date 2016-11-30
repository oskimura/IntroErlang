# Erlangのコンパイル過程
Erlangがどのようにコンパイルされ、実行されるか簡単に説明します。
Erlangは次の順序でコンパイルされます。

1. プリプロセッサ
1. レコード展開
1. コアErlang
1. カーネルErlang
1. アセンブル
1. BEAMファイル

## プリプロセッサ
プログラムソースからマクロを展開します。

## レコード展開
レコードを展開してタプルにします。

## コアErlang
コアErlangと呼ばれるErlangのサブセットの文法に変換します。ちなみにコアErlangはErlangをLLVMに対応させるために作成されたそうです。

## カーネルErlang
コアErlangからラムダリフティングやrpcの変換などを行います。
ラムダリフティングとは無名関数や局所関数に対してグローバルスコープで名前が衝突しないユニークな名前を与えてグローバルスコープにその関数を置き自由変数を除去して陽な引数とすることです。

## アセンブル
BEAMのバイナリに一対一で対応したアセンブルに変換します。

## BEAMファイル
ErlagVM(BEAM)で実行可能なバイナリファイルに変換します。
ちなみにBEAMファイルのフォーマットは”EA IFF 85 - Standard for Interchange Format Files”に準拠しています。


これらはそれぞれ以下のコードで変換できる。
マクロ展開

````
compile:file(File, ['P']).
````

レコード展開

````
compile:file(File, ['E']).
````

コアErlang

````
compile:file(File, [to_core]).

````

カーネルErlang

````
compile:file(File, [to_kernel]).
````

アセンブリ

````
compile:file(File, ['S']).
````

BEAM file

````
compile:file(File).
````

https://www.it.uu.se/research/group/hipe/cerl/
http://studzien.github.io/hack-vm/part1.html