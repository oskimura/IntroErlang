# Erlang入門
Erlangは並列処理を言語VMでサポートすることに特徴がある関数型言語です。
ErlangはPrologというか並列論理型言語の強い影響をうけていて構文やVMなどにその影響が見られます。

## インストール

### windows
http://www.erlang.org/downloads
よりインストーラを落としてインストールしてください

### mac

````
brew install erlang
````
でインストールできます

### linux
デビアン系なら
````
apt install erlang
````
## 対話環境
### windows
````
"スタート" -> "全てのプログラム" -> "Erlang OTP " -> "Erlang"
````
### mac & linux
ターミナルより
````
erl
````
と打ち込むことで対話環境が立ち上がります。
ためしに 1+2+3.と打ち込んで見ましょう。
````
:~/work$ erl
Erlang R16B03 (erts-5.10.4) [source] [64-bit] [async-threads:10] [kernel-poll:false]

Eshell V5.10.4  (abort with ^G)
1> 1 + 2 + 3.
6
2>
````
## コンパイル
ercコマンドでコンパイルします。
ErlangはBEAMというVM上で実行されるのでバイナリコンパイルされます。
こうして出来上がったファイルをbeamファイルと呼びます。
作成したファイルは
````
erl -pz . -noshell -noinput -s モジュール名 関数名 -s init stop
````
などとして実行することができますが。

実行させたい場合はescriptを使用するほうが便利でしょう。
## escript
escriptはErlangのプログラムをPerlスクリプトのように実行することができます。
````
$ cat factorial
#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -sname factorial -mnesia debug verbose
main([String]) ->
    try
        N = list_to_integer(String),
        F = fac(N),
        io:format("factorial ~w = ~w\n", [N,F])
    catch
        _:_ ->
            usage()
    end;
main(_) ->
    usage().

usage() ->
    io:format("usage: factorial integer\n"),
    halt(1).

fac(0) -> 1;
fac(N) -> N * fac(N-1).
````
````
$ chmod u+x factorial
````

````
$ ./factorial 5
factorial 5 = 120
````
````
$ ./factorial
usage: factorial integer
````
````
$ ./factorial five
usage: factorial integer
````
````
$ escript factorial 5
````
詳しくは
http://erlang.org/doc/man/escript.html

## 整数実数
````
4> 2#0101.
5
5> 16#deadbeaf.
3735928495
````
のように＃のまえに数字を置くことでN進数表記ができます。
Erlangは多倍長整数なので整数の範囲に限りはありません。
浮動小数点数 IEEE754 形式で 1.0e-323 から 1.0e+308の範囲です。

## 文字列
文字はASCII文字の前に$を付けます。
````
7> $a.
97
````
文字列はダブルクォートで囲みます。これは文字のリストの糖衣構文です。
````
8> "a".
"a"
9> [$a,$b].
"ab"
````
日本語は多バイト文字で表現する必要があります。

## 変数
Erlangの変数は大文字から始まります。

````
10> X = 1.
1
11> X.
1
````
これは変数Xに１を代入して、Xを評価しています。
代入については後述するパタンマッチで説明します。


## 演算子

### 算術演算子

1. \+
加算

1. \*
乗算

1. \-
減産

1. /
除算

1. div
整数の商

1. rem
整数の商の余り

基本的にCやJavaと同じです。divとrem整数で割ったときの商と余りです。

### 比較演算子

* \>
大なり

* <
小なり

* \>=*
大なりイコール

* =<
小なりイコール

* ==
等しい

* /=
等しくない

* =:=
等しい（タイプチェック付き）

* =/=
等しくない（タイプチェック付き）

### 論理演算子

* not
否定

* and
論理積∧

* andalso
論理積∧（短絡）

* or
論理和∨

* orelse
論理和∨（短絡）

* xor
排他的論理和


## 条件分岐

### if
````
if  <条件式> -> <式1>;
   <条件式> -> <式2>
end
````
があまりつかいません後述するパタンマッチの方をよく使います。

## アトム
アトムは識別子を表します。小文字英語もしくはバッククォートでくくられています。

````
1> abc.
abc
````
もちろん変数に代入もできます。

````
2> X = abc.
abc
3> X.
abc
````
アトムは後述するタプルやメッセージなどをパタンマッチするときに便利なのでErlangプログラミングではLisp同様よくつかわれます。

