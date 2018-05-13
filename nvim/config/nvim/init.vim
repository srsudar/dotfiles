set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vim/vimrc

" <Esc> to exit terminal mode.
" Use the <C-v><Esc> binding to send a literal escape to the underlying program.
" The mnemonic here, taken from Modern Vim, is a verbatim escape, just like
" verbatim tab.
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
  tnoremap <C-v><Esc> <Esc>
endif

" Highlight the terminal cursor in terminal mode.
if has('nvim')
  highlight! link TermCursor Cursor
  highlight! TermCursorNC guibg=orange guifg=white ctermbg=166 ctermfg=15
endif
