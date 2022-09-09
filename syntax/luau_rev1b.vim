" Vim syntax file
" Language:     Luau 0.543
" Maintainer:    polychromatist <polychromatist 'at' proton me>
" First Author: polychromatist
" Last Change:  2022 Sep 7 (luau-vim v0.2.0)
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

syn keyword luauOperator and or not

syn keyword luauBoolean false true
syn keyword luauConstant nil

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

" the commented out sections are implemented in function:
"   s:defineExpressions('')

" Section: Luau string literal - core

" simple string matches - multiline, single and double single line strings
" syn region luauString matchgroup=luauString start="\[\z(=*\)\[" end="\]\z1\]"   contains=luauEscape
" syn region luauString matchgroup=luauString start=+'+ end=+'+ skip=+\\\\\|\\'+  contains=luauEscape oneline
" syn region luauString matchgroup=luauString start=+"+ end=+"+ skip=+\\\\\|\\"+  contains=luauEscape oneline

" Section: Luau string literal - line splice "\" & whitespace vacuum "\z"

" following six: syntax treatment for backslash string input device
" each type of line is distinguished into a unique match group
" it is expected to have:
"   (1) a quote opener line that can end in a backslash
"   (2) a continued string input line which can end in a backslash
"   (3) a final string input line that ends with a closing quote
" these three cases have two possibilities for quoting characters which
" cannot be interchanged.
" we also permit the \z device to be detected in these match groups when
" it is reasonably expected that the next line could contain one.
" syn match luauStringF1            /".\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luauStringF2,luauStringZF2,luauStringF3 skipwhite skipnl
" syn match luauStringF2 contained  /^.\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luauStringF2,luauStringZF2,luauStringF3 skipwhite skipnl
" syn match luauStringF3 contained  /^.\{-}\%(\\\)\@1<!"/ contains=luauEscape

" syn match luauStringF1Alt /'.\{-}\\$/                     contains=luauEscape,luauEOLEscape nextgroup=luauStringF2Alt,luauStringZF2Alt,luauStringF3Alt skipnl skipwhite
" syn match luauStringF2Alt /^.\{-}\\$/           contained contains=luauEscape,luauEOLEscape nextgroup=luauStringF2Alt,luauStringZF2Alt,luauStringF3Alt skipnl skipwhite
" syn match luauStringF3Alt /^.\{-}\%(\\\)\@1<!'/ contained contains=luauEscape

" following six: syntax treatment for \z string input device
" analogous to the backslash device, except using regions to properly
" model all types of acceptable behavior specified in Luau documentation.
" characters beyond a \z input device can span unbounded amounts of lines and
" whitespace, but not any character that is not whitespace. once a
" non-whitespace character is encountered, the \z device has completed its
" task and no other special behavior can be expected from it.
" syn region luauStringZF1           start=+"+ end=+\\z+ skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luauStringZF2,luauStringF2,luauStringZF3 skipwhite skipempty oneline
" syn region luauStringZF2 contained start=+^+ end=+\\z+ skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luauStringZF2,luauStringF2,luauStringZF3 skipwhite skipempty oneline
" syn region luauStringZF3 contained start=+^+ end=+"+   skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape oneline

" syn region luauStringZF1Alt           start=+'+ end=+\\z+ skip=+\\\\\|\\'+  contains=luauEscape,luauZEscape nextgroup=luauStringZF2Alt,luauStringF2Alt,luauStringZF3Alt skipwhite skipempty oneline
" syn region luauStringZF2Alt contained start=+^+ end=+\\z+ skip=+\\\\\|\\'+  contains=luauEscape,luauZEscape nextgroup=luauStringZF2Alt,luauStringF2Alt,luauStringZF3Alt skipwhite skipempty oneline
" syn region luauStringZF3Alt contained start=+^+ end=+'+   skip=+\\\\\|\\'+  contains=luauEscape,luauZEscape oneline

