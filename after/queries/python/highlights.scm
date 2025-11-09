; (A) コードセルマーカー
(comment
  (source) @python.cell.marker ; <-- 変更点
  (#match? @python.cell.marker "^# %%( |$).*") 
) 

; (B) Markdownセルマーカー
(comment
  (source) @markdown.cell.marker ; <-- 変更点
  (#match? @markdown.cell.marker "^# %% \[markdown\].*") 
)