## 出力
Erlangではコンソールへの出力は一般にはio:formatという関数を使って行います。

### io:format

## パタンマッチ

### case文
````
case <式>of
<パタン1> -> <式1> ;
<パタン2> -> <式2>
end
````
case文はパタンマッチの一番わかり易い形式です。
````
2> A = 3.
3
3> case A of 1 -> a; 2 -> b; 3 -> c end.
c
````
とするとｃが返ります。
このようにCのswitchのように使うこともでるのです。
こから最後のパタンマッチの処理を除くとどうなるでしょうか？
````
4> case A of 1 -> a; 2 -> b end.        
** exception error: no case clause matching 3
5>
````
このように例外が発生します。

### ワイルドカード
では次のように変更するとどうでしょうか？
````
5> case A of 1 -> a; 2 -> b; _ -> c end.
c
````
_はワイルドカードといってあらゆる場合にマッチします。正規表現の*に似ています。よく予期しない値などのエラー処理に使われます。

### 単一代入
````
X = 1.
````
先程代入といったのは実はパタンマッチなのです。
＝演算子はパタンマッチを行う演算です。
＝をつかってわざとパタンマッチエラーの例外を起こすなどの使い方をする人もいます。

この例では数値型なのでこのような面白くない使い方になっていますが、後述するリストやレコード、タプルなどと組み合わせることで非常に多様な使い方ができ、Erlangにはなくてはならない機能です。

## 関数
````
<関数名>(仮引数...) ->
<本体>
end
````
以下は引数をインクリメントする関数です。
````
inc(X) -> X+1.
````
のようにして定義します。

## 関数とパタンマッチング
Erlangは関数の引数にもパタンマッチを行うことができます。

````
signal(red) -> stop;
signal(blue) -> do;
signal(yello) -> carefull;
signal(_) -> error.
````

### 再帰
Erlangにはwhileなどのループ制御構文がないので、ループ処理は再帰で行います。
階上を求める関数を書いてみます。
````
pow(1) -> 1 end;
pow(X) -> X*pow(X-1) end.
````

###  末尾再帰
末尾再帰という形式にすることによってループ処理を最適化できます。

````
pow_tail(X,Ret) -> pow_tail(X-1,X*Ret) end
````

## レコード
いわゆる構造体です

````
-record(<レコード名>, {＜要素目1>,＜要素目2>,...}).
````

レコードを定義するrd関数というのも存在します。

````
rd(item, {id,name,price}).
````

