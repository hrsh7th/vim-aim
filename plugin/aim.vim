if exists('g:loaded_aim')
  finish
endif
let g:loaded_aim = v:true

let g:aim_enabled = get(g:, 'aim_enabled', v:true)

augroup aim
  autocmd!
  autocmd ColorScheme * call s:highlight()
  autocmd CmdlineLeave * if s:is_search() | call s:reserve_reset() | endif
augroup END

function! s:highlight() abort
  highlight! Search
  \   gui=bold,underline
  \   guifg=Red
  \   guibg=NONE
  \   cterm=bold,underline
  \   ctermfg=Red
  \   ctermbg=NONE

  highlight! IncSearch
  \   gui=bold,underline
  \   guifg=Yellow
  \   guibg=NONE
  \   cterm=bold,underline
  \   ctermfg=Yellow
  \   ctermbg=NONE
endfunction
call s:highlight()

"
" public mapping
"
nnoremap <silent><expr> <Plug>(aim-n) <SID>move('n')
nnoremap <silent><expr> <Plug>(aim-N) <SID>move('N')

"
" private mapping
"
nnoremap <silent><Plug>(aim-internal-nohlsearch) :<C-u>nohlsearch<CR>
xnoremap <silent><Plug>(aim-internal-nohlsearch) :<C-u>nohlsearch<CR>gv
inoremap <silent><Plug>(aim-internal-nohlsearch) <C-o>:<C-u>nohlsearch<CR>

"
" move
"
function! s:move(dir) abort
  call s:reserve_reset()
  call feedkeys(a:dir, 'n')
  return ''
endfunction

"
" nohlsearch
"
function! s:nohlsearch() abort
  call feedkeys("\<Plug>(aim-internal-nohlsearch)", 't')
endfunction

"
" is_search
"
function! s:is_search() abort
  return index(['/', '?'], get(get(v:, 'event', {}), 'cmdtype', '')) >= 0
endfunction

"
" reserve_reset
"
function! s:reserve_reset() abort
  if !g:aim_enabled
    return
  endif

  augroup aim-reset
    autocmd!
  augroup END

  let l:ctx = {}
  function! l:ctx.callback() abort
    augroup aim-reset
      autocmd CursorMoved,InsertEnter,BufEnter * ++once call feedkeys("\<Plug>(aim-internal-nohlsearch)", 't')
    augroup END
  endfunction
  call timer_start(200, { -> l:ctx.callback() })
endfunction

