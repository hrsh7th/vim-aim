# vim-aim
This plugin provides motion that similar to /.

# Status
- API's aren't stable
- Not documented
- Under consideration

# Usage
```viml
nmap e <Plug>(aim-start-upward)
nmap E <Plug>(aim-start-downward)
xmap e <Plug>(aim-start-upward)
xmap E <Plug>(aim-start-downward)
omap e <Plug>(aim-start-upward)
omap E <Plug>(aim-start-downward)

cmap <silent> <C-h> <C-r>=aim#move('h')<CR>
cmap <silent> <C-j> <C-r>=aim#move('j')<CR>
cmap <silent> <C-k> <C-r>=aim#move('k')<CR>
cmap <silent> <C-l> <C-r>=aim#move('l')<CR>
```

