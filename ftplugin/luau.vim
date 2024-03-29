" Vim filetype plugin file.
" Language:	Luau
" Maintainer:	polychromatist (polychromatist@pm.me)
" Last Change:	2022 Aug 31

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

" Set 'formatoptions' to break comment lines but not other lines, and insert
" the comment leader when hitting <CR> or using "o".
setlocal fo-=t fo+=croql

setlocal com=:--
setlocal cms=--%s
setlocal suffixesadd=.luau


" The following lines enable the macros/matchit.vim plugin for
" extended matching with the % key.
if exists("loaded_matchit")

  let b:match_ignorecase = 0
  let b:match_words =
    \ '\<\%(do\|function\|if\)\>:' .
    \ '\<\%(return\|else\|elseif\)\>:' .
    \ '\<end\>,' .
    \ '\<repeat\>:\<until\>'

endif " exists("loaded_matchit")

let &cpo = s:cpo_save
unlet s:cpo_save

let b:undo_ftplugin = "setlocal fo< com< cms< suffixesadd<"

