# vim-aim
This plugin provides motion that similar to /.

# Status
- API's aren't stable
- Not documented
- Under consideration

# Usage
```viml
nmap <C-n> <Plug>(aim-start-n)
nmap <C-p> <Plug>(aim-start-p)
cnoremap <C-n> <C-r>=aim#move('n')<CR>
cnoremap <C-p> <C-r>=aim#move('p')<CR>
```

