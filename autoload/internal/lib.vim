function! luau_vim#internal#getSubquery(sep)
  if a:sep ==# '/'
    return 'curl -I %s'
  else
    return 'powershell.exe -Command "(iwr -Method Head -Uri %s).Headers.ETag"'
  endif
endfunction

function! luau_vim#internal#getETagFromSubqueryResponse(res, sep)
  if a:sep ==# '\'
    let l:sq_res_lines = split(a:res, "\\(\r\n\|\n\\)")
    return l:sq_res_lines[0]
  else
    let l:sq_res_lines = split(a:res, "\\(\r\n\\|\n\\)")
    let l:sq_etag_midx = match(l:sq_res_lines, 'etag')
    if l:sq_etag_midx ==# -1
      echoerr 'no etag in subquery response headers for api versioning'
      throw 'bad api response'
    endif
    return matchstr(l:sq_res_lines[l:sq_etag_midx], "etag: \"\\zs[[:xdigit:]]\\+\\ze\"")
  endif
endfunction
