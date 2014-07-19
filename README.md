# CoPL resolver

http://www.fos.kuis.kyoto-u.ac.jp/~igarashi/CoPL/index.cgi の練習問題を解きます。今のところEvalML3くらいのものを解くことができます。[紹介記事](http://hakobe932.hatenablog.com/entry/2014/07/19/204139)。

### ビルド

```
npm install
$(npm bin)/gulp
```

### 実行

```
node build/run.js
```

### ブラウザで実行

```
open run.html
```

### 見どころ
- [文法定義](src/grammer.jison) 
- [問題を解いてるところ](src/ml.coffee#L127)