" Section: Luau string syn-clustering

" syn cluster luauGeneralString contains=luauString
" syn cluster luauGeneralString add=luauStringF1,luauStringF2,luauStringF3
" syn cluster luauGeneralString add=luauStringF1Alt,luauStringF2Alt,luauStringF3Alt
" syn cluster luauGeneralString add=luauStringZF1,luauStringZF2,luauStringZF3
" syn cluster luauGeneralString add=luauStringZF1Alt,luauStringZF2Alt,luauStringZF3Alt

" Section: Luau numerics

" in Luau, similar to python, numbers can be interfixed by underscores
" with no consequence.
" * if it's an irregular base, the format prefix (0x) cannot be interfixed.
" there are no formats for unsigned integers.

" (1) regular integers
" syn match luauNumber "\<[[:digit:]_]\+\>\%(\.\)\@!"
" (2) decimals; possible scientific E-notation with signed exponential
" syn match luauFloat  "\<[[:digit:]_]\+\.[[:digit:]_]*\%([eE][-+]\=[[:digit:]_]\+\)\=\>\%(\.\)\@!"
" (3) same as (3) with implicit zero on mantissa's most significant digit
" syn match luauFloat  "\.[[:digit:]_]\+\%([eE][-+]\=[[:digit:]_]\+\)\=\>\%(\.\)\@!"
" scientific E-notation with integer mantissa
" syn match luauNumber  "\<[[:digit:]_]\+[eE][-+]\=[[:digit:]_]\+\>\%(\.\)\@!"
" (4) hex-format integers 
" syn match luauNumber "\<0[xX][[:xdigit:]_]\+\>\%(\.\)\@!"
" (5) binary-format integers (w.r.t bit32 library)
" syn match luauNumber "\<0[bB][01_]\+\>\%(\.\)\@!"

