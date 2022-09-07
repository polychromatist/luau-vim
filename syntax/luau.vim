" Vim syntax file
" Language:     Luau 0.543
" Maintainer:    polychromatist <polychromatist 'at' proton me>
" First Author: polychromatist
" Last Change:  2022 Sep 5 (luau-vim v0.2.0)
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

syn keyword luauOperator and in or not

syn keyword luauConstant false nil true

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

" Section: Luau string literal - core

" simple string matches - multiline, single and double single line strings
syn region luauString matchgroup=luauString start="\[\z(=*\)\[" end="\]\z1\]"   contains=luauEscape
syn region luauString matchgroup=luauString start=+'+ end=+'+ skip=+\\\\\|\\'+  contains=luauEscape oneline
syn region luauString matchgroup=luauString start=+"+ end=+"+ skip=+\\\\\|\\"+  contains=luauEscape oneline

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
syn match luauStringF1            /".\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luauStringF2,luauStringZF2,luauStringF3 skipwhite skipnl
syn match luauStringF2 contained  /^.\{-}\\$/           contains=luauEscape,luauEOLEscape nextgroup=luauStringF2,luauStringZF2,luauStringF3 skipwhite skipnl
syn match luauStringF3 contained  /^.\{-}\%(\\\)\@1<!"/ contains=luauEscape

syn match luauStringF1Alt /'.\{-}\\$/                     contains=luauEscape,luauEOLEscape nextgroup=luauStringF2Alt,luauStringZF2Alt,luauStringF3Alt skipnl skipwhite
syn match luauStringF2Alt /^.\{-}\\$/           contained contains=luauEscape,luauEOLEscape nextgroup=luauStringF2Alt,luauStringZF2Alt,luauStringF3Alt skipnl skipwhite
syn match luauStringF3Alt /^.\{-}\%(\\\)\@1<!'/ contained contains=luauEscape

" following six: syntax treatment for \z string input device
" analogous to the backslash device, except using regions to properly
" model all types of acceptable behavior specified in Luau documentation.
" characters beyond a \z input device can span unbounded amounts of lines and
" whitespace, but not any character that is not whitespace. once a
" non-whitespace character is encountered, the \z device has completed its
" task and no other special behavior can be expected from it.
syn region luauStringZF1           start=+"+ end=+\\z+ skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luauStringZF2,luauStringF2,luauStringZF3 skipwhite skipempty oneline
syn region luauStringZF2 contained start=+^+ end=+\\z+ skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape nextgroup=luauStringZF2,luauStringF2,luauStringZF3 skipwhite skipempty oneline
syn region luauStringZF3 contained start=+^+ end=+"+   skip=+\\\\\|\\"+ contains=luauEscape,luauZEscape oneline

syn region luauStringZF1Alt           start=+'+ end=+\\z+ skip=+\\\\\|\\'+  contains=luauEscape,luauZEscape nextgroup=luauStringZF2Alt,luauStringF2Alt,luauStringZF3Alt skipwhite skipempty oneline
syn region luauStringZF2Alt contained start=+^+ end=+\\z+ skip=+\\\\\|\\'+  contains=luauEscape,luauZEscape nextgroup=luauStringZF2Alt,luauStringF2Alt,luauStringZF3Alt skipwhite skipempty oneline
syn region luauStringZF3Alt contained start=+^+ end=+'+   skip=+\\\\\|\\'+  contains=luauEscape,luauZEscape oneline

" Section: Luau string syn-clustering

syn cluster luauGeneralString contains=luauString
syn cluster luauGeneralString add=luauStringF1,luauStringF2,luauStringF3
syn cluster luauGeneralString add=luauStringF1Alt,luauStringF2Alt,luauStringF3Alt
syn cluster luauGeneralString add=luauStringZF1,luauStringZF2,luauStringZF3
syn cluster luauGeneralString add=luauStringZF1Alt,luauStringZF2Alt,luauStringZF3Alt

" Section: Luau numerics

" in Luau, similar to python, numbers can be interfixed by underscores
" with no consequence.
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

