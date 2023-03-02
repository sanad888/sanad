source ../init.vim

let g:wiki_root = g:testroot . '/wiki-basic'
let g:wiki_filetypes = ['wiki', 'md']
let g:wiki_link_extension = '.wiki'

runtime plugin/wiki.vim

silent edit test.md

" Should use .wiki extension when we navigate to the wiki
call assert_false(has_key(b:wiki, 'root'))

" Test for #234
try
  call append(0, 'test')
  let s:link = wiki#link#get_at_pos(1, 1)
  call s:link.toggle()
catch
  call assert_true(0, 'Toggle should work without buffer root')
endtry

call wiki#test#finished()
