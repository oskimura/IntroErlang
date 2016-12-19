#Ulangの使い方

## Ulangのコンパイル

### ダウンロード

````
git clone https://github.com/oskimura/ulang
````

### コンパイル
````
cd ulang
````
````
rebar compile
````

### テスト
````
rebar test
````

### 実行  

* iulang
インタプリタ
* ulangc
コンパイラbeamファイルを生成します。


# Ulangの文法

UlangはあくまでErlangの薄いラッパーであり、独自の機能はないので基本的にErlangに準ずると考えてよいです。
関数のおもな構成要素は次のようになります。

* モジュール
* 関数
* 演算子
* 変数束縛
* if
* リスト
* タプル

## 式
ulangのほとんどの構文は式になり、式は最も基本的な単位で連続した式が書きたい場合は、;で分割します。
連続した式は最後の式の評価がその文評価となります。
式として扱われないものはモジュール宣言とエクスポート宣言です。

## 再帰と末尾再帰
Erlangと同じくループ構文がないので再帰もしくは末尾再帰を使用します

## モジュール宣言
````
module my_module
````

### エクスポート宣言
エクスポートする関数です。関数名と引数の数をタプルで表現したものを、リストで並べます。

````
export [(fun0,0)]
````

## 関数
関数を宣言する際は

````
fn fun() ->
{

}
````
という風に書きます

他モジュールの関数は
````
fn module.fun() ->
{

}
````
とすることで呼び出せます。

## 演算子

* \+
* \-
* \*
* /

etc ...

Erlangと同じ演算子を使用しています


## 変数束縛
````
let x <- var
````
とするこでxがvarの値に束縛できます。
Erlangと同様再代入は不可能です。

## if
````
if then else
````
ifの値が真ならtrue文にfalseであればfalse文に

## リスト
````
[1,2,3]
````
Erlangのリストと同じです。
ですがリストのパタンマッチはサポートしません。

````
[]
````
とすることでnilとなります。

## タプル
````
(1,2,3)
````
Erlangタプルの{}を()に変更しただけです。