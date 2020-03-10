
" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()

" Indent = 4 spaces.
filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Highlight code syntax.
syntax on

" Highlight "NOTE"
match Todo /NOTE/

" Highlight all search results.
set hlsearch

" Show trailing whitespace.
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

set number
highlight lineNr ctermfg=darkblue

let mapleader=";"

"" pymode things:
"----------------
" NOTE: pymode is currently disabled.
" let g:pymode_rope_completion = 1
" let g:pymode_rope_completion_bind = '<C-Space>'

" Only use pep8.
" let g:pymode_lint_checkers = []

" Disable folding.
" let g:pymode_folding = 0
" End of pymode things.

" Map "ctrl+j" etc. to "ctrl+w j" (moving between splits).
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set clipboard=unnamedplus

" Groovy syntax highlighting
au BufNewFile,BufRead *.groovy  setf groovy
au BufNewFile,BufRead *.nf setf groovy