" Section: syntax command generator - expressions
" there are many expression contexts. some are simply for raw expressions,
" like a while loop control expression or the top level anonymous wrapper ( ).
" many contexts allow you to write a list of expressions. some contexts, like
" table contents, allow you to choose between a list of expressions and a structured
" form [(exp)] = (exp) & (var) = (exp).
" the main two contexts for us to model are  the standard and the
" list style to cover most areas, and combining them with other syntax rules to
" form our syntax plugin.
" this means we need two (or more) parallel copies of the entire expression model,
" as the syn-nextgroup might differ in target to reflect that contrast in behavior.
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
        \ 'syn cluster luau%pGeneralString add=luau%pStringF1,luau%pStringF2,luau%pStringF3',
        \ 'syn cluster luau%pGeneralString add=luau%pStringF1Alt,luau%pStringF2Alt,luau%pStringF3Alt',
        \ 'syn cluster luau%pGeneralString add=luau%pStringZF1,luau%pStringZF2,luau%pStringZF3',
        \ 'syn cluster luau%pGeneralString add=luau%pStringZF1Alt,luau%pStringZF2Alt,luau%pStringZF3Alt' ],
      \ 'number': [ 
        \ 'syn match luau%pNumber "\<[[:digit:]_]\+\>\%%(\.\)\@!"%n',
        \ {'hilink': 'luauFloat', 'cmd': 'syn match luau%pFloat  "\<[[:digit:]_]\+\.[[:digit:]_]*\%%([eE][-+]\=[[:digit:]_]\+\)\=\>\%%(\.\)\@!"%n'},
        \ {'hilink': 'luauFloat', 'cmd': 'syn match luau%pFloat  "\.[[:digit:]_]\+\%%([eE][-+]\=[[:digit:]_]\+\)\=\>\%%(\.\)\@!"%n'},
        \ 'syn match luau%pNumber "\<[[:digit:]_]\+[eE][-+]\=[[:digit:]_]\+\>\%%(\.\)\@!"%n',
        \ 'syn match luau%pNumber "\<0[xX][[:xdigit:]_]\+\>\%%(\.\)\@!"%n',
        \ 'syn match luau%pNumber "\<0[bB][01_]\+\>\%%(\.\)\@!"%n' ],
      \ 'expc': [
        \ 'syn cluster luau%t contains=luau%t_Callback,luau%t_Wrap,luau%t_Var,luau%t_Variadic,luau%pNumber,luau%pFloat,@luau%pGeneralString',
        \ 'syn cluster luau%t add=luau%pNumber,luau%pFloat,@luau%pGeneralString',
        \ 'syn cluster luau%t2 contains=luau%t2_Invoke,luau%t2_Dot,luau%t2_Colon,luau%t2_Bracket%n' ],
      \ 'exp': [
        \ 'syn keyword luau%t_Callback function contained nextgroup=luau%t_FunctionParams skipwhite',
        \ 'syn region luau%t_FunctionParams matchgroup=luauF_ParamDelim start="(" end=")"me=e-1 contained contains=@luauBindings nextgroup=luau%t_Block',
        \ 'syn region luau%t_Block matchgroup=luauF_ParamDelim start=")" matchgroup=luauK_Function end="end" transparent contains=TOP contained%n',
        \ 'syn match luau%t_Var /\K\k*/ contains=luau%t_InvokedVar contained nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_InvokedVar /\K\k*\%%(\s*\%%(:\|(\)\)\@=/ contained nextgroup=@luau%t2 skipwhite',
        \ 'syn region luau%t_Wrap matchgroup=luau%t_Wrap start="(" end=")" transparent contained contains=@luau%e nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_Variadic /\.\.\./ contained%n' ],
      \ 'exp2': [
        \ 'syn match luau%t2_Dot /\./ contained nextgroup=@luau%t skipwhite',
        \ 'syn region luau%t2_Invoke matchgroup=luau%t2_Invoke start="(" end=")" contained contains=@luau%l nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t2_Colon /\%%(:\s*\)\@<=\K\k*\%%(\s*\%%((\|"\|''\|\[=*\[\)\)\@=/ contained nextgroup=luau%t2_Invoke skipwhite skipnl',
        \ 'syn region luau%t2_Bracket matchgroup=luau%t2_Bracket start="\[" end="\]" contained contains=@luau%e nextgroup=@luau%t2 skipwhite' ] }
" luauL2 - (L)ist expression splitters, notably including a comma
" syn match luauL2_Sep /,/ contained nextgroup=@luauL skipwhite skipempty
" syn match luauL2_Dot /\./ contained nextgroup=@luauL skipwhite
" syn region luauL2_Invoke matchgroup=luauL2_Invoke start="(" end=")" contained contains=@luauL nextgroup=@luauL2 skipwhite
" syn match luauL2_Colon /\%(:\s*\)\@<=\K\k*\%(\s*\%((\|"\|'\|\[=*\[\)\)\@=/ contained nextgroup=luauL2_Invoke skipwhite
" syn region luauL2_Bracket matchgroup=luauL2_Bracket start="\[" end="\]" contained contains=@luauE nextgroup=@luauL2 skipwhite

" luauL - (L)ist-contained expressions
" syn keyword luauL_Callback function contained nextgroup=luauL_FunctionParams skipwhite
" syn region luauL_FunctionParams matchgroup=luauF_ParamDelim start="(" end=")"me=e-1 contained contains=@luauBindings nextgroup=luauL_Block
" syn region luauL_Block matchgroup=luauF_ParamDelim start=")" matchgroup=luauStatement end="end" transparent contains=TOP contained nextgroup=luauL2_Sep skipwhite

" syn match luauL_Var /\K\k*/ contains=luauL_InvokedVar contained nextgroup=@luauL2 skipwhite
" syn match luauL_InvokedVar /\K\k*\%(\s*\%(:\|(\)\)\@=/ contained nextgroup=@luauL2 skipwhite
" syn region luauL_Wrap matchgroup=luauL_Wrap start="(" end=")" transparent contained contains=@luauE nextgroup=@luauL2 skipwhite
" syn match luauL_Variadic /\.\.\./ contained nextgroup=luauL2_Sep skipwhite

