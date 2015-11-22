欧文フォントインストールスクリプト for platex
========

必要なもの
----
- Ruby, Rake
- otftotfm, ec.enc, q-ts1-uni.enc ... 新しいフォントからインストーラを作成する場合に必要

ディレクトリ構成
----
- package/ ... 生成したtfm, vf, map, fd, encファイルを格納
- opentype/ ... インストーラを作成する際，ここに置いたフォントファイルを使う（シンボリックリンクを貼っておくのが良い）
- settings/ ... 新しく導入するフォントのファミリ名，ウェイトなどを定義したファイルを置く
- installers/ ... 作成したインストーラが置かれる

使い方
----
- rake initdirs
  + クローンしたらまずこれを実行してディレクトリ構成を初期化する
- rake generate
  + settings/以下のファイルに基いてtfmファイル等を生成し，installers/以下にTeXに導入するためのインストーラスクリプトを作成する
- rake install
  + installers/以下のインストーラを実行
