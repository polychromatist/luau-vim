" luau-vim/autoload/luau_vim.vim
" Author:       polychromatist <polychromatist proton me>
" Last Change:  2022 Sep 26 (luau-vim v0.3.1)

" this source file is a monolith that handles all tasks requiring logic and
" advertises them under the luau_vim scope. there is currently only one task:
" - implement g:luauRobloxIncludeAPIDump
"   * fetch, parse Roblox API
"   * generate vim syntax file for luau.vim integration

" roblox api source url
if exists('g:luauRobloxAPIDumpURL')
  let s:api_dump_url = g:luauRobloxAPIDumpURL
else
  let s:api_dump_url = 'https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.txt'
endif
" roblox api storage directory name
" stored in plugin folder
if exists('g:luauRobloxAPIDumpDirname')
  let s:api_dump_dirname = g:luauRobloxAPIDumpDirname
else
  let s:api_dump_dirname = 'robloxapi'
endif
if !exists('g:luauRobloxNonstandardTypesAreErrors')
  let g:luauRobloxNonstandardTypesAreErrors = 0
endif

" plugin folder
let s:_project_root = expand('<sfile>:p:h:h')
" file name for roblox api used to generate syntax file
let s:_current_api_prefix = 'current'
" file prefix for old roblox apis
let s:_dated_api_prefix = 'dated'

" XXX this is not implemented
" TODO cmd interface for selecting previously downloaded api files
if (g:luauMaxOldAPIFilesCount)
  let s:max_old_api = g:LuauMaxOldAPIFilesCount
else
  let s:max_old_api = 3
endif

" windows/unix+curl wrapper to fetch roblox api content from s:api_dump_url
function! luau_vim#robloxAPIFetch() abort
  if has('win64') || has('win32')
    return s:winAPIFetch()
  elseif has('unix') && executable('curl')
    return s:curlAPIFetch()
  else
    echoerr 'please install curl or put "let g:luauIncludeRobloxAPIDump = 0" in vim config'
    throw 'no roblox api retrieval method'
  endif
endfunction