let s:hilinkmap = {
      \ 'string': 'luauString',
      \  'number': 'luauNumber'
      \ }

let s:_expout = []
let s:_hilinkout = {}

" embed a specific syntax command template with the given data and add it to
" the script expression generator stack - string
function! s:_embed_strexp(mval, gkdata, ekey) abort
  if (has_key(s:hilinkmap, a:ekey))
    let l:hilink = s:hilinkmap[a:ekey]

    if (!has_key(s:_hilinkout, l:hilink))
      let l:hlout = []
      let s:_hilinkout[l:hilink] = l:hlout
    else
      let l:hlout = s:_hilinkout[l:hilink]
    endif
  endif

  call s:_embed_exp(a:mval, a:gkdata, l:hlout)
endfunction

" same as above, for dictionary-based syntax template
function! s:_embed_dexp(mval, gkdata, ekey) abort
  if (has_key(a:mval, 'hilink'))
    let l:hilink = a:mval.hilink
  elseif (has_key(s:hilinkmap, a:ekey) && !has_key(a:mval, 'hilinkoff'))
    let l:hilink = s:hilinkmap[a:ekey]
  endif
  if (exists('l:hilink'))
    if (!has_key(s:_hilinkout, l:hilink))
      let l:hlout = []
      let s:_hilinkout[l:hilink] = l:hlout
    else
      let l:hlout  = s:_hilinkout[l:hilink]
    endif
  endif

  call s:_embed_exp(a:mval.cmd, a:gkdata, l:hlout)
endfunction

