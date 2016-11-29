# Erlangでコンパイラ実装

ErlangでBEAMで動くコンパイラする作成を説明します。

ulangというサンプルプログラムを作ったのでこれを元に説明します。
https://github.com/oskimura/ulang.git

主な流れとしては字句解析器、構文解析器を行って中間表現に変換しcompileモジュールを使ってBEAMで実行可能なバイナリを作成するという流れです。
今回はulang.xrlで字句解析を行い、ulang_yecc.yrlで構文解析及び中間表現の出力、compiler.erlでバイナリ出力するようにつくりました。

## 字句解析器
Erlangにはleexという字句解析器があります。
http://erlang.org/doc/man/leex.html
類似のツールを使ったことがある人なら分かるでしょうけど、Definitions、Rules、Erlang codeに分かれています。
Definitionsはruleで仕様される正規表現の定義を行います。
[今回はこの箇所](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang.xrl#L1-L7)に該当します。

````
INT        = [0-9]+
ATOM       = :[a-z_]+
VAR        = [a-z0-9_]+
CHAR       = [a-z0-9_]
WHITESPACE = [\s\t\n\r]
````

Rulesは生成するトークンを記述します。

Erlang codeはRulesで仕様されるErlangのコードを記述します。
[今回はこの部分](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang.xrl#L9-L62)に該当します。

````
module  : {token,{module,TokenLine}}.
````

のように

```
マッチする字句 : {生成するトークン}
````

という風に書きます。

````
{token,{いろいろ,行数}}.
````

という風になっているようです。
Definitionsで定義された定義を仕様するには
[という風にINTなら{INT}と{}で囲む必要](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang.xrl#L45
)があるようです。


今回の場合はここの
[to_atom関数](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang.xrl#L69)に該当します。
[この様に](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang.xrl#L14)Rulesで使用することができます。

今回はこのように作成しました
https://github.com/oskimura/ulang/blob/master/ulang/src/ulang.xrl

## 構文解析器
同じようにErlangにはyeccという構文解析器があります。
http://erlang.org/doc/man/yecc.html
yeccはErlangのコンパイラコンパイラでBNFで文法を記述できます。
[ちなみにErlangのパーサもyeccによって書かれています](https://github.com/blackberry/Erlang-OTP/blob/master/lib/stdlib/src/erl_parse.yrl)。


yeccはNonterminals、Terminals、規則部、Erlang codeに別れています。
[Nonterminalsは非終端記号の集合の宣言を行います](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang_yecc.yrl#L1)。

[Terminalsは終端記号の宣言を行います](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang_yecc.yrl#L3)。


規則部はRootSymbolを開始記号とする簡約規則を記述します。RootSymbolがないとエラーになります。
https://github.com/oskimura/ulang/blob/master/ulang/src/ulang_yecc.yrl#L6

規則部は
https://github.com/oskimura/ulang/blob/master/ulang/src/ulang_yecc.yrl#L9-L13

````
program ->
    module_exp: [ '$1' ].

program ->
    module_exp exps: [ '$1' | '$2' ].
````

のように
非終端記号 -> 　ルール : アクション
という風にかきます。'$1'は引数です。基本的にはlex/flexと一緒です。非終端記号に複数のルールがある場合は上記のように複数書きます。

[今回作成した規則部](https://github.com/oskimura/ulang/blob/master/ulang/src/ulang_yecc.yrl#L9-L160)
今回作成するyeccはアクションに作成する中間表現を記述します。中間表現の詳細は後述します。

Erlang codeは
規則部で使用するErlangコードを記述します。leexと同じです。
https://github.com/oskimura/ulang/blob/master/ulang/src/ulang_yecc.yrl#L163-L174


今回作成したたyeccの全体はこちらです。
https://github.com/oskimura/ulang/blob/master/ulang/src/ulang_yecc.yrl



## 中間表現
erl_syntaxというドキュメントに中間表現のシンタックスツリーを組み立てるためのAPI書いてありますが、
http://erlang.org/doc/man/erl_syntax.html
今回コレは使用せずに自分で組み立てる事にします。
[このモジュール](https://gist.github.com/oskimura/7386c37260528bf208b1)でErlangプログラムファイルの中間表現を取得できます。
今回はコレを使って中間表現を解析して中間表現を組み立てます。




### compileモジュール
生成された中間表現をコンパイルしてバイナリを出力するのはcompileモジュールでおこないます。　
http://www.erlang.org/doc/man/compile.html

今回はnoenv_forms関数を使用して[次のように書きました](https://github.com/oskimura/ulang/blob/master/ulang/src/compiler.erl#L13-L14)。

````
compile:noenv_forms(Spec,[return]) of
 {ok,Module,Binary,Wornings} ->
end
````

compile:noenv_formsの第一引数はバイナリ変換したい中間表現、第二引数はオプションです。
コンパイルが成功した場合は{ok,Module,Binary,Wornings}というタプルが返されます。
Moduleはモジュール名、Binaryは変換バイナリ、Worningはコンパイル時の警告です。

https://github.com/oskimura/ulang/blob/master/ulang/src/compiler.erl


## 中間表現について
中間表現は基本的にタプルで表現され、{タグ名,ソース行数,引数1,引数2,...}といった形になっています。
このタグのリストが中間表現です。compileモジュールの関数に渡すことでバイナリへとコンパイルされます。
[サンプルプログラム](https://gist.github.com/oskimura/e5b58a789e74be75c60c)を例に説明します。
Eralangの文法にかんしては[ココ](http://erlang.org/doc/reference_manual/expressions.html)を参考にしてください。
では中間表現の説明をしていきます。

### module宣言

````
-module(sample).
````

というモジュール宣言は

````
{attribute,1,module,sample},
````

となります

````
module := {attribute,Line,module,ModuleName},
````

Lineは行数、ModuleNameはモジュール名となります。
attributeというタグは後述するexportなどmoduleの箇所を変えて使われます。
ModuleNameはモジュールの名前です今回はsampleです。

### export宣言

````
-export([func1/0]).
````

というexport宣言は

````
{attribute,2,export,[{func1,0}]},
````
と変換されます。

````
export := {attribute,Line,export,[{f1,Arg},...]},
````

exportの後に関数のリストが必要です。{変数名,関数の数}のリストという形で表現されます。


### 関数宣言

````
func1 () ->
    ok.
````    

という関数宣言は

````
{function,3,func1,0,[{clause,3,[],[],[{atom,4,ok}]}]}
````

と変換されます。

````
function := {function, Line, FunctionName, ArgNumber [Clause1,...]}
````

Lineは行数、FunctionNameは関数名、ArgNumberは引数の数、Clauseのリストは関数の本体です。
なぜリストなのかというと、次のような場合

````
func2([]) ->
    ok;
func2(X) ->
    ok.
````

引数のマッチングによって複数の本体があるからです。
ちなみにこのClauseはcase hoge of～形式のパタンマッチの中間表現と共通の形式です。

````
clause := {clause,Line,[Args],[TestFuncs],[Bodys]}
````

Lineは行数、Argsのリストは仮引数、TestFuncのリストはガード節、Bodysのリストは関数本体です。
ガード節は

````
func3(X)  when is_atom(X)  ->
    X.
````

のwhen以降で引数のチェックを行う箇所です。
上記のような関数の場合

````
{function,10,func3,1,[{clause,10,[{var,10,'X'}],[[{call,10,{atom,10,is_atom},[{var,10,'X'}]}]],[{var,11,'X'}]}]}
````

と変換されます。


### 文字列
````
string_fun() ->
    "abc".
````

は

````
{function,15,string_fun,0,[{clause,15,[],[],[{string,16,"abc"}]}]}
````

と変換されます。

````
{string,Line,Str}
````

Strは文字列です

### 文字

````
char_fun() ->
    $a.
````

は

````
{function,18,char_fun,0,[{clause,18,[],[],[{char,19,97}]}]}
````

と変換されます。

````
{char,Line,Char}
````

Charは文字のASCIIコードです
### 整数

````
integer_fun() ->
    1.
````

は

````
{function,21,integer_fun,0,[{clause,21,[],[],[{integer,22,1}]}]
````

と変換されます。

````
{integer,Line,Num}
````

Numは数字です
### 演算子
````
op_fun() ->
    1+1.
````

は

````
{function,24,op_fun,0,[{clause,24,[],[],[{op,25,'+',{integer,25,1},{integer,25,1}}]}]}
````
と変換されます。

````
{op,Line, Op,LVal,RVal}
````

Opは演算子です。LValとRValはそれぞれ演算子の左辺と右辺です。

### 関数呼び出し
callで呼ぶことができる関数は同じモジュール内の関数に限られる。他のモジュールで宣言してある関数は 後述するremote callで呼び出す必要があります。

````
call_fun() ->
    func1().
````

という関数は

````
{function,13,call_fun,0,[{clause,13,[],[],[{call,14,{atom,14,func1},[]}]}]},
````

と変換されます。

````
call := {call,Line,{atom,Line,FunctionName},Args},
var := {var,Line,VarNme}
````

Lineは行数、FunctionNameは関数名、Argsは引数のリストです。

### 関数呼び出し
他のモジュールで宣言された関数はremote callで呼び出す必要があります。

````
remote_call_fun() ->
    io:format("test").
````

という関数は

````
{function,16,remote_call_fun,0,[{clause,16,[],[],[{call,17,{remote,17,{atom,17,io},{atom,17,format}},[{string,17,"test"}]}]}]}
````

と変換されます。


````
remotecall :={call,Line,{remote,Line,{atom,Line,ModuleName},{atom,Line,FunctionName}},Args}
Args := {var,Line,VarNme}
````

remoteが入る以外はcallと同じです。


### パタンマッチ
パタンマッチです

````
match_fun(X) ->
    case X of
        a ->
            a;
        b ->
            b
````

という関数が

````
{function,19,match_fun,1,[{clause,19,[{var,19,'X'}],[],[{case,20,{var,20,'X'},[{clause,21,[{atom,21,a}],[],[{atom,22,a}]},{clause,23,[{atom,23,b}],[],[{atom,24,b}]}]}]}]}
````

と変換されます。

````
case := {'case', Line, MatchExp, [Clause1,...]}
matchexp := {clause, Line, Match, Test, Bodys}
````

MatchExpは上のソースでいうcaseとofの間の式にあたりますClauseの

### 代入
単一代入です。

````
bind_fun() ->
    X = 1.
````

は    

````
{function,29,bind_fun,0,[{clause,29,[],[],[{match,30,{var,30,'X'},{integer,30,1}}]}]}
````

と変換されます。

````
{match,Line,Var,Val}
````

VarにValを代入します。

````
{var,Line,Var}
````

は変数です。Varは変数名です。

````
{integer,Line,Val}
````

は整数です。Valは設定する整数です。

### リスト

````
list_fun() ->
    [1,2,3,4].
```

という関数は

````
{function,27,list_fun,0,[{clause,27,[],[],[{cons,28,{integer,28,1},{cons,28,{integer,28,2},{cons,28,{integer,28,3},{cons,28,{integer,28,4},{nil,28}}}}}]}]}
````

と変換されます。

````
{cons, Line, {Elent1,{Element2, Line,... {nil,Line}}
````

Element1,Element2はリストの要素です。consは入れ子構造になってます。

最後に
---------------------------
上記の情報があればBEAMで動く処理系が作れるとおもいます。中間表現の他の文法等についてはいろいろ試してみよう