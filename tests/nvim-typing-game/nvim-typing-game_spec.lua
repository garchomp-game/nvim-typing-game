local plugin = require("nvim-typing-game")
local game = require("nvim-typing-game.core.game")

describe("nvim-typing-game", function()
  it("カーソルがN行目にある場合、0-indexedでN-1を返す", function()
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

  it("ゲーム開始時、カーソル位置以下の行がゲームに登録される", function()
    -- バッファの作成と初期化
    local buffer = vim.api.nvim_create_buf(false, true)
    local lines = {"line 1", "line 2", "line 3", "line 4"}
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

    -- 新しいバッファを現在のウィンドウに設定
    local window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(window, buffer)

    -- ゲームを開始
    plugin.start_game(lines)

    -- 登録された行を取得して検証
    local game_words = game.get_registered_words()
    local expected_words = lines
    assert.are.same(expected_words, game_words)
  end)

  it("正しい入力でハイライトが次の行に移動する", function()
    -- バッファの初期化、ゲームの開始などのセットアップ
    local buffer = vim.api.nvim_create_buf(false, true)
    local lines = {"line 1", "line 2", "line 3", "line 4"}
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

    plugin.start_game(lines)
    local initial_highlight = game.get_current_highlighted_line(1)
    assert.are.equal("line 1", initial_highlight)  -- 初期ハイライトが最初の行にあることを確認

    -- 正しい入力を模倣
    plugin.on_input_submit("line 1")
    local next_highlight = game.get_current_highlighted_line(2)
    assert.are.equal("line 2", next_highlight)  -- ハイライトが次の行に移動していることを確認
  end)

  it("全行入力後ゲーム終了とバッファ復帰を確認", function()
    -- 元のバッファのハンドルを保存
    local before_buffer = vim.api.nvim_get_current_buf()
    local buffer = vim.api.nvim_create_buf(false, true)
    local lines = {"line 1", "line 2", "line 3"}
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)

    -- ゲームの初期化
    plugin.start_game(lines)

    -- 全ての行を入力
    for _, line in ipairs(lines) do
      plugin.on_input_submit(line)
    end

    -- ゲーム終了の検証
    assert.is_true(game.is_game_over())

    -- 元のバッファに戻っていることの検証
    local current_buffer = vim.api.nvim_get_current_buf()
    assert.are.equal(before_buffer, current_buffer)

    -- 追加: 全ての行が正確に入力されたことの検証
    -- 全ての行が入力された後のゲームの状態を確認
    -- 追加: 全ての行が正確に入力されたことの検証
    local final_progress = plugin.get_progress()
    local expected_final_progress = {
      current_line = #lines + 1,
      total_lines = #lines,
      completed = true
    }
    assert.are.same(expected_final_progress, final_progress)
  end)

  it("誤入力後のエラーカウント増加とゲーム継続を確認", function()
    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3", "line 4"}
    plugin.start_game(lines)

    -- 正しい入力と誤った入力のシミュレート
    plugin.on_input_submit("line 1")
    plugin.on_input_submit("wrong input")

    -- エラー処理の検証
    local error_count = game.get_error_count()
    assert.are.equal(1, error_count)  -- 1つのエラーが記録されていることを確認

    plugin.on_input_submit("line 2")
    plugin.on_input_submit("wrong input")

    -- エラー処理の検証
    error_count = game.get_error_count()
    assert.are.equal(2, error_count)  -- 1つのエラーが記録されていることを確認

    -- ゲームがまだ終了していないことを確認
    assert.is_false(game.is_game_over())

    -- 追加: 誤った入力後の進行状況を検証
    local progress_after_error = plugin.get_progress()
    local expected_progress_after_error = {
      current_line = 3,  -- エラー後も次の行に進んでいることを確認
      completed = false,  -- ゲームがまだ完了していないことを確認
      total_lines = 4
    }
    assert.are.same(expected_progress_after_error, progress_after_error)
  end)

  it("正入力による進行状況の更新を検証", function()
    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3"}
    plugin.start_game(lines)

    -- 正しい入力をシミュレート
    plugin.on_input_submit("line 1")

    -- 進行状況の検証
    local progress = plugin.get_progress()
    local expected_progress = {
      current_line = 2,  -- 次の行に進んでいることを確認
      completed = false,  -- ゲームがまだ完了していないことを確認
      total_lines = 3
    }
    assert.are.same(expected_progress, progress)

    -- 追加: さらに進行した後の状況を検証
    plugin.on_input_submit("line 2")
    local progress_after_second_input = plugin.get_progress()
    local expected_progress_after_second_input = {
      current_line = 3,  -- 次の行に進んでいることを確認
      completed = false,  -- ゲームがまだ完了していないことを確認
      total_lines = 3
    }
    assert.are.same(
      expected_progress_after_second_input,
      progress_after_second_input
    )
  end)

  -- TODO: 実装中
  it("スコアや成績が正しく計算される", function()
    -- ゲームの初期化
    local lines = {"line 1", "line 2", "line 3"}
    plugin.start_game(lines)

    -- 入力をシミュレート（正確な入力と誤入力を含む）
    plugin.on_input_submit("line 1")
    plugin.on_input_submit("wrong input")  -- 誤った入力
    plugin.on_input_submit("line 2")

    -- スコアや成績の計算の検証
    local score = plugin.get_score()
    assert.is_true(score >= 0 and score <= 999)  -- スコアが0から100の間であることを確認

    local grade = plugin.get_grade()
    assert.is_true(grade == "A" or grade == "B" or grade == "C" or grade == "D" or grade == "F")  -- 成績がAからFのいずれかであることを確認

    -- 追加: エラー発生時のスコアの減点を確認
    local error_deduction = plugin.get_error_deduction()
    assert.is_true(error_deduction > 0)  -- エラーが発生した場合、スコアは減点される

    -- 追加: ストレステスト（高速連続入力）
    for i = 1, 100 do
      plugin.on_input_submit("line " .. tostring(i))
    end
    local stress_score = plugin.get_score()
    assert.is_true(stress_score >= 0 and stress_score <= 100)  -- ストレステスト後もスコアが正常範囲内であることを確認
  end)

  -- TODO: 中身未実装
  it("ゲームの一時停止と再開が正しく機能する", function()
    -- ゲームの初期化と開始
    plugin.start_game({"line 1", "line 2", "line 3"})

    -- 一時停止のテスト
    plugin.pause_game()
    assert.is_true(plugin.is_game_paused())  -- ゲームが一時停止しているか確認

    -- 追加: 一時停止中のゲーム状態変更を確認
    local paused_state = plugin.get_game_state()  -- 一時停止時の状態を取得
    -- 一時停止中に特定の操作（例：入力）を試み、状態変更がないことを確認
    plugin.on_input_submit("test input during pause")
    local paused_state_after_input = plugin.get_game_state()
    assert.are.same(paused_state, paused_state_after_input)

    -- 再開のテスト
    plugin.resume_game()
    assert.is_false(plugin.is_game_paused())  -- ゲームが再開しているか確認

    -- 追加: 再開後の動作を確認
    local resumed_state = plugin.get_game_state()  -- 再開後の状態を取得
    assert.are.not_same(paused_state, resumed_state)  -- 再開後の状態が異なることを確認
    -- 再開後の入力に応じた状態変更を確認
    plugin.process_input("line 1")
    local resumed_state_after_input = plugin.get_game_state()
    assert.are.not_same(resumed_state, resumed_state_after_input)
  end)
end)
