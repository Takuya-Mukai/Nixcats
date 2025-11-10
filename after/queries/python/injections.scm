; Jupytext markdown cells
(
  (comment) @_start
  (#match? @_start "^# %% \\[markdown\\]")
  .
  (comment)+ @injection.content
  (#offset! @injection.content 0 2 0 0)
  (#set! injection.language "markdown")
  (#set! injection.combined)
)
