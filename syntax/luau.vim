" Vim syntax file
" Language:     Luau 0.546
" Maintainer:    polychromatist <polychromatist 'at' proton me>
" First Author: polychromatist
" Last Change:  2022 Sep 27 (luau-vim v0.3.1)
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

if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpoptions
set cpoptions&vim

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

syn region luauInt matchgroup=luauSpecial start=+\%(\\\)\@1<!{+ end=+}+ contained contains=@luauE
syn match luauIntEscape #\\{# contained

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
"
let s:expmap = {
      \ 'string': [
      \   'syn region luau%pString matchgroup=luau%pString start="\[\z(=*\)\[" end="\]\z1\]"   contains=luauEscape%n',
        \ 'syn region luau%pString matchgroup=luau%pString start=+''+ end=+''+ skip=+\\\\\|\\''+  contains=luauEscape oneline%n',
        \ 'syn region luau%pString matchgroup=luau%pString start=+"+ end=+"+ skip=+\\\\\|\\"+  contains=luauEscape oneline%n',
        \ 'syn region luau%pString matchgroup=luau%pString start=+`+ end=+`+ skip=+\\\\\|\\`+ contains=luauEscape,luauInt,luauIntEscape oneline%n',
        \ 'syn match luau%pStringF1            /".\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF3,luau%pStringZF2,luau%pStringF3 skipwhite skipnl',
        \ 'syn match luau%pStringF2 contained  /^.\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF2,luau%pStringZF2,luau%pStringF3 skipwhite skipnl',
        \ 'syn match luau%pStringF3 contained  /^.\{-}\%(\\\)\@1<!"/ contains=luauEscape%n',
        \ 'syn match luau%pStringF1Alt /''.\{-}\\$/                    contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF2Alt,luau%pStringZF2Alt,luau%pStringF3Alt skipnl skipwhite',
        \ 'syn match luau%pStringF2Alt /^.\{-}\\$/           contained contains=luauEscape,luauEOLEscape nextgroup=luau%pStringF2Alt,luau%pStringZF2Alt,luau%pStringF3Alt skipnl skipwhite',
        \ 'syn match luau%pStringF3Alt /^.\{-}\%(\\\)\@1<!''/ contained contains=luauEscape%n',
        \ 'syn region luau%pStringZF1           start=+"+ end=+\\z+me=e-2 skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2,luau%pStringF2 skipwhite skipempty oneline',
        \ 'syn region luau%pStringZF2 contained start=+\\z+ end=+[^[:space:]"]+me=e-1 skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luau%pStringF2,luau%pStringZF3 skipwhite skipempty',
        \ 'syn region luau%pStringZF3 contained start=+[^[:space:]"]+ end=+\\z+me=e-2 end=+"+ skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2,luau%pStringF2 skipwhite skipempty oneline',
        \ 'syn region luau%pStringZF1Alt           start=+''+ end=+\\z+me=e-2 skip=+\\\\\|\\''+ contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2Alt,luau%pStringF2Alt skipwhite skipempty oneline',
        \ 'syn region luau%pStringZF2Alt contained start=+\\z+ end=+[^[:space:]'']+me=e-1 skip=+\\\\\|\\''+ contains=luauEscape,luauZEscape nextgroup=luau%pStringF2Alt,luau%pStringZF3Alt skipwhite skipempty',
        \ 'syn region luau%pStringZF3Alt contained start=+[^[:space:]'']+ end=+\\z+me=e-2 end=+''+ skip=+\\\\\|\\''+ contains=luauEscape,luauZEscape nextgroup=luau%pStringZF2Alt,luau%pStringF2Alt skipwhite skipempty oneline',
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
        \ 'syn cluster luau%t contains=luau%t_Callback,luau%t_Wrap,luau%t_HeadVar,luau%t_BuiltinTemplate,luau%t_Variadic,luau%t_Table,luau%t_InlineIf',
        \ 'syn cluster luau%t add=luau%pNumber,luau%pFloat,@luau%pGeneralString',
        \ 'syn cluster luau%t add=luau%pNil,luau%pBoolean,luauComment',
        \ 'syn cluster luau%t2 contains=luau%t2_Invoke,luau%t2_Dot,luau%t2_Colon,luau%t2_Bracket,luau%t2_Binop,luau%t2_CastSymbol%n' ],
      \ 'exp': [
        \ 'syn keyword luau%t_Callback function contained nextgroup=luau%t_FunctionParams,luau%t_CallbackGen skipwhite',
        \ 'syn region luau%t_CallbackGen matchgroup=luauStructure start="<" end=">" transparent contained contains=@luauTypeGenParam nextgroup=luau%t_FunctionParams skipwhite skipnl',
        \ 'syn region luau%t_FunctionParams matchgroup=luauF_ParamDelim start="(" end=")\%(\_s*:\)\@!"me=e-1 end=")\_s*:"me=e-1 contained contains=luauB_Param,luauB_ParamVariadic nextgroup=luau%t_TypeHeader,luau%t_Block',
        \ 'syn region luau%t_Block matchgroup=luauF_ParamDelim start="." matchgroup=luauK_Function end="end" transparent contains=@luauTop contained%n',
        \ 'syn region luau%t_TypeHeader matchgroup=luauF_ParamDelim start=":" end="$" contained transparent contains=@luauType,luauTypeL_Variadic,luauTypeL_GenPack nextgroup=luau%t_Block skipwhite skipempty',
        \ 'syn match luau%t_Var /\%(\.\s*\)\@<=\<\K\k*\>/ contained nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_HeadVar /\%(\.\s*\)\@<!\<\K\k*\>/ contained nextgroup=@luau%t2 skipwhite',
        \ 'syn match luau%t_BuiltinTarget /[.:]\<\K\k*\>/ contains=@luauDotLibs contained nextgroup=@luau%t2 skipwhite skipnl',
        \ 'syn match luau%t_BuiltinTemplate /\%(\s\|(\|{\)\@1<=\<\K\k*\>\%([.:]\<\K\k*\>\)\@=/ contains=@luauGeneralBuiltin contained nextgroup=luau%t_BuiltinTarget',
        \ 'syn match luau%t_InvokedVar /\<\K\k*\>\%(\s*\%((\|"\|''\|\[=*\[\)\)\@=/ contained containedin=luau%t_HeadVar,luau%t_Var,luau%t_BuiltinTarget nextgroup=@luau%t2_Invoke,@luau%t_GeneralString skipwhite skipnl',
        \ 'syn match luau%t_ColonInvoked /\<\K\k*\>\%(\s*\%((\|"\|''\|\[=*\[\)\)\@=/ contained nextgroup=luau%t2_Invoke,@luau%t_GeneralString skipwhite skipnl',
        \ 'syn region luau%t_Wrap matchgroup=luau%t_Wrap start="(" end=")" transparent contained contains=@luau%e nextgroup=@luau%t2 skipwhite skipnl',
        \ 'syn match luau%t_Variadic /\.\.\./ contained%n',
        \ 'syn match luau%t_Uop /#\|-\%(-\)\@!\|\<not\>/ contained nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn region luau%t_Table matchgroup=luauTable start="{" end="}" transparent contained contains=@luau%l,@luauT,luauComment%n',
        \ 'syn region luau%t_InlineIf matchgroup=luauC_Keyword start="\<if\>" end="\<then\>"me=e-4 display transparent contained contains=@luau%e,luau%e_Uop nextgroup=luau%t_InlineThen',
        \ 'syn region luau%t_InlineThen matchgroup=luauC_Keyword start="\<then\>" end="\<else\>" display transparent contained contains=@luau%e,luau%e_Uop,luau%t_InlineElseif nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn region luau%t_InlineElseif matchgroup=luauC_Keyword start="\<elseif\>" end="\<then\>" display transparent contained contains=@luau%e,luau%e_Uop nextgroup=@luau%e,luau%e_Uop skipwhite' ],
      \ 'exp2': [
        \ 'syn match luau%t2_Dot /\./ transparent contained nextgroup=@luau%t,luau%t_Var skipwhite',
        \ 'syn match luau%t2_Colon /\:/ transparent contained nextgroup=luau%t_ColonInvoked skipwhite',
        \ 'syn region luau%t2_Invoke matchgroup=luau%t2_Invoke start="(" end=")" contained contains=@luau%l,luau%l_Uop nextgroup=@luau%t2 skipwhite',
        \ 'syn region luau%t2_Bracket matchgroup=luau%t2_Bracket start="\[" end="\]" contained contains=@luau%e,luau%e_Uop nextgroup=@luau%t2 skipwhite skipnl',
        \ 'syn match luau%t2_Binop /+\|-\%(-\)\@!\|\*\|\/\|\^\|%\|\.\.\|<=\?\|>=\?\|[~=]=\|\<and\>\|\<or\>/ contained nextgroup=@luau%t,luau%t_Uop skipwhite',
        \ 'syn match luau%t2_CastSymbol /::/ contained nextgroup=@luauCast%t skipwhite'] }

 

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
let s:exp_nxt1 = ' nextgroup=luauE2_Binop,luauE2_CastSymbol skipwhite skipnl'
let s:exp_nxt2 = ' nextgroup=luauE2_CastSymbol skipwhite'
call s:newExp(s:expmap, s:exphilinkmap, s:expout, s:exphilinkout, {
     \ 'string': {           'n': s:exp_nxt1,   'p': ''                     },
     \ 'number': {           'n': s:exp_nxt1,   'p': ''                     },
     \ 'const':  {           'n': s:exp_nxt1,   'p': ''                     },
     \ 'expc':   {'t': 'E',  'n': '',           'p': ''                     },
     \ 'exp':    {'t': 'E',  'n': s:exp_nxt2,           'e': 'E', 'l': 'L'  },
     \ 'exp2':   {'t': 'E',                             'e': 'E', 'l': 'L'  } })
