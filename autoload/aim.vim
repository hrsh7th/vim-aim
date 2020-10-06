"
" aim#start
"
function! aim#start(dir) abort
  let s:state = {
  \   'orig_dir': a:dir ==# 'upward' ? 'k' : 'j',
  \   'orig_pos': getpos('.')[1 : 2],
  \   'curr_pos': getpos('.')[1 : 2],
  \   'input': '',
  \   'prev_dir': '',
  \   'locations': [],
  \ }
  let l:timer_id = timer_start(16, { -> s:on_input() }, { 'repeat': -1 })
  try
    let l:input = input('$ ')
    if empty(l:input)
      call cursor(s:state.orig_pos)
    endif
    redraw
  finally
    for l:match in getmatches()
      if l:match.group =~# '^Aim'
        call matchdelete(l:match.id)
      endif
    endfor
    call timer_stop(l:timer_id)
  endtry
endfunction

"
" aim#move
"
function! aim#move(dir) abort
  call s:move(a:dir, s:state.curr_pos)
  redraw
  return ''
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
    let s:state.locations = s:get_locations(s:state.input, s:state.orig_pos)
  else
    let s:state.locations = []
  endif

  " Update highlights
  for l:match in getmatches()
    if l:match.group ==# 'AimCurrentLocation'
      call matchdelete(l:match.id)
    endif
  endfor
  for l:match in getmatches()
    if l:match.group ==# 'AimLocation'
      call matchdelete(l:match.id)
    endif
  endfor
  for l:location in s:state.locations
    call matchaddpos('AimLocation', [[l:location[0], l:location[1], strlen(s:state.input)]])
  endfor
  call s:move(s:state.orig_dir, s:state.orig_pos)
  redraw
endfunction

"
" move
"
function! s:move(dir, from_pos) abort
  let l:location = s:find(a:dir, s:state.input, a:from_pos)
  if !empty(l:location) && line('w0') <= l:location[0] && l:location[0] <= line('w$')
    call cursor(l:location)
    let s:state.curr_pos = l:location
    for l:match in getmatches()
      if l:match.group ==# 'AimCurrentLocation'
        call matchdelete(l:match.id)
      endif
    endfor
    call matchaddpos('AimCurrentLocation', [[l:location[0], l:location[1], strlen(s:state.input)]])
  endif
  return ''
endfunction

"
" find
"
function! s:find(dir, input, from_pos) abort
  let l:cursor = a:from_pos
  let l:locations = copy(s:state.locations)
  if a:dir ==# 'h'
    let l:locations = filter(l:locations, 'v:val[1] < l:cursor[1]')
  endif
  if a:dir ==# 'j'
    let l:locations = filter(l:locations, 'v:val[0] > l:cursor[0]')
  endif
  if a:dir ==# 'k'
    let l:locations = filter(l:locations, 'v:val[0] < l:cursor[0]')
  endif
  if a:dir ==# 'l'
    let l:locations = filter(l:locations, 'v:val[1] > l:cursor[1]')
  endif

  let l:locations = sort(copy(l:locations), { a, b -> float2nr(s:compare(a:dir, l:cursor, a, b)) })
  if !empty(l:locations)
    return l:locations[0]
  endif
  return v:null
endfunction

"
" compare
"
function! s:compare(dir, cursor, pos1, pos2) abort
  let l:lnum_delta1 = abs(a:cursor[0] - a:pos1[0]) * 2
  let l:col_delta1 = abs(a:cursor[1] - a:pos1[1])
  let l:lnum_delta2 = abs(a:cursor[0] - a:pos2[0]) * 2
  let l:col_delta2 = abs(a:cursor[1] - a:pos2[1])

  return (l:lnum_delta1 + l:col_delta1) - (l:lnum_delta2 + l:col_delta2)
endfunction

"
" get_locations
"
function! s:get_locations(input, pos) abort
  let l:locations = []

  call cursor(a:pos)
  while v:true
    let [l:lnum, l:col] = searchpos('\V' . escape(a:input, '\/'), 'bW')
    if l:lnum == 0
      break
    endif
    let l:locations += [[l:lnum, l:col]]
  endwhile
  call cursor(a:pos)
  while v:true
    let [l:lnum, l:col] = searchpos('\V' . escape(a:input, '\/'), 'W')
    if l:lnum == 0
      break
    endif
    let l:locations += [[l:lnum, l:col]]
  endwhile
  call cursor(a:pos)

  return l:locations
endfunction