" Section: Luau grammar
syn cluster luauK contains=luauK_Local,luauK_Function
" exp membership determination
" prefixexp: simpleexp -> asexp -> exp
" luauCallback: 'function' funcbody -> prefixexp -> exp
" luauInvoke: functioncall -> prefixexp -> exp
" luauExpWrap: '(' exp ')' -> prefixexp -> exp
syn cluster luauE contains=luauE_Callback,luauE_Wrap,luauE_Var,luauE_Variadic
syn cluster luauE2 contains=luauE2_Invoke,luauE2_Dot,luauE2_Colon,luauE2_Bracket

syn cluster luauL contains=luauL_Callback,luauL_Wrap,luauL_Var,luauL_Variadic
syn cluster luauL2 contains=luauL2_Invoke,luauL2_Dot,luauL2_Colon,luauL2_Bracket,luauL2_Sep

" luauE2 - expression splitters
syn match luauE2_Dot /\./ contained nextgroup=@luauE skipwhite
syn region luauE2_Invoke matchgroup=luauOperator start="(" end=")" contained contains=@luauL nextgroup=@luauE2 skipwhite
syn match luauE2_Colon /\%(:\s*\)\@<=\K\k*\%(\s*\%((\|"\|'\|\[=*\[\)\)\@=/ contained nextgroup=luauE2_Invoke skipwhite skipnl
syn region luauE2_Bracket matchgroup=luauOperator start="\[" end="\]" contained contains=@luauE nextgroup=@luauE2 skipwhite

" luauL2 - list expression splitters, notably including a comma
syn match luauL2_Sep /,/ contained nextgroup=@luauL skipwhite skipempty
syn match luauL2_Dot /\./ contained nextgroup=@luauL skipwhite
syn region luauL2_Invoke matchgroup=luauOperator start="(" end=")" contained contains=@luauL nextgroup=@luauL2 skipwhite
syn match luauL2_Colon /\%(:\s*\)\@<=\K\k*\%(\s*\%((\|"\|'\|\[=*\[\)\)\@=/ contained nextgroup=luauL2_Invoke skipwhite
syn region luauL2_Bracket matchgroup=luauOperator start="\[" end="\]" contained contains=@luauE nextgroup=@luauL2 skipwhite

" luauE - single expressions
syn keyword luauE_Callback function contained nextgroup=luauE_FunctionParams skipwhite
syn region luauE_FunctionParams matchgroup=luauDelimiter start="(" end=")"me=e-1 contained contains=@luauBindings nextgroup=luauE_Block
syn region luauE_Block matchgroup=luauDelimiter start=")" matchgroup=luauStatement end="end" transparent contains=TOP contained

syn match luauE_Var /\K\k*\%(\s*\%(\.\|:\|\[\|(\)\)\@=/ contained nextgroup=@luauE2 skipwhite
syn region luauE_Wrap start="(" end=")" transparent contained contains=@luauE nextgroup=@luauE2 skipwhite
syn match luauE_Variadic /\.\.\./ contained

" luauL - list-contained expressions
syn keyword luauL_Callback function contained nextgroup=luauL_FunctionParams skipwhite
syn region luauL_FunctionParams matchgroup=luauDelimiter start="(" end=")"me=e-1 contained contains=@luauBindings nextgroup=luauL_Block
syn region luauL_Block matchgroup=luauDelimiter start=")" matchgroup=luauStatement end="end" transparent contains=TOP contained nextgroup=luauL2_Sep skipwhite

syn match luauL_Var /\K\k*\%(\s*\%(\.\|:\|\[\|(\)\)\@=/ contained nextgroup=@luauL2 skipwhite
syn region luauL_Wrap start="(" end=")" transparent contained contains=@luauE nextgroup=@luauL2 skipwhite
syn match luauL_Variadic /\.\.\./ contained nextgroup=luauL2_Sep skipwhite

" luauA - variable assignment syntax
syn match luauA_Symbol /=/ contained nextgroup=@luauL skipwhite
syn match luauA_Dot /\./ transparent contained nextgroup=luauA_DottedVar,luauA_HungVar,luauA_TailVar skipwhite
syn match luauA_DottedVar /\K\k*\%(\s*\.\)\@=/ transparent contained nextgroup=luauA_Dot skipwhite
syn match luauA_HungVar /\K\k*\%(\s*,\)\@=/ transparent contained nextgroup=luauA_Comma skipwhite
syn match luauA_TailVar /\K\k*\%(\s*=\)\@=/ transparent contained nextgroup=luauA_Symbol skipwhite
syn match luauA_Comma /,/ transparent contained nextgroup=luauA_DottedVar,luauA_HungVar,luauA_TailVar skipwhite skipnl

" luauK - keyword, luauF - function header, luauB - bindings

" Top Level Keyword: function
syn keyword luauK_Function function nextgroup=luauF_Name skipwhite
syn match luauF_Name /\K\k*/ contained nextgroup=luauF_Sep,luauF_Colon,luauE_FunctionParams skipwhite
syn match luauF_Method /\K\k*/ contained nextgroup=luauE_FunctionParams skipwhite
syn match luauF_Sep /\./ contained nextgroup=luauF_Name skipwhite
syn match luauF_Colon /:/ contained nextgroup=luauF_Method skipwhite

" Top Level Keyword: local
syn keyword luauK_Local local nextgroup=luauK_Function,luauB_Name skipwhite
syn match luauB_Name /\K\k*/ contained nextgroup=luauB_Sep,luauA_Symbol skipwhite skipnl
syn match luauB_Sep /,/ contained nextgroup=luauB_Name skipwhite

" luauS

" Top Level Statement: top level variables
syn match luauS_DottedVar /\K\k*\%(\s*\.\)\@=/ transparent nextgroup=luauV_Dot skipwhite
syn match luauS_HungVar /\K\k*\%(\s*,\)\@=/ transparent nextgroup=luauA_Comma skipwhite
syn match luauS_TailVar /\K\k*\%(\s*=\)\@=/ transparent nextgroup=luauA_Symbol skipwhite

" Top Level Statement: anonymous wrapped expression
syn region luauS_Wrap matchgroup=luauS_Wrap start="\%(\K\k*\|\]\|:\)\@<!(" end=")" transparent contains=@luauE nextgroup=@luauE2 skipwhite skipnl

" Top Level Statement: function or method invocation
syn match luauS_InvokedVar /\K\k*\%(\s*\%((\|'\|"\|\[=*\[\)\)\@=/ transparent nextgroup=luauE2_Invoke skipwhite
syn match luauS_ColonInvocation /\K\k*\%(\s*:\)\@=/ transparent nextgroup=luauV_Colon skipwhite skipnl

" luauV - operators on top level variables
syn match luauV_Dot /\./ transparent contained nextgroup=luauS_DottedVar,luauS_HungVar,luauS_TailVar,luauS_InvokedVar skipwhite
syn match luauV_Colon /:/ transparent contained nextgroup=luauS_InvokedVar skipwhite


if (g:luauHighlightTypes)
  " One of Luau's signature features is a rich type system.
  " * luau-lang.org/typecheck
  

endif

if (g:luauHighlightBuiltins)
  syn keyword luauBuiltin assert collectgarbage error gcinfo
  syn keyword luauBuiltin getfenv getmetatable ipairs loadstring newproxy
  syn keyword luauBuiltin next pairs pcall print rawget rawequal rawset require
  syn keyword luauBuiltin setfenv select setmetatable tonumber tostring type
  syn keyword luauBuiltin typeof unpack xpcall

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

hi def link luauIdentifier            Identifier
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
hi def link luauDelimiter             Delimiter

hi def link luauStringF1              luauString
hi def link luauStringF2              luauString
hi def link luauStringF3              luauString
hi def link luauStringZF1             luauString
hi def link luauStringZF2             luauString
hi def link luauStringZF3             luauString
hi def link luauZEscape               luauEscape
hi def link luauEOLEscape             luauEscape
hi def link luauAnonymousFunction     luauStatement
hi def link luauK_Function            luauStatement
hi def link luauK_Local               luauStatement
hi def link luauE_Callback            luauStatement
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

    hi def link rbxLibrary            rbxBuiltin
    hi def link rbxDotTask            rbxLibrary
  endif
endif

syn sync match luauSync grouphere NONE "\(\<function\s\+[a-zA-Z_][a-zA-Z0-9_]*(\)\@<=)$"
syn sync minlines=200

let b:current_syntax='luau'

let &cpo = s:cpo_save
unlet s:cpo_save