function! s:_embed_exp(exp, gkdata, ...) abort
  let l:exp = a:exp
  let l:cursor = 0
  let l:special = v:false
  let l:tail = ''

  while l:cursor < len(l:exp)
    " get current working character
    let l:curchar = l:exp[l:cursor]

    " see if it's a special character in a non-special context
    if (!l:special && l:curchar ==# '%')
      let l:special = v:true
    endif

    " work with a nonempty special token stack
    while !empty(l:tail)
      " get working token
      " if there's a mapped group key in input
      if a:gkdata[l:tail]
        let l:gkval = a:gkdata[l:tail]
        " update the cursor position
        " we start the cursor before the resolved token value
        " that's because it might have some unresolved tokens itself
        let l:cursor -= len(l:tail) - 1
        " update the syntax command
        let l:exp = strpart(l:exp, 0, l:cursor) . l:gkval . strpart(l:exp, l:cursor + len(l:tail) + 1)
        " reset tail
        let l:tail = ''

      " if we've got no more characters in the token...
      elseif empty(l:tail)
        " we need to remove the entire token
        " all that's left to remove is the token delimiter '%'
        " update the cursor position for this
        let l:cursor -= 1
        " and now the command
        let l:exp = strpart(l:exp, 0, l:cursor) . strpart(l:exp, l:cursor + 1)
        " reset tail
        let l:tail = ''

      " if there are more characters in the token...
      else
        " remove the last character and repeat process
        let l:tail = l:tail[:-2]
        let l:cursor -= 1
      endif
    endwhile
    
    if (l:special)
      if iskeyword(l:curchar)
        let l:tail += l:curchar
        let l:cursor += 1
      else
        if (empty(l:tail) && l:curchar ==# '%')
          let l:cursor -= 1
          let l:exp = strpart(l:exp, 0, l:cursor) . strpart(l:exp, l:cursor + 1)
        endif
        let l:special = v:false
      endif
    endif
  endwhile

  echom l:exp

  " for [l:gktoken, l:gkval] in items(a:gkdata)
    " let l:gkval = substitute(l:gkval, '%', '%%', 'g')
    " printf may be contributing to needless obscurity on this pattern
    " \%(\%(^\|[^%]\)\%(%%\)*\)\@<=%<TOKEN>
    " the lookbehind is to preserve escaped % signs in the syntax template
    "let l:exp = substitute(l:exp, printf('\%%(\%%(^\|[^%%]\)\%%(%%%%\)*\)\@<=%%%s', l:gktoken), l:gkval, 'g')
  " endfor
 "  let l:exp = substitute(l:exp, '%%', '%', 'g')
  call add(s:_expout, l:exp)

  if (exists('a:1') && (l:exp[4:10] !=# 'cluster'))
    call add(a:1, matchstr(l:exp, 'luau\k\+'))
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
      execute printf('hi def link %s %s', l:hout, l:houtkey)
    endfor
  endfor
endfunction

call s:_exp_new({
      \ 'string': {},
      \ 'number': {},
      \ 'expc':   {'t': 'E'},
      \ 'exp':    {'t': 'E', 'e': 'E', 'l': 'L'}
      \ 'exp2':   {} })
let s:_lexp_nxt1 = ' contained nextgroup=luau%l2_Sep skipwhite'
let s:_lexp_nxt2 = ',luau%l2_Sep'
let s:_lexp_nxt3 = ' nextgroup=luau%l2_Sep skipwhite'
call s:_exp_new({
      \ 'string': {'t': 'L', 'n': s:_lexp_nxt1, 'p': 'L_', 'l': 'L'},
      \ 'number': {'t': 'L', 'n': s:_lexp_nxt1, 'p': 'L_', 'l': 'L'},
      \ 'expc':   {'t': 'L', 'n': s:_lexp_nxt2, 'p': 'L_'},
      \ 'exp':    {'t': 'L', 'n': s:_lexp_nxt3, 'e', 'E', 'l': 'L'} })
call s:_process_expstack()

" Section: Luau grammar
syn cluster luauK contains=luauK_Local,luauK_Function,luauK_Do
syn cluster luauS contains=luauS_Wrap,luauS_DottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar,luauS_ColonInvocation
" exp membership determination
" prefixexp: simpleexp -> asexp -> exp
" luauCallback: 'function' funcbody -> prefixexp -> exp
" luauInvoke: functioncall -> prefixexp -> exp
" luauExpWrap: '(' exp ')' -> prefixexp -> exp
" syn cluster luauE contains=luauE_Callback,luauE_Wrap,luauE_Var,luauE_Variadic
" syn cluster luauE add=luauNumber,luauFloat,@luauGeneralString
" syn cluster luauE2 contains=luauE2_Invoke,luauE2_Dot,luauE2_Colon,luauE2_Bracket

" syn cluster luauL contains=luauL_Callback,luauL_Wrap,luauL_Var,luauL_Variadic
" syn cluster luauL add=luauL_Number,luauL_Float,@luauL_GeneralString
" syn cluster luauL2 contains=luauL2_Invoke,luauL2_Dot,luauL2_Colon,luauL2_Bracket,luauL2_Sep

" NOTE: suffix 2 on the grammar class label luauX stands for 'X splitter'

" luauE2 - (E)xpression splitters
syn match luauE2_Dot /\./ contained nextgroup=@luauE skipwhite
syn region luauE2_Invoke matchgroup=luauE2_Invoke start="(" end=")" contained contains=@luauL nextgroup=@luauE2 skipwhite
syn match luauE2_Colon /\%(:\s*\)\@<=\K\k*\%(\s*\%((\|"\|'\|\[=*\[\)\)\@=/ contained nextgroup=luauE2_Invoke skipwhite skipnl
syn region luauE2_Bracket matchgroup=luauE2_Bracket start="\[" end="\]" contained contains=@luauE nextgroup=@luauE2 skipwhite

" luauL2 - (L)ist expression splitters, notably including a comma
syn match luauL2_Sep /,/ contained nextgroup=@luauL skipwhite skipempty
syn match luauL2_Dot /\./ contained nextgroup=@luauL skipwhite
syn region luauL2_Invoke matchgroup=luauL2_Invoke start="(" end=")" contained contains=@luauL nextgroup=@luauL2 skipwhite
syn match luauL2_Colon /\%(:\s*\)\@<=\K\k*\%(\s*\%((\|"\|'\|\[=*\[\)\)\@=/ contained nextgroup=luauL2_Invoke skipwhite
syn region luauL2_Bracket matchgroup=luauL2_Bracket start="\[" end="\]" contained contains=@luauE nextgroup=@luauL2 skipwhite

" luauE - single (E)xpressions
syn keyword luauE_Callback function contained nextgroup=luauE_FunctionParams skipwhite
syn region luauE_FunctionParams matchgroup=luauF_ParamDelim start="(" end=")"me=e-1 contained contains=@luauBindings nextgroup=luauE_Block
syn region luauE_Block matchgroup=luauF_ParamDelim start=")" matchgroup=luauK_Function end="end" transparent contains=TOP contained

syn match luauE_Var /\K\k*/ contains=luauE_InvokedVar contained nextgroup=@luauE2 skipwhite
syn match luauE_InvokedVar /\K\k*\%(\s*\%(:\|(\)\)\@=/ contained nextgroup=@luauE2 skipwhite
syn region luauE_Wrap matchgroup=luauE_Wrap start="(" end=")" transparent contained contains=@luauE nextgroup=@luauE2 skipwhite
syn match luauE_Variadic /\.\.\./ contained

" luauL - (L)ist-contained expressions
syn keyword luauL_Callback function contained nextgroup=luauL_FunctionParams skipwhite
syn region luauL_FunctionParams matchgroup=luauF_ParamDelim start="(" end=")"me=e-1 contained contains=@luauBindings nextgroup=luauL_Block
syn region luauL_Block matchgroup=luauF_ParamDelim start=")" matchgroup=luauStatement end="end" transparent contains=TOP contained nextgroup=luauL2_Sep skipwhite

syn match luauL_Var /\K\k*/ contains=luauL_InvokedVar contained nextgroup=@luauL2 skipwhite
syn match luauL_InvokedVar /\K\k*\%(\s*\%(:\|(\)\)\@=/ contained nextgroup=@luauL2 skipwhite
syn region luauL_Wrap matchgroup=luauL_Wrap start="(" end=")" transparent contained contains=@luauE nextgroup=@luauL2 skipwhite
syn match luauL_Variadic /\.\.\./ contained nextgroup=luauL2_Sep skipwhite

" luauA - variable (A)ssignment syntax
syn match luauA_Symbol /=/ contained nextgroup=@luauL skipwhite
syn match luauA_Dot /\./ contained nextgroup=luauA_DottedVar,luauA_HungVar,luauA_TailVar skipwhite
syn match luauA_DottedVar /\K\k*\%(\s*\.\)\@=/ contained nextgroup=luauA_Dot skipwhite
syn match luauA_HungVar /\K\k*\%(\s*,\)\@=/ contained nextgroup=luauA_Comma skipwhite
syn match luauA_TailVar /\K\k*\%(\s*=\)\@=/ contained nextgroup=luauA_Symbol skipwhite
syn match luauA_Comma /,/ contained nextgroup=luauA_DottedVar,luauA_HungVar,luauA_TailVar skipwhite skipnl

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
syn region luauK_Do matchgroup=luauK_Keyword start="do" end="end" transparent contains=TOP

" luauR - (R)epeat

" Top Level Repeat: while
syn region luauR_While matchgroup=luauR_While start="while" end="do"me=e-2 contains=@luauE nextgroup=luauR_Do
syn region luauR_Do matchgroup=luauR_Keyword start="do" end="end" transparent contained contains=TOP

syn keyword luauR_For for nextgroup=luauD_HeadBinding skipwhite

" luauD - (D)omain of iteration
syn match luauD_HeadBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_ExpRangeStart,luauD_CanonRange skipwhite
syn match luauD_CanonListBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_CanonRange skipwhite
syn match luauD_CanonListBindingSep /,/ contained nextgroup=luauD_CanonListBinding skipwhite skipnl

syn region luauD_CanonRange matchgroup=luauD_CanonRange start="in" end="do"me=e-2 contained contains=@luauL nextgroup=luauR_Do

syn region luauD_ExpRangeStart matchgroup=luauD_ExpRangeStart start="=" end=","me=e-1 contained contains=@luauE nextgroup=luauD_ExpRangeStep
syn region luauD_ExpRangeStep matchgroup=luauD_ExpRangeStep start="," end="do"me=e-2 contained contains=@luauE nextgroup=luauR_Do

" luauS - top level syntactic (S)tatements

" Top Level Statement: top level variables
syn match luauS_DottedVar /\K\k*\%(\s*\.\)\@=/ nextgroup=luauV_Dot skipwhite
syn match luauS_HungVar /\K\k*\%(\s*,\)\@=/ nextgroup=luauA_Comma skipwhite
syn match luauS_TailVar /\K\k*\%(\s*=\)\@=/ nextgroup=luauA_Symbol skipwhite

" Top Level Statement: anonymous wrapped expression
syn region luauS_Wrap matchgroup=luauS_Wrap start="\%(\K\k*\|\]\|:\)\@<!(" end=")" transparent contains=@luauE nextgroup=@luauE2 skipwhite skipnl

" Top Level Statement: function or method invocation
syn match luauS_InvokedVar /\K\k*\%(\s*\%((\|'\|"\|\[=*\[\)\)\@=/  nextgroup=luauE2_Invoke skipwhite
syn match luauS_ColonInvocation /\K\k*\%(\s*:\)\@=/ nextgroup=luauV_Colon skipwhite skipnl

" luauV - operators on top level (V)ariables

syn match luauV_Dot /\./ transparent contained nextgroup=luauS_DottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar skipwhite
syn match luauV_Colon /:/ transparent contained nextgroup=luauS_InvokedVar skipwhite


if (g:luauHighlightTypes)
  " One of Luau's signature features is a rich type system.
  " * luau-lang.org/typecheck
  

endif

if (g:luauHighlightBuiltins)
  syn keyword luauBuiltin assert collectgarbage error gcinfo nextgroup=luauE2_Invoke
  syn keyword luauBuiltin getfenv getmetatable ipairs loadstring newproxy nextgroup=luauE2_Invoke
  syn keyword luauBuiltin next pairs pcall print rawget rawequal rawset require nextgroup=luauE2_Invoke
  syn keyword luauBuiltin setfenv select setmetatable tonumber tostring type nextgroup=luauE2_Invoke
  syn keyword luauBuiltin typeof unpack xpcall nextgroup=luauE2_Invoke

  syn keyword luauLibrary bit32 coroutine string table math os debug utf8 nextgroup=luauLibraryDot

  syn match luauLibraryDot /\./ transparent contained nextgroup=luauDotBit32,luauDotCoroutine,luauDotString,luauDotTable,luauDotMath,luauDotOS,luauDotDebug,luauDotUTF8

  syn keyword luauDotBit32 lrotate lshift replace rrotate rshift contained

  syn keyword luauDotCoroutine close create isyieldable resume running status wrap yield contained

  syn keyword luauDotString byte char find format gmatch gsub len lower contained
  syn keyword luauDotString match pack packsize rep reverse split sub unpack upper contained

  syn keyword luauDotTable create clear clone concat foreach foreachi find freeze contained
  syn keyword luauDotTable getn insert isfrozen maxn move pack remove sort unpack contained

  syn keyword luauDotMath abs acos asin atan atan2 ceil clamp cos cosh deg exp contained
  syn keyword luauDotMath floor fmod frexp huge ldexp log log10 max min modf noise pi contained
  syn keyword luauDotMath pow rad random randomseed round sign sin sinh sqrt tan tanh contained

  syn keyword luauDotOS clock date difftime time contained

  syn keyword luauDotDebug info traceback contained
  if (g:luauHighlightRoblox)
    syn keyword luauDotDebug profilebegin profileend resetmemorycategory setmemorycategory contained
  endif

  syn keyword luauDotUTF8 char codepoint codes len offset contained
endif

if (g:luauHighlightRoblox)
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
    syn keyword rbxDotData new contained

    syn keyword rbxDatatype Color3 nextgroup=rbxColor3Dot
    syn match rbxColor3Dot /\./ contained nextgroup=rbxDotColor3,rbxDotData
    syn keyword rbxDotColor3 fromRGB, fromHSV, fromHex contained

    syn keyword rbxDatatype DateTime nextgroup=rbxDateTimeDot
    syn match rbxDateTimeDot /\./ contained nextgroup=rbxDotDateTime,rbxDotData
    syn keyword rbxDotDateTime fromUnixTimestamp fromUnixTimestampMillis 

    syn keyword rbxDatatype Enums nextgroup=rbxEnumsMethod
    syn match rbxEnumsMethod /:/ contained nextgroup=rbxMethodEnums
    syn keyword rbxMethodEnums GetEnums contained

    syn keyword rbxDatatype Font nextgroup=rbxFontDot
    syn keyword rbxDatatype UDim2 nextgroup=rbxUDim2Dot
    syn keyword rbxDatatype Vector2 nextgroup=rbxVector2Dot
    syn keyword rbxDatatype Vector3 nextgroup=rbxVector3Dot

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
hi def link luauR_While               luauStatement
hi def link luauR_For                 luauStatement
hi def link luauR_Keyword             luauStatement
hi def link luauD_CanonRange          luauOperator
hi def link luauA_Symbol              luauOperator

hi def link luauD_ExpRangeStart       luauA_Symbol

hi def link luauE_Callback            luauStatement
hi def link luauL_Callback            luauE_Callback

hi def link luauE_Variadic            luauSpecial
hi def link luauL_Variadic            luauE_Variadic

hi def link luauF_Name                luauFunction
hi def link luauF_Method              luauF_Name

hi def link luauF_ParamDelim          luauDelimiter

hi def link luauS_InvokedVar          luauFunction
hi def link luauE_InvokedVar          luauS_InvokedVar
hi def link luauL_InvokedVar          luauS_InvokedVar

hi def link luauS_HungVar             luauIdentifier
hi def link luauA_HungVar             luauS_HungVar

hi def link luauS_TailVar             luauIdentifier
hi def link luauA_TailVar             luauS_TailVar

call s:_process_hilinkstack()

if (g:luauHighlightBuiltins)
  hi def link luauBuiltin           Function

  hi def link luauLibrary           luauBuiltin
  hi def link luauDotBit32          luauLibrary
  hi def link luauDotCoroutine      luauLibrary    
  hi def link luauDotString         luauLibrary
  hi def link luauDotTable          luauLibrary
  hi def link luauDotMath           luauLibrary
  hi def link luauDotOS             luauLibrary
  hi def link luauDotDebug          luauLibrary
  hi def link luauDotUTF8           luauLibrary
  if (g:luauHighlightRoblox)
    hi def link rbxIdentifier         Identifier
    hi def link rbxBuiltin            Function
    hi def link rbxInstantiator       Structure

    hi def link rbxLibrary            rbxBuiltin
    hi def link rbxDotTask            rbxLibrary

    hi def link rbxMethodGame         rbxInstantiator
  endif
endif

syn sync match luauSync grouphere NONE "\(\<function\s\+[a-zA-Z_][a-zA-Z0-9_]*(\)\@<=)$"
syn sync minlines=200

let b:current_syntax='luau'

let &cpo = s:cpo_save
unlet s:cpo_save
