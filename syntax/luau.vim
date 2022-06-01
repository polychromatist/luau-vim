" Vim syntax file
" Language:     Luau 0.529
" Maintainer:   polychromatist <polychromatist 'at' proton me>
" First Author: polychromatist
" Last Change:  2022 May 31
" Options:      luau_roblox = 0 (Luau standalone) or 1 (with Roblox envvars)
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists("luau_roblox")
  let luau_roblox = 1
endif

syn case match

syn sync minlines=100


syn region luaParen      transparent                     start='(' end=')' contains=ALLBUT,luaParenError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=ALLBUT,luaBraceError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement
syn match  luaParenError ")"
syn match  luaBraceError "}"

syn match luauOperator "\v\+"
syn match luauOperator "\v-"
syn match luauOperator "\v\*"
syn match luauOperator "\v/"
syn match luauOperator "\v\%"
syn match luauOperator "\v^"
syn match luauOperator "\v#"
syn match luauOperator "\v\=\="
syn match luauOperator "\v\~\="
syn match luauOperator "\v\<\="
syn match luauOperator "\v\>\="
syn match luauOperator "\v\>"
syn match luauOperator "\v\<"
syn match luauOperator "\v\="
syn match luauOperator "\v\)"
syn match luauOperator "\v\("
syn match luauOperator "\v\]"
syn match luauOperator "\v\["
syn match luauOperator "\v;"
syn match luauOperator "\v:"
syn match luauOperator "\v,"
syn match luauOperator "\v\."
syn match luauOperator "\v\.\."
syn match luauOperator "\v\.\.\."

" Inherited from syntax/lua.vim

" Comments
syn keyword luaTodo            contained TODO FIXME XXX
syn match   luaComment         "--.*$" contains=luaTodo,@Spell
if lua_version == 5 && lua_subversion == 0
  syn region luaComment        matchgroup=luaComment start="--\[\[" end="\]\]" contains=luaTodo,luaInnerComment,@Spell
  syn region luaInnerComment   contained transparent start="\[\[" end="\]\]"
elseif lua_version > 5 || (lua_version == 5 && lua_subversion >= 1)
  " Comments in Lua 5.1: --[[ ... ]], [=[ ... ]=], [===[ ... ]===], etc.
  syn region luaComment        matchgroup=luaComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell
endif
syn match luaComment "\%^#!.*"

syn match  luaError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"


" function ... end
syn region luaFunctionBlock transparent matchgroup=luaFunction start="\<function\>" end="\<end\>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" if ... then
syn region luaIfThen transparent matchgroup=luaCond start="\<if\>" end="\<then\>"me=e-4           contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaIn nextgroup=luaThenEnd skipwhite skipempty

" then ... end
syn region luaThenEnd contained transparent matchgroup=luaCond start="\<then\>" end="\<end\>" contains=ALLBUT,luaTodo,luaSpecial,luaThenEnd,luaIn

" elseif ... then
syn region luaElseifThen contained transparent matchgroup=luaCond start="\<elseif\>" end="\<then\>" contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" else
syn keyword luaElse contained else

" do ... end
syn region luaBlock transparent matchgroup=luaStatement start="\<do\>" end="\<end\>"          contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" repeat ... until
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<repeat\>" end="\<until\>"   contains=ALLBUT,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" while ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<while\>" end="\<do\>"me=e-2 contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaIn nextgroup=luaBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<for\>" end="\<do\>"me=e-2   contains=ALLBUT,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd nextgroup=luaBlock skipwhite skipempty

syn keyword luaIn contained in

