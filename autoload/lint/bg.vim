let s:state = {
      \ 'enabled': v:false,
      \ }

function! s:createData(service_name) abort
  let l:data = {}

  try
    call function('luau_vim#lint#' . a:service_name . '#init')(l:data)
  catch /^Vim\%((\a\+)\)\=:E700:/
    throw 'luau_vim: the linter or service ' . a:service_name . ' is not recognized by luau_vim'
  endtry

  return l:data
endfunction

function! luau_vim#lint#start()

endfunction
