# PathfindPlus
PathfindPlus は、Stormworks のアドオン上で動作する海洋経路探索の独自実装です。

## 概要
Stormworks のアドオン Lua では、海洋経路探索を実現する方法として `server.pathfindOcean` というビルトイン関数が既に用意されています。しかし残念ながら、この関数による経路探索は失敗しやすく、あまり役に立ちません（詳細は[バグレポート](https://geometa.co.uk/support/stormworks/117/)を参照ください）。そこで私は、このビルトイン関数を代替する別の手段として PathfindPlus を作成しました。

PathfindPlus の利点：
 - どのような出発地・目的地を設定しても必ず経路探索が成功します。

PathfindPlus の欠点：
 - `server.pathfindOcean` と比較してパフォーマンスが悪く、アドオンの初期化に約5秒、1回の経路探索に最大1秒程度掛かります。
 - スクリプトに約16000文字のコードを追加する必要があります。これは、スクリプトの最大文字数(131072文字)のおよそ12%に相当します。

## 動作確認方法
[GitHub](https://github.com/gcrtnst/sw-pathfindplus/tree/main/pathfindplus) または [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2594168437) で公開されているアドオンを使用することで、PathfindPlus の挙動を確認できます。

### アドオンの導入
アドオンの導入方法は他のアドオンと同じです。
 1. [Steam Workshop の作品](https://steamcommunity.com/sharedfiles/filedetails/?id=2594168437)をサブスクライブします。もしくは、[pathfindplus/](https://github.com/gcrtnst/sw-pathfindplus/tree/main/pathfindplus) ディレクトリそのものを `%APPDATA%\Stormworks\data\missions` の下へコピーします。
 1. Stormworks のタイトル画面から New Game > Enabled Addons と進み、アドオン一覧を表示させます。
 1. 「Saved」タブまたは「Workshop」タブ内にある「PathfindPlus」にチェックを入れます。
 1. このまま新規ワールドを作成すると、アドオンが有効になります。

既存のセーブデータにアドオンを追加することは（セーブデータを直接編集しない限り）できません。

### カスタムコマンドの使い方
このアドオンを導入したワールドでは下記のカスタムコマンドが使えます。

```
?pathfind [-start START_X START_Y] [-end END_X END_Y]
```

 - 経路探索を実施し、結果を出力します。
 - `-start` フラグを使用して、出発地を指定できます。指定しなかった場合、プレイヤーの現在位置が出発地になります。
 - `-end` フラグを使用して、目的地を指定できます。指定しなかった場合、目的地はランダムに決定されます。

### 経路探索結果の見方
経路探索の結果はマップ上に表示されます。
 - 出発地と目的地がマップマーカーで表示されます。
 - PathfindPlus による経路探索の結果は実線で表示されます。
 - ビルトイン関数 `server.pathfindOcean` による経路探索の結果が、比較用に破線で表示されます。

また、チャット欄に下記のようなメッセージが出力されます。
 - 1行目には、`server.pathfindOcean` による経路探索の、計算時間と、生成されたパスの合計距離が示されます。
 - 2行目には、PathfindPlus による経路探索の、計算時間と、生成されたパスの合計距離が示されます。
 - もし、PathfindPlus により「非海洋タイルを通らない限り、目的地にたどり着けない」と判断された場合、2行目に [unreachable] と表示されます。
```
PathfindOcean: 0ms, 88.1km
PathfindPlus: 38ms, 85.4km [unreachable]
```

### カスタムコマンドの例
 - `?pathfind`：引数なしで実行すると、プレイヤーの現在位置を出発地、ランダムな場所を目的地とします。
 - `?pathfind -start -64000 -64000 -end 64000 64000`：`-start` と `-end` を使用して、出発地を (-64000, -64000)、目的地を (64000, 64000) に設定しています。

## 組み込み方法
下記の手順により、PathfindPlus を任意のアドオンに組み込んで使用できます。
 1. [script.lua](https://github.com/gcrtnst/sw-pathfindplus/blob/main/pathfindplus/script.lua) 内の `buildPathfinder` 関数全体を、組み込み先のアドオンにコピーします。
 1. アドオンの初期化時に `buildPathfinder` 関数をコールして、戻り値の Pathfinder オブジェクトをグローバル変数にて保持します。
 1. Pathfinder オブジェクトの `pathfindOcean` メソッドを使って、経路探索を行います。`pathfindOcean` メソッドの引数・戻り値の仕様は、`server.pathfindOcean` と同じです。

サンプルスクリプト：
```lua
function onCreate(is_world_create)
    -- initialization
    pf = buildPathfinder()
end

function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, cmd, ...)
    -- call pf:pathfindOcean wherever you want
    local path_list = pf:pathfindOcean(matrix_start, matrix_end)
end

function buildPathfinder()
    -- snip
end

```

### パフォーマンス Tips
PathfindPlus は `server.pathfindOcean` と比較してパフォーマンスが悪いです。より良いパフォーマンスを得るためには下記を心掛けてください。
 - `pathfindOcean` メソッドを毎 tick コールするのは避けてください。経路探索の結果は変数に保持して、可能な限り再利用してください。
 - `buildPathfinder` 関数を経路探索の度にコールするのは避け、アドオンの初期化時に一度だけコールするようにしてください。
 - 非海洋タイルを通らないと到達できないような出発地・目的地を設定すると、経路探索に時間がかかります。`getOceanReachable` メソッドを使うと、経路に非海洋タイルが含まれるかどうか事前に確認できます（`getOceanReachable` メソッドは出発地・目的地に依らず定数時間で終わります）。
 - 経路探索は、距離が短いほど早く終わります。

### リファレンス
#### `pf = buildPathfinder()`
`buildPathfinder` 関数はPathfinder オブジェクトを生成し、初期化して返します。
初期化にはおよそ5秒程度掛かります。
Pathfinder オブジェクトは関数や非 ASCII 文字列を含むため、`g_savedata` に格納してセーブすることはできません。

#### `{ [i] = {x = world_x, z = world_z} } = pf:pathfindOcean(matrix_start, matrix_end)`
`pathfindOcean` メソッドは海洋経路探索を行います。
 - `matrix_start` には、出発地を表す行列を指定します。
 - `matrix_end` には、目的地を表す行列を指定します。
 - 戻り値は、経路探索結果のパスを表す、インデックスが1始まりのリストとなります。リストには、出発地の次のポイントから、目的地のポイントまでが順番に格納されます。

#### `is_reachable = pf:getOceanReachable(matrix_start, matrix_end)`
`getOceanReachable` メソッドは、指定された出発地から目的地まで、海洋タイルのみを通って到達できるかどうか調べます。
 - `matrix_start` には、出発地を表す行列を指定します。
 - `matrix_end` には、目的地を表す行列を指定します。
 - 戻り値は boolean 型です。`true` のとき、`pathfindOcean` メソッドから返されるパスが海洋タイルのみを通ることが保証されます。`false` のときは非海洋タイルを通るため、陸地に阻まれて目的地に到達できなかったり、地形に衝突したりする恐れがあります。

# ライセンス
PathfindPlus は [The Unlicense](https://github.com/gcrtnst/sw-pathfindplus/blob/main/LICENSE) の下で配布されています。

# リンク
 - GitHub リポジトリ：[https://github.com/gcrtnst/sw-pathfindplus](https://github.com/gcrtnst/sw-pathfindplus)
 - Steam Workshop：[https://steamcommunity.com/sharedfiles/filedetails/?id=2594168437](https://steamcommunity.com/sharedfiles/filedetails/?id=2594168437)
 - バグレポート：[https://geometa.co.uk/support/stormworks/117/](https://geometa.co.uk/support/stormworks/117/)
