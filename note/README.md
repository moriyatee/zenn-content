# note

note.com 公開用の記事を置くフォルダです。Zenn（`articles/`）とは別に、note向けの原稿・画像を管理します。

## 構成

各記事は 1 サブフォルダにまとめます。

```
note/
  <記事スラッグ>/
    article.md       … 記事のマスター原稿（Markdown / 脚注・表を含む、GitHubで読みやすい版）
    note-paste.html  … noteエディタ貼り付け用（ブラウザで開き全選択→コピー→note本文へ）
    images/          … 本文図・見出し画像（noteへは手動アップロード）
```

## note公開の手順

note.com には記事投稿の公開APIがないため、公開は手動です。

1. `note-paste.html` をブラウザで開き、ページ内を全選択 → コピー
2. note の本文エディタに貼り付け（見出し・太字・箇条書き・リンクが変換される）
3. 本文中の「▼画像1〜3」の位置に `images/` の各PNGをアップロードし、目印の行を削除
4. 記事タイトルは note のタイトル欄へ、`images/eyecatch.png` を見出し画像に設定

> note は Markdown ソースの貼り付けに非対応（記号がそのまま残る）ため、整形済みの
> `note-paste.html` からリッチテキストとしてコピーする方式をとっています。

## 記事一覧

- `karadamate-watch-calorie-algorithm/` … シャープ「からだメイト Watch」の摂取カロリー自動測定の仕組み解説