" parse & create vim syntax output
function! luau_vim#robloxAPIParse(api_data) abort
  let l:rbx_syngen_fpath = luau_vim#get_rbx_syngen_fpath()

  if (filereadable(l:rbx_syngen_fpath))
    delete(l:rbx_syngen_fpath)
  endif

  let l:is_service = {}
  " "standard": type is a Class with Service tag, or is not nonstandard
  "             nor erroneus
  " "nonstandard":  type is a Class with Deprecated and/or NotBrowsable
  "                 tag(s), or type is an Enum with similar tags
  " "erroneous": type exists but should never be used
  " Option: g:luauRobloxNonstandardTypesAreErrors = 0 or 1
  let l:type_dict = {
        \ 'standard': [],
        \ 'nonstandard': [],
        \ 'erroneous': [] }
  let l:classes_list = []
  let l:enums_dict = {}

  let l:api_item_max = len(a:api_data)
  let l:_i = 0
  
  " Classes

  while l:_i < l:api_item_max
    " Termination Condition: hitting the enum section
    let l:api_item = a:api_data[l:_i]
    if l:api_item[0] ==# 'E'
      break
    endif
    if l:api_item[0] ==# 'C'
      " Skip Condition: the api item is a property
      " there are a lot of properties, discretion is needed
      " when the time comes to consider them for syntax rules
      " Known Tags: Deprecated, NotBrowsable, NotCreatable, Service,
      "             NotReplicated

      let l:class_data = matchlist(l:api_item, 'Class \(\w\+\)\(.*Deprecated\|.*NotBrowsable\)\@!')
      if empty(l:class_data)
        let l:_i += 1
        continue
      endif

      let l:class_name = l:class_data[1]
      let l:tags_offset = 9 + len(l:class_name)

      " Branch: if it is a Service (note Service always has NotCreatable)
      if (match(l:api_item, 'Service', l:tags_offset) != -1)
        l:is_service[l:class_name] = v:true
      " Branch: if the NotCreatable tag is missing
      elseif (match(l:api_item, 'NotCreatable', l:tags_offset) ==# -1)
        " this is a non-deprecated, browsable, creatable Class
        call add(l:type_dict.standard, l:class_name)
      endif
    endif
    let l:_i += 1
  endwhile
  
  " Enums

  let l:current_enum = ''
  let l:enum_unused = 0
  while l:_i < l:api_item_max
    " Branch: the item is an enum type
    if a:api_data[l:_i][0] ==# 'E'
      let l:enum_data = matchlist(a:api_data[l:_i], 'Enum \(\w\+\)\(.*Deprecated\)\@!')
      l:current_enum = a:api_data[l:_i][5:]

      let l:enums_dict[l:current_enum] = []
    " Branch: the item is an enum property contained in the last enum type
    else

    endif

  endwhile

endfunction

function! luau_vim#rbxAPIClean() abort
  let l:api_dirpath = s:getAPIDir()

  delete(l:api_dirpath, 'rf')

  let l:rbx_syngen_fpath = luau_vim#getRobloxSyntaxTargetPath()

  delete(l:rbx_syngen_fpath)
endfunction

function! s:getAPIDir() abort
  return $"{s:_project_root}/{s:api_dump_dirname}"
endfunction

function! s:getAPIFilename() abort
  return $"{s:_get_api_dirpath()}/{s:_current_api_suffix}.json"
endfunction

function! luau_vim#getRobloxSyntaxTargetPath() abort
  return $"{s:_project_root}/syntax/{s:api_dump_dirname}.vim"
endfunction

function! s:checkAPIReadiness() abort
  let api_dirpath = s:getAPIDir()

  if !isdirectory(api_dirpath)
    return 0
  endif

  let api_filepath = s:getAPIFilename()

  if !filereadable(l:api_filepath)
    return 0
  endif

  return 1
endfunction

function! s:perpareAPITargets() abort
  let l:api_dirpath = s:getAPIDir()
  let l:api_filepath = s:getAPIFilename()
  let l:etag_filepath = l:api_filepath . '.etag'

  if !isdirectory(l:api_dirpath)
    call mkdir(l:api_dirpath)
  endif

  return {
        \ 'dir': l:api_dirpath,
        \ 'filename': l:api_filepath,
        \ 'etagpath': l:etag_filepath }
endfunction

function! s:winAPIFetch() abort
  let l:api_dirpath = s:getAPIDir()
  let l:api_filepath = s:getAPIFilename()
  let l:etag_filepath = l:api_filepath . '.etag'

  let l:query = 'powershell.exe -command "irm -Method HEAD -Uri %s"'


endfunction

function! s:curlAPIFetch(force) abort
  let l:api_dirpath = s:getAPIDir()
  let l:api_filepath = s:getAPIFilename()
  let l:etag_filepath = l:api_filepath . '.etag'

  if !isdirectory(l:api_dirpath)
    call mkdir(l:api_dirpath)
  endif

  let l:subquery = 'curl -I %s'
  call printf(l:subquery, shellescape(s:api_dump_url))

  let l:sq_res = system(l:subquery)

  let l:sq_res_lines = split(l:sq_res, "\\(\r\n\\|\n\\)")

  let l:sq_etag_midx = match(l:sq_res_lines, 'etag')

  if l:sq_etag_midx ==# -1
    echoerr 'no etag in subquery response headers for api versioning'
    throw 'bad api response'
  endif

  let l:remote_etag = matchstr(l:sq_res_lines[l:sq_etag_midx], "etag: \"\\zs[[:xdigit:]]\\+\\ze\"")

  if (!a:force && filereadable(l:etag_filepath))
    let l:stored_etag = readfile(l:etag_filepath)[0]
    if (l:remote_etag ==# l:stored_etag)
      return readfile(l:api_filepath)
    endif
  endif

  let l:query = 'curl -fsSL --http2 %s --compressed -o %s'

  if filereadable(l:etag_filepath)
    delete(l:etag_filepath)
  endif
  if filereadable(l:api_filepath)
    delete(l:api_filepath)
  endif

  call printf(l:query, shellescape(s:api_dump_url), l:api_filepath)
  call system(l:query)

  if !filereadable(l:api_filepath)
    echoerr 'no file containing response body was found after api request'
    throw 'no curl output file'
  endif

  call writefile([l:remote_etag], l:api_filepath, '')

  return readfile(l:api_filepath)
endfunction