" @luauL, @luauL2, luauL_Number, luauL_Float, @luauL_GeneralString
let s:lexp_nxt1 = ' contained nextgroup=luauL2_Sep,luauL2_Binop,luauL2_CastSymbol skipwhite skipnl'
let s:lexp_nxt2 = ',luauL2_Sep'
let s:lexp_nxt3 = ' nextgroup=luauL2_Sep,luauL2_CastSymbol skipwhite'
call s:newExp(s:expmap, s:exphilinkmap, s:expout, s:exphilinkout, {
     \ 'string': {           'n': s:lexp_nxt1, 'p': 'L_',                     },
     \ 'number': {           'n': s:lexp_nxt1, 'p': 'L_',                     },
     \ 'const':  {           'n': s:lexp_nxt1, 'p': 'L_'                      },
     \ 'expc':   {'t': 'L',  'n': s:lexp_nxt2, 'p': 'L_',           'l': 'L'  },
     \ 'exp':    {'t': 'L',  'n': s:lexp_nxt3,            'e': 'E', 'l': 'L'  },
     \ 'exp2':   {'t': 'L',                               'e': 'E', 'l': 'L'  } })
call s:processExpStack(s:expout)

syn cluster luauK contains=luauK_Local,luauK_Function,luauK_Do,luauK_Return,luauK_Break,luauK_Continue
syn cluster luauS contains=luauS_Wrap,luauS_HeadVar,luauS_HeadDottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar,luauS_ColonInvocation,luauS_DictRef
syn cluster luauR contains=luauR_While,luauR_Repeat,luauR_For
syn cluster luauC contains=luauC_If
syn cluster luauTop contains=@luauK,@luauS,@luauR,@luauC,luauComment,@luauGeneralString

