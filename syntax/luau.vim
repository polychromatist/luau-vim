" Vim syntax file
" Language:     Luau 0.544
" Maintainer:    polychromatist <polychromatist 'at' proton me>
" First Author: polychromatist
" Last Change:  2022 Sep 12 (luau-vim v0.2.0)
" Options:      XXX Set options before loading the plugin.
"               luauHighlightAll = 0 or 1 (default 1)
"               - luauHighlightTypes = 0 or 1
"               - luauHighlightBuiltins = 0 or 1
"               - luauHighlightRoblox = 0 or 1
"               luauRobloxIncludeAPIDump = 0 or 1 (default 0)
"               - luauRobloxAPIDumpURL = < url >
"                 (default 'https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.txt')
"               - luauRobloxAPIDumpDirname = < relative path >
"                 (default 'robloxapi')
"               - luauRobloxNonstandardTypesAreErrors = 0 or 1
"                 (default 0)


if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:luauHighlightAll')
  let g:luauHighlightAll = 1
endif
let g:luauHighlightTypes = g:luauHighlightAll
let g:luauHighlightBuiltins = g:luauHighlightAll
let g:luauHighlightRoblox = g:luauHighlightAll
if !exists('g:luauRobloxIncludeAPIDump')
  let g:luauRobloxIncludeAPIDump = 0
endif

syn case match

syn keyword luauIdentifier _G _VERSION

" syn keyword luauBoolean false true
" syn keyword luauConstant nil

syn match luauComment "--.*$" contains=luauTodo
syn region luauComment matchgroup=luauComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luauTodo

syn keyword luauTodo TODO FIXME XXX NOTE contained

" Section: Luau string escape sequences

" (1) single-character string escape sequence
syn match luauEscape contained #\\[\\abfnrtv'"]#
" (2) hex based ASCII character escape sequence
syn match luauEscape contained #\\x[0-9a-fA-F]\{2}#
" digit based ASCII character escape sequence
syn match luauEscape contained #\\\d#
syn match luauEscape contained #\\\d\d#
syn match luauEscape contained #\\[01]\d\d#
syn match luauEscape contained #\\2[0-4]\d#
syn match luauEscape contained #\\25[0-5]#
" hex based unicode character escape sequence
syn match luauEscape contained #\\u{[0-9a-fA-F]\{,3}}#

" special string device '\z'
" to ignore whitespace and line breaks from input once only on a oneline
" string and continue at remainder if any exists
syn match luauZEscape contained #\\z\(\_s*\)\@=#

" special end-of-line backslash device
" to permit only the next line of a oneline string as continued string input
syn match luauEOLEscape contained #\\$#

" Section: syntax command generator - expressions
" there are many expression contexts. some are simply for single expressions,
" like a while loop control expression or the top level anonymous wrapper ( ).
" many contexts allow you to write a list of expressions. some contexts, like
" table contents, allow you to choose between a list of expressions and a structured
" form [(exp)] = (exp) & (var) = (exp).
" the main two contexts for us to model are the single style and the
" list style to cover most areas, and combining them with other syntax rules to
" form our syntax plugin.
" this means we need two (or more) parallel copies of the entire expression model,
" as the syn-nextgroup might differ in target to better reflect the true behavior.
" we can merely allow commas in all cases to fix this issue - this would not
" give us too much grief as long as the end user is typing proper Luau.
" despite that logic, maybe it could be useful to adopt the parallel model, as
" the grammar of Luau distinguishes between exp and explist. in that case,
" in order not to have to copy and paste for all changes to the
" common expression model, we use this generator.

