" Vim syntax file
" Language:     Luau 0.543
" Maintiner:    polychromatist <polychromatist 'at' proton me>
" First Author: polychromatist
" Last Change:  2022 Sep 1
" Options:      luau_roblox = 0 or 1

if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:luauHighlightAll')
  let g:luauHighlightAll = 1
endif
let g:luauHighlightNumbers = g:luauHighlightAll
let g:luauHighlightTypes = g:luauHighlightAll
let g:luauHighlightBuiltins = g:luauHighlightAll
let g:luauHighlightRoblox = g:luauHighlightAll

let s:api_dump_url = 'https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.json'

syn case match

syn keyword luauStatement break continue do export local return type

syn keyword luauOperator and in or not

syn keyword luauConstant false nil true

syn keyword luauRepeat for repeat until while

syn match luauStatement "function\s\+\%([a-zA-Z_]\)\@=" nextgroup=luauFunction

syn match luauFunction "[a-zA-Z_][a-zA-Z0-9_]*" contained nextgroup=luauBlockFunction1

syn match luauAnonymousFunction "function\_s*\%((\)\@=" transparent nextgroup=luauBlockFunction1

syn keyword luauConditional if elseif else

syn match luauComment "--.*$" contains=luauTodo
syn region luauComment matchgroup=luauComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luauTodo

syn keyword luauTodo TODO FIXME XXX NOTE contained

" single-character string escape sequence
syn match luauEscape contained #\\[\\abfnrtv'"]#
" hex based ASCII character escape sequence
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

" simple string matches - multiline, single and double single line strings
syn region luauString matchgroup=luauString start="\[\z(=*\)\[" end="\]\z1\]"   contains=luauEscape
syn region luauString matchgroup=luauString start=+'+ end=+'+ skip=+\\\\\|\\'+  contains=luauEscape oneline
syn region luauString matchgroup=luauString start=+"+ end=+"+ skip=+\\\\\|\\"+  contains=luauEscape oneline

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
syn match luauStringFragment1 /".\{-}\\$/ nextgroup=luauStringFragment2,luauStringZFragment2,luauStringFragment3            contains=luauEscape,luauEOLEscape skipwhite skipnl
syn match luauStringFragment2 /^.\{-}\\$/ contained nextgroup=luauStringFragment2,luauStringZFragment2,luauStringFragment3  contains=luauEscape,luauEOLEscape skipwhite skipnl
syn match luauStringFragment3 /^.\{-}"/   contained contains=luauEscape

syn match luauStringFragment1Alt /'.\{-}\\$/  nextgroup=luauStringFragment2Alt,luauStringZFragment2Alt,luauStringFragment3Alt            contains=luauEscape,luauEOLEscape skipnl skipwhite
syn match luauStringFragment2Alt /^.\{-}\\$/  contained nextgroup=luauStringFragment2Alt,luauStringZFragment2Alt,luauStringFragment3Alt  contains=luauEscape,luauEOLEscape skipnl skipwhite
syn match luauStringFragment3Alt /^.\{-}'/    contained contains=luauEscape

" following six: syntax treatment for \z string input device
" analogous to the backslash device, except using regions to properly
" model all types of acceptable behavior specified in Luau documentation.
" characters beyond a \z input device can span unbounded amounts of lines and
" whitespace, but not any character that is not whitespace. once a
" non-whitespace character is encountered, the \z device has completed its
" task and no other special behavior can be expected from it.
syn region luauStringZFragment1           start=+"+ end=+\\z+ skip=+\\\\\|\\"+  nextgroup=luauStringZFragment2,luauStringFragment2,luauStringZFragment3 contains=luauEscape,luauZEscape skipwhite skipempty oneline
syn region luauStringZFragment2 contained start=+^+ end=+\\z+ skip=+\\\\\|\\"+  nextgroup=luauStringZFragment2,luauStringFragment2,luauStringZFragment3 contains=luauEscape,luauZEscape skipwhite skipempty oneline
syn region luauStringZFragment3 contained start=+^+ end=+"+   skip=+\\\\\|\\"+  contains=luauEscape,luauZEscape skipwhite skipempty oneline

syn region luauStringZFragment1Alt            start=+'+ end=+\\z+ skip=+\\\\\|\\'+  nextgroup=luauStringZFragment2Alt,luauStringFragment2Alt,luauStringZFragment3Alt contains=luauEscape,luauZEscape skipwhite skipempty oneline
syn region luauStringZFragment2Alt  contained start=+^+ end=+\\z+ skip=+\\\\\|\\'+  nextgroup=luauStringZFragment2Alt,luauStringFragment2Alt,luauStringZFragment3Alt contains=luauEscape,luauZEscape skipwhite skipempty oneline
syn region luauStringZFragment3Alt  contained start=+^+ end=+'+   skip=+\\\\\|\\'+  contains=luauEscape,luauZEscape skipwhite skipempty oneline