" syn region luaDotInvocation keepend start="\." end="(" contains=luaWord
syn match luaDotInvocation "\v[.:]\zs[a-zA-Z_]\w*\ze\(" contains=luaInvocationWord
syn match luaInvocationWord "\v[a-zA-Z_]\w*\ze\(" contained
" syn match luaInvocationWord /[a-zA-Z_]\w*/ contained containedin=luaDotInvocation

" other keywords
syn keyword luaStatement return local break
syn keyword luaOperator and or not
syn keyword luaConstant nil
syn keyword luaConstant true false

" Strings
syn match  luaSpecial contained #\\[\\abfnrtvz'"]\|\\x[[:xdigit:]]\{2}\|\\[[:digit:]]\{,3}#
syn region luaString2 matchgroup=luaString start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
syn region luaString  start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,luauSpecial,@Spell
syn region luaString  start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,luauSpecial,@Spell

" luaNumber would be here, see luauNumber

syn keyword luaFunc assert collectgarbage error next newproxy
syn keyword luaFunc print rawget rawset tonumber tostring type _VERSION

syn keyword luaFunc getmetatable setmetatable
syn keyword luaFunc ipairs pairs
syn keyword luaFunc pcall xpcall
syn keyword luaFunc _G rawequal require
syn keyword luaFunc getfenv setfenv
syn keyword luaFunc gcinfo
syn keyword luaFunc loadstring unpack
syn keyword luaFunc select
" since these bit32 are practically Lua functions i won't denominate
" them under luauFunc, except for countlz/countrz
syn match   luaFunc /\<bit32\.arshift\>/
syn match   luaFunc /\<bit32\.band\>/
syn match   luaFunc /\<bit32\.bnot\>/
syn match   luaFunc /\<bit32\.bor\>/
syn match   luaFunc /\<bit32\.btest\>/
syn match   luaFunc /\<bit32\.bxor\>/
syn match   luaFunc /\<bit32\.extract\>/
syn match   luaFunc /\<bit32\.lrotate\>/
syn match   luaFunc /\<bit32\.lshift\>/
syn match   luaFunc /\<bit32\.replace\>/
syn match   luaFunc /\<bit32\.rrotate\>/
syn match   luaFunc /\<bit32\.rshift\>/
syn match luaFunc /\<coroutine\.running\>/
syn match   luaFunc /\<coroutine\.create\>/
syn match   luaFunc /\<coroutine\.resume\>/
syn match   luaFunc /\<coroutine\.status\>/
syn match   luaFunc /\<coroutine\.wrap\>/
syn match   luaFunc /\<coroutine\.yield\>/
syn match   luaFunc /\<string\.byte\>/
syn match   luaFunc /\<string\.char\>/
syn match   luaFunc /\<string\.find\>/
syn match   luaFunc /\<string\.format\>/
syn match   luaFunc /\<string\.gsub\>/
syn match   luaFunc /\<string\.len\>/
syn match   luaFunc /\<string\.lower\>/
syn match   luaFunc /\<string\.rep\>/
syn match   luaFunc /\<string\.sub\>/
syn match   luaFunc /\<string\.upper\>/
syn match luaFunc /\<string\.gmatch\>/
syn match luaFunc /\<string\.match\>/
syn match luaFunc /\<string\.reverse\>/
syn match luaFunc /\<string\.pack\>/
syn match luaFunc /\<string\.packsize\>/
syn match luaFunc /\<string\.unpack\>/
syn match luaFunc /\<table\.getn\>/
syn match luaFunc /\<table\.foreach\>/
syn match luaFunc /\<table\.foreachi\>/
syn match luaFunc /\<table\.maxn\>/
syn match luaFunc /\<table\.pack\>/
syn match luaFunc /\<table\.unpack\>/
syn match   luaFunc /\<table\.concat\>/
syn match   luaFunc /\<table\.sort\>/
syn match   luaFunc /\<table\.insert\>/
syn match   luaFunc /\<table\.remove\>/
syn match   luaFunc /\<math\.abs\>/
syn match   luaFunc /\<math\.acos\>/
syn match   luaFunc /\<math\.asin\>/
syn match   luaFunc /\<math\.atan\>/
syn match   luaFunc /\<math\.atan2\>/
syn match   luaFunc /\<math\.ceil\>/
syn match   luaFunc /\<math\.sin\>/
syn match   luaFunc /\<math\.cos\>/
syn match   luaFunc /\<math\.tan\>/
syn match   luaFunc /\<math\.deg\>/
syn match   luaFunc /\<math\.exp\>/
syn match   luaFunc /\<math\.floor\>/
syn match   luaFunc /\<math\.log\>/
syn match   luaFunc /\<math\.max\>/
syn match   luaFunc /\<math\.min\>/
syn match luaFunc /\<math\.log10\>/
syn match luaFunc /\<math\.huge\>/
syn match luaFunc /\<math\.fmod\>/
syn match luaFunc /\<math\.modf\>/
syn match luaFunc /\<math\.cosh\>/
syn match luaFunc /\<math\.sinh\>/
syn match luaFunc /\<math\.tanh\>/
syn match   luaFunc /\<math\.pow\>/
syn match   luaFunc /\<math\.rad\>/
syn match   luaFunc /\<math\.sqrt\>/
syn match   luaFunc /\<math\.frexp\>/
syn match   luaFunc /\<math\.ldexp\>/
syn match   luaFunc /\<math\.random\>/
syn match   luaFunc /\<math\.randomseed\>/
syn match   luaFunc /\<math\.pi\>/
syn match luaFunc /\<os\.clock\>/
syn match luaFunc /\<os\.difftime\>/
syn match luaFunc /\<os\.date\>/
syn match luaFunc /\<os\.time\>/
syn match luaFunc /\<debug\.traceback\>/

" Luau

" Luau statements / operators
syn keyword luauStatement continue export type
" for some reason the vim lua syntax does not recognize rudimentary operator
" tokens, so i guess they go here
" and we can't forget the luau incremental operators
syn keyword luauOperator += -= /= *= %= ^= ..=

" Luau unicode escape sequence ( https://luau-lang.org/syntax#string-literals )
syn match luauSpecial contained #\\u{[[:xdigit:]]\{,3}}#

" https://luau-lang.org/syntax#number-literals

" Luau binary integer literals
syn match luauNumber "\<0[bB][01_]\+\>"
" integer number
syn match luauNumber "\<[[:digit:]_]\+\>"
" floating point number, with dot, optional exponent
syn match luauNumber  "\<[[:digit:]_]\+\.[[:digit:]_]*\%([eE][-+]\=[[:digit:]_]\+\)\=\>"
" floating point number, starting with a dot, optional exponent
syn match luauNumber  "\.[[:digit:]_]\+\%([eE][-+]\=[[:digit:]_]\+\)\=\>"
" floating point number, without dot, with exponent
syn match luauNumber  "\<[[:digit:]_]\+[eE][-+]\=[[:digit:]_]\+\>"
" hex numbers
syn match luauNumber "\<0[xX][[:xdigit:]_]\+\>"

" Luau special standard library methods
syn match luauFunc /\<bit32\.countlz\>/
syn match luauFunc /\<bit32\.countrz\>/
syn match luauFunc /\<table\.create\>/
syn match luauFunc /\<table\.clear\>/
syn match luauFunc /\<table\.freeze\>/
syn match luauFunc /\<table\.isfrozen\>/
syn match luauFunc /\<table\.clone\>/
syn match luauFunc /\<table\.move\>/
syn match luauFunc /\<debug\.dumpheap\>/
syn match luauFunc /\<debug\.info\>/
syn match luauFunc /\<debug\.loadmodule\>/
syn match luauFunc /\<debug\.profilebegin\>/
syn match luauFunc /\<debug\.profileend\>/
syn match luauFunc /\<debug\.setmemorycategory\>/
syn match luauFunc /\<debug\.resetmemorycategory\>/

" Roblox environment variables
if luau_roblox == 1
  syn keyword robloxConst self
  syn keyword robloxFunc warn typeof settings UserSettings
  syn keyword robloxFunc game workspace script plugin
  " syn keyword robloxFunc Instance UDim2 Vector3 CFrame TweenInfo Enum UDim Vector2 Vector3int16 Vector2int16 FloatCurveKey Faces BrickColor Axes DateTime Color3 ColorSequence ColorSequenceKeypoint NumberRange NumberSequence NumberSequenceKeypoint Random PhysicalProperties Ray RaycastResult Rect Region3 Region3int16 OverlapParams PathWaypoint DockWidgetPluginGuiInfo RaycastParams
  syn match robloxFunc /\<RaycastParams\.new\>/
  syn match robloxFunc /\<Ray\.new\>/
  syn match robloxFunc /\<DockWidgetPluginGuiInfo\.new\>/
  syn match robloxFunc /\<DateTime\.fromIsoDate\>/
  syn match robloxFunc /\<DateTime\.fromLocalTime\>/
  syn match robloxFunc /\<DateTime\.fromUniversalTime\>/
  syn match robloxFunc /\<DateTime\.fromUnixTimestamp\>/
  syn match robloxFunc /\<DateTime\.fromUnixTimestampMillis\>/
  syn match robloxFunc /\<DateTime\.now\>/
  syn match robloxFunc /\<PhysicalProperties\.new\>/
  syn match robloxFunc /\<ColorSequenceKeypoint\.new\>/
  syn match robloxFunc /\<ColorSequence\.new\>/
  syn match robloxFunc /\<OverlapParams\.new\>/
  syn match robloxFunc /\<BrickColor\.Red\>/
  syn match robloxFunc /\<BrickColor\.White\>/
  syn match robloxFunc /\<BrickColor\.DarkGray\>/
  syn match robloxFunc /\<BrickColor\.Gray\>/
  syn match robloxFunc /\<BrickColor\.Green\>/
  syn match robloxFunc /\<BrickColor\.Blue\>/
  syn match robloxFunc /\<BrickColor\.Black\>/
  syn match robloxFunc /\<BrickColor\.Yellow\>/
  syn match robloxFunc /\<BrickColor\.random\>/
  syn match robloxFunc /\<BrickColor\.New\>/
  syn match robloxFunc /\<BrickColor\.palette\>/
  syn match robloxFunc /\<BrickColor\.Random\>/
  syn match robloxFunc /\<BrickColor\.new\>/
  syn match robloxFunc /\<Color3\.toHSV\>/
  syn match robloxFunc /\<Color3\.fromHSV\>/
  syn match robloxFunc /\<Color3\.fromHex\>/
  syn match robloxFunc /\<Color3\.fromRGB\>/
  syn match robloxFunc /\<Color3\.new\>/
  syn match robloxFunc /\<TweenInfo\.new\>/
  syn match robloxFunc /\<Rect\.new\>/
  syn match robloxFunc /\<NumberRange\.new\>/
  syn match robloxFunc /\<NumberSequenceKeypoint\.new\>/
  syn match robloxFunc /\<NumberSequence\.new\>/
  syn match robloxFunc /\<Random\.new\>/
  syn match robloxFunc /\<PathWaypoint\.new\>/
  syn match robloxFunc /\<Region3int16\.new\>/
  syn match robloxFunc /\<Region3\.new\>/
  syn match robloxFunc /\<Axes\.new\>/
  syn match robloxFunc /\<Vector2int16\>new\>/
  syn match robloxFunc /\<Vector3int16\.new\>/
  syn match robloxFunc /\<CFrame\.Angles\>/
  syn match robloxFunc /\<CFrame\.fromEulerAngles\>/
  syn match robloxFunc /\<CFrame\.fromEulerAnglesXYZ\>/
  syn match robloxFunc /\<CFrame\.fromEulerAnglesYXZ\>/
  syn match robloxFunc /\<CFrame\.fromMatrix\>/
  syn match robloxFunc /\<CFrame\.fromOrientation\>/
  syn match robloxFunc /\<CFrame\.identity\>/
  syn match robloxFunc /\<CFrame\.lookAt\>/
  syn match robloxFunc /\<CFrame\.new\>/
  syn match robloxFunc /\<Instance\.new\>/
  syn match robloxFunc /\<Vector3\.FromAxis\>/
  syn match robloxFunc /\<Vector3\.FromNormalId\>/
  syn match robloxFunc /\<Vector3\.fromAxis\>/
  syn match robloxFunc /\<Vector3\.fromNormalId\>/
  syn match robloxFunc /\<Vector3\.new\>/
  syn match robloxFunc /\<Vector3\.one\>/
  syn match robloxFunc /\<Vector3\.xAxis\>/
  syn match robloxFunc /\<Vector3\.yAxis\>/
  syn match robloxFunc /\<Vector3\.zAxis\>/
  syn match robloxFunc /\<Vector3\.zero\>/
  syn match robloxFunc /\<UDim2\.fromOffset\>/
  syn match robloxFunc /\<UDim2\.fromScale\>/
  syn match robloxFunc /\<UDim2\.new\>/
  syn match robloxFunc /\<Vector2\.new\>/
  syn match robloxFunc /\<Vector2\.one\>/
  syn match robloxFunc /\<Vector2\.xAxis\>/
  syn match robloxFunc /\<Vector2\.yAxis\>/
  syn match robloxFunc /\<Vector2\.zero\>/
  syn match robloxFunc /\<UDim\.new\>/
endif

hi def link luaStatement		Statement
hi def link luaRepeat		Repeat
hi def link luaFor			Repeat
hi def link luaString		String
hi def link luaString2		String
hi def link luauString          String
hi def link luaNumber		Number
hi def link luauNumber          Number
hi def link luaOperator		Operator
hi def link luaIn			Operator
hi def link luaConstant		Constant
hi def link luaCond		Conditional
hi def link luaElse		Conditional
hi def link luaFunction		Function
hi def link luaComment		Comment
hi def link luaTodo		Todo
hi def link luaTable		Structure
hi def link luaError		Error
hi def link luaParenError		Error
hi def link luaBraceError		Error
hi def link luaSpecial		SpecialChar
hi def link luauSpecial         SpecialChar
hi def link luaFunc		Identifier
hi def link luauFunc            Identifier
hi def link luaLabel		Label
hi def link robloxFunc          Identifier
hi def link luauOperator        Operator
hi def link luauStatement       Statement
hi def link luaInvocationWord   Identifier
" hi def link luaDotInvocation    Identifier

let b:current_syntax = "luau"

let &cpo = s:cpo_save
unlet s:cpo_save
