; Pythonのデフォルトのコードセル (# %%)
(comment
  (source) @injection.content ; <-- 変更点
  (#match? @injection.content "^# %%( |$).*") 
  (#set! injection.language "python")
  (#set! injection.combined)
)
(comment
  ; Pythonセル内のコメント行
  (source) @injection.content ; <-- 変更点
  (#match? @injection.content "^# ")
  (#set! injection.language "python")
  (#set! injection.combined)
)

; Markdownセル
(comment
  (source) @injection.content ; <-- 変更点
  (#match? @injection.content "^# %% \[markdown\].*") 
  (#set! injection.language "markdown")
  (#set! injection.strip_prefix "# ")
  (#set! injection.combined)
)
(comment
  ; Markdownセルに属するコメント行
  (source) @injection.content ; <-- 変更点
  (#match? @injection.content "^#($| .*)")
  (#set! injection.language "markdown")
  (#set! injection.strip_prefix "# ")
  (#set! injection.combined)
)