syn region luauBlockTable matchgroup=luauStructure start=+{+ end=+}+ contains=luauBlockTable,luauBlockFunction,luauEntryTable,luauString
syn region luauBlockFunction1 matchgroup=luauStructure start=+(+ end=+)+ contained nextgroup=luauBlockFunction2 skipwhite skipempty
syn region luauBlockFunction2 start=+.+ end=+end+ transparent contained



if (g:luauHighlightNumbers)
  " In Luau, numbers can be interfixed by underscores with no consequence.
  " * if it's an irregular base, the format prefix (0x) cannot be interfixed.
  " there are no formats for unsigned integers.

  " (1) regular integers
  syn match luauNumber "\<[[:digit:]_]\+\>"
  " (2) decimals; possible scientific E-notation with signed exponential
  syn match luauNumber  "\<[[:digit:]_]\+\.[[:digit:]_]*\%([eE][-+]\=[[:digit:]_]\+\)\=\>"
  " (3) same as (3) with implicit zero on mantissa's most significant digit
  syn match luauNumber  "\.[[:digit:]_]\+\%([eE][-+]\=[[:digit:]_]\+\)\=\>"
  " scientific E-notation with integer mantissa
  syn match luauNumber  "\<[[:digit:]_]\+[eE][-+]\=[[:digit:]_]\+\>"
  " (4) hex-format integers 
  syn match luauNumber "\<0[xX][[:xdigit:]_]\+\>"
  " (5) binary-format integers (w.r.t bit32 library)
  syn match luauNumber "\<0[bB][01_]\+\>"
endif

if (g:luauHighlightTypes)
  " One of Luau's signature features is a rich type system.
  " * luau-lang.org/typecheck
  

endif

if (g:luauHighlightBuiltins)
  syn keyword luauBuiltin _G _VERSION assert collectgarbage error gcinfo
  syn keyword luauBuiltin getfenv getmetatable ipairs loadstring newproxy
  syn keyword luauBuiltin next pairs pcall print rawget rawequal rawset require
  syn keyword luauBuiltin setfenv select setmetatable tonumber tostring type
  syn keyword luauBuiltin typeof unpack xpcall

  syn keyword luauLibrary bit32 coroutine string table math os debug utf8 nextgroup=luauLibraryDot

  syn match luauLibraryDot /\./ transparent contained nextgroup=luauDotBit32,luauDotCorotuine,luauDotString,luauDotTable,luauDotMath,luauDotOS,luauDotDebug,luauDotUTF8

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
  syn keyword rbxBuiltin game plugin script workspace

  syn keyword rbxBuiltin delay DebuggerManager elapsedTime LoadLibrary PluginManager
  syn keyword rbxBuiltin printidentity settings spawn stats tick time UserSettings
  syn keyword rbxBuiltin version warn

  syn keyword rbxLibrary task nextgroup=rbxLibraryDot

  syn match rbxLibraryDot /\./ transparent contained nextgroup=rbxDotTask

  syn keyword rbxDotTask cancel defer delay desynchronize spawn wait contained
endif

hi def link luauStatement             Statement
hi def link luauString                String
hi def link luauNumber                Number
hi def link luauFunction              Function
hi def link luauConditional           Conditional
hi def link luauOperator              Operator
hi def link luauComment               Comment
hi def link luauEscape                Special
hi def link luauTodo                  Todo
hi def link luauStructure             Structure

hi def link luauStringFragment1       luauString
hi def link luauStringFragment2       luauString
hi def link luauStringFragment3       luauString
hi def link luauStringFragment1Alt    luauString
hi def link luauStringFragment2Alt    luauString
hi def link luauStringFragment3Alt    luauString
hi def link luauStringZFragment1      luauString
hi def link luauStringZFragment2      luauString
hi def link luauStringZFragment3      luauString
hi def link luauStringZFragment1Alt   luauString
hi def link luauStringZFragment2Alt   luauString
hi def link luauStringZFragment3Alt   luauString
hi def link luauZEscape               luauEscape
hi def link luauEOLEscape             luauEscape
hi def link luauAnonymousFunction     luauStatement
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
    hi def link rbxBuiltin            Function

    hi def link rbxLibrary            rbxBuiltin
    hi def link rbxDotTask            rbxLibrary
  endif
endif

syn sync match luauSync grouphere NONE "\(\<function\s\+[a-zA-Z_][a-zA-Z0-9_]*(\)\@<=)$"
syn sync minlines=200

let b:current_syntax='luau'

let &cpo = s:cpo_save
unlet s:cpo_save
