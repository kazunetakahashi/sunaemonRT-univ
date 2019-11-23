# sunaemonRT-univ

Twitter の [@sunaemonRT_univ](https://twitter.com/sunaemonRT_univ) の中身

## 概要

[@sunaemonRT](https://twitter.com/sunaemonRT) と [@kazune_lab](https://twitter.com/kazune_lab) の絵付きツイートのうち、大学で見ても問題なさそうなものを自動判定してリツイートします。

## 機能

リツイートした絵を [Microsoft Azure Computer Vision API](https://azure.microsoft.com/ja-jp/services/cognitive-services/computer-vision/) に投げて Adult でも Racy でもないものを ReTweet するものです。

- 5 分に 1 回 チェック + リツイート
- 1 時間に 1 回 フォロー返し
- 毎日 0 時 5 分頃にレポート

詳細は[私の記事](http://kazune-lab.net/diary/2017/05/01/sunaemonrt_univ/)を参考にしてください。

## 免責事項

Computer Vision API の精度はすごいと思いますが、それでも完璧なわけではありません。大学での閲覧は自己責任でお願いします。
