# Ulang製作

## xrl
字句解析については既に書いてるのでここでは説明しません。

````
Definitions.
INT        = [0-9]+
ATOM       = :[a-z_]+
VAR        = [a-z0-9_]+
CHAR       = [a-z0-9_]
WHITESPACE = [\s\t\n\r]

Rules.

{WHITESPACE}+ : skip_token.
%% String
"(\\x{H}+;|\\.|[^"])*" :
                    S = string:substr(TokenChars, 2, TokenLen - 2),
                {token,{string,TokenLine,S}}.
Erlang code.
````
整数や空白など基本的な要素を追加します。

## yecc
構文解析はすでに書いてるのでここでは説明しません。
今回はprogramをルートシンボルとするので次のようにyrlファイルに記述してください。

````
Nonterminals.
Terminals.
Rootsymbol program.
Erlang code.
````

##　実装する文法
* モジュール
* 関数
* 演算子
* 変数束縛
* if
* リスト
* タプル

## モジュール
### xrl
#### Rules
````
module  : {token,{module,TokenLine}}.
````

### yecc
#### Nonterminals
Nonterminalsにmodule_expを追加してください

````
Nonterminals program module_exp .
````

### Terminals

````
Terminals 'module'.
````


#### ルール

````
module_exp ->
    'module' var:
        {attribute, ?line('$2'),module, element(3,'$2')}.
````


````
program ->
    module_exp: [ '$1' ].
````

````
program ->
    module_exp: [ '$1' ].

program ->
    module_exp exps: [ '$1' | '$2' ].
````


## 式
expとexpのリストexpsを追加します。expとexpは;で区切ります。

### xrl
xrlのRuleに;を追加するため次のコードを追加します。
#### Rule

````
;      : {token,{';', TokenLine}}.
````
### yecc
expとexpsを追加します。
#### Nonterminals
````
Nonterminals exp exps.
````
### Terminals
````
Terminals ';'.
````

#### ルール
expとexpsのルールを記述して

````
exps ->
    exp :
[ '$1' ].
exps ->
     exp ';' exps  :
[ '$1' | '$3' ].        
````
ルートシンボルのprogramからたどれるように次のコードを追加します。

````
program ->
    module_exp exps: [ '$1' | '$2' ].
````

## 関数宣言

