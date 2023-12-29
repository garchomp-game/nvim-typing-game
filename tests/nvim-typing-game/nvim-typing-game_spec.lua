local plugin = require("nvim-typing-game")

describe("nvim-typing-game", function()
  it("現在のカーソル位置から行を正しく取得する", function()
    -- テストのセットアップ
    local buffer = vim.api.nvim_create_buf(false, true)
    local lines = {"line 1", "line 2", "line 3"}
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_win_set_cursor(0, {2, 0}) -- 2行目にカーソルを設定

    -- カーソル位置の取得と検証
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local start_line = cursor_pos[1] - 1 -- カーソル位置を0-indexedに変換
    assert.are.equal(1, start_line) -- カーソルが2行目（indexは1）にあることを確認
  end)

  it("ゲーム開始コマンドでバッファの行をゲームに登録する", function()
    -- テストのセットアップ
    local buffer = vim.api.nvim_create_buf(false, true)
    local lines = {"line 1", "line 2", "line 3", "line 4"}
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_win_set_cursor(0, {2, 0}) -- 2行目にカーソルを設定

    -- ゲーム開始コマンドの実行（仮）
    plugin.start_game()

    -- 登録されたワードを検証（仮）
    local expected_words = {"line 2", "line 3", "line 4"}
    local game_words = plugin.get_registered_words() -- ゲームに登録されたワードを取得する関数
    assert.are.same(expected_words, game_words)
  end)

  it("ユーザー入力に基づいてゲームが正しく進行する", function()
    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3"}
    plugin.start_game(lines)

    -- ユーザー入力をシミュレート
    -- 仮に、プラグインがユーザー入力を処理する関数を持っているとします
    plugin.process_input("line 1")
    plugin.process_input("line 2")

    -- ゲームの進行状況の検証
    -- 進行状況を取得する関数を使用することを想定します
    local progress = plugin.get_progress()
    local expected_progress = {
      current_line = 3,
      completed = false
    }
    assert.are.same(expected_progress, progress)
  end)

  it("全ての入力が完了した後にゲームが終了し、元のバッファに戻る", function()
    -- 元のバッファのハンドルを保存
    local original_buffer_handle = vim.api.nvim_get_current_buf()

    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3"}
    plugin.start_game(lines)

    -- 全ての行を入力
    for _, line in ipairs(lines) do
      plugin.process_input(line)
    end

    -- ゲーム終了の検証
    assert.is_true(plugin.is_game_over())

    -- 元のバッファに戻っていることの検証
    local current_buffer = vim.api.nvim_get_current_buf()
    assert.are.equal(original_buffer_handle, current_buffer)
  end)

  it("タイピングエラーが正しく処理される", function()
    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3"}
    plugin.start_game(lines)

    -- 誤った入力をシミュレート
    plugin.process_input("wrong input")

    -- エラー処理の検証
    -- ゲームがエラーを正しく記録しているか確認
    local error_count = plugin.get_error_count()
    assert.is_true(error_count > 0)

    -- ゲームがまだ終了していないことを確認
    assert.is_false(plugin.is_game_over())
  end)

  it("正しい入力で進行状況が更新される", function()
    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3"}
    plugin.start_game(lines)

    -- 正しい入力をシミュレート
    plugin.process_input("line 1")

    -- 進行状況の検証
    -- ゲームの進行状況が適切に更新されているか確認
    local progress = plugin.get_progress()
    local expected_progress = {
      current_line = 2,  -- 次の行に進んでいることを確認
      completed = false  -- ゲームがまだ完了していないことを確認
    }
    assert.are.same(expected_progress, progress)
  end)

  it("スコアや成績が正しく計算される", function()
    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3"}
    plugin.start_game(lines)

    -- 入力をシミュレート
    plugin.process_input("line 1")
    plugin.process_input("line 2")

    -- スコアや成績の計算の検証
    local score = plugin.get_score()
    local expected_score = 100 -- 仮に、完璧なタイピングで最高スコアを達成した場合
    assert.are.equal(expected_score, score)

    local grade = plugin.get_grade()
    local expected_grade = "A" -- 仮に、全ての入力が正確だった場合の成績
    assert.are.equal(expected_grade, grade)
  end)

  it("ゲームの一時停止と再開が可能", function()
    -- ゲームの初期化と開始
    plugin.start_game({"line 1", "line 2", "line 3"})

    -- 一時停止のテスト
    plugin.pause_game()
    assert.is_true(plugin.is_game_paused())  -- ゲームが一時停止しているか確認

    local paused_state = plugin.get_game_state()  -- 一時停止時の状態を取得

    -- 再開のテスト
    plugin.resume_game()
    assert.is_false(plugin.is_game_paused())  -- ゲームが再開しているか確認

    local resumed_state = plugin.get_game_state()  -- 再開後の状態を取得
    assert.are.same(paused_state, resumed_state)  -- 一時停止前と後の状態が同じであることを確認
  end)

  it("異なるバッファでゲームが正しく機能する", function()
    local buffer1 = vim.api.nvim_create_buf(false, true)
    local buffer2 = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buffer1, 0, -1, false, {"buffer1 line 1", "buffer1 line 2"})
    vim.api.nvim_buf_set_lines(buffer2, 0, -1, false, {"buffer2 line 1", "buffer2 line 2"})

    -- バッファ1でのゲーム開始と検証
    vim.api.nvim_set_current_buf(buffer1)
    plugin.start_game()
    -- ここでバッファ1でのゲームの状態を検証

    -- バッファ2でのゲーム開始と検証
    vim.api.nvim_set_current_buf(buffer2)
    plugin.start_game()
    -- ここでバッファ2でのゲームの状態を検証
  end)
end)
