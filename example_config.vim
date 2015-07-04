set nu
set textwidth=79
set colorcolumn=79
set clipboard=unnamed

if has('gui_running')
    set lines=120
    set columns=120
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Wakatime
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:wakatime_PythonBinary = '/usr/local/bin/python'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 25
map <F2> <leader>nn
map <F3> <leader>nf


""""""""""""""""""""""""""""""
" => Tagbar
""""""""""""""""""""""""""""""
autocmd BufReadPost *.cpp,*.c,*.h,*.py call tagbar#autoopen()
autocmd BufReadPost *.html,*.js,*.css,.vimrc* call tagbar#CloseWindow()
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_sort = 0
let g:tagbar_width = 29
let g:tagbar_autofocus = 0
let g:tagbar_show_linenumbers = 1


""""""""""""""""""""""""""""""
" => Syntastic
""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers=['python', 'flake8']
let g:syntastic_python_flake8_post_args='--ignore=W391,E712'
let g:syntastic_html_checkers=['']

""""""""""""""""""""""""""""""
" => ctrlsf.vim
""""""""""""""""""""""""""""""
let g:ctrlsf_position = 'bottom'
nmap <C-C> <Plug>CtrlSFPrompt
