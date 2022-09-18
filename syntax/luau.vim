" Vim syntax file
" Language:     Luau 0.545
" Maintainer:    polychromatist <polychromatist 'at' proton me>
" First Author: polychromatist
" Last Change:  2022 Sep 17 (luau-vim v0.3.0b)
" Options:      XXX Set options before loading the plugin.
"               luauHighlightAll = 0 or 1 (no default)
"               - luauHighlightTypes = 0 or 1 (default 1)
"               - luauHighlightBuiltins = 0 or 1 (default 1)
"               - luauHighlightRoblox = 0 or 1 (default 1)
"               luauRobloxIncludeAPIDump = 0 or 1 (default 0)
"               - luauRobloxAPIDumpURL = < url >
"                 (default 'https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.txt')
"               - luauRobloxAPIDumpDirname = < relative path >
"                 (default 'robloxapi')
"               - luauRobloxNonstandardTypesAreErrors = 0 or 1
"                 (default 0)
"

" TODO: make functions adopt the following region format:
"   syn region start="function" end="end"


if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:luauHighlightAll')
  let g:luauHighlightTypes = exists('g:luauHighlightTypes') ? g:luauHighlightTypes : 1
  let g:luauHighlightBuiltins = exists('g:luauHighlightBuiltins') ? g:luauHighlightBuiltins : 1
  let g:luauHighlightRoblox = exists('g:luauHighlightRoblox') ? g:luauHighlightRoblox : 1
else
  let g:luauHighlightTypes = g:luauHighlightAll
  let g:luauHighlightBuiltins = g:luauHighlightAll
  let g:luauHighlightRoblox = g:luauHighlightAll
endif
if !exists('g:luauRobloxIncludeAPIDump')
  let g:luauRobloxIncludeAPIDump = 0
endif

syn case match

syn keyword luauIdentifier _G _VERSION

syn match luauComment "--.*$" contains=luauTodo
syn region luauComment matchgroup=luauComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luauTodo,luauDirective

syn region luauDirectiveHeader start="\%^" end="\K"me=e-1 transparent contains=luauComment,luauDirective
syn match luauDirective /\s*\zs--!\(strict\|nonstrict\|nocheck\)\ze\s*$/ contained
syn match luauDirective /^\s*\zs--!nolint\ze\s/ contained nextgroup=luauLintWarnings skipwhite
syn match luauLintWarnings /.*$/ contained contains=luauLintWarning
syn keyword luauLintWarning UnknownGlobal DeprecatedGlobal GlobalUsedAsLocal LocalShadow SameLineStatement MultiLineStatement contained skipwhite
syn keyword luauLintWarning LocalUnused FunctionUnused ImportUnused BuiltinGlobalWrite PlaceholderRead UnreachableCode contained skipwhite
syn keyword luauLintWarning UnknownType ForRange UnbalancedAssignment ImplicitReturn DuplicateLocal FormatString TableLiteral contained skipwhite
syn keyword luauLintWarning UninitializedLocal DuplicateFunction DeprecatedApi TableOperations DuplicateCondition MisleadingAndOr contained skipwhite
syn keyword luauLintWarning CommentDirective IntegerParsing ComparisonPrecedence contained skipwhite

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
        \ 'syn cluster luau%t contains=luau%t_Callback,luau%t_Wrap,luau%t_Var,luau%t_Variadic,luau%t_Table,luau%t_InlineIf,luau%t_BuiltinTmpl',
        \ 'syn cluster luau%t add=luau%pNumber,luau%pFloat,@luau%pGeneralString',
        \ 'syn cluster luau%t add=luau%pNil,luau%pBoolean,luauComment',
        \ 'syn cluster luau%t2 contains=luau%t2_Invoke,luau%t2_Dot,luau%t2_Colon,luau%t2_Bracket,luau%t2_Binop,luau%t2_CastSymbol%n' ],
      \ 'exp': [
        \ 'syn keyword luau%t_Callback function contained nextgroup=luau%t_FunctionParams,luau%t_CallbackGen skipwhite',
        \ 'syn region luau%t_CallbackGen matchgroup=luauStructure start="<" end=">" transparent contained contains=@luauTypeGenParam nextgroup=luau%t_FunctionParams skipwhite skipnl',
        \ 'syn region luau%t_FunctionParams matchgroup=luauF_ParamDelim start="(" end=")"me=e-1 contained contains=luauB_Param nextgroup=luau%t_Block',
        \ 'syn region luau%t_Block matchgroup=luauF_ParamDelim start=")" matchgroup=luauK_Function end="end" transparent contains=@luauTop contained%n',
        \ 'syn match luau%t_Var /\K\k*/ transparent contains=luau%t_InvokedVar contained nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_InvokedVar /\K\k*\%(\s*\%((\|"\|''\|\[=*\[\)\)\@=/ contained nextgroup=@luau%t2_Invoke,@luau%t_GeneralString skipwhite skipnl',
        \ 'syn match luau%t_ColonInvoked /\K\k*\%(\s*\%((\|"\|''\|\[=*\[\)\)\@=/ contained nextgroup=luau%t2_Invoke,@luau%t_GeneralString skipwhite skipnl',
        \ 'syn match luau%t_BuiltinTmpl /\%(\s\|(\)\@1<=\<\K\k*[.:]\K\k*\>/ contained contains=@luauGeneralBuiltin,luau%t_InvokedVar nextgroup=@luau%t2 skipwhite skipnl',
        \ 'syn region luau%t_Wrap matchgroup=luau%t_Wrap start="(" end=")" transparent contained contains=@luau%e nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_Variadic /\.\.\./ contained%n',
        \ 'syn match luau%t_Uop /#\|-\%(-\)\@!\|\<not\>/ contained nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn region luau%t_Table matchgroup=luauStructure start="{" end="}" transparent contained contains=@luau%l,@luauT,luauComment%n',
        \ 'syn region luau%t_InlineIf matchgroup=luauC_Keyword start="\<if\>" end="\<then\>"me=e-4 transparent contained contains=@luau%e,luau%e_Uop nextgroup=luau%t_InlineThen',
        \ 'syn region luau%t_InlineThen matchgroup=luauC_Keyword start="\<then\>" end="\<else\>" transparent contained contains=@luau%e,luau%e_Uop,luau%t_InlineElseif nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn region luau%t_InlineElseif matchgroup=luauC_Keyword start="\<elseif\>" end="\<then\>" transparent contained contains=@luau%e,luau%e_Uop nextgroup=@luau%e,luau%e_Uop skipwhite' ],
      \ 'exp2': [
        \ 'syn match luau%t2_Dot /\./ transparent contained nextgroup=@luau%t skipwhite',
        \ 'syn match luau%t2_Colon /\:/ transparent contained nextgroup=luau%t_ColonInvoked skipwhite',
        \ 'syn region luau%t2_Invoke matchgroup=luau%t2_Invoke start="(" end=")" contained contains=@luau%l,luau%l_Uop nextgroup=@luau%t2 skipwhite',
        \ 'syn region luau%t2_Bracket matchgroup=luau%t2_Bracket start="\[" end="\]" contained contains=@luau%e,luau%e_Uop nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t2_Binop /+\|-\%(-\)\@!\|\*\|\/\|\^\|%\|\.\.\|<=\?\|>=\?\|[~=]=\|\<and\>\|\<or\>/ contained nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn match luau%t2_CastSymbol /::/ contained nextgroup=@luauCast%t skipwhite'] }