### xrl
必要な字句をRuleに宣言します。
#### Rule
````
fn      : {token,{'fn',TokenLine}}.
\-\>    : {token,{'->', TokenLine}}.
\{      : {token,{'{', TokenLine}}.
\}      : {token,{'}', TokenLine}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
````
### yeec

#### Nonterminals
Nonterminalsにexp expsを追加してください。
#### Terminals
Terminalsに fn -> {} () を追加。

#### ルール
````
function ->
    'fn' var '(' args  ')' '->'  '{' exps '}' :
        {function,?line('$1'),element(3,'$2'), length('$4'),
         [{clause,?line('$1'),'$4',[],
           '$8'
          }]
        }.

function ->
    'fn' var '('  ')' '->'  '{' exps '}' :
        {function,?line('$1'),element(3,'$2'), 0,
         [{clause,?line('$1'),[],[],
           '$7'
          }]
        }.
````
引数のルールを追加します。

````
args ->
    arg ',' args :
        [ '$1' | '$3' ].

args ->
    arg : [ '$1' ].

arg ->
    var : '$1'.
````

これをexpに追加しexpからたどれるようにします。

````
exp ->
    function : '$1'.
````


#### Erlang code
文字列を整数に変換するために次の関数を用意してください。

````
Erlang code.
string_to_integer(Str) ->
    case string:to_integer(Str) of
        {Code,_} ->
            Code
    end.
````

## 関数呼び出し


### xrl
### yecc

#### Nonterminals
Nonterminalsにcall_expを追加してください。

#### ルール
呼び出しルールを記述します。引数ありと引数なしの２種類です。
````
call_exp ->
    var '(' ')':
        {call, ?line('$1'),var_to_atom('$1'),nil}.

call_exp ->
    var '(' exps ')' :
        {call, ?line('$1'),var_to_atom('$1'),'$3'}.
````

exp からたどれるようにします。

````
exp ->
    call_exp : '$1'.
````

#### Erlang code.
Erlang codeにatomに変換する関数を追加します。

````
var_to_atom({var,Line,V}) ->
    {atom,Line,V}.
````

## 演算子
演算子を追加します。

### xrl

Ruleに演算子を追加します。
#### Rule
````
\+      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\-      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\*      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\/      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\=\=    : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\<      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\>      : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\<\=    : {token,{'op',TokenLine, to_atom(TokenChars)}}.
\>\=    : {token,{'op',TokenLine, to_atom(TokenChars)}}.
````

#### Erlang code
アトムに変換するサポート関数を定義します。

````
Erlang code.
to_atom(Chars) ->
    list_to_atom(Chars).
````

### yecc
#### Terminals

Terminals に　op_expを追加します。


#### ルール

````
op_exp ->
    exp op exp :
        {op, ?line('$1'), element(3,'$2'), '$1', '$3' }.
````
expにop_expを追加します。

````
exp ->
    op_exp : '$1'.
````

## 変数束縛
変数束縛のためのlet構文を追加します。
### xrl

````
let     : {token,{'let', TokenLine}}.
\<\-    : {token,{'<-', TokenLine}}.
````

### yecc
#### Nonterminals
Nonterminalsにはlet_expを追加します。
#### Terminals
Terminalsには'<-' 'let'を追加します。

#### ルール
let_exp構文を追加します。

````
let_exp ->
    'let' var '<-' exp :
        {'match', ?line('$1'), '$2', '$4'}.

````
expからよびだせるようにします。

````
exp ->
    let_exp : '$1'.
````



## if
### xrl
if then else end を追加します。

````
if      : {token,{'if', TokenLine}}.
then      : {token,{'then', TokenLine}}.
else      : {token,{'else', TokenLine}}.
end     : {token,{'end', TokenLine}}.
````

### yecc
#### Nonterminals

Nonterminalsに```if_exp test_exp true_exp false_exp```を追加します。
#### Terminals
Terminalsに``` 'if' 'then' 'else' 'end' ```を追加します。

#### ルール

````
if_exp ->
    'if' test_exp 'then' true_exp 'else' false_exp 'end':
        {'case', ?line('$1'),
         '$2',
         [{'clause', ?line('$3'), [{atom, ?line('$3'),'true'}],
           [],
           '$4'},
          {'clause', ?line('$5'), [{atom, ?line('$5'),'false'}],
           [],
           '$6'}]}.
````
````
test_exp ->
     exp  :  '$1' .
true_exp ->
     exps :  '$1' .
false_exp ->
     exps :  '$1' .
````

## リスト
### xrl
#### Rule
````
\[            : {token, {'[',  TokenLine}}.
\]            : {token, {']',  TokenLine}}.
,             : {token, {',',  TokenLine}}.
````
### yecc
#### Nonterminals
Nonterminalsにlist_exp tail_expを追加します。
#### Terminals
Terminalsに[] ,を追加します。
#### ルール
````
list_exp ->
    '[' ']': {nil, ?line('$1')}.
list_exp ->
    '[' exp tail_exp:
        {cons, ?line('$2'), '$2', '$3'}.
````
````
tail_exp ->
    ',' exp  tail_exp:
        {cons, ?line('$1'), '$2', '$3'}.

tail_exp ->
     ']':
        {nil, ?line('$1')}.
````

## タプル
### yecc
#### Nonterminals
Nonterminalsにtuple_exp tuple_buildを追加してください。

#### ルール
リストと同様にタプルを定義していきます。

````
tuple_exp ->
    '(' ')' :
        {tuple, ?line('$1'),[]}.
tuple_exp ->
    '(' tuple_build ')' :
        {tuple, ?line('$1'), '$2'}.
tuple_build ->
     exp ',' tuple_build :
        [ '$1' | '$3' ].
tuple_build ->    
    exp :
        [ '$1' ].
````
これまでと同様にexpにtuple_expを追加してください。

````
exp ->
    tuple_exp : '$1'.
````
