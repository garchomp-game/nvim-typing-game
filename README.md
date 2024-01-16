# nvim-typing-game

Neovimのためのインタラクティブなタイピングゲームプラグインです。

## 機能

- ユーザーが入力を行うことでゲームの進行を行う
- ゲームの進行状況、得点、エラー数などをリアルタイムで追跡
- タイピングの精度と速度に基づいてスコアを計算

## コマンド

### `TypingGameStart`

タイピングゲームを開始します。

## クラス

### GameRunner

ゲームの実行を管理するクラスです。

#### フィールド

- `game`: ゲームのロジックを扱うGameクラスのインスタンス
- `ui_popup`: ユーザーインターフェースの表示を扱うUiPopupクラスのインスタンス
- `text_popup`: テキスト表示用のポップアップオブジェクト

#### メソッド

- `on_input_submit(value)`: ユーザーが入力を送信したときに呼び出される関数
- `on_input_change(value)`: ユーザーの入力が変更されるたびに呼び出される関数
- `get_progress()`: ゲームの進行状況を取得する関数
- `start_game(test_lines)`: ゲームを開始する関数
- `get_registered_words()`: 登録されたテキスト行を取得する関数
- `is_game_over()`: ゲームが終了しているか判定する関数
- `get_error_count()`: エラーの総数を取得する関数
- `get_score()`: ゲームのスコアを取得する関数
- `get_grade()`: ゲームの成績を取得する関数

### Game

ゲームのロジックを扱うクラスです。

#### フィールド

- `game_lines`: ゲームで使用されるテキスト行の配列
- `current_line`: 現在のテキスト行番号
- `is_over`: ゲームが終了したかどうか
- `before_buffer`: ゲーム開始前のバッファID
- `error_count`: エラーの総数
- `keystroke_count`: キーストロークの総数
- `start_time`: ゲーム開始時のタイムスタンプ
- `char_error_count`: 文字入力エラーの総数
- `result_score`: ゲームのスコア

#### メソッド

- `init_game(lines)`: ゲームを初期化し、開始状態に設定する関数
- `process_input(line)`: ユーザーの入力を処理し、正しいかどうかを判定する関数
- `increment_keystroke_count()`: キーストロークのカウントを1増やす関数
- `is_game_over()`: ゲームが終了しているかどうかを判定する関数
- `get_current_highlighted_line(line_number)`: 指定された行番号のテキスト行を取得する関数
- `get_registered_words()`: ゲームで使用されるテキスト行の配列を返す関数
- `get_game_lines_length()`: ゲームで使用されるテキスト行の総数を返す関数
- `get_error_count()`: エラーの総数を返す関数
- `get_score()`: リザルトのスコアを返す関数
- `get_grade()`: リザルトのスコアに基づいてグレードの情報を返す関数

### UiPopup

ユーザーインターフェースの表示を扱うクラスです。

#### フィールド

- `lines`: バッファの情報を保存
- `count_buf`: カウンター表示用のバッファ番号
- `count_popup`: カウンター表示用のポップアップオブジェクト

#### メソッド

- `show_input_popup(on_input_submit, on_input_change)`: 入力を受け付けるポップアップを表示する関数
- `show_text_popup(current_line, text_lines)`: テキストを表示するポップアップを作成し、表示する関数
- `show_counter(count)`: カウンターを表示するポップアップを作成し、表示する関数
- `update_counter_display(new_count)`: カウンターの表示を更新する関数

## インストール

```lua
-- lazy
{
    'your_username/nvim-typing-game'
}
```

## 使い方

プラグインをインストールした後、以下のコマンドでタイピングゲームを開始できます。

```vim
:TypingGameStart
```

ゲーム中は画面上に表示されるテキストをタイピングして、スコアを競います。エラー数や現在の行、合計行数などが表示され、ゲームの進行状況を追跡できます。

## ライセンス

このプラグインは[MITライセンス](https://opensource.org/licenses/MIT)の下で公開されています。