"        \ 'syn region luau%t_CallbackGen matchgroup=luauType_AngleBracket start="<" end=">" transparent contained contains=@luauTypeGenParam nextgroup=luau%t_FunctionParams skipwhite skipnl',

let s:exphilinkmap = {
      \ 'string': 'luauString',
      \  'number': 'luauNumber',
      \ 'const': 'luauConstant'
      \ }

let s:expout = []
let s:exphilinkout = {}

" embed a specific syntax command template with the given data and add it to
" the script expression generator stack - string
function! s:embedExpString(himap, synout, hiout, mval, gkdata, ekey) abort
  if (has_key(a:himap, a:ekey))
    let l:hilink = a:himap[a:ekey]
  endif

  if exists('l:hilink')
    call s:embedExp(a:synout, a:hiout, a:mval, a:gkdata, l:hilink)
  else
    call s:embedExp(a:synout, a:hiout, a:mval, a:gkdata)
  endif
endfunction

" same as above, for dictionary-based syntax template
function! s:embedExpDict(himap, synout, hiout, mval, gkdata, ekey) abort
  if (has_key(a:mval, 'hilink'))
    let l:hilink = a:mval.hilink
  elseif (has_key(a:himap, a:ekey) && !has_key(a:mval, 'hilinkoff'))
    let l:hilink = a:himap[a:ekey]
  endif

  if exists('l:hilink')
    call s:embedExp(a:synout, a:hiout, a:mval.cmd, a:gkdata, l:hilink)
  else
    call s:embedExp(a:synout, a:hiout, a:mval.cmd, a:gkdata)
  endif
endfunction

function! s:parseTokenBody(tsrc, tmap)
  let l:ttarg = a:tsrc
  for [l:tkey, l:tval] in items(a:tmap)
    let l:ttarg = substitute(l:ttarg, '%' . l:tkey, l:tval, 'g')
  endfor
  return l:ttarg
endfunction