let s:expmap = {
      \ 'string': [
      \   'syn region luau%pString matchgroup=luau%pString start="\[\z(=*\)\[" end="\]\z1\]"   contains=luauEscape%n',
        \ 'syn region luau%pString matchgroup=luau%pString start=+''+ end=+''+ skip=+\\\\\|\\''+  contains=luauEscape oneline%n',
        \ 'syn region luau%pString matchgroup=luau%pString start=+"+ end=+"+ skip=+\\\\\|\\"+  contains=luauEscape oneline%n',
        \ 'syn match luau%pStringF1            /".\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF3,luau%pStringZF2,luau%pStringF3 skipwhite skipnl',
        \ 'syn match luau%pStringF2 contained  /^.\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF2,luau%pStringZF2,luau%pStringF3 skipwhite skipnl',
        \ 'syn match luau%pStringF3 contained  /^.\{-}\%(\\\)\@1<!"/ contains=luauEscape%n',
        \ 'syn match luau%pStringF1Alt /''.\{-}\\$/                    contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF2Alt,luau%pStringZF2Alt,luau%pStringF3Alt skipnl skipwhite',
        \ 'syn match luau%pStringF2Alt /^.\{-}\\$/           contained contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF2Alt,luau%pStringZF2Alt,luau%pStringF3Alt skipnl skipwhite',
        \ 'syn match luau%pStringF3Alt /^.\{-}\%(\\\)\@1<!''/ contained contains=luauEscape%n',
        \ 'syn region luau%pStringZF1           start=+"+ end=+\\z+ skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2,luau%pStringF2,luau%pStringZF3 skipwhite skipempty oneline',
        \ 'syn region luau%pStringZF2 contained start=+^+ end=+\\z+ skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2,luau%pStringF2,luau%pStringZF3 skipwhite skipempty oneline',
        \ 'syn region luau%pStringZF3 contained start=+^+ end=+"+   skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape oneline%n',
        \ 'syn region luau%pStringZF1Alt           start=+''+ end=+\\z+ skip=+\\\\\|\\''+  contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2Alt,luau%pStringF2Alt,luau%pStringZF3Alt skipwhite skipempty oneline',
        \ 'syn region luau%pStringZF2Alt contained start=+^+ end=+\\z+ skip=+\\\\\|\\''+  contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2Alt,luau%pStringF2Alt,luau%pStringZF3Alt skipwhite skipempty oneline',
        \ 'syn region luau%pStringZF3Alt contained start=+^+ end=+''+   skip=+\\\\\|\\''+  contains=luauEscape,luauZEscape oneline%n',
        \ 'syn cluster luau%pGeneralString contains=luau%pString',
        \ 'syn cluster luau%pGeneralString add=luau%pStringF1',
        \ 'syn cluster luau%pGeneralString add=luau%pStringF1Alt',
        \ 'syn cluster luau%pGeneralString add=luau%pStringZF1',
        \ 'syn cluster luau%pGeneralString add=luau%pStringZF1Alt' ],
      \ 'number': [ 
        \ 'syn match luau%pNumber "\<[[:digit:]_]\+\>\%(\.\)\@!"%n',
        \ {'hilink': 'luauFloat', 'cmd': 'syn match luau%pFloat  "\<[[:digit:]_]\+\.[[:digit:]_]*\%([eE][-+]\=[[:digit:]_]\+\)\=\>\%(\.\)\@!"%n'},
        \ {'hilink': 'luauFloat', 'cmd': 'syn match luau%pFloat  "\.[[:digit:]_]\+\%([eE][-+]\=[[:digit:]_]\+\)\=\>\%(\.\)\@!"%n'},
        \ 'syn match luau%pNumber "\<[[:digit:]_]\+[eE][-+]\=[[:digit:]_]\+\>\%(\.\)\@!"%n',
        \ 'syn match luau%pNumber "\<0[xX][[:xdigit:]_]\+\>\%(\.\)\@!"%n',
        \ 'syn match luau%pNumber "\<0[bB][01_]\+\>\%(\.\)\@!"%n' ],
      \ 'const': [
        \ 'syn keyword luau%pNil nil%n',
        \ 'syn keyword luau%pBoolean true false%n' ],
      \ 'expc': [
        \ 'syn cluster luau%t contains=luau%t_Callback,luau%t_Wrap,luau%t_Var,luau%t_Variadic,luau%t_Table,luau%t_InlineIf,luau%t_BUiltinTmpl',
        \ 'syn cluster luau%t add=luau%pNumber,luau%pFloat,@luau%pGeneralString',
        \ 'syn cluster luau%t add=luau%pNil,luau%pBoolean',
        \ 'syn cluster luau%t2 contains=luau%t2_Invoke,luau%t2_Dot,luau%t2_Colon,luau%t2_Bracket,luau%t2_Binop%n' ],
      \ 'exp': [
        \ 'syn keyword luau%t_Callback function contained nextgroup=luau%t_FunctionParams skipwhite',
        \ 'syn region luau%t_FunctionParams matchgroup=luauF_ParamDelim start="(" end=")"me=e-1 contained contains=@luauBindings nextgroup=luau%t_Block',
        \ 'syn region luau%t_Block matchgroup=luauF_ParamDelim start=")" matchgroup=luauK_Function end="end" transparent contains=TOP contained%n',
        \ 'syn match luau%t_Var /\K\k*/ transparent contains=luau%t_InvokedVar,@luauGeneralBuiltin contained nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_InvokedVar /\K\k*\%(\s*\%((\|"\|''\|\[=*\[\)\)\@=/ contained nextgroup=@luau%t2_Invoke,@luau%t_GeneralString skipwhite skipnl',
        \ 'syn match luau%t_ColonInvoked /\K\k*\%(\s*\%((\|"\|''\|\[=*\[\)\)\@=/ contained nextgroup=luau%t2_Invoke,@luau%t_GeneralString skipwhite skipnl',
        \ 'syn match luau%t_BuiltinTmpl /\<\K\k*[.:]\K\k*\>/ contained contains=@luauGeneralBuiltin,luau%t_InvokedVar nextgroup=@luau%t2 skipwhite skipnl',
        \ 'syn region luau%t_Wrap matchgroup=luau%t_Wrap start="(" end=")" transparent contained contains=@luau%e nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_Variadic /\.\.\./ contained%n',
        \ 'syn match luau%t_Uop /#\|-\|\<not\>/ contained nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn region luau%t_Table matchgroup=luauStructure start="{" end="}" transparent contained contains=@luau%l,@luauT%n',
        \ 'syn region luau%t_InlineIf matchgroup=luauC_Keyword start="\<if\>" end="\<then\>"me=e-4 transparent contained contains=@luau%e,luau%e_Uop nextgroup=luau%t_InlineThen',
        \ 'syn region luau%t_InlineThen matchgroup=luauC_Keyword start="\<then\>" end="\<else\>" transparent contained contains=@luau%e,luau%e_Uop,luau%t_InlineElseif nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn region luau%t_InlineElseif matchgroup=luauC_Keyword start="\<elseif\>" end="\<then\>" transparent contained contains=@luau%e,luau%e_Uop nextgroup=@luau%e,luau%e_Uop skipwhite' ],
      \ 'exp2': [
        \ 'syn match luau%t2_Dot /\./ transparent contained nextgroup=@luau%t skipwhite',
        \ 'syn match luau%t2_Colon /\:/ transparent contained nextgroup=luau%t_ColonInvoked skipwhite',
        \ 'syn region luau%t2_Invoke matchgroup=luau%t2_Invoke start="(" end=")" contained contains=@luau%l,luau%l_Uop nextgroup=@luau%t2 skipwhite',
        \ 'syn region luau%t2_Bracket matchgroup=luau%t2_Bracket start="\[" end="\]" contained contains=@luau%e,luau%e_Uop nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t2_Binop /+\|-\|\*\|\/\|\^\|%\|\.\.\|<=\?\|>=\?\|[~=]=\|\<and\>\|\<or\>/ contained nextgroup=@luau%t,luau%t_Uop skipwhite'] }

