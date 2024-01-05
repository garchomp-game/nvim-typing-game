# 使われているneovim組み込み関数の説明

`nvim_buf_get_lines`

```help
*nvim_buf_get_lines()*
nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
バッファから特定の範囲の行を取得します。

インデックスはゼロベースで、終了は排他的です。負のインデックスは長さ+1+インデックスとして解釈されます：-1は終了後のインデックスを指します。最後の要素を取得するには、start=-2、end=-1を使用します。

`strict_indexing`が設定されていない限り、範囲外のインデックスは最も近い有効な値にクランプされます。

パラメーター: ~
• {buffer}           バッファハンドル、または現在のバッファに対しては0
• {start}            最初の行のインデックス
• {end}              最後の行のインデックス、排他的
• {strict_indexing}  範囲外がエラーになるかどうか

戻り値: ~
行の配列、または未ロードのバッファに対しては空の配列。
```

`nvim_win_get_cursor`

```help
nvim_win_get_cursor({window})                          *nvim_win_get_cursor()*
特定のウィンドウに対して、(1,0)インデックスでバッファに関連したカーソル位置を取得します
（同じバッファを表示している異なるウィンドウは、独立したカーソル位置を持ちます）。|api-indexing|

パラメーター: ~
• {window}  ウィンドウハンドル、または現在のウィンドウに対しては0

戻り値: ~
(行, 列) のタプル

参照: ~
• |getcurpos()|
```

`nvim_win_get_height`

```help
nvim_win_get_height({window})                          *nvim_win_get_height()*
ウィンドウの高さを取得します

パラメーター: ~
• {window}  ウィンドウハンドル、または現在のウィンドウに対しては0

戻り値: ~
行数としての高さ

```

`nvim_buf_set_lines`

```help
*nvim_buf_set_lines()*
nvim_buf_set_lines({buffer}, {start}, {end}, {strict_indexing}, {replacement})
バッファ内の行範囲を設定（置換）します。

インデックスはゼロベースで、終了は排他的です。負のインデックスは長さ+1+インデックスとして解釈されます：-1は終了後のインデックスを指します。最後の要素を変更または削除するには、start=-2、end=-1を使用します。

与えられたインデックスに行を挿入するには、`start`と`end`を同じインデックスに設定します。行の範囲を削除するには、`replacement`を空の配列に設定します。

`strict_indexing`が設定されていない限り、範囲外のインデックスは最も近い有効な値にクランプされます。

属性: ~
|textlock|がアクティブな時は許可されません

パラメーター: ~
• {buffer}           バッファハンドル、または現在のバッファに対しては0
• {start}            最初の行のインデックス
• {end}              最後の行のインデックス、排他的
• {strict_indexing}  範囲外がエラーになるかどうか
• {replacement}      置換に使用する行の配列

参照: ~
• |nvim_buf_set_text()|
```

`nvim_set_option_value`

```help
*nvim_set_option_value()*
nvim_set_option_value({name}, {value}, {*opts})
オプションの値を設定します。この関数の動作は|:set|のものと一致し、グローバル・ローカルオプションの場合、特に{scope}で指定されていない限り、グローバルとローカルの両方の値が設定されます。

{win}と{buf}オプションは同時に使用できないことに注意してください。

パラメーター: ~
• {name}   オプション名
• {value}  新しいオプション値
• {opts}   オプションのパラメーター
• scope: "global"または"local"のいずれか。それぞれ|:setglobal|と|:setlocal|に相当します。
• win: |window-ID|。ウィンドウローカルオプションの設定に使用します。
• buf: バッファ番号。バッファローカルオプションの設定に使用します。
```

`nvim_buf_add_highlight`

```help
*nvim_buf_add_highlight()*
nvim_buf_add_highlight({buffer}, {ns_id}, {hl_group}, {line}, {col_start}, {col_end})
    バッファにハイライトを追加します。

    これは、バッファに動的にハイライトを生成するプラグイン（例えばセマンティックハイライターやリンターなど）に役立ちます。この関数は、バッファに単一のハイライトを追加します。|matchaddpos()|とは異なり、ハイライトは行番号の変更に追随します（ハイライトされた行の上に行が挿入/削除されるときのように）、サインやマークのように。

    名前空間は、ハイライトの一連の削除/更新のために使用されます。名前空間を作成するには、|nvim_create_namespace()|を使用して名前空間IDを取得します。この関数に`ns_id`として渡して、名前空間にハイライトを追加します。

同じ名前空間内のすべてのハイライトは、|nvim_buf_clear_namespace()|を一度呼び出すだけでクリアできます。

API呼び出しによってハイライトが削除されることがない場合は、`ns_id = -1`を渡します。

    簡単な方法として、`ns_id = 0`を使用して、ハイライトのための新しい名前空間を作成できます。割り当てられたIDはその後返されます。`hl_group`が空文字列の場合は、ハイライトは追加されませんが、新しい`ns_id`は依然として返されます。これは後方互換性のためにサポートされており、新しいコードでは|nvim_create_namespace()|を使用して新しい空の名前空間を作成するべきです。

    パラメーター: ~
      • {buffer}     バッファハンドル、または現在のバッファに対しては0
      • {ns_id}      使用する名前空間、または-1でグループ化されていないハイライト
      • {hl_group}   使用するハイライトグループの名前
      • {line}       ハイライトする行（ゼロインデックス）
      • {col_start}  ハイライトする列範囲の開始（バイトインデックス）
      • {col_end}    ハイライトする列範囲の終了（バイトインデックス）、または-1で行末までハイライト

    戻り値: ~
        使用されたns_id
```

`nvim_get_current_win`

```help
nvim_get_current_win()                                *nvim_get_current_win()*
    現在のウィンドウを取得します。

戻り値: ~
    ウィンドウハンドル
```

`nvim_win_set_buf`

```help
nvim_win_set_buf({window}, {buffer})                      *nvim_win_set_buf()*
    サイドエフェクトなしでウィンドウ内の現在のバッファを設定します。

属性: ~
    |textlock| がアクティブなときは許可されません。

パラメーター: ~
    • {window}  ウィンドウハンドル、または現在のウィンドウに対しては0
    • {buffer}  バッファハンドル
```

`nvim_get_current_buf`

```help
nvim_get_current_buf()                                *nvim_get_current_buf()*
    現在のバッファを取得します。

戻り値: ~
    バッファハンドル
```
