" luau-vim/autoload/luau_vim.vim
" Author:       polychromatist <polychromatist proton me>
" Last Change:  2022 Oct 6 (luau-vim v0.4pre1)

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

" a developer managed variable that is changed according to changes in the
" generated syntax rules file
let s:gen_syntax_version = 100

function! luau_vim#robloxAPIValid(path, sep) abort
  if !filereadable(a:path)
    return v:false
  endif

  let l:api_filepath = luau_vim#getAPIFilename(a:sep)

  if !filereadable(l:api_filepath)
    return v:false
  endif

  let l:filedata = readfile(a:path, '', 1)
  let l:fverdata = matchlist(l:filedata[0], '^" ver: \(\d\+\)$')

  if empty(l:fverdata)
    return v:false
  endif
  
  if str2nr(l:fverdata[1]) !=# s:gen_syntax_version
    return v:false
  endif

  " call luau_vim#jobs#startAPIJob(a:sep)

  return v:true
endfunction

" windows/unix+curl wrapper to fetch roblox api content from s:api_dump_url
function! luau_vim#robloxAPIFetch(force) abort
  if has('win64') || has('win32')
    return s:winAPIFetch(a:force)
  elseif has('unix') && executable('curl')
    return s:curlAPIFetch(a:force)
  else
    echoerr 'please install curl or put "let g:luauIncludeRobloxAPIDump = 0" in vim config'
    throw 'no roblox api retrieval method'
  endif
endfunction

" parse & create vim syntax output
function! luau_vim#robloxAPIParse(api_data, api_file_target) abort
  if (filereadable(a:api_file_target))
    call delete(a:api_file_target)
  endif

  let l:api_item_max = len(a:api_data)
  let l:_i = 0

  let l:outfiledata = ['" ver: ' . s:gen_syntax_version ]
  
  " Classes

  while l:_i < l:api_item_max
    " Termination Condition: hitting the enum section
    let l:api_item = a:api_data[l:_i]
    let l:_i += 1
    if l:api_item[0] ==# 'E'
      break
    endif
    if l:api_item[0] ==# 'C'
      " there are a lot of properties, discretion is needed
      " when the time comes to consider them for syntax rules
      " Known Tags: Deprecated, NotBrowsable, NotCreatable, Service,
      "             NotReplicated
      " Tags of lesser importance are RobloxSecurity, PluginSecurity, etc

      let l:class_name = matchstr(l:api_item, '\%(^Class \)\@6<=\w\+\%(.*Deprecated\)\@!')

      " Skip Condition: the api item is a property
      if empty(l:class_name)
        continue
      endif

      let l:is_nb = l:api_item =~# 'NotBrowsable'
      let l:is_nc = l:api_item =~# 'NotCreatable'

      call add(l:outfiledata, 'syn keyword rbxAPITypeName ' . l:class_name)

      if l:is_nb
        continue
      endif

      if l:is_nc
        if l:api_item =~# 'Service'
          call add(l:outfiledata, 'syn keyword rbxAPIService ' . l:class_name)
        endif
        continue
      endif

      call add(l:outfiledata, 'syn keyword rbxAPICreatableInstance ' . l:class_name)
    endif
  endwhile
  
  " Enums

  let l:current_enum = ''
  let l:enum_unused = 0
  while l:_i < l:api_item_max
    " Branch: the item is an enum type
    let l:api_item = a:api_data[l:_i]
    if a:api_data[l:_i][0] ==# 'E'
      let l:current_enum = matchstr(l:api_item, '\%(^Enum \)\@5<=\w\+\%(.*Deprecated\)\@!')

      if !empty(l:current_enum)
        call add(l:outfiledata, 'syn keyword rbxAPIEnumItem ' . l:current_enum )
      endif

    " Branch: the item is an EnumItem contained in the last enum type
    else
      let l:item_name = matchstr(l:api_item, '\%(^[\t]EnumItem \w\+\.\)\@<=\w\+\%(.*Deprecated\|.*NotBrowsable\)\@!')

      if !empty(l:item_name)
        call add(l:outfiledata, 'syn match rbxAPIEnumMember /\%(' . l:current_enum . '\s*\.\s*\)\@<=\<' . l:item_name . '\>/')
      endif
    endif
    let l:_i += 1
  endwhile

  call writefile(l:outfiledata, a:api_file_target)
endfunction

function! luau_vim#rbxAPIClean(sep) abort
  let l:api_dirpath = luau_vim#getAPIDir(a:sep)

  call delete(l:api_dirpath, 'rf')

  let l:rbx_syngen_fpath = luau_vim#getRobloxSyntaxTargetPath(a:sep)

  call delete(l:rbx_syngen_fpath)
endfunction

function! luau_vim#getAPIDir(sep) abort
  return s:_project_root . a:sep . s:api_dump_dirname
endfunction

function! luau_vim#getAPIFilename(sep) abort
  return luau_vim#getAPIDir(a:sep) . a:sep . s:_current_api_prefix .  '.txt'
endfunction

function! luau_vim#getRobloxSyntaxTargetPath(sep) abort
  return s:_project_root . a:sep . 'syntax' . a:sep . s:api_dump_dirname . '.vim'
endfunction

function! s:prepareAPITargets(sep) abort
  let l:api_dirpath = luau_vim#getAPIDir(a:sep)
  let l:api_filepath = luau_vim#getAPIFilename(a:sep)
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
    call delete(a:targets.etag)
  endif
  if filereadable(a:targets.filename)
    call delete(a:targets.filename)
  endif

  let l:query = printf(a:query, shellescape(s:api_dump_url), fnameescape(a:targets.filename))
  call system(l:query)

  if !filereadable(a:targets.filename)
    echoerr 'no file containing response body was found after web request'
    throw 'failed api fetch'
  endif

  call writefile([a:etag], a:targets.etag, '')

  return readfile(a:targets.filename)
endfunction

function! luau_vim#getAPIDumpURL()
  return s:api_dump_url
endfunction

function! s:winAPIFetch(force) abort
  let l:targets = s:prepareAPITargets('\')

  let l:subquery = printf(luau_vim#internal#getSubquery('\'), shellescape(s:api_dump_url))
  let l:sq_res = system(l:subquery)

  let l:remote_etag = luau_vim#internal#getETagFromSubqueryResponse(l:sq_res, '\')

  if (!a:force && s:collideCache(l:targets.etag, l:remote_etag))
    return readfile(l:targets.filepath)
  endif

  let l:query = 'powershell.exe -Command "irm -Method GET -Uri %s -OutFile %s"'

  return s:processMainQuery(l:query, l:targets, l:remote_etag)
endfunction

function! s:curlAPIFetch(force) abort
  let l:targets = s:prepareAPITargets('/')

  let l:subquery = printf(luau_vim#internal#getSubquery('/'), shellescape(s:api_dump_url))
  let l:sq_res = system(l:subquery)

  let l:remote_etag = luau_vim#internal#getETagFromSubqueryResponse(l:sq_res, '/')

  if (!a:force && s:collideCache(l:targets.etag, l:remote_etag))
    return readfile(l:targets.filename)
  endif

  let l:query = 'curl -sSL %s -o %s'
  
  return s:processMainQuery(l:query, l:targets, l:remote_etag)
endfunction

function! luau_vim#deselectCurrentAPIVersion(sep)
  call delete(luau_vim#getAPIFilename(a:sep))
  call delete(luau_vim#getAPIFilename(a:sep) . '.etag')
endfunction