let s:hilinkmap = {
      \ 'string': 'luauString',
      \  'number': 'luauNumber',
      \ 'const': 'luauConstant'
      \ }

let s:_expout = []
let s:_hilinkout = {}

" embed a specific syntax command template with the given data and add it to
" the script expression generator stack - string
function! s:_embed_strexp(mval, gkdata, ekey) abort
  if (has_key(s:hilinkmap, a:ekey))
    let l:hilink = s:hilinkmap[a:ekey]
  endif

  if exists('l:hilink')
    call s:_embed_exp(a:mval, a:gkdata, l:hilink)
  else
    call s:_embed_exp(a:mval, a:gkdata)
  endif
endfunction

" same as above, for dictionary-based syntax template
function! s:_embed_dexp(mval, gkdata, ekey) abort
  if (has_key(a:mval, 'hilink'))
    let l:hilink = a:mval.hilink
  elseif (has_key(s:hilinkmap, a:ekey) && !has_key(a:mval, 'hilinkoff'))
    let l:hilink = s:hilinkmap[a:ekey]
  endif

  if exists('l:hilink')
    call s:_embed_exp(a:mval.cmd, a:gkdata, l:hilink)
  else
    call s:_embed_exp(a:mval.cmd, a:gkdata)
  endif
endfunction

function! s:_parse_tokenbody(tsrc, tmap)
  let l:ttarg = a:tsrc
  for [l:tkey, l:tval] in items(a:tmap)
    let l:ttarg = substitute(l:ttarg, '%' . l:tkey, l:tval, 'g')
  endfor
  return l:ttarg
endfunction

