source ../init.vim
runtime plugin/wiki.vim

" Test that the autocommand WikiLinkFollowed is triggered when a wiki link is
" followed.

let g:it_works = 0
augroup MyWikiAutocmds
  autocmd!
  autocmd User WikiLinkFollowed let g:it_works = 1
augroup END

silent edit ../wiki-basic/index.wiki
silent execute "normal \<Plug>(wiki-link-next)"
silent execute "normal \<Plug>(wiki-link-follow)"
call assert_equal(g:it_works, 1)

call wiki#test#finished()