````
7> rd(player, {name,hp}).      
player
`````

### 初期化

````
#<レコード名>{＜要素目１>=初期値１}
````

といった形で初期化します。


````
9> P = #player{name="hoge", hp=3}.
#player{name = "hoge",hp = 3}

````

### 参照
````
変数＃<レコード名>.<要素＞
````
と言った形で参照します。
````
10> P#player.name.
"hoge"
````

### 変更

`````
変数#<レコード名>{<要素＞="hage"}.         
`````

とすることでレコードの要素を変更したレコードを返します。

````
11> P#player{name="hage"}.         
#player{name = "hage",hp = 3}
````
### レコードのパタンマッチ

## リスト
````
[<要素１>,<要素２>...]
````
````
1> [1,2,3].
[1,2,3]
````

Lispとかリストと同じです。

### リスト処理
リストはパタンマッチで処理が可能です。
次はリストの長さを計算する関数です。
````
len([]) ->
    0;
len([Head|Tail]) ->
    1+len(Tail).
````
[]は空のリストにマッチします。
[Head|Tail]のHeadはリスト先頭、たとえば[1,2,3]とあったら１にマッチしてTailは2,3にマッチします。

なおリストを処理する関数は標準のlistsというモジュールにまとめられています。

# タプル
````
{<要素１>,<要素２>...}
````
````
1> {1,2,3}.
{1,2,3}
````
ErlangではLispのS式代わりに使われることが多いです。

## バイナリ
````
<< <値1>:<サイズ1>, <値2>:<サイズ2> ...>>
````
という風にかいて値をサイズ毎に指定できます。サイズ指定を省略するとデフォルトの8ビットになります。

### バイナリのパタンマッチ
たとえば、
````
1> Color = <<16#FF00FF:(8*3)>>.
<<255,0,255>>
````
としてRGBのカラーを定義して、次のように
````
2> <<R,G,B>> = Color.
<<255,0,255>>
````
パタンマッチによって8ビットごとに分解したりすることができます。
先頭だけほしい場合は、
````
2> <<R:8,_/binary>> = Color.
<<255,0,255>>
3> R.
255
````
とすることで先頭の値だけ取得できます。

余談ですが、Erlangで日本語のような多バイト文字を扱うには
io:format("~ts~n",[<<"お"/utf8>>]).
のようにバイナリ形式でutf8を支持する必要があります。

## 並列
Erlangにおいて並列処理は、軽量プロセス（以下プロセス）とメッセージによって実現されています。
プロセスはOSのプロセスに似ていますが、ErlangのVMで実行されOSでのコンテキストスイッチが行われません。プロセス同士はメモリ領域を共有せずにメッセージ・キューを通じて通信を行い、基本的に完全に独立しています。
そのため複雑なコンテキストスイッチを伴わないため切り替えは高速です。

### spawn
````
Pid = spawn(<モジュール名>, <関数名>, <引数のリスト>)
````
と言った形でよびだして軽量プロセスを生成します。
spawnはPidはプロセスIDと呼ばれプロセス毎にユニークな数値をかえします。
メッセージを他のプロセスに送る際にこの数値を利用します。


### メッセージの送信
````
Pid ! メッセージ
````
という風に送りたいプロセスのプロセスIDに！メッセージという形式でメッセージを送信します。
このプロセスIDは spawnが返したものと同じものです。

### メッセージの受信
````
receive
    <パターン1> ->
        <処理1>;
    <パターン2> ->
       <処理2>
    ............
    <パターンN> ->
        <処理N>
end
````
というふうにreceiveでメッセージを受け取けとってパタンマッチすることでメッセージに対応する処理をしていきます。

### プロセス登録
spawnが生成するプロセスIDは常に同じである保証はありません。なので複数のプロセスがメッセージを送るプログラムを作るときは不便です。
なのでプロセスIDではなく、アトムでメッセージを送る方法があります。
それがプロセス登録です。
プロセスを登録するはregister関数をしようします。
````
register(Atom,Pid)
````
とすることで、
Atom!メッセージ
と言った形でアトムを使って登録したプロセスにメッセージが送れます。

## spawn_link
spawn_linkは基本的にspawnと同じですが例外が発生した時に動作が異なり、
発生した例外をプロセスが作成したがわが受け取ります。

## 例外
例外
````
try <評価される式> of
    <パターン1> ガード1 -> <処理1>;
    <パターン2 ガード2 -> <処理2>;
catch
    <例外のタイプ1>: <パターン1> ガ−ド1 -> <例外処理1>;
    <例外のタイプ2>: <パターン2> ガ−ド2 -> <例外処理2>;
after
    <例外が起きても起きなくても実行される処理>
end
````
try ... ofで囲まれた式で例外が発生するとcatch以降でパタンマッチが行われ、例外処理が実行されたあとにafterの処理が行われます。

次にあげるのは例外を発生させる関数です。
### throw
例外をなげます。
## exit
例外をあげ、プロセスを終了させます。
## error
重大な例外をあげ、プロセスを終了させます。



## モジュール

モジュールはソースを記述するファイル単位でコンパイルする際の最小単位です。ソースは何らかのモジュールに属していないとコンパイルできません。
モジュールを作成するには.erlファイルに
モジュール宣言などのモジュール属性を記述する必要があります。

### モジュール属性

モジュール属性はファイルの先頭によくある-から始まる宣言です。
たとえば、モジュール宣言などがあります。

#### モジュール宣言

````
-module(<モジュール名>).
````

#### エクスポート宣言
エクスポート宣言する関数を宣言します。
以下のように関数名と引数の数を/でつなげてください。
````
-export([<関数名>/<引数の数>])
````
以下のようにすればモジュールで作成した全ての関数をエクスポートできます。
````
-export_all
````

#### コンパイルオプション宣言
コンパイラに指定するオプション
http://erlang.org/doc/man/compile.html

#### マクロ定義
````
-define{<マクロ>,<式>}
````
#### レコード宣言
レコードを宣言します。
````
-record(<レコード名>, {＜要素目1>,＜要素目2>,...}).
````
### インクルード
ヘッダファイルをインクルードします。
````
-include("<ヘッダファイル>").
````
ヘッダファイルの拡張子は.hrlです

## 参考文献
* https://www.ymotongpoo.com/works/lyse-ja/index.html