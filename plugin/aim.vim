if exists('g:loaded_aim')
  finish
endif
let g:loaded_aim = v:true

function! s:highlight() abort
  if !hlexists('AimLocation')
    highlight! default link AimLocation IncSearch
  endif

  if !hlexists('AimCurrentLocation')
    highlight! default link AimCurrentLocation Search
  endif
endfunction
call s:highlight()

augroup aim
  autocmd!
  autocmd ColorScheme * call s:highlight()
augroup END

nnoremap <silent> <Plug>(aim-start) :<C-u>call aim#start()<CR>
onoremap <silent> <Plug>(aim-start) :<C-u>call aim#start()<CR>

