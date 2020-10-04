"
" aim#active
"
function! aim#active() abort
  return !empty(s:state)
endfunction

"
" aim#start
"
function! aim#start() abort
  let s:state = {
  \   'input': '',
  \   'prev_dir': '',
  \   'locations': [],
  \ }
  let l:timer_id = timer_start(16, { -> s:on_input() }, { 'repeat': -1 })
  try
    call input('$ ')
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
  call s:move(a:dir)
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
    let s:state.locations = s:get_locations(s:state.input)
  else
    let s:state.locations = []
  endif

  " Update highlights
  for l:match in getmatches()
    if l:match.group ==# 'AimLocation'
      call matchdelete(l:match.id)
    endif
  endfor
  for l:location in s:state.locations
    call matchaddpos('AimLocation', [[l:location[0], l:location[1], strlen(s:state.input)]])
  endfor
  redraw
endfunction

"
" move
"
function! s:move(dir) abort
  let l:location = s:find(a:dir, s:state.input)
  if !empty(l:location)
    call cursor(l:location)
    for l:match in getmatches()
      if l:match.group ==# 'AimCurrentLocation'
        call matchdelete(l:match.id)
      endif
    endfor
    call matchaddpos('AimCurrentLocation', [[l:location[0], l:location[1], strlen(s:state.input)]])
    redraw
  endif
  return ''
endfunction

"
" find
"
function! s:find(dir, input) abort
  let l:cursor = getpos('.')[1 : 2]
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
  let l:updown = index(['j', 'k'], a:dir) >= 0
  let l:lnum_delta1 = abs(a:cursor[0] - a:pos1[0]) * 2
  let l:col_delta1 = abs(a:cursor[1] - a:pos1[1])
  let l:lnum_delta2 = abs(a:cursor[0] - a:pos2[0]) * 2
  let l:col_delta2 = abs(a:cursor[1] - a:pos2[1])

  if !l:updown
    let l:col_delta1 = l:col_delta1 * 0.1
    let l:col_delta2 = l:col_delta2 * 0.1
  else
    let l:lnum_delta1 = l:lnum_delta1 * 0.1
    let l:lnum_delta2 = l:lnum_delta2 * 0.1
  endif

  return (l:lnum_delta1 + l:col_delta1) - (l:lnum_delta2 + l:col_delta2)
endfunction

"
" get_locations
"
function! s:get_locations(input) abort
  let l:locations = []

  let l:cursor = getpos('.')[1 : 2]
  while v:true
    let [l:lnum, l:col] = searchpos('\V' . escape(a:input, '\/?'), 'bW')
    if l:lnum == 0
      break
    endif
    let l:locations += [[l:lnum, l:col]]
  endwhile
  call cursor(l:cursor)
  while v:true
    let [l:lnum, l:col] = searchpos('\V' . escape(a:input, '\/?'), 'W')
    if l:lnum == 0
      break
    endif
    let l:locations += [[l:lnum, l:col]]
  endwhile
  call cursor(l:cursor)

  return l:locations
endfunction

