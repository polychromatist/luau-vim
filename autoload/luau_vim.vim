" luau-vim/autoload/luau_vim.vim
" Author:       polychromatist <polychromatist proton me>
" Last Change:  2022 Sep 26 (luau-vim v0.3.1)

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
if (exists('g:luauMaxOldAPIFilesCount'))
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
  let l:rbx_syngen_fpath = luau_vim#getRobloxSyntaxTargetPath()

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

function! luau_vim#rbxAPIClean(sep) abort
  let l:api_dirpath = s:getAPIDir(a:sep)

  delete(l:api_dirpath, 'rf')

  let l:rbx_syngen_fpath = luau_vim#getRobloxSyntaxTargetPath(a:sep)

  delete(l:rbx_syngen_fpath)
endfunction

function! s:getAPIDir(sep) abort
  return $"{s:_project_root}{a:sep}{s:api_dump_dirname}"
endfunction

function! s:getAPIFilename(sep) abort
  return $"{s:getAPIDir(a:sep)}{a:sep}{s:_current_api_suffix}.txt"
endfunction

function! luau_vim#getRobloxSyntaxTargetPath(sep) abort
  return $"{s:_project_root}{a:sep}syntax{a:sep}{s:api_dump_dirname}.vim"
endfunction

function! s:prepareAPITargets(sep) abort
  let l:api_dirpath = s:getAPIDir(a:sep)
  let l:api_filepath = s:getAPIFilename(a:sep)
  let l:etag_filepath = l:api_filepath . '.etag'

  if !isdirectory(l:api_dirpath)
    call mkdir(l:api_dirpath)
  endif

  return {
        \ 'dir': l:api_dirpath,
        \ 'filename': l:api_filepath,
        \ 'etag': l:etag_filepath }
endfunction

function! s:collideCache(etagtarget, etagremotedata) abort
  if (filereadable(a:etagtarget))
    let l:etagdata = readfile(a:etagtarget)[0]
    if (a:etagremotedata ==# l:etagdata)
      return 1
    endif
  endif
  return 0
endfunction

function! s:processMainQuery(query, targets, etag) abort
  if filereadable(a:targets.etag)
    delete(a:targets.etag)
  endif
  if filereadable(a:targets.filepath)
    delete(a:targets.filepath)
  endif

  call printf(a:query, shellescape(s:api_dump_url), fnameescape(a:targets.filepath))
  call system(a:query)

  if !filereadable(a:targets.filepath)
    echoerr 'no file containing response body was found after web request'
    throw 'failed api fetch'
  endif

  call writefile([a:etag], a:targets.etag, '')

  return readfile(a:targets.filepath)
endfunction

function! s:winAPIFetch(force) abort
  let l:targets = s:prepareAPITargets('\')

  let l:subquery = 'powershell.exe -Command "(iwr -Method Head -Uri %s).Headers.ETag"'
  call printf(l:subquery, shellescape(s:api_dump_url))

  let l:sq_res = system(l:subquery)
  let l:sq_res_lines = split(l:sq_res, "\\(\r\n\|\n\\)")
  let l:remote_etag = l:sq_res_lines[0]

  if (!a:force && s:collideCache(l:targets.etag, l:remote_etag))
    return readfile(l:targets.filepath)
  endif

  let l:query = 'powershell.exe -Command "irm -Method GET -Uri %s -OutFile %s"'

  return s:processMainQuery(l:query, l:targets, l:remote_etag)
endfunction

function! s:curlAPIFetch(force) abort
  let l:targets = s:prepareAPITargets('/')

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

  if (!a:force && s:collideCache(l:targets.etag, l:remote_etag))
    return readfile(l:targets.filename)
  endif

  let l:query = 'curl -sSL %s -o %s'
  
  return s:processMainQuery(l:query, l:targets, l:remote_etag)
endfunction
