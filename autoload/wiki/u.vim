" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! wiki#u#cnum_to_byte(cnum) abort " {{{1
  if a:cnum <= 0 | return a:cnum | endif
  let l:bytes = len(strcharpart(getline('.')[a:cnum-1:], 0, 1))
  return a:cnum + l:bytes - 1
endfunction

" }}}1
function! wiki#u#command(cmd) abort " {{{1
  return split(execute(a:cmd, 'silent!'), "\n")
endfunction

" }}}1
function! wiki#u#escape(string) abort "{{{1
  return escape(a:string, '~.*[]\^$')
endfunction

"}}}1
function! wiki#u#eval_filename(input) abort " {{{1
  " Input:    Something that could indicate a target filename
  " Output:   The filename
  " Fallback: If we can't evaluate the input, then we return the current
  "           buffers filename.
  let l:current = expand('%:p')
  if empty(a:input) | return l:current | endif

  " Either it is an actual filename/path, or it is a string formatted link
  if type(a:input) == v:t_string
    return filereadable(a:input)
          \ ? a:input
          \ : get(wiki#url#parse(a:input), 'path', l:current)
  endif

  " A wiki and markdown link object should have the path attribute
  if type(a:input) == v:t_dict
    return get(a:input, 'path', l:current)
  endif

  return l:current
endfunction

" }}}1
function! wiki#u#extend_recursive(dict1, dict2, ...) abort " {{{1
  let l:option = a:0 > 0 ? a:1 : 'force'
  if index(['force', 'keep', 'error'], l:option) < 0
    throw 'E475: Invalid argument: ' . l:option
  endif

  for [l:key, l:Value] in items(a:dict2)
    if !has_key(a:dict1, l:key)
      let a:dict1[l:key] = l:Value
    elseif type(l:Value) == type({})
      call wiki#u#extend_recursive(a:dict1[l:key], l:Value, l:option)
    elseif l:option ==# 'error'
      throw 'E737: Key already exists: ' . l:key
    elseif l:option ==# 'force'
      let a:dict1[l:key] = l:Value
    endif
    unlet l:Value
  endfor

  return a:dict1
endfunction

" }}}1
function! wiki#u#get_os() abort " {{{1
  if wiki#u#is_win()
    return 'win'
  elseif has('unix')
    if has('mac') || has('ios') || wiki#jobs#cached('uname')[0] =~# 'Darwin'
      return 'mac'
    else
      return 'linux'
    endif
  endif
endfunction

" }}}1
function! wiki#u#is_win() abort " {{{1
  return has('win32') || has('win32unix')
endfunction

" }}}1
function! wiki#u#in_syntax(name, ...) abort " {{{1
  let l:pos = [0, 0]
  let l:pos[0] = a:0 > 0 ? a:1 : line('.')
  let l:pos[1] = a:0 > 1 ? a:2 : col('.')
  if mode() ==# 'i'
    let l:pos[1] -= 1
  endif
  if l:pos[1] <= 0
    let l:pos[0] -= 1
    let l:pos[1] = 10000
  endif
  call map(l:pos, 'max([v:val, 1])')

  " Check syntax at position
  return match(map(synstack(l:pos[0], l:pos[1]),
        \          "synIDattr(v:val, 'name')"),
        \      '^' . a:name) >= 0
endfunction

" }}}1
function! wiki#u#is_code(...) abort " {{{1
  let l:lnum = a:0 > 0 ? a:1 : line('.')
  let l:col = a:0 > 1 ? a:2 : col('.')

  return match(map(synstack(l:lnum, l:col),
          \        "synIDattr(v:val, 'name')"),
          \    '^\%(wikiPre\|mkd\%(Code\|Snippet\)\|markdownCode\)') > -1
endfunction

" }}}1
function! wiki#u#trim(str) abort " {{{1
  if exists('*trim') | return trim(a:str) | endif

  let l:str = substitute(a:str, '^\s*', '', '')
  let l:str = substitute(l:str, '\s*$', '', '')

  return l:str
endfunction

" }}}1
function! wiki#u#uniq_unsorted(list) abort " {{{1
  if len(a:list) <= 1 | return a:list | endif

  let l:visited = {}
  let l:result = []
  for l:x in a:list
    let l:key = string(l:x)
    if !has_key(l:visited, l:key)
      let l:visited[l:key] = 1
      call add(l:result, l:x)
    endif
  endfor

  return l:result
endfunction

" }}}1
function! wiki#u#group_by(list_of_dicts, key) abort " {{{1
  if type(a:list_of_dicts) !=# v:t_list | return {} | endif
  let l:relevant_dicts = filter(
        \ a:list_of_dicts,
        \ { _, x -> type(x) ==# v:t_dict && has_key(x, a:key) })

  let l:result = {}
  for l:dict in l:relevant_dicts
    let l:value = remove(l:dict, a:key)
    if has_key(l:result, l:value)
      call add(l:result[l:value], l:dict)
    else
      let l:result[l:value] = [l:dict]
    endif
  endfor

  return l:result
endfunction

" }}}1
