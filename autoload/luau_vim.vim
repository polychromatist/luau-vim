if exists('g:os')
  let s:os = g:os
else
  if has('win64') || has('win32')
    let s:os = 'Windows'
  elseif has('unix') && executable('curl')
    let s:os = 'Unixlike'
  else
    echoerr 'please install curl or put "let g:luauIncludeRobloxAPIDump = 0" in vim config'
    throw 'could not detect any api retrieval method'
  endif
endif

if (g:luauCustomRobloxAPIDumpURL)
  let s:api_dump_url = g:luauRobloxAPIDumpURL
else
  let s:api_dump_url = 'https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.txt'
endif
if (g:luauCustomRobloxAPIDumpDirname)
  let s:api_dump_dirname = g:luauRobloxAPIDumpDirname
else
  let s:api_dump_dirname = 'robloxapi'
endif

let s:_project_root = expand('<sfile>:p:h:h')
let s:_current_api_suffix = 'current'
let s:_dated_api_suffix = 'dated'

" TODO command interface for selecting and preserving previously downloaded api files
if (g:luauMaxOldAPIFilesCount)
  let s:max_old_api = g:LuauMaxOldAPIFilesCount
else
  let s:max_old_api = 3
endif

function! luau_vim#rbx_api_fetch() abort
  if (s:os ==# 'Windows')
    return s:_win_api_fetch()
  else
    return s:_curl_api_fetch()
  endif
endfunction

function! luau_vim#rbx_api_parse() abort
  let l:rbx_syngen_fpath = luau_vim#get_rbx_syngen_fpath()

  if (filereadable(l:rbx_syngen_fpath))
    delete(l:rbx_syngen_fpath)
  endif

  let l:api_data = luau_vim#rbx_api_fetch()

  let l:classes_dict = {}
  let l:enums_dict = {}

  let l:api_item_max = len(l:api_data)
  let l:_i = 0
  " classes
  
  while l:_i < l:api_item_max do
    if l:api_data[l:_i][0] ==# 'E'
      break
    endif
    if l:api_data[l:_i][0] ==# 'C'
      let l:class_data = matchlist(l:api_data[l:_i], 'Class \(\w\+\) : \(\w\+\)\(.*Deprecated\|.*NotBrowsable\)\@!')
      if empty(l:class_data)
        let l:_i += 1
        continue
      endif

      if !has_key(l:classes_dict, l:class_data[2])
        let l:class_list = []
        l:classes_dict[l:class_data[2]] = l:class_list
      else
        let l:class_list = l:classes_dict[l:class_data[2]]
      endif
    endif
    let l:_i += 1
  endwhile
  " enums
  let l:current_enum = ''
  while l:_i < l:api_item_max do
    if l:api_data[l:_i][0] ==# 'E'
      l:current_enum = l:api_data[l:_i][5:]
      let l:enums_dict[l:current_enum] = []
    endif

  endwhile
  call filter(l:api_data, 'match(v:val, ''^\(Class\|Enum\) \w\+ : \w\+\(.*Deprecated\|.*NotBrowsable\)\@!'') != -1')

endfunction

function! luau_vim#rbx_api_clean() abort
  let l:api_dirpath = s:_get_api_dirpath()

  delete(l:api_dirpath, 'rf')

  let l:rbx_syngen_fpath = luau_vim#get_rbx_syngen_fpath()

  delete(l:rbx_syngen_fpath)
endfunction

function! s:_get_api_dirpath() abort
  return $"{s:_project_root}/{s:api_dump_dirname}"
endfunction

function! s:_get_api_filepath() abort
  return $"{s:_get_api_dirpath()}/{s:_current_api_suffix}.json"
endfunction

function! luau_vim#get_rbx_syngen_fpath() abort
  return $"{s:_project_root}/syntax/{s:api_dump_dirname}.vim"
endfunction

function! s:_check_api_readiness() abort
  let l:api_dirpath = s:_get_api_dirpath()

  if !isdirectory(l:api_dirpath)
    return 0
  endif

  let l:api_filepath = s:_get_api_filepath()

  if !filereadable(l:api_filepath)
    return 0
  endif

  return 1
endfunction

function! s:_win_api_fetch() abort
  let l:query = 'powershell -command "Invoke-WebRequest -Uri %s -Method GET"'


endfunction

function! s:_curl_api_fetch(force) abort
  let l:api_dirpath = s:_get_api_dirpath()
  let l:api_filepath = s:_get_api_filepath()
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