function! s:embedExp(synout, hiout, exp, gkdata, ...) abort
  let l:exp = s:parseTokenBody(a:exp, a:gkdata)

  " echo l:exp
  
  if empty(l:exp)
    return
  endif

  call add(a:synout, l:exp)

  if (exists('a:1') && (l:exp[4:10] !=# 'cluster'))
    let l:hlexp = s:parseTokenBody(a:1, a:gkdata)
    let l:hlsrc = matchstr(l:exp, 'luau\k\+')

    if empty(l:hlsrc)
      throw 'empty highlight source on expression' . l:exp
    endif
    if (empty(l:hlexp) || l:hlsrc ==# l:hlexp)
      return
    endif

    if !has_key(a:hiout, l:hlexp)
      let l:hiout_exp = []
      let a:hiout[l:hlexp] = l:hiout_exp
    else
      let l:hiout_exp = a:hiout[l:hlexp]
    endif

    call add(l:hiout_exp, l:hlsrc)
  endif
endfunction

" add a new expression context to the expression syntax command generator
" stack
function! s:newExp(synmap, himap, synout, hiout, grpdata) abort
  for [l:ekey, l:evalue] in items(a:synmap)
    if has_key(a:grpdata, l:ekey)
      let l:grpkeydata = a:grpdata[l:ekey]
    else
      continue
    endif

    for l:syndata in l:evalue
      if type(l:syndata) ==# v:t_string
        call s:embedExpString(a:himap, a:synout, a:hiout, l:syndata, l:grpkeydata, l:ekey)
      elseif type(l:syndata) ==# v:t_dict
        call s:embedExpDict(a:himap, a:synout, a:hiout, l:syndata, l:grpkeydata, l:ekey)
      endif
    endfor
  endfor
endfunction

function! s:processExpStack(stack)
  for l:syntax_query in a:stack
    if exists('s:_debugexpstackprint')
      echo l:syntax_query
    endif
    execute l:syntax_query
  endfor
endfunction

function! s:processHighlightMap(hioutmap)
  for [l:houtkey, l:houtlist] in items(a:hioutmap)
    for l:hout in l:houtlist
      execute printf('hi def link %s %s', l:hout, l:houtkey)
    endfor
  endfor
endfunction

" Section: Luau grammar

" @luauE, @luauE2, luauNumber, luauFloat, @luauGeneralString
let s:exp_nxt1 = ' nextgroup=luauE2_Binop skipwhite'
call s:newExp(s:expmap, s:exphilinkmap, s:expout, s:exphilinkout, {
     \ 'string': {           'n': s:exp_nxt1,   'p': ''                     },
     \ 'number': {           'n': s:exp_nxt1,   'p': ''                     },
     \ 'const':  {           'n': s:exp_nxt1,   'p': ''                     },
     \ 'expc':   {'t': 'E',  'n': '',           'p': ''                     },
     \ 'exp':    {'t': 'E',  'n': '',                   'e': 'E', 'l': 'L'  },
     \ 'exp2':   {'t': 'E',                             'e': 'E', 'l': 'L'  } })
" @luauL, @luauL2, luauL_Number, luauL_Float, @luauL_GeneralString
let s:lexp_nxt1 = ' contained nextgroup=luauL2_Sep,luauL2_Binop skipwhite'
let s:lexp_nxt2 = ',luauL2_Sep'
let s:lexp_nxt3 = ' nextgroup=luauL2_Sep skipwhite'
call s:newExp(s:expmap, s:exphilinkmap, s:expout, s:exphilinkout, {
     \ 'string': {           'n': s:lexp_nxt1, 'p': 'L_',                     },
     \ 'number': {           'n': s:lexp_nxt1, 'p': 'L_',                     },
     \ 'const':  {           'n': s:lexp_nxt1, 'p': 'L_'                      },
     \ 'expc':   {'t': 'L',  'n': s:lexp_nxt2, 'p': 'L_',           'l': 'L'  },
     \ 'exp':    {'t': 'L',  'n': s:lexp_nxt3,            'e': 'E', 'l': 'L'  },
     \ 'exp2':   {'t': 'L',                               'e': 'E', 'l': 'L'  } })
call s:processExpStack(s:expout)

syn cluster luauK contains=luauK_Local,luauK_Function,luauK_Do,luauK_Return,luauK_Break,luauK_Continue
syn cluster luauS contains=luauS_Wrap,luauS_DottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar,luauS_ColonInvocation,luauS_DictRef
syn cluster luauR contains=luauR_While,luauR_Repeat,luauR_For
syn cluster luauC contains=luauC_If
syn cluster luauTop contains=@luauK,@luauS,@luauR,@luauC,@luauGeneralBuiltin,luauComment

syn cluster luauA contains=luauA_DottedVar,luauA_HungVar,luauA_TailVar,luauA_DictRef
syn cluster luauT contains=luauT_NDictK,luauT_EDictK,luauT_Symbol,luauT_Semicolon

syn match luauL2_Sep /,/ contained nextgroup=@luauL,luauL_Uop skipwhite skipempty

" luauA - variable (A)ssignment syntax
syn match luauA_Symbol /=/ contained nextgroup=@luauL,luauL_Uop skipwhite skipnl
syn match luauA_Symbol '+=\|-=\|\/=\|\*=\|\^=\|\.\.=' contained nextgroup=@luauE,luauE_Uop skipwhite
syn match luauA_Dot /\./ contained nextgroup=@luauA skipwhite
syn match luauA_DottedVar /\K\k*\%(\s*\.\)\@=/ contained nextgroup=luauA_Dot skipwhite
syn match luauA_DictRef /\K\k*\%(\s*\[\)\@=/ contained nextgroup=luauA_DictKey skipwhite
syn region luauA_DictKey start="\[" end="\]" transparent contained contains=@luauE nextgroup=luauA_Comma,luauA_DictKey,luauA_Dot,luauA_Symbol skipwhite
syn match luauA_HungVar /\K\k*\%(\s*,\)\@=/ contained nextgroup=luauA_Comma skipwhite
syn match luauA_TailVar /\K\k*\%(\s*=\)\@=/ contained nextgroup=luauA_Symbol skipwhite
syn match luauA_Comma /,/ contained nextgroup=@luauA skipwhite skipnl

" luauK - (K)eyword, luauF - (F)unction, luauB - (B)indings

" Top Level Keyword: function
syn keyword luauK_Function function nextgroup=luauF_Name skipwhite
syn match luauF_Name /\K\k*/ contained nextgroup=luauF_Sep,luauF_Colon,luauF_TypeParam,luauE_FunctionParams skipwhite
syn region luauF_TypeParam matchgroup=luauStructure start="<" end=">" transparent contained contains=@luauTypeGenParam nextgroup=luauE_FunctionParams skipwhite
syn match luauF_Method /\K\k*/ contained nextgroup=luauF_TypeParam,luauE_FunctionParams skipwhite
syn match luauF_Sep /\./ contained nextgroup=luauF_Name skipwhite
syn match luauF_Colon /:/ contained nextgroup=luauF_Method skipwhite

" Top Level Keyword: return
syn keyword luauK_Return return nextgroup=@luauL,luauL_Uop skipwhite

" Top Level Keyword: local
syn keyword luauK_Local local nextgroup=luauB_Function,luauB_LocalVar skipwhite
syn match luauB_LocalVar /\K\k*/ contained nextgroup=luauB_LocalVarColon,luauB_LocalVarSep,luauA_Symbol skipwhite skipnl
syn match luauB_LocalVarSep /,/ contained nextgroup=luauB_LocalVar skipwhite
syn match luauB_Param /\K\k*/ contained nextgroup=luauB_ParamSep,luauB_ParamColon skipwhite
syn match luauB_Param /\.\.\./ contained nextgroup=luauB_ParamVariadicColon skipwhite
syn match luauB_ParamSep /,/ contained nextgroup=luauB_Param skipwhite skipnl
syn keyword luauB_Function function contained nextgroup=luauF_Method skipwhite

" Top Level Keyword: do (anonymous block)
syn region luauK_Do matchgroup=luauK_Keyword start="\<do\>" end="\<end\>" transparent contains=@luauTop

" luauR - (R)epeat

" Top Level Repeat: while
syn region luauR_While matchgroup=luauR_Keyword start="\<while\>" end="\<do\>"me=e-2 transparent contains=@luauE,luauE_Uop nextgroup=luauR_Do
syn region luauR_Do matchgroup=luauR_Keyword start="\<do\>" end="\<end\>" transparent contained contains=@luauTop
syn region luauR_Repeat matchgroup=luauR_Keyword start="\<repeat\>" end="\<until\>" transparent contains=@luauTop nextgroup=@luauE,luauE_Uop skipwhite skipnl

syn keyword luauR_For for nextgroup=luauD_HeadBinding skipwhite

" Top Level Keywords: break, continue
syn keyword luauK_Break break
syn keyword luauK_Continue continue

" Top Level Keyword: [export] type
syn match luauK_Export /export\%(\s\+[^[:keyword:]]\)\@!/ nextgroup=luauK_Type skipwhite
syn match luauK_Type /type\%(\s\+[^[:keyword:]]\)\@!/ nextgroup=luauTypedef_Name skipwhite
syn match luauTypedef_Name /\K\k*/ contained nextgroup=luauTypedef_GenParam,luauTypedef_Symbol skipwhite
syn region luauTypedef_GenParam matchgroup=luauStructure start="<" end=">" transparent contained contains=@luauTypeGenParam nextgroup=luauTypedef_Symbol skipwhite skipnl
syn match luauTypedef_Symbol /=/ contained nextgroup=@luauType skipwhite skipnl

" luauD - (D)omain of iteration

syn match luauD_HeadBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_ExpRangeStart,luauD_CanonRange skipwhite
syn match luauD_CanonListBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_CanonRange skipwhite
syn match luauD_CanonListBindingSep /,/ contained nextgroup=luauD_CanonListBinding skipwhite skipnl

syn region luauD_CanonRange matchgroup=luauD_CanonRange start="\<in\>" end="\<do\>"me=e-2 transparent contained contains=@luauL,luauL_Uop nextgroup=luauR_Do

syn region luauD_ExpRangeStart matchgroup=luauD_ExpRangeStart start="=" end=","me=e-1 transparent contained contains=@luauE,luauE_Uop nextgroup=luauD_ExpRangeStep
syn region luauD_ExpRangeStep matchgroup=luauD_ExpRangeStep start="," end="\<do\>"me=e-2 transparent contained contains=@luauE,luauE_Uop nextgroup=luauR_Do

" luauS - top level syntactic (S)tatements

" Top Level Statement: variable tokens
syn match luauS_DottedVar /\K\k*\%(\s*\.\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauV_Dot skipwhite
syn match luauS_HungVar /\K\k*\%(\s*,\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauA_Comma skipwhite
syn match luauS_TailVar /\K\k*\%(\s*\%(=\|+=\|-=\|\/=\|\*=\|\^=\|\.\.=\)\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauA_Symbol skipwhite
syn match luauS_DictRef /\K\k*\%(\s*\[\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauV_DictKey skipwhite

" Top Level Statement: anonymous wrapped expression
syn region luauS_Wrap matchgroup=luauS_Wrap start="\%(\K\k*\|\]\|:\)\@<!(" end=")" transparent contains=@luauE,luauE_Uop nextgroup=@luauE2 skipwhite skipnl

 " Top Level Statement: function or method invocation
syn match luauS_InvokedVar /\K\k*\%(\s*\%((\|'\|"\|\[=*\[\)\)\@=/ nextgroup=luauV_Invoke skipwhite
syn match luauS_ColonInvocation /\K\k*\%(\s*:\)\@=/ nextgroup=luauV_Colon skipwhite skipnl

" luauV - operators on top level (V)ariables

syn cluster luauV contains=luauV_Invoke,luauV_DictKey,luauV_Dot,luauV_Colon
syn region luauV_Invoke matchgroup=luauV_Invoke start="(" end=")" contained contains=@luauL,luauL_Uop nextgroup=@luauV
syn region luauV_DictKey start="\[" end="\]" transparent contained contains=@luauE,luauE_Uop nextgroup=@luauV,luauA_Comma,luauA_Symbol skipwhite
syn match luauV_Dot /\./ transparent contained nextgroup=luauS_DottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar skipwhite
syn match luauV_Colon /:/ transparent contained nextgroup=luauS_InvokedVar skipwhite

" luauC - top level & contained (C)onditional

" Top Level Statement: if branch
syn region luauC_If matchgroup=luauC_Keyword start="\<if\>" end="\<then\>"me=e-4 transparent contains=@luauE,luauE_Uop nextgroup=luauC_Then
syn region luauC_Then matchgroup=luauC_Keyword start="\<then\>" end="\<end\>" transparent contained contains=@luauTop,luauC_Elseif,luauC_Else
syn region luauC_Elseif matchgroup=luauC_Keyword start="\<elseif\>" end="\<then\>" transparent contained contains=@luauE,luauE_Uop nextgroup=luauC_Then
syn keyword luauC_Else else contained

" luauT - (T)able fields

syn match luauT_Symbol /=/ contained nextgroup=@luauL,luauL_Uop skipwhite
syn match luauT_Semicolon /;/ contained nextgroup=@luauL,@luauT,luauL_Uop skipwhite skipempty
syn region luauT_EDictK matchgroup=luauDelimiter start="\[" end="\]" transparent contained contains=@luauE,luauE_Uop nextgroup=luauT_Symbol skipwhite
syn match luauT_NDictK /\K\k*\%(\s*=\)\@=/ contained nextgroup=luauT_Symbol skipwhite

if (g:luauHighlightTypes)
  " One of Luau's signature features is a rich type system.
  " * luau-lang.org/typecheck

  " it's important to distinguish between single types and type lists, because
  " in many cases there is a type annotation that is inside a binding list,
  " and thus we don't want to clobber delimiters unless we know a type list is
  " reasonably expected.

  " there's also a sort of type-level binding when defining types using the
  " type keyword. it only accepts a single keyword and an angle-bracketed
  " function generic type list.

  " thanks to typecasting, there is also an insertion of type expressions into
  " both expression-level contexts. that's because we can have a binary
  " operator from the expression context right after a typecast:
  "   local n1: any
  "   local n2: any
  "   local n3 = n1 :: number + n2 :: number
  
  " TODO: ColonReturnType on keyworded functions
  
  let s:typeout = []
  let s:typehilinkout = {}

  let s:typemap = {
        \ 'typec': [
          \ 'syn cluster luau%T contains=luau%T_Name,luau%T_Module,luau%T_Table,luau%T_FunctionGen,luau%T_StringSingleton,luau%T_BoolSingleton,luau%T_SpecialTypeOf',
          \ 'syn cluster luau%T2 contains=luau%T2_Binop',
          \ ],
        \ 'type': [
          \ {'hilink': 'luauOperator', 'cmd': 'syn match luau%T_Uop /?/ contained nextgroup=@luau%T2 skipwhite'},
          \ {'hilink': 'luauTypeAnnotation', 'cmd': 'syn match luau%T_Name /\<\K\k*\>\%(\s*\%(\.\|:\)\)\@!/ contained nextgroup=@luau%T2,luau%T_Uop,luau%T_Param skipwhite' },
          \ 'syn match luau%T_Module /\<\K\k*\s*\.\%(\s*\K\)\@=/ contained nextgroup=luau%T_Name skipwhite',
          \ 'syn region luau%T_Table matchgroup=luauStructure start=+{+ end=+}+ transparent contained contains=@luauType,luauTypeProp_Name,luauTypeProp_Key nextgroup=@luau%T2,luau%T_Uop skipwhite',
          \ 'syn region luau%T_FunctionGen matchgroup=luauStructure start=+\%(\k\s*\)\@<!<+ end=+>+ transparent contained contains=@luauTypeGenParam nextgroup=luau%T_FunctionParam skipwhite',
          \ 'syn region luau%T_Param matchgroup=luauDelimiter start=+<+ end=+>+ transparent contained contains=@luauTypeParam nextgroup=@luau%T2,luau%T_Uop skipwhite',
          \ {'hilink': 'luauPreProc', 'cmd': 'syn keyword luau%T_SpecialTypeOf typeof nextgroup=luau%T_ExpInference skipwhite'},
          \ 'syn region luau%T_ExpInference matchgroup=luauDelimiter start=+(+ end=+\%((\)\@1<!)+ transparent contained contains=@luauE nextgroup=@luau%T2 skipwhite skipnl',
          \ {'hilink': 'luauString', 'cmd': 'syn region luau%T_StringSingleton matchgroup=luauString start=+\z("\|''\)+ end=+\z1+ contained nextgroup=@luau%T2,luau%T_Uop skipwhite' },
          \ {'hilink': 'luauBoolean', 'cmd': 'syn keyword luau%T_BoolSingleton true false contained nextgroup=@luau%T2,luau%T_Uop skipwhite' },
          \ 'syn region luau%T_FunctionParam matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name,luauTypeFParam_Variadic nextgroup=luau%T_Arrow skipwhite',
          \ {'hilink': 'luauStructure', 'cmd': 'syn match luau%T_Arrow /->/ contained nextgroup=@luau%T,luau%T_Pack,luauTypeL_Variadic,luauTypeL_GenPack skipwhite skipnl' },
          \ 'syn region luau%T_Pack matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL nextgroup=@luau%T2 skipwhite' ],
        \ 'type2': [
          \ {'hilink': 'luauStructure', 'cmd': 'syn match luau%T2_Binop /|\|&/ contained nextgroup=@luau%T skipwhite skipnl' } ] }

  let s:typehilinkmap = {}
  " luauType
  call s:newExp(s:typemap, s:typehilinkmap, s:typeout, s:typehilinkout, {
        \ 'typec':  {'T': 'Type'},
        \ 'type':   {'T': 'Type'},
        \ 'type2':  {'T': 'Type'} })
  " luauTypeL
  call s:newExp(s:typemap, s:typehilinkmap, s:typeout, s:typehilinkout, {
        \ 'typec':  {'T': 'TypeL'},
        \ 'type':   {'T': 'TypeL'},
        \ 'type2':  {'T': 'TypeL'} })
  " luauTypeParam
  call s:newExp(s:typemap, s:typehilinkmap, s:typeout, s:typehilinkout, {
        \ 'typec':  {'T': 'TypeParam'},
        \ 'type':   {'T': 'TypeParam'},
        \ 'type2':  {'T': 'TypeParam'} })
  call s:newExp(s:typemap, s:typehilinkmap, s:typeout, s:typehilinkout, {
        \ 'typec':  {'T': 'CastE'},
        \ 'type':   {'T': 'CastE'},
        \ 'type2':  {'T': 'CastE'} })
  call s:newExp(s:typemap, s:typehilinkmap, s:typeout, s:typehilinkout, {
        \ 'typec':  {'T': 'CastL'},
        \ 'type':   {'T': 'CastL'},
        \ 'type2':  {'T': 'CastL'} })
  call s:processExpStack(s:typeout)


  " syn cluster luauType contains=luauType_Name,luauType_Module,luauType_Table,luauType_FunctionGen,luauType_FunctionParam,luauType_StringSingleton,luauType_BoolSingleton,luauType_SpecialTypeOf
  " syn cluster luauType2 contains=luauType2_Binop
  " syn cluster luauTypeL contains=luauTypeL_Name,luauTypeL_Module,luauTypeL_Table,luauTypeL_FunctionGen,luauTypeL_FunctionParam,luauTypeL_Variadic,luauTypeL_StringSingleton,luauTypeL_BoolSingleton,luauTypeL_SpecialTypeOf
  " syn cluster luauTypeL2 contains=luauTypeL2_Binop,luauTypeL2_Sep
  " syn cluster luauTypeParam contains=luauTypeParam_Variadic,luauTypeParam_Name,luauTypeParam_Module,luauTypeParam_Table,luauTypeParam_FunctionGen,luauTypeParam_Paren,luauTypeParam_StringSingleton,luauTypeParam_BoolSingleton,luauTypeParam_SpecialTypeOf
  " syn cluster luauTypeParam2 contains=luauTypeParam2_Sep,luauTypeParam2_Binop
  syn cluster luauTypeL2 add=luauTypeL2_Sep
  syn cluster luauTypeParam2 add=luauTypeParam2_Sep
  syn cluster luauType add=luauType_FunctionParam
  syn cluster luauTypeL add=luauTypeL_FunctionParam,luauTypeL_Variadic,luauTypeL_GenPack
  syn cluster luauTypeParam add=luauTypeParam_Paren,luauTypeParam_Variadic,luauTypeParam_GenPack
  syn cluster luauCastE2 add=@luauE2
  syn cluster luauCastL2 add=@luauL2

  syn match luauTypeL2_Sep /,/ contained nextgroup=@luauTypeL skipwhite skipnl
  syn match luauTypeParam2_Sep /,/ contained nextgroup=@luauTypeParam skipwhite skipnl

  syn region luauType_LocalVar start=/[^,=[:space:]?]/ end=/,/me=e-1 end=/=/me=e-1 end=/$/ transparent contained contains=@luauType nextgroup=luauB_LocalVarSep,luauA_Symbol skipwhite
  syn region luauType_ParamBinding start=/[^,=[:space:]?]/ end=/,/me=e-1 end=/)/me=e-1 end=/$/ transparent contained contains=@luauType nextgroup=luauB_ParamSep skipwhite
  syn region luauType_ParamVariadicBinding start=/[^,=[:space:]?]/ end=/)/me=e-1 transparent contained contains=@luauType,luauTypeL_Variadic,luauTypeL_GenPack skipwhite
  syn match luauB_LocalVarColon /:/ contained nextgroup=luauType_LocalVar skipwhite
  syn match luauB_ParamColon /:/ contained nextgroup=luauType_ParamBinding skipwhite
  syn match luauB_ParamVariadicColon /:/ contained nextgroup=luauType_ParamVariadicBinding skipwhite

  syn region luauTypeParam_Paren matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name,luauTypeFParam_Variadic nextgroup=luauType_Arrow,@luauTypeParam2 skipwhite

  syn match luauTypeFParam_Name /\K\k*\%(\s*:\)\@=/ contained nextgroup=luauTypeFParam_Sep skipwhite
  syn region luauTypeFParam_Sep start=/:/ end=/,/me=e-1 end=/)/me=e-1 transparent contained contains=@luauType skipwhite
  syn match luauTypeFParam_Variadic /\%(\k\s*\)\@<!\.\.\.\%(\s*:\)\@=/ contained nextgroup=luauTypeFParam_VariadicStop skipwhite
  syn region luauTypeFParam_VariadicStop start=/:/ end=/)/me=e-1 transparent contained contains=@luauType,luauTypeL_Variadic,luauTypeL_GenPack skipwhite

  syn match luauTypeL_Variadic /\%(\k\s*\)\@<!\.\.\.\%(\s*:\)\@!/ contained nextgroup=@luauType skipwhite
  syn match luauTypeParam_Variadic /\%(\k\s*\)\@<!\.\.\.\%(\s*:\)\@!/ contained nextgroup=@luauTypeParam skipwhite

  syn match luauTypeL_GenPack /\<\K\k*\>\%(\s*\.\.\.\)\@=/ transparent contained nextgroup=luauTypeL_GenSymbol
  syn match luauTypeL_GenSymbol /\.\.\./ contained
  syn match luauTypeParam_GenPack /\<\K\k*\>\%(\s*\.\.\.\)\@=/ transparent contained nextgroup=luauTypeParam_GenSymbol skipwhite
  syn match luauTypeParam_GenSymbol /\.\.\./ contained nextgroup=@luauTypeParam2 skipwhite

  " used in luau%T_Table

  syn match luauTypeProp_Name /\K\k*\%(\s*:\)\@=/ contained nextgroup=luauTypeProp_Sep skipwhite skipnl
  syn region luauTypeProp_Sep start=/:/ end=/,/ end=/}/me=e-1 transparent contained contains=@luauType skipwhite
  syn region luauTypeProp_Key matchgroup=luauDelimiter start=/\[/ end=/\]/ transparent contained contains=@luauType nextgroup=luauTypeProp_Sep skipwhite

  " syn match luauType2_Binop /|\|&/ contained nextgroup=@luauType skipwhite skipnl
  " syn match luauTypeL2_Binop /|\|&/ contained nextgroup=@luauTypeL skipwhite skipnl
  " syn match luauTypeParam2_Binop /|\|&/ contained nextgroup=@luauTypeParam skipwhite skipnl

  " syn match luauType_Uop /?/ contained nextgroup=@luauType2 skipwhite
  " syn match luauTypeL_Uop /?/ contained nextgroup=@luauTypeL2 skipwhite
  "syn match luauTypeParam_Uop /?/ contained nextgroup=@luauTypeParam2 skipwhite

  " Note: TypeParams entry point (syn-nextgroup)
  " syn match luauType_Name /\<\K\k*\%(\s*\%(\.\|:\)\)\@!/ contained nextgroup=@luauType2,luauType_Uop,luauType_Param skipwhite
  " syn match luauTypeL_Name /\<\K\k*\%(\s*\%(\.\|:\)\)\@!/ contained nextgroup=@luauTypeL2,luauTypeL_Uop,luauTypeL_Param skipwhite
  " syn match luauTypeParam_Name /\<\K\k*\%(\s*\%(\.\|:\)\)\@!/ contained nextgroup=@luauTypeParam2,luauTypeParam_Uop,luauTypeParam_Param skipwhite

  " Note: TypeParams entry point (syn-nextgroup)
  " syn match luauType_Module /\<\K\k*\s*\./ contained nextgroup=luauType_Name skipwhite
  " syn match luauTypeL_Module /\<\K\k*\s*\./ contained nextgroup=luauTypeL_Name skipwhite
  " syn match luauTypeParam_Module /\<\K\k*\s*\./ contained nextgroup=luauTypeParam_Name skipwhite

  " syn keyword luauType_SpecialTypeOf typeof transparent nextgroup=luauType_ExpInference
  " syn region luauType_ExpInference matchgroup=luauDelimiter start="(" end=")" transparent contains=@luauE nextgroup=@luauType2 skipwhite skipnl
  " syn keyword luauTypeL_SpecialTypeOf typeof transparent nextgroup=luauTypeL_ExpInference
  " syn region luauTypeL_ExpInference matchgroup=luauDelimiter start="(" end=")" transparent contains=@luauE nextgroup=@luauTypeL2 skipwhite skipnl
  " syn keyword luauTypeParam_SpecialTypeOf typeof transparent nextgroup=luauTypeParam_ExpInference
  " syn region luauTypeParam_ExpInference matchgroup=luauDelimiter start="(" end=")" transparent contains=@luauE nextgroup=@luauTypeParam2 skipwhite skipnl

  " singleton types
  " syn region luauType_StringSingleton matchgroup=luauString start=+\z("\|'\)+ end=+\z1+ contained nextgroup=@luauType2,luauType_Uop skipwhite
  " syn region luauTypeL_StringSingleton matchgroup=luauString start=+\z("\|'\)+ end=+\z1+ contained nextgroup=@luauType2,luauTypeL_Uop skipwhite
  " syn region luauTypeParam_StringSingleton matchgroup=luauString start=+\z("\|'\)+ end=+\z1+ contained nextgroup=@luauType2,luauTypeParams_Uop skipwhite
  " syn keyword luauType_BoolSingleton true false contained nextgroup=@luauType2,luauType_Uop skipwhite
  " syn keyword luauTypeL_BoolSingleton true false contained nextgroup=@luauTypeL2,luauTypeL_Uop skipwhite
  " syn keyword luauTypeParam_BoolSingleton true false contained nextgroup=@luauTypeParam2,luauTypeParam_Uop skipwhite

  " Note: TypeParams entry point (syn-contains)
  " syn region luauType_Param matchgroup=luauDelimiter start=+<+ end=+>+ transparent contained contains=@luauTypeParam nextgroup=@luauType2,luauType_Uop skipwhite
  " syn region luauTypeL_Param matchgroup=luauDelimiter start=+<+ end=+>+ transparent contained contains=@luauTypeParam nextgroup=@luauTypeL2,luauTypeL_Uop skipwhite
  " syn region luauTypeParam_Param matchgroup=luauDelimiter start=+<+ end=+>+ transparent contained contains=@luauTypeParam nextgroup=@luauTypeParam2,luauTypeParam_Uop skipwhite

  " Note: GenericTypeParameterList entry point (syn-contains)
  " syn region luauType_FunctionGen matchgroup=luauStructure start=+<+ end=+>+ transparent contained contains=@luauTypeGenParam nextgroup=luauType_FunctionParam skipwhite
  " syn region luauTypeL_FunctionGen matchgroup=luauStructure start=+<+ end=+>+ transparent contained contains=@luauTypeGenParam nextgroup=luauTypeL_FunctionParam skipwhite
  " syn region luauTypeParam_FunctionGen matchgroup=luauStructure start=+<+ end=+>+ transparent contained contains=@luauTypeGenParam nextgroup=luauTypeParam_FunctionParam skipwhite

  " syn region luauType_FunctionParam matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name nextgroup=luauType_Arrow skipwhite
  " syn region luauTypeL_FunctionParam matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name nextgroup=luauTypeL_Arrow skipwhite
  " syn region luauTypeParam_FunctionParam matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name nextgroup=luauTypeParam_Arrow skipwhite

  " syn match luauType_Arrow /->/ contained nextgroup=@luauType,luauType_Pack skipwhite skipnl
  " syn match luauTypeL_Arrow /->/ contained nextgroup=@luauTypeL,luauTypeL_Pack skipwhite skipnl
  " syn match luauTypeParam_Arrow /->/ contained nextgroup=@luauTypeParam,luauTypeParam_Pack skipwhite skipnl

  " syn region luauType_Pack matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL nextgroup=@luauType2 skipwhite
  " syn region luauTypeL_Pack matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL nextgroup=@luauTypeL2 skipwhite
  " syn region luauTypeParam_Pack matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL nextgroup=@luauTypeParam2 skipwhite

  " nextgroup below is luauType rather than luauTypeL, because it's supposed
  " to be the last element if it's in a type list

  " TableType

  " the grammar is missing the concise list type:
  " { T }
  " we'll be respecting it though
  " from testing, it looks like the concise list type cannot be mixed
  " with the proplist-based spec

  " syn region luauType_Table matchgroup=luauStructure start=+{+ end=+}+ transparent contained contains=@luauType,luauTypeProp_Name,luauTypeProp_Key nextgroup=@luauType2,luauType_Uop skipwhite
  " syn region luauTypeL_Table matchgroup=luauStructure start=+{+ end=+}+ transparent contained contains=@luauType,luauTypeProp_Name,luauTypeProp_Key nextgroup=@luauTypeL2,luauTypeL_Uop skipwhite
  " syn region luauTypeParam_Table matchgroup=luauStructure start=+{+ end=+}+ transparent contained contains=@luauType,luauTypeProp_Name,luauTypeProp_Key nextgroup=@luauTypeParam2,luauParamType_Uop skipwhite

  " GenericTypeParameterList

  " Note that this list is logically split into halves;
  " 1. type parameters (NAME1 [ '=' Type1], NAME2 [ '=' Type2], ...)
  " 2. pack generics T... [ '=' luauTypePack ]
  " however, my only problem with these is that, in practice, the
  " bracketed (meaning optional) type instantiators produce a syntax error.

  syn cluster luauTypeGenParam contains=luauTypeGenParam_Name,@luauTypeGenPack
  syn cluster luauTypeGenPack contains=luauTypeGenPack_Name

  syn match luauTypeGenParam_Sep /,/ contained nextgroup=@luauTypeGenParam,@luauTypeGenPack skipwhite skipnl
  syn match luauTypeGenPack_Sep /,/ contained nextgroup=@luauTypeGenPack skipwhite skipnl
  syn match luauTypeGenPack_Symbol /\.\.\./ contained nextgroup=luauTypeGenPack_Sep skipwhite
  syn match luauTypeGenPack_Name /\K\k*\%(\s*\.\)\@=/ contained nextgroup=luauTypeGenPack_Symbol skipwhite
  syn match luauTypeGenParam_Name /\K\k*\%(\s*\.\)\@!/ contained nextgroup=luauTypeGenParam_Sep skipwhite
endif

syn cluster luauGeneralBuiltin contains=luauBuiltin,luauLibrary,luauIdentifier
syn cluster luauGeneralBuiltinDot contains=luauLibraryDot
if (g:luauHighlightBuiltins)
  " The Luau builtin functions are straightforward.
  " There are some extra debug library functions in Roblox.
  syn keyword luauBuiltin assert collectgarbage error gcinfo nextgroup=luauE2_Invoke
  syn keyword luauBuiltin getfenv getmetatable ipairs loadstring newproxy nextgroup=luauE2_Invoke
  syn keyword luauBuiltin next pairs pcall print rawget rawequal rawset require nextgroup=luauE2_Invoke
  syn keyword luauBuiltin setfenv select setmetatable tonumber tostring nextgroup=luauE2_Invoke
  syn match luauBuiltin /\<type\%(\s*[^[:keyword:][:space:]]\)\@=/ nextgroup=luauE2_Invoke
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
hi def link luauRepeat                Repeat
hi def link luauKeyword               Keyword
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
hi def link luauDirective             Underlined
hi def link luauLintWarning           SpecialComment
hi def link luauTypeAnnotation        Type
hi def link luauTypeDefinition        Typedef
hi def link luauPreProc               PreProc

hi def link luauLintWarnings          luauComment
hi def link luauZEscape               luauEscape
hi def link luauEOLEscape             luauEscape
hi def link luauAnonymousFunction     luauStatement
hi def link luauK_Function            luauStatement
hi def link luauK_Local               luauStatement
hi def link luauK_Keyword             luauStatement
hi def link luauK_Return              luauStatement
hi def link luauK_Break               luauStatement
hi def link luauK_Continue            luauStatement
hi def link luauR_For                 luauStatement
hi def link luauR_Keyword             luauRepeat
hi def link luauC_Keyword             luauConditional
hi def link luauK_Export              luauKeyword
hi def link luauK_Type                luauKeyword
hi def link luauD_CanonRange          luauOperator
hi def link luauA_Symbol              luauOperator

" hi def link luauType_Uop              luauOperator
" hi def link luauTypeL_Uop             luauType_Uop
" hi def link luauTypeParam_Uop         luauType_Uop
" hi def link luauType2_Binop           luauStructure
" hi def link luauTypeL2_Binop          luauType2_Binop
" hi def link luauTypeParam2_Binop      luauType2_Binop
" hi def link luauType_Arrow            luauStructure
" hi def link luauTypeL_Arrow           luauType_Arrow
" hi def link luauTypeParam_Arrow       luauType_Arrow
hi def link luauTypedef_Symbol        luauA_Symbol
" hi def link luauType_StringSingleton    luauString
" hi def link luauTypeL_StringSingleton   luauType_StringSingleton
" hi def link luauTypeParam_StringSingleton             luauType_StringSingleton
" hi def link luauType_BoolSingleton    luauBoolean
" hi def link luauTypeL_BoolSingleton   luauType_BoolSingleton
" hi def link luauTypeParam_BoolSingleton             luauType_BoolSingleton
" hi def link luauType_SpecialTypeOf    luauStructure
" hi def link luauTypeL_SpecialTypeOf    luauType_SpecialTypeOf
" hi def link luauTypeParam_SpecialTypeOf    luauType_SpecialTypeOf

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

hi def link luauB_Function            luauK_Function

call s:processHighlightMap(s:exphilinkout)
if exists('s:typehilinkout')
  call s:processHighlightMap(s:typehilinkout)
endif

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

syn sync match luauSync grouphere NONE "function"
syn sync minlines=200

let b:current_syntax='luau'

let &cpo = s:cpo_save
unlet s:cpo_save
