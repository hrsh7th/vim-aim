# vim-aim
This plugin provides motion that similar to /.

# Status
- API's aren't stable
- Not documented
- Under consideration

# Usage
```viml
nnoremap <silent> , <Plug>(aim-start)
onoremap <silent> , <Plug>(aim-start)

cmap <silent> <C-h> <C-r>=aim#move("h")<CR>
cmap <silent> <C-j> <C-r>=aim#move("j")<CR>
cmap <silent> <C-k> <C-r>=aim#move("k")<CR>
cmap <silent> <C-l> <C-r>=aim#move("l")<CR>
```

