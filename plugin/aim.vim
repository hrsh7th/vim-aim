if exists('g:loaded_aim')
  finish
endif
let g:loaded_aim = v:true

function! s:highlight() abort
  if !hlexists('AimLocation')
    highlight! default AimLocation
    \   gui=bold,underline
    \   guifg=Red
    \   guibg=NONE
    \   cterm=bold,underline
    \   ctermfg=Red
    \   ctermbg=NONE
  endif

  if !hlexists('AimCurrentLocation')
    highlight! default AimCurrentLocation
    \   gui=bold,underline
    \   guifg=Yellow
    \   guibg=NONE
    \   cterm=bold,underline
    \   ctermfg=Yellow
    \   ctermbg=NONE
  endif
endfunction
call s:highlight()

augroup aim
  autocmd!
  autocmd ColorScheme * call s:highlight()
augroup END

nnoremap <silent> <Plug>(aim-start-upward) :<C-u>call aim#start('downward')<CR>
nnoremap <silent> <Plug>(aim-start-downward) :<C-u>call aim#start('upward')<CR>
xnoremap <silent> <Plug>(aim-start-upward) :<C-u>call aim#start('downward')<CR>
xnoremap <silent> <Plug>(aim-start-downward) :<C-u>call aim#start('upward')<CR>
onoremap <silent> <Plug>(aim-start-upward) :<C-u>call aim#start('downward')<CR>
onoremap <silent> <Plug>(aim-start-downward) :<C-u>call aim#start('upward')<CR>

