let s:sep = ''
let s:last_check = 0
let s:started = 0
let s:pollintv = 10

function! s:completeAPIJobCollision(data) abort
  echom a:data

  let l:remote_etag = luau_vim#internal#getETagFromSubqueryResponse(a:data, s:sep)
  let l:etag_filepath = luau_vim#getAPIFilename(s:sep) . '.etag'

  if !filereadable(l:etag_filepath)
    return
  endif

  let l:etag = readfile(l:etag_filepath)[0]

  if (l:etag ==# l:remote_etag)
    echo 'luau_vim roblox api job: check returned OK'
    call s:markAPIJobCheck()
    return
  endif

  echo l:remote_etag
  echo 'luau_vim roblox api job: new api version available'

  call luau_vim#deselectCurrentAPIVersion(s:sep)
endfunction

function! s:getAPILastCheckFilename() abort
  return luau_vim#getAPIDir(s:sep) . s:sep . 'apilastcheck.unixtime.txt'
endfunction

function! s:getAPIJobLastCheck() abort
  let l:chkfile = s:getAPILastCheckFilename()

  if !filereadable(l:chkfile)
    return
  endif

  let s:last_check = str2nr(readfile(l:chkfile)[0])
endfunction

function! s:markAPIJobCheck() abort
  let l:chkfile = s:getAPILastCheckFilename()

  if filereadable(l:chkfile)
    call delete(l:chkfile)
  endif

  call writefile([localtime()], l:chkfile)
endfunction

function! s:tryCollectChannelOutData(ch, job_out)
  if ch_canread(a:ch)
    call add(a:job_out, ch_read(a:ch))
  elseif ch_status(a:ch) ==# 'fail'
    echom '-- channel dump --'
    echom ch_info(a:ch)
    throw 'channel reported failure fetching api data'
  endif
endfunction

function! s:wakeUpColliderJob(timer_id)
  " let l:job_options = {  'exit_cb': {ch, other -> s:completeAPIJobCollision(ch, other) } }
  let l:job_out = []
  let l:job_options = {
        \ 'out_mode': 'nl',
        \ 'out_cb': {ch, other -> s:tryCollectChannelOutData(ch, l:job_out) },
        \ 'exit_cb': {ch, other -> s:completeAPIJobCollision(join(l:job_out, "\n")) }
        \ }
  if s:sep ==# '/'
    let l:curlpath = exepath('curl')
    call job_start([l:curlpath, '-I', luau_vim#getAPIDumpURL()], l:job_options)
  else
    let l:pwshpath = fnamemodify(exepath('powershell.exe'), ':h')
    let l:command = printf(l:pwshpath . luau_vim#internal#getSubquery('\'), shellescape(luau_vim#getAPIDumpURL()))
    call job_start(l:command, l:job_options)
  endif
endfunction

function! luau_vim#jobs#startAPIJob(sep) abort
  let s:sep = a:sep
  let s:started = 1

  call s:getAPIJobLastCheck()

  let l:sleep_delta = 1000 * (s:pollintv - min([s:pollintv, localtime() - s:last_check]))

  " let l:subquery = printf(luau_vim#internal#getSubquery(a:sep), shellescape(luau_vim#getAPIDumpURL()))
  " call job_start('sleep ' . l:sleep_delta, { 'exit_cb': {... -> s:wakeUpColliderJob(l:subquery)} })
  call timer_start(l:sleep_delta, function('s:wakeUpColliderJob'))
endfunction
