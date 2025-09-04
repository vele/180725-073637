set exrc
set secure
autocmd BufRead,BufNewFile *.yaml,*.yml setlocal tabstop=2 shiftwidth=2 expandtab
autocmd BufRead,BufNewFile *.yaml,*.yml setlocal ai
autocmd BufRead,BufNewFile *.tpl setlocal filetype=gotexttmpl
autocmd BufRead,BufNewFile templates/*.yaml setlocal filetype=yaml.helm
set number
set relativenumber
autocmd BufRead,BufNewFile * match ErrorMsg '\s\+$'
set foldmethod=indent
set foldlevel=99