syn cluster luauA contains=luauA_DottedVar,luauA_HungVar,luauA_TailVar,luauA_DictRef
syn cluster luauT contains=luauT_NDictK,luauT_EDictK,luauT_Symbol,luauT_Semicolon

syn match luauL2_Sep /,/ contained nextgroup=@luauL,luauL_Uop skipwhite skipempty

syn match luauS_InvokedVar /\<\K\k*\>\%(\s*\%((\|'\|"\|\[=*\[\)\)\@=/ containedin=luauS_HeadVar,luauS_DotHead nextgroup=luauV_Invoke skipwhite
syn match luauS_ColonInvocation /\<\K\k*\>\%(\s*:\)\@=/ containedin=luauS_HeadVar,luauS_DotHead nextgroup=luauV_Colon skipwhite skipnl
" Top Level Statements: variable tokens
syn match luauS_HeadVar /\%(\.\s*\)\@<!\<\K\k*\>\%(\s*\%(,\|\[\|\.\)\)\@!/ nextgroup=@luauV skipwhite
syn match luauS_HeadDottedVar /\%(\.\s*\)\@<!\<\K\k*\>\%(\s*\.\)\@=/ nextgroup=luauV_HeadDot skipwhite
syn match luauS_DotHead /\<\K\k*\>\%(\s*\%(,\|\[\|\.\)\)\@!/ contained nextgroup=@luauV,luauA_Symbol skipwhite
syn match luauS_DottedVar /\<\K\k*\>\%(\s*\.\)\@=/ contained nextgroup=luauV_Dot skipwhite
syn match luauS_HungVar /\%(end\)\@!\<\K\k*\>\%(\s*,\)\@=/ nextgroup=luauA_Comma skipwhite
syn match luauS_TailVar /\<\K\k*\>\%(\s*\%(=\|+=\|-=\|\/=\|\*=\|\^=\|\.=\)\)\@=/ containedin=luauS_DotHead nextgroup=luauA_Symbol skipwhite
syn match luauS_DictRef /\<\K\k*\>\%(\s*\[\)\@=/ contains=@luauGeneralBuiltin nextgroup=luauV_DictKey skipwhite

" Top Level Statement: anonymous wrapped expression
syn region luauS_Wrap matchgroup=luauS_Wrap start="\%(\%(\K\k*\|\]\|:\)\s*\)\@<!(" end=")" transparent contains=@luauE,luauE_Uop nextgroup=@luauV,@luauE2 skipwhite skipnl

" /\K\k*\%(\s*\%((\|"\|''\|\[=*\[\)\)\@=/
" /\K\k*\%(\s*\%((\|'\|"\|\[=*\[\)\)\@=/ 

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
syn match luauB_ParamVariadic /\.\.\./ contained nextgroup=luauB_ParamVariadicColon skipwhite
syn match luauB_ParamSep /,/ contained nextgroup=luauB_Param skipwhite skipnl
syn keyword luauB_Function function contained nextgroup=luauF_Method skipwhite

" Top Level Keyword: do (anonymous block)
syn region luauK_Do matchgroup=luauK_Keyword start="\<do\>" end="\<end\>" transparent contains=@luauTop

" luauR - (R)epeat

" Top Level Repeats: while, repeat, for
syn region luauR_While matchgroup=luauR_Keyword start="\<while\>" end="\<do\>"me=e-2 transparent contains=@luauE,luauE_Uop nextgroup=luauR_Do
syn region luauR_Repeat matchgroup=luauR_Keyword start="\<repeat\>" end="\<until\>" transparent contains=@luauTop nextgroup=@luauE,luauE_Uop skipwhite skipnl
syn keyword luauR_For for nextgroup=luauD_HeadBinding skipwhite

syn region luauR_Do matchgroup=luauR_Keyword start="\<do\>" end="\<end\>" transparent contained contains=@luauTop

" Top Level Keywords: break, continue
syn keyword luauK_Break break
syn keyword luauK_Continue continue

" luauD - (D)omain of iteration

syn match luauD_HeadBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_ExpRangeStart,luauD_CanonRange skipwhite
syn match luauD_CanonListBinding /\K\k*/ contained nextgroup=luauD_CanonListBindingSep,luauD_CanonRange skipwhite
syn match luauD_CanonListBindingSep /,/ contained nextgroup=luauD_CanonListBinding skipwhite skipnl

syn region luauD_CanonRange matchgroup=luauD_CanonRange start="\<in\>" end="\<do\>"me=e-2 transparent contained contains=@luauL,luauL_Uop nextgroup=luauR_Do

syn region luauD_ExpRangeStart matchgroup=luauD_ExpRangeStart start="=" end=","me=e-1 transparent contained contains=@luauE,luauE_Uop nextgroup=luauD_ExpRangeStep
syn region luauD_ExpRangeStep matchgroup=luauD_ExpRangeStep start="," end="\<do\>"me=e-2 transparent contained contains=@luauE,luauE_Uop nextgroup=luauR_Do

" luauS - top level syntactic (S)tatements

" Top Level Keyword: [export] type
syn match luauK_Export /export\%(\s\+[^[:keyword:]]\)\@!/ nextgroup=luauK_Type skipwhite
syn match luauK_Type /type\%(\s\+[^[:keyword:]]\)\@!/ nextgroup=luauTypedef_DottedName,luauTypedef_Name skipwhite
syn match luauTypedef_DottedName /\<\K\k*\>\%(\s*\.\)\@=/ contained nextgroup=luauTypedef_Dot skipwhite
syn match luauTypedef_Dot /\./ contained nextgroup=luauTypedef_Name skipwhite
syn match luauTypedef_Name /\<\K\k*\>\%(\s*\.\)\@!/ contained nextgroup=luauTypedef_GenParam,luauTypedef_Symbol skipwhite
syn region luauTypedef_GenParam matchgroup=luauStructure start="<" end=">" transparent contained contains=@luauDefGen nextgroup=luauTypedef_Symbol skipwhite skipnl
syn match luauTypedef_Symbol /=/ contained nextgroup=@luauType skipwhite skipnl

" luauV - operators on top level (V)ariables

syn cluster luauV contains=luauV_Invoke,luauV_DictKey,luauV_Dot,luauV_Colon
syn region luauV_Invoke matchgroup=luauV_Invoke start="(" end=")" contained contains=@luauL,luauL_Uop nextgroup=@luauV
syn region luauV_DictKey start="\[" end="\]" transparent contained contains=@luauE,luauE_Uop nextgroup=@luauV,luauA_Comma,luauA_Symbol skipwhite
syn match luauV_HeadDot /\./ transparent contained nextgroup=luauS_DotHead skipwhite
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
          \ 'syn cluster luau%T contains=luau%T_Name,luau%T_Module,luau%T_Table,luau%T_FunctionGen,luau%T_StringSingleton,luau%T_BoolSingleton,luau%T_NilSingleton,luau%T_SpecialTypeOf,luau%T_Paren',
          \ 'syn cluster luau%T2 contains=luau%T2_Binop',
          \ ],
        \ 'type': [
          \ {'hilink': 'luauIdentifier', 'cmd': 'syn keyword luau%T_Primitive any number string boolean function table thread userdata contained containedin=luau%T_Name' },
          \ {'hilink': 'luauSpecial', 'cmd': 'syn keyword luau%T_Boundary never unknown contained containedin=luau%T_Name' },
          \ {'hilink': 'luauOperator', 'cmd': 'syn match luau%T_Uop /?/ contained nextgroup=@luau%T2 skipwhite skipnl'},
          \ {'hilink': 'luauTypeAnnotation', 'cmd': 'syn match luau%T_Name /\<\K\k*\>\%(\s*\%(\.\|:\)\)\@!/ contained nextgroup=@luau%T2,luau%T_Uop,luau%T_Param skipwhite skipnl' },
          \ 'syn match luau%T_Module /\<\K\k*\s*\.\%(\s*\K\)\@=/ contained nextgroup=luau%T_Name skipwhite',
          \ 'syn region luau%T_Table matchgroup=luauTable start=+{+ end=+}+ transparent contained contains=@luauType,luauTypeProp_Name,luauTypeProp_Key,luauComment nextgroup=@luau%T2,luau%T_Uop skipwhite',
          \ 'syn region luau%T_FunctionGen matchgroup=luauStructure start=+\%(\k\s*\)\@<!<+ end=+>+ transparent contained contains=@luauTypeGenParam nextgroup=luau%T_FunctionParam skipwhite',
          \ 'syn region luau%T_Param matchgroup=luauDelimiter start=+<+ end=+>+ transparent contained contains=@luauTypeParam nextgroup=@luau%T2,luau%T_Uop skipwhite',
          \ {'hilink': 'luauPreProc', 'cmd': 'syn match luau%T_SpecialTypeOf /\<typeof\%(\s*[^(]\)\@!/ nextgroup=luau%T_ExpInference skipwhite'},
          \ 'syn region luau%T_ExpInference matchgroup=luauDelimiter start=+(+ end=+\%((\)\@1<!)+ transparent contained contains=@luauE nextgroup=@luau%T2 skipwhite skipnl',
          \ {'hilink': 'luauString', 'cmd': 'syn region luau%T_StringSingleton matchgroup=luauString start=+\z("\|''\)+ end=+\z1+ contained nextgroup=@luau%T2,luau%T_Uop skipwhite' },
          \ {'hilink': 'luauBoolean', 'cmd': 'syn keyword luau%T_BoolSingleton true false contained nextgroup=@luau%T2,luau%T_Uop skipwhite' },
          \ {'hilink': 'luauConstant', 'cmd': 'syn keyword luau%T_NilSingleton nil contained nextgroup=@luau%T2,luau%T_Uop skipwhite' },
          \ 'syn region luau%T_FunctionParam matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name,luauTypeFParam_Variadic nextgroup=luau%T_Arrow,luau%T_Uop skipwhite',
          \ {'hilink': 'luauStructure', 'cmd': 'syn match luau%T_Arrow /->/ contained nextgroup=@luau%T,luau%T_Paren,luauTypeL_Variadic,luauTypeL_GenPack skipwhite skipnl' },
          \ 'syn region luau%T_Paren matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name,luauTypeFParam_Variadic nextgroup=luau%T_Arrow,luau%T_Uop,@luau%T2 skipwhite skipnl' ],
        \ 'type2': [
          \ {'hilink': 'luauStructure', 'cmd': 'syn match luau%T2_Binop /|\|&/ contained nextgroup=@luau%T skipwhite skipnl' } ] }

  " \ 'syn region luau%T_Pack matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL nextgroup=@luau%T2 skipwhite' ],

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

  syn cluster luauTypeL2 add=luauTypeL2_Sep
  syn cluster luauTypeParam2 add=luauTypeParam2_Sep
  syn cluster luauTypeL add=luauTypeL_Variadic,luauTypeL_GenPack
  syn cluster luauTypeParam add=luauTypeParam_Variadic,luauTypeParam_GenPack
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

  " syn region luauTypeParam_Paren matchgroup=luauDelimiter start=+(+ end=+)+ transparent contained contains=@luauTypeL,luauTypeFParam_Name,luauTypeFParam_Variadic nextgroup=luauType_Arrow,@luauTypeParam2 skipwhite

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
  syn region luauTypeProp_Key matchgroup=luauStructure start=/\[/ end=/\]/ transparent contained contains=@luauType nextgroup=luauTypeProp_Sep skipwhite

  " GenericTypeParam (non-typedef: no instantiation of generics is permitted)

  syn cluster luauTypeGenParam contains=luauTypeGenParam_Name,@luauTypeGenPack
  syn cluster luauTypeGenPack contains=luauTypeGenPack_Name

  syn match luauTypeGenParam_Sep /,/ contained nextgroup=@luauTypeGenParam,@luauTypeGenPack skipwhite skipnl
  syn match luauTypeGenPack_Sep /,/ contained nextgroup=@luauTypeGenPack skipwhite skipnl
  syn match luauTypeGenPack_Symbol /\.\.\./ contained nextgroup=luauTypeGenPack_Sep skipwhite
  syn match luauTypeGenPack_Name /\K\k*\%(\s*\.\)\@=/ contained nextgroup=luauTypeGenPack_Symbol skipwhite
  syn match luauTypeGenParam_Name /\K\k*\%(\s*\.\)\@!/ contained nextgroup=luauTypeGenParam_Sep skipwhite

  " GenericTypeParameterList (can instantiate generics)
  
  syn cluster luauDefGen contains=luauDefGen_Name,@luauDefPack
  syn cluster luauDefPack contains=luauDefPack_Name

  syn region luauDefPack_Assign start="=" end=","me=e-1 end=">"me=e-1 transparent contained contains=luauType_Paren,luauTypeL_Variadic nextgroup=luauDefPack_Sep skipwhite skipnl
  syn region luauDefGen_Assign start="=" end=","me=e-1 end=">"me=e-1 transparent contained contains=@luauType nextgroup=luauDefGen_Sep skipwhite skipnl
  syn match luauDefGen_Sep /,/ contained nextgroup=@luauDefGen skipwhite skipnl
  syn match luauDefPack_Sep /,/ contained nextgroup=@luauDefPack skipwhite skipnl
  syn match luauDefPack_Symbol  /\.\.\./ contained nextgroup=luauDefPack_Sep,luauDefPack_Assign skipwhite
  syn match luauDefPack_Name /\K\k*\%(\s*\.\)\@=/ contained nextgroup=luauDefPack_Symbol skipwhite
  syn match luauDefGen_Name /\K\k*\%(\s*\.\)\@!/ contained nextgroup=luauDefGen_Sep,luauDefGen_Assign skipwhite
endif

syn cluster luauGeneralBuiltin contains=luauBuiltin,luauLibrary,luauIdentifier
" syn cluster luauGeneralBuiltinDot contains=luauLibraryDot
syn cluster luauEnv contains=luauS_HeadVar,luauS_HeadDottedVar,luauE_HeadVar,luauL_HeadVar
if (g:luauHighlightBuiltins)
  " The Luau builtin functions are straightforward.
  " There are some extra debug library functions in Roblox.
  syn keyword luauBuiltin assert collectgarbage error gcinfo contained containedin=@luauEnv
  syn keyword luauBuiltin getfenv getmetatable ipairs loadstring newproxy contained containedin=@luauEnv
  syn keyword luauBuiltin next pairs pcall print rawget rawequal rawset require contained containedin=@luauEnv
  syn keyword luauBuiltin setfenv select setmetatable tonumber tostring contained containedin=@luauEnv
  syn match luauBuiltin /\<type\%(\s*[^[:keyword:][:space:]]\)\@=/  contained containedin=@luauEnv
  syn keyword luauBuiltin typeof unpack xpcall contained containedin=@luauEnv

  syn keyword luauLibrary bit32 coroutine string table math os debug utf8 contained containedin=@luauEnv nextgroup=luauLibraryDot

  syn match luauLibraryDot /\./ transparent contained nextgroup=@luauDotLibs

  syn cluster luauDotLibs contains=luauDotBit32,luauDotCoroutine,luauDotString,luauDotTable
  syn cluster luauDotLibs add=luauDotMath,luauDotMath_const,luauDotOS,luauDotDebug,luauDotUTF8

  syn keyword luauDotBit32 arshift lrotate lshift replace rrotate rshift contained
  syn keyword luauDotBit32 btest bxor band bnot bor countlz countrz extract contained

  syn keyword luauDotCoroutine close create isyieldable resume running status wrap yield contained

  syn keyword luauDotString byte char find format gmatch gsub len lower contained
  syn keyword luauDotString match pack packsize rep reverse split sub unpack upper contained

  syn keyword luauDotTable create clear clone concat foreach foreachi find freeze contained
  syn keyword luauDotTable getn insert isfrozen maxn move pack remove sort unpack contained

  syn keyword luauDotMath abs acos asin atan atan2 ceil clamp cos cosh deg exp contained
  syn keyword luauDotMath floor fmod frexp ldexp log log10 max min modf noise contained
  syn keyword luauDotMath pow rad random randomseed round sign sin sinh sqrt tan tanh contained
  syn keyword luauDotMath_const huge pi contained

  syn keyword luauDotOS clock date difftime time contained

  syn keyword luauDotDebug info traceback contained
  if (g:luauHighlightRoblox)
    syn keyword luauDotDebug profilebegin profileend resetmemorycategory setmemorycategory contained
  endif

  syn keyword luauDotUTF8 char codepoint codes len offset contained
endif

syn cluster luauGeneralBuiltin add=rbxIdentifier,rbxBuiltin,rbxLibrary,rbxDatatype
" syn cluster luauGeneralBuiltinDot add=rbxLibraryDot,rbxDataDot,rbxCFrameDot,rbxColor3Dot,rbxDateTimeDot,rbxFontDot,rbxUDim2Dot,rbxVector2Dot,rbxVector3Dot,rbxInstanceDot
if (g:luauHighlightRoblox)
  syn cluster luauTop add=rbxIdentifier,rbxBuiltin,rbxLibrary,rbxDatatype

  syn keyword rbxIdentifier game contained containedin=@luauEnv nextgroup=rbxGameMethod
  syn keyword rbxIdentifier plugin script workspace shared contained containedin=@luauEnv

  syn keyword rbxBuiltin delay DebuggerManager elapsedTime LoadLibrary PluginManager contained containedin=@luauEnv
  syn keyword rbxBuiltin printidentity settings spawn stats tick time UserSettings contained containedin=@luauEnv
  syn keyword rbxBuiltin version warn contained containedin=@luauEnv

  syn keyword rbxLibrary task contained containedin=@luauEnv nextgroup=rbxLibraryDot

  syn match rbxLibraryDot /\./ transparent contained nextgroup=rbxDotTask

  syn keyword rbxDotTask cancel defer delay desynchronize spawn wait contained

  syn match rbxGameMethod /:/ contained nextgroup=rbxMethodGame
  syn keyword rbxMethodGame GetService nextgroup=rbxGetService skipwhite
  " syn region rbxGetService start="GetService"

  if (g:luauHighlightTypes)
    syn keyword rbxDatatype Enum EnumItem contained
    syn keyword rbxDatatype RBXScriptConnection RBXScriptSignal contained
    syn keyword rbxDatatype RaycastResult contained

    syn keyword rbxDatatype Axes BrickColor CatalogSearchParams ColorSequence contained containedin=@luauEnv nextgroup=rbxDataDot
    syn keyword rbxDatatype ColorSequence ColorSequenceKeypoint contained containedin=@luauEnv nextgroup=rbxDataDot
    syn keyword rbxDatatype DockWidgetPluginGuiInfo Faces FloatCurveKey contained containedin=@luauEnv nextgroup=rbxDataDot
    syn keyword rbxDatatype NumberRange NumberSequence NumberSequenceKeypoint contained containedin=@luauEnv nextgroup=rbxDataDot
    syn keyword rbxDatatype OverlapParams PathWaypoint PhysicalProperties contained containedin=@luauEnv nextgroup=rbxDataDot
    syn keyword rbxDatatype Random RaycastParams Rect Region3 contained containedin=@luauEnv nextgroup=rbxDataDot
    syn keyword rbxDatatype Region3int16 TweenInfo UDim Vector2int16 contained containedin=@luauEnv nextgroup=rbxDataDot
    syn keyword rbxDatatype Vector3int16 contained containedin=@luauEnv nextgroup=rbxDataDot
    syn match rbxDataDot /\./ contained nextgroup=rbxDotData
    syn keyword rbxDotData new contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype CFrame contained containedin=@luauEnv nextgroup=rbxCFrameDot
    syn match rbxCFrameDot /\./ contained nextgroup=rbxDotCFrame,rbxDotData
    syn keyword rbxDotCFrame lookAt fromEulerAnglesXYZ fromEulerAnglesYXZ contained nextgroup=luauE2_Invoke
    syn keyword rbxDotCFrame Angles fromOrientation fromAxisAngle fromMatrix contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Color3 contained containedin=@luauEnv nextgroup=rbxColor3Dot
    syn match rbxColor3Dot /\./ contained nextgroup=rbxDotColor3,rbxDotData
    syn keyword rbxDotColor3 fromRGB, fromHSV, fromHex contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype DateTime contained containedin=@luauEnv nextgroup=rbxDateTimeDot
    syn match rbxDateTimeDot /\./ contained nextgroup=rbxDotDateTime,rbxDotData
    syn keyword rbxDotDateTime fromUnixTimestamp fromUnixTimestampMillis nextgroup=luauE2_Invoke
    syn keyword rbxDotDateTime fromUniversalTime fromLocalTime fromIsoDate nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Enum contained containedin=@luauEnv nextgroup=rbxEnumsMethod
    syn match rbxEnumsMethod /:/ contained nextgroup=rbxMethodEnums
    syn keyword rbxMethodEnums GetEnums contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Font contained containedin=@luauEnv nextgroup=rbxFontDot
    syn match rbxFontDot /\./ contained nextgroup=rbxDotFont,rbxDotData
    syn keyword rbxDotFont fromEnum contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype UDim2 contained containedin=@luauEnv nextgroup=rbxUDim2Dot
    syn match rbxUDim2Dot /\./ contained nextgroup=rbxDotUDim2,rbxDotData
    syn keyword rbxDotUDim2 fromScale fromOffset contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Vector2 contained containedin=@luauEnv nextgroup=rbxVector2Dot
    syn match rbxVector2Dot /\./ contained nextgroup=rbxDotVector2_const,rbxDotData
    syn keyword rbxDotVector2_const zero one xAxis yAxis contained

    syn keyword rbxDatatype Vector3 contained containedin=@luauEnv nextgroup=rbxVector3Dot,rbxDotData
    syn match rbxVector3Dot /\./ contained nextgroup=rbxDotVector3,rbxDotVector3_const
    syn keyword rbxDotVector3_const zero one xAxis yAxis zAxis contained
    syn keyword rbxDotVector3 FromNormalId FromAxis contained nextgroup=luauE2_Invoke

    syn keyword rbxDatatype Instance contained containedin=@luauEnv nextgroup=rbxInstanceDot
    syn match rbxInstanceDot /\./ contained nextgroup=rbxDotInstance
    syn keyword rbxDotInstance new contained nextgroup=rbxInstanceNewInvoke,rbxInstanceNewArg skipwhite
    syn region rbxInstanceNewInvoke matchgroup=luauDelimiter start=+(\%(\_s*\z("\|'\)\)\@=+ end=+\%(\z1\_s*\)\@<=)+ contained contains=rbxInstanceNewArg keepend
    syn region rbxInstanceNewArg start=+\z("\|'\)+ end=+\z1+ transparent contained 

  endif

  if (g:luauRobloxIncludeAPIDump)
    if has('win32') || has('win64')
      let s:rbx_syngen_fpath = luau_vim#getRobloxSyntaxTargetPath('\')
    else
      let s:rbx_syngen_fpath = luau_vim#getRobloxSyntaxTargetPath('/')
    endif

    if !filereadable(s:rbx_syngen_fpath)
      call luau_vim#robloxAPIParse(luau_vim#robloxAPIFetch())
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
hi def link luauIntEscape             luauEscape
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

hi def link luauTypedef_Symbol        luauA_Symbol

hi def link luauD_ExpRangeStart       luauA_Symbol

hi def link luauT_Symbol              luauA_Symbol

hi def link luauE_Callback            luauStatement
hi def link luauL_Callback            luauE_Callback

hi def link luauE_Variadic            luauSpecial
hi def link luauL_Variadic            luauE_Variadic
hi def link luauB_ParamVariadic       luauE_Variadic
hi def link luauTypeL_Variadic        luauE_Variadic
hi def link luauTypeParam_Variadic    luauE_Variadic

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

hi def link luauTable               luauStructure

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

let &cpoptions = s:cpo_save
unlet s:cpo_save