function! s:_embed_exp(exp, gkdata, ...) abort
  let l:exp = s:_parse_tokenbody(a:exp, a:gkdata)

  " echo l:exp
  
  if empty(l:exp)
    return
  endif

  call add(s:_expout, l:exp)

  if (exists('a:1') && (l:exp[4:10] !=# 'cluster'))
    let l:hlexp = s:_parse_tokenbody(a:1, a:gkdata)
    let l:hlsrc = matchstr(l:exp, 'luau\k\+')

    if empty(l:hlsrc)
      throw 'empty highlight source on expression' . l:exp
    endif
    if (empty(l:hlexp) || l:hlsrc ==# l:hlexp)
      return
    endif

    if !has_key(s:_hilinkout, l:hlexp)
      let l:hlout = []
      let s:_hilinkout[l:hlexp] = l:hlout
    else
      let l:hlout = s:_hilinkout[l:hlexp]
    endif

    call add(l:hlout, l:hlsrc)
  endif
endfunction

" add a new expression context to the expression syntax command generator
" stack
function! s:_exp_new(grpdata) abort
  for [l:ekey, l:evalue] in items(s:expmap)
    if has_key(a:grpdata, l:ekey)
      let l:grpkeydata = a:grpdata[l:ekey]
    else
      continue
    endif

    for l:syndata in l:evalue
      if type(l:syndata) ==# v:t_string
        call s:_embed_strexp(l:syndata, l:grpkeydata, l:ekey)
      elseif type(l:syndata) ==# v:t_dict
        call s:_embed_dexp(l:syndata, l:grpkeydata, l:ekey)
      endif
    endfor
  endfor
endfunction

function! s:_process_expstack()
  for l:syntax_query in s:_expout
    execute l:syntax_query
  endfor
endfunction

function! s:_process_hilinkstack()
  for [l:houtkey, l:houtlist] in items(s:_hilinkout)
    for l:hout in l:houtlist
      "echo printf('hi def link %s %s', l:hout, l:houtkey)
      execute printf('hi def link %s %s', l:hout, l:houtkey)
    endfor
  endfor
endfunction

" Section: Luau grammar

" @luauE, @luauE2, luauNumber, luauFloat, @luauGeneralString
let s:_exp_nxt1 = ' nextgroup=luauE2_Binop skipwhite'
call s:_exp_new({
     \ 'string': {           'n': s:_exp_nxt1,  'p': ''                    },
     \ 'number': {           'n': s:_exp_nxt1,  'p': ''                    },
     \ 'const':  {           'n': s:_exp_nxt1,  'p': ''                    },
     \ 'expc':   {'t': 'E',  'n': '',           'p': ''                    },
     \ 'exp':    {'t': 'E',  'n': '',                   'e': 'E', 'l': 'L' },
     \ 'exp2':   {'t': 'E',                             'e': 'E', 'l': 'L' } })
" @luauL, @luauL2, luauL_Number, luauL_Float, @luauL_GeneralString
let s:_lexp_nxt1 = ' contained nextgroup=luauL2_Sep,luauL2_Binop skipwhite'
let s:_lexp_nxt2 = ',luauL2_Sep'
let s:_lexp_nxt3 = ' nextgroup=luauL2_Sep skipwhite'
call s:_exp_new({
     \ 'string': {           'n': s:_lexp_nxt1, 'p': 'L_',                    },
     \ 'number': {           'n': s:_lexp_nxt1, 'p': 'L_',                    },
     \ 'const':  {           'n': s:_lexp_nxt1, 'p': 'L_'                     },
     \ 'expc':   {'t': 'L',  'n': s:_lexp_nxt2, 'p': 'L_',           'l': 'L' },
     \ 'exp':    {'t': 'L',  'n': s:_lexp_nxt3,            'e': 'E', 'l': 'L' },
     \ 'exp2':   {'t': 'L',                                'e': 'E', 'l': 'L' } })
call s:_process_expstack()

syn cluster luauK contains=luauK_Local,luauK_Function,luauK_Do
syn cluster luauS contains=luauS_Wrap,luauS_DottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar,luauS_ColonInvocation,luauS_DictRef
syn cluster luauR contains=luauR_While,luauR_Repeat,luauR_For
syn cluster luauC contains=luauC_If
syn cluster luauTop contains=@luauK,@luauS,@luauR,@luauC,@luauGeneralBuiltin

syn cluster luauA contains=luauA_DottedVar,luauA_HungVar,luauA_TailVar,luauA_DictRef
syn cluster luauT contains=luauT_NDictK,luauT_EDictK,luauT_Symbol,luauT_Semicolon

syn match luauL2_Sep /,/ contained nextgroup=@luauL,luauL_Uop skipwhite skipempty

" luauA - variable (A)ssignment syntax
syn match luauA_Symbol /=/ contained nextgroup=@luauL,luauL_Uop skipwhite
syn match luauA_Symbol '+=\|-=\|\/=\|\*=\|\^=\|\.\.=' contained nextgroup=@luauE,luauE_Uop skipwhite
syn match luauA_Dot /\./ contained nextgroup=@luauA skipwhite
syn match luauA_DottedVar /\K\k*\%(\s*\.\)\@=/ contained nextgroup=luauA_Dot skipwhite
syn match luauA_DictRef /\K\k*\%(\s*\[\)\@=/ contained nextgroup=luauA_DictKey skipwhite
syn region luauA_DictKey start="\[" end="\]" transparent contained contains=@luauE nextgroup=luauA_Comma,luauA_DictKey,luauA_Dot,luauA_Symbol skipwhite
syn match luauA_HungVar /\K\k*\%(\s*,\)\@=/ contained nextgroup=luauA_Comma skipwhite
syn match luauA_TailVar /\K\k*\%(\s*=\)\@=/ contained nextgroup=luauA_Symbol skipwhite
syn match luauA_Comma /,/ contained nextgroup=@luauA skipwhite skipnl

" luauK - (K)eyword, luauF - (F)unction header, luauB - (B)indings

" Top Level Keyword: function
syn keyword luauK_Function function nextgroup=luauF_Name skipwhite
syn match luauF_Name /\K\k*/ contained nextgroup=luauF_Sep,luauF_Colon,luauE_FunctionParams skipwhite
syn match luauF_Method /\K\k*/ contained nextgroup=luauE_FunctionParams skipwhite
syn match luauF_Sep /\./ contained nextgroup=luauF_Name skipwhite
syn match luauF_Colon /:/ contained nextgroup=luauF_Method skipwhite
syn match luauF_ParamDelim /(/ contained
syn match luauF_ParamDelim /)/ contained

" Top Level Keyword: local
syn keyword luauK_Local local nextgroup=luauK_Function,luauB_Name skipwhite
syn match luauB_Name /\K\k*/ contained nextgroup=luauB_Sep,luauA_Symbol skipwhite skipnl
syn match luauB_Sep /,/ contained nextgroup=luauB_Name skipwhite

" Top Level Keyword: do (anonymous block)
syn region luauK_Do matchgroup=luauK_Keyword start="\<do\>" end="\<end\>" transparent contains=TOP

" luauR - (R)epeat

" Top Level Repeat: while
syn region luauR_While matchgroup=luauR_Keyword start="\<while\>" end="\<do\>"me=e-2 transparent contains=@luauE,luauE_Uop nextgroup=luauR_Do
syn region luauR_Do matchgroup=luauR_Keyword start="\<do\>" end="\<end\>" transparent contained contains=TOP
syn region luauR_Repeat matchgroup=luauR_Keyword start="\<repeat\>" end="\<until\>" transparent contains=TOP nextgroup=@luauE,luauE_Uop skipwhite skipnl

syn keyword luauR_For for nextgroup=luauD_HeadBinding skipwhite

" luauD - (D)omain of iteration
syn match luauD_HeadBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_ExpRangeStart,luauD_CanonRange skipwhite
syn match luauD_CanonListBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_CanonRange skipwhite
syn match luauD_CanonListBindingSep /,/ contained nextgroup=luauD_CanonListBinding skipwhite skipnl

syn region luauD_CanonRange matchgroup=luauD_CanonRange start="\<in\>" end="\<do\>"me=e-2 contained contains=@luauL,luauL_Uop nextgroup=luauR_Do

syn region luauD_ExpRangeStart matchgroup=luauD_ExpRangeStart start="=" end=","me=e-1 contained contains=@luauE,luauE_Uop nextgroup=luauD_ExpRangeStep
syn region luauD_ExpRangeStep matchgroup=luauD_ExpRangeStep start="," end="\<do\>"me=e-2 contained contains=@luauE,luauE_Uop nextgroup=luauR_Do

" luauS - top level syntactic (S)tatements

" Top Level Statement: variable tokens
syn match luauS_DottedVar /\K\k*\%(\s*\.\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauV_Dot skipwhite
syn match luauS_HungVar /\K\k*\%(\s*,\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauA_Comma skipwhite
syn match luauS_TailVar /\K\k*\%(\s*\%(=\|+=\|-=\|\/=\|\*=\|\^=\|\.\.=\)\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauA_Symbol skipwhite
syn match luauS_DictRef /\K\k*\%(\s*\[\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauS_DictKey skipwhite
syn region luauS_DictKey start="\[" end="\]" transparent contained contains=@luauE,luauE_Uop nextgroup=luauV_Dot,luauV_Colon,luauS_DictKey,luauA_Comma,luauA_Symbol skipwhite

" Top Level Statement: anonymous wrapped expression
syn region luauS_Wrap matchgroup=luauS_Wrap start="\%(\K\k*\|\]\|:\)\@<!(" end=")" transparent contains=@luauE,luauE_Uop nextgroup=@luauE2 skipwhite skipnl

" Top Level Statement: function or method invocation
syn match luauS_InvokedVar /\K\k*\%(\s*\%((\|'\|"\|\[=*\[\)\)\@=/ nextgroup=luauE2_Invoke skipwhite
syn match luauS_ColonInvocation /\K\k*\%(\s*:\)\@=/ nextgroup=luauV_Colon skipwhite skipnl

" luauV - operators on top level (V)ariables

syn match luauV_Dot /\./ transparent contained nextgroup=luauS_DottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar skipwhite
syn match luauV_Colon /:/ transparent contained nextgroup=luauS_InvokedVar skipwhite

" luauC - top level & contained (C)onditional
syn region luauC_If matchgroup=luauC_Keyword start="\<if\>" end="\<then\>"me=e-4 transparent contains=@luauE,luauE_Uop nextgroup=luauC_Then
syn region luauC_Then matchgroup=luauC_Keyword start="\<then\>" end="\<end\>" transparent contained contains=@luauTop,luauC_Elseif,luauC_Else
syn region luauC_Elseif matchgroup=luauC_Keyword start="\<elseif\>" end="\<then\>" transparent contained contains=@luauE,luauE_Uop nextgroup=luauC_Then
syn keyword luauC_Else else contained

" luauT - (T)able fields
syn match luauT_Symbol /=/ contained nextgroup=@luauL,luauL_Uop skipwhite
syn match luauT_Semicolon /;/ contained nextgroup=@luauL,@luauT,luauL_Uop skipwhite skipempty
syn region luauT_EDictK matchgroup=luauDelimiter start="\[" end="\]" transparent contained contains=@luauE,luauE_Uop nextgroup=luauT_Symbol skipwhite
syn match luauT_NDictK /\K\k*\%(\s*=\)\@=/ contained nextgroup=luauT_Symbol skipwhite

" syn region luauE_InlineIf matchgroup=luauC_Keyword start="\<if\>" end="\<then\>"me=e-4 transparent contained contains=@luauE,luauE_Uop nextgroup=luauE_InlineThen
" syn region luauE_InlineThen matchgroup=luauC_Keyword start="\<then\>" end="\<else\>" transparent contained contains=@luauE,luauE_Uop,luauE_InlineElseif nextgroup=@luauE,luauE_Uop
" syn region luauE_InlineElseif matchgroup=luauC_Keyword start="\<elseif\>" end="\<then\>" transparent contained contains=@luauE,luauE_Uop

" syn cluster luauE add=luauE_InlineIf

if (g:luauHighlightTypes)
  " One of Luau's signature features is a rich type system.
  " * luau-lang.org/typecheck
  

endif

syn cluster luauGeneralBuiltin contains=luauBuiltin,luauLibrary,luauIdentifier
syn cluster luauGeneralBuiltinDot contains=luauLibraryDot
if (g:luauHighlightBuiltins)

  " The Luau builtin functions are straightforward.
  " There are some extra debug library functions in Roblox.
  syn keyword luauBuiltin assert collectgarbage error gcinfo nextgroup=luauE2_Invoke
  syn keyword luauBuiltin getfenv getmetatable ipairs loadstring newproxy nextgroup=luauE2_Invoke
  syn keyword luauBuiltin next pairs pcall print rawget rawequal rawset require nextgroup=luauE2_Invoke
  syn keyword luauBuiltin setfenv select setmetatable tonumber tostring type nextgroup=luauE2_Invoke
  syn keyword luauBuiltin typeof unpack xpcall nextgroup=luauE2_Invoke

  syn keyword luauLibrary bit32 coroutine string table math os debug utf8 nextgroup=luauLibraryDot

  syn match luauLibraryDot /\./ transparent contained nextgroup=luauDotBit32,luauDotCoroutine,luauDotString,luauDotTable,luauDotMath,luauDotMath_const,luauDotOS,luauDotDebug,luauDotUTF8

  syn keyword luauDotBit32 arshift lrotate lshift replace rrotate rshift contained nextgroup=luauE2_Invoke

  syn keyword luauDotCoroutine close create isyieldable resume running status wrap yield contained nextgroup=luauE2_Invoke

  syn keyword luauDotString byte char find format gmatch gsub len lower contained nextgroup=luauE2_Invoke
  syn keyword luauDotString match pack packsize rep reverse split sub unpack upper contained nextgroup=luauE2_Invoke

  syn keyword luauDotTable create clear clone concat foreach foreachi find freeze contained nextgroup=luauE2_Invoke
  syn keyword luauDotTable getn insert isfrozen maxn move pack remove sort unpack contained nextgroup=luauE2_Invoke

  syn keyword luauDotMath abs acos asin atan atan2 ceil clamp cos cosh deg exp contained nextgroup=luauE2_Invoke
  syn keyword luauDotMath floor fmod frexp ldexp log log10 max min modf noise contained nextgroup=luauE2_Invoke
  syn keyword luauDotMath pow rad random randomseed round sign sin sinh sqrt tan tanh contained nextgroup=luauE2_Invoke
  syn keyword luauDotMath_const huge pi contained

  syn keyword luauDotOS clock date difftime time contained nextgroup=luauE2_Invoke

  syn keyword luauDotDebug info traceback contained nextgroup=luauE2_Invoke
  if (g:luauHighlightRoblox)
    syn keyword luauDotDebug profilebegin profileend resetmemorycategory setmemorycategory contained nextgroup=luauE2_Invoke
  endif

  syn keyword luauDotUTF8 char codepoint codes len offset contained nextgroup=luauE2_Invoke
endif

syn cluster luauGeneralBuiltin add=rbxIdentifier,rbxBuiltin,rbxLibrary,rbxDatatype
syn cluster luauGeneralBuiltinDot add=rbxLibraryDot,rbxDataDot,rbxCFrameDot,rbxColor3Dot,rbxDateTimeDot,rbxFontDot,rbxUDim2Dot,rbxVector2Dot,rbxVector3Dot,rbxInstanceDot
if (g:luauHighlightRoblox)
  syn cluster luauTop add=rbxIdentifier,rbxBuiltin,rbxLibrary,rbxDatatype

  syn keyword rbxIdentifier game nextgroup=rbxGameMethod
  syn keyword rbxIdentifier plugin script workspace shared

  syn keyword rbxBuiltin delay DebuggerManager elapsedTime LoadLibrary PluginManager
  syn keyword rbxBuiltin printidentity settings spawn stats tick time UserSettings
  syn keyword rbxBuiltin version warn

  syn keyword rbxLibrary task nextgroup=rbxLibraryDot

  syn match rbxLibraryDot /\./ transparent contained nextgroup=rbxDotTask

  syn keyword rbxDotTask cancel defer delay desynchronize spawn wait contained

  syn match rbxGameMethod /:/ contained nextgroup=rbxMethodGame
  syn keyword rbxMethodGame GetService nextgroup=rbxGetService skipwhite
  " syn region rbxGetService start="GetService"

  if (g:luauHighlightTypes)
    syn keyword rbxDatatype Enum transparent
    syn keyword rbxDatatype Enum EnumItem contained
    syn keyword rbxDatatype RBXScriptConnection RBXScriptSignal contained
    syn keyword rbxDatatype RaycastResult contained

    syn keyword rbxDatatype Axes BrickColor CatalogSearchParams ColorSequence nextgroup=rbxDataDot
    syn keyword rbxDatatype ColorSequence ColorSequenceKeypoint nextgroup=rbxDataDot
    syn keyword rbxDatatype DockWidgetPluginGuiInfo Faces FloatCurveKey nextgroup=rbxDataDot
    syn keyword rbxDatatype NumberRange NumberSequence NumberSequenceKeypoint nextgroup=rbxDataDot
    syn keyword rbxDatatype OverlapParams PathWaypoint PhysicalProperties nextgroup=rbxDataDot
    syn keyword rbxDatatype Random RaycastParams Rect Region3 nextgroup=rbxDataDot
    syn keyword rbxDatatype Region3int16 TweenInfo UDim Vector2int16 nextgroup=rbxDataDot
    syn keyword rbxDatatype Vector3int16 nextgroup=rbxDataDot
    syn match rbxDataDot /\./ contained nextgroup=rbxDotData
    syn keyword rbxDotData new contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype CFrame nextgroup=rbxCFrameDot
    syn match rbxCFrameDot /\./ contained nextgroup=rbxDotCFrame,rbxDotData
    syn keyword rbxDotCFrame lookAt fromEulerAnglesXYZ fromEulerAnglesYXZ contained nextgroup=luauE2_Invoke
    syn keyword rbxDotCFrame Angles fromOrientation fromAxisAngle fromMatrix contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Color3 nextgroup=rbxColor3Dot
    syn match rbxColor3Dot /\./ contained nextgroup=rbxDotColor3,rbxDotData
    syn keyword rbxDotColor3 fromRGB, fromHSV, fromHex contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype DateTime nextgroup=rbxDateTimeDot
    syn match rbxDateTimeDot /\./ contained nextgroup=rbxDotDateTime,rbxDotData
    syn keyword rbxDotDateTime fromUnixTimestamp fromUnixTimestampMillis nextgroup=luauE2_Invoke
    syn keyword rbxDotDateTime fromUniversalTime fromLocalTime fromIsoDate nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Enums nextgroup=rbxEnumsMethod
    syn match rbxEnumsMethod /:/ contained nextgroup=rbxMethodEnums
    syn keyword rbxMethodEnums GetEnums contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Font nextgroup=rbxFontDot
    syn match rbxFontDot /\./ contained nextgroup=rbxDotFont,rbxDotData
    syn keyword rbxDotFont fromEnum contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype UDim2 nextgroup=rbxUDim2Dot
    syn match rbxUDim2Dot /\./ contained nextgroup=rbxDotUDim2,rbxDotData
    syn keyword rbxDotUDim2 fromScale fromOffset contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Vector2 nextgroup=rbxVector2Dot
    syn match rbxVector2Dot /\./ contained nextgroup=rbxDotVector2_const,rbxDotData
    syn keyword rbxDotVector2_const zero one xAxis yAxis contained

    syn keyword rbxDatatype Vector3 nextgroup=rbxVector3Dot,rbxDotData
    syn match rbxVector3Dot /\./ contained nextgroup=rbxDotVector3,rbxDotVector3_const
    syn keyword rbxDotVector3_const zero one xAxis yAxis zAxis contained
    syn keyword rbxDotVector3 FromNormalId FromAxis contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Instance nextgroup=rbxInstanceDot
    syn match rbxInstanceDot /\./ contained nextgroup=rbxDotInstance
    syn keyword rbxDotInstance new contained nextgroup=rbxInstanceNewInvoke,rbxInstanceNewArg skipwhite
    syn region rbxInstanceNewInvoke matchgroup=luauDelimiter start=+(\%(\_s*\z("\|'\)\)\@=+ end=+\%(\z1\_s*\)\@<=)+ contained contains=rbxInstanceNewArg keepend
    syn region rbxInstanceNewArg start=+\z("\|'\)+ end=+\z1+ transparent contained 

  endif

  if (g:luauRobloxIncludeAPIDump)
    let s:rbx_syngen_fpath = luau_vim#get_rbx_syngen_fpath()
    if (!filereadable(s:rbx_syngen_fpath))
      call luau_vim#rbx_api_parse()
    endif

    source! s:rbx_syngen_fpath
  endif
endif

hi def link luauBoolean               Boolean
hi def link luauConstant              Constant
hi def link luauIdentifier            Identifier
hi def link luauStatement             Statement
hi def link luauString                String
hi def link luauNumber                Number
hi def link luauFloat                 Float
hi def link luauFunction              Function
hi def link luauConditional           Conditional
hi def link luauOperator              Operator
hi def link luauComment               Comment
hi def link luauEscape                Special
hi def link luauSpecial               Special
hi def link luauTodo                  Todo
hi def link luauStructure             Structure
hi def link luauDelimiter             Delimiter

hi def link luauZEscape               luauEscape
hi def link luauEOLEscape             luauEscape
hi def link luauAnonymousFunction     luauStatement
hi def link luauK_Function            luauStatement
hi def link luauK_Local               luauStatement
hi def link luauK_Keyword             luauStatement
hi def link luauR_For                 luauStatement
hi def link luauR_Keyword             luauStatement
hi def link luauC_Keyword             luauConditional
hi def link luauD_CanonRange          luauOperator
hi def link luauA_Symbol              luauOperator

hi def link luauD_ExpRangeStart       luauA_Symbol

hi def link luauT_Symbol              luauA_Symbol

hi def link luauE_Callback            luauStatement
hi def link luauL_Callback            luauE_Callback

hi def link luauE_Variadic            luauSpecial
hi def link luauL_Variadic            luauE_Variadic

hi def link luauE_Uop                 luauOperator
hi def link luauL_Uop                 luauE_Uop
hi def link luauE2_Binop              luauOperator
hi def link luauL2_Binop              luauE2_Binop

hi def link luauF_Name                luauFunction
hi def link luauF_Method              luauF_Name

hi def link luauF_ParamDelim          luauDelimiter

hi def link luauS_InvokedVar          luauFunction
hi def link luauE_InvokedVar          luauS_InvokedVar
hi def link luauL_InvokedVar          luauS_InvokedVar
hi def link luauE_ColonInvoked        luauS_InvokedVar
hi def link luauL_ColonInvoked        luauS_InvokedVar

hi def link luauS_HungVar             luauIdentifier
hi def link luauA_HungVar             luauS_HungVar

hi def link luauS_TailVar             luauIdentifier
hi def link luauA_TailVar             luauS_TailVar

hi def link luauC_Else                luauC_Keyword

call s:_process_hilinkstack()

if (g:luauHighlightBuiltins)
  hi def link luauBuiltin           Function

  hi def link luauLibrary           luauBuiltin
  hi def link luauDotBit32          luauLibrary
  hi def link luauDotCoroutine      luauLibrary    
  hi def link luauDotString         luauLibrary
  hi def link luauDotTable          luauLibrary
  hi def link luauDotMath           luauLibrary
  hi def link luauDotMath_const     luauConstant
  hi def link luauDotOS             luauLibrary
  hi def link luauDotDebug          luauLibrary
  hi def link luauDotUTF8           luauLibrary
  if (g:luauHighlightRoblox)
    hi def link rbxIdentifier         Identifier
    hi def link rbxBuiltin            Function
    hi def link rbxMethod             Function
    hi def link rbxInstantiator       Structure
    hi def link rbxConstant           luauConstant

    hi def link rbxLibrary            rbxBuiltin
    hi def link rbxDotTask            rbxLibrary

    hi def link rbxMethodGame         rbxInstantiator

    hi def link rbxDatatype           rbxIdentifier
    hi def link rbxDotData            rbxInstantiator
    hi def link rbxDotCFrame          rbxInstantiator
    hi def link rbxDotColor3          rbxInstantiator
    hi def link rbxDotDateTime        rbxInstantiator
    hi def link rbxMethodEnums        rbxMethod
    hi def link rbxDotFont            rbxInstantiator
    hi def link rbxDotUDim2           rbxInstantiator
    hi def link rbxDotVector2_const   rbxConstant
    hi def link rbxDotVector3_const   rbxConstant
    hi def link rbxDotVector3         rbxInstantiator
    hi def link rbxDotInstance        rbxInstantiator
  endif
endif

syn sync match luauSync grouphere NONE "\(\<function\s\+[a-zA-Z_][a-zA-Z0-9_]*(\)\@<=)$"
syn sync minlines=200

let b:current_syntax='luau'

let &cpo = s:cpo_save
unlet s:cpo_save
