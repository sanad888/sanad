source ../init.vim

function! UserFunc1(ctx, string) abort " {{{1
  return toupper(a:string)
endfunction

" }}}1
function! UserFunc2(ctx) abort " {{{1
  return 'TEST'
endfunction

" }}}1
function! TemplateB(context) abort " {{{1
  call append(0, [
        \ 'Hello from TemplateB function!',
        \ a:context.name,
        \ a:context.path_wiki,
        \])
endfunction

" }}}1
let g:wiki_root = g:testroot . '/wiki-basic'
let g:wiki_templates = [
      \ {
      \   'match_re': '^Template A',
      \   'source_filename': g:testroot . '/test-templates/template-a.md'
      \ },
      \ {
      \   'match_re': '^Template B',
      \   'source_func': function('TemplateB')
      \ },
      \ {
      \   'match_re': '^case titled template',
      \   'source_filename': g:testroot . '/test-templates/template-d.md'
      \ },
      \ {
      \   'match_func': {_ -> v:true},
      \   'source_func': {_ -> append(0, ['Fallback'])}
      \ },
      \]

runtime plugin/wiki.vim

silent call wiki#page#open('Template A')
call assert_equal([
      \ '# TEMPLATE A',
      \ 'Created: ' . strftime("%Y-%m-%d %H:%M"),
      \ '',
      \ 'TEST',
      \], getline(1, line('$') - 1))

bwipeout
silent call wiki#page#open('Template B')
call assert_equal([
      \ 'Hello from TemplateB function!',
      \ 'Template B',
      \ 'Template B.wiki',
      \], getline(1, line('$') - 1))

bwipeout
silent call wiki#page#open('Template C')
call assert_equal('Fallback', getline(1))

bwipeout
silent call wiki#page#open('case titled template')
call assert_equal(['# Case Titled Template'], getline(1, line('$') - 1))

call wiki#test#finished()
