let s:state = {}

"
" aim#start
"
function! aim#start(dir) abort
  if !empty(s:state)
    return aim#move(a:dir, '')
  endif

  let s:state = {
  \   'orig_dir': a:dir,
  \   'orig_pos': getpos('.')[1 : 2],
  \   'dir': a:dir,
  \   'input': '',
  \   'locations': [],
  \ }
  let l:timer_id = timer_start(16, { -> s:on_input() }, { 'repeat': -1 })
  try
    let l:input = input('/')
    if empty(l:input)
      call g:aim.goto(s:state.orig_pos)
    endif
    redraw
  finally
    call timer_stop(l:timer_id)
  endtry
  call s:reserve_reset()
endfunction

"
" on_input
"
function! s:on_input() abort
  let l:input = getcmdline()
  if s:state.input ==# l:input
    return
  endif
  let s:state.input = l:input

  " Update location cache
  if l:input !=# ''
    call s:reserve_reset()
    let s:state.locations = s:get_locations(s:state.input, s:state.orig_pos)
  else
    let s:state.locations = []
  endif

  " Update highlights
  for l:match in getmatches()
    if l:match.group =~# '^Aim'
      call matchdelete(l:match.id)
    endif
  endfor
  for l:location in s:state.locations
    call matchaddpos('AimLocation', [[l:location[0], l:location[1], strlen(l:location[2])]])
  endfor
  call s:move(s:state.orig_dir, s:state.orig_pos)
  redraw
endfunction

"
" aim#move
"
function! aim#move(dir, fallback) abort
  if !empty(s:state)
    let s:state.dir = a:dir
    call feedkeys("\<Plug>(aim-move)", 't')
    return ''
  endif
  return a:fallback
endfunction

"
" aim#_move
"
nnoremap <silent> <Plug>(aim-move) :<C-u>call aim#_move()<CR>
cnoremap <silent> <Plug>(aim-move) <C-r>=aim#_move()<CR>
function! aim#_move() abort
  call s:move(s:state.dir, getpos('.')[1 : 2])
  return ''
endfunction

"
" move
"
function! s:move(dir, from_pos) abort
  call s:reserve_reset()

  let l:location = s:find(a:dir, s:state.input, a:from_pos)
  if !empty(l:location)
    call g:aim.goto(l:location)
    for l:match in getmatches()
      if l:match.group ==# 'AimCurrentLocation'
        call matchdelete(l:match.id)
      endif
    endfor
    call matchaddpos('AimCurrentLocation', [[l:location[0], l:location[1], strlen(l:location[2])]])
    redraw!
  endif
  return ''
endfunction

"
" find
"
function! s:find(dir, input, from_pos) abort
  let l:cursor = a:from_pos
  let l:locations = copy(s:state.locations)
  if a:dir ==# 'n'
    let l:locations = filter(l:locations, 'v:val[0] > l:cursor[0] || (v:val[0] == l:cursor[0] && v:val[1] > l:cursor[1])')
  endif
  if a:dir ==# 'p'
    let l:locations = filter(l:locations, 'v:val[0] < l:cursor[0] || (v:val[0] == l:cursor[0] && v:val[1] < l:cursor[1])')
    let l:locations = reverse(l:locations)
  endif
  if !empty(l:locations)
    return l:locations[0]
  endif
  return v:null
endfunction

"
" compare
"
function! s:compare(pos1, pos2) abort
  if a:pos1[0] - a:pos2[0] > 0
    return a:pos1[1] - a:pos2[1]
  endif
  return a:pos1[0] - a:pos2[0]
endfunction

"
" get_locations
"
function! s:get_locations(input, pos) abort
  let l:pattern = '\(' . g:aim.pattern(a:input) . '\)'

  let l:locations = []
  call cursor(a:pos)
  while v:true
    let [l:lnum, l:col] = searchpos(l:pattern, 'bW')
    if l:lnum == 0
      break
    endif
    let l:locations += [[l:lnum, l:col, matchstr(getline(l:lnum)[l:col - 1 : -1], l:pattern)]]
  endwhile
  let l:locations = reverse(l:locations)

  call cursor(a:pos)
  while v:true
    let [l:lnum, l:col] = searchpos(l:pattern, 'W')
    if l:lnum == 0
      break
    endif
    let l:locations += [[l:lnum, l:col, matchstr(getline(l:lnum)[l:col - 1 : -1], l:pattern)]]
  endwhile

  call cursor(a:pos)
  return l:locations
endfunction

"
" reserve_reset
"
function! s:reserve_reset() abort
  augroup aim
    autocmd!
  augroup END

  let l:ctx = {}
  function! l:ctx.callback() abort
    augroup aim
      autocmd!
      autocmd BufEnter,InsertEnter,CursorMoved <buffer> ++once call <SID>clear()
    augroup END
  endfunction
  call timer_start(0, { -> l:ctx.callback() })
endfunction

"
" clear
"
function! s:clear() abort
  let s:state = {}
  for l:match in getmatches()
    if l:match.group =~# '^Aim'
      call matchdelete(l:match.id)
    endif
  endfor
endfunction
