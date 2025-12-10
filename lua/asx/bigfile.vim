" disable syntax highlighting in big files
function DisableSyntaxTreesitter()
    echo("Big file, disabling some things")

    set foldmethod=manual
    syntax off
    filetype off
    set noundofile
    set noswapfile
    set noloadplugins
endfunction

augroup BigFileDisable
    autocmd!
    autocmd BufReadPre,FileReadPre * if getfsize(expand("%")) > 512 * 1024 | exec DisableSyntaxTreesitter() | endif

augroup END

