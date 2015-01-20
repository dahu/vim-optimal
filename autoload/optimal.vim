let s:optimal_options = {'lock' : {}, 'sync' : {}}

let myops = s:optimal_options
function! optimal#is_locked(opt)
  let opt = a:opt
  if !has_key(s:optimal_options.lock, opt)
    let s:optimal_options.lock[opt] = {'locked' : -1}
  endif
  return s:optimal_options.lock[opt].locked
endfunction

function! s:lock(lock, opt, value, msg)
  let [lock, opt, value, msg] = [a:lock, a:opt, a:value, a:msg]
  let lock_str = lock ? 'lock' : 'unlock'
  let was_locked = optimal#is_locked(opt)
  call extend(s:optimal_options.lock[opt], {'locked' : lock, 'value' : value})
  call optimal#log#add(opt, lock_str, [[was_locked, 1], value], msg)
endfunction

function! optimal#lock(opt, value, msg)
  let ops = vimple#options#new().to_d()
  if ops[a:opt].type == 'bool'
    exe 'set ' (a:value == 1 ? '' : 'no') . a:opt
  else
    exe 'set ' a:opt . '=' . a:value
  endif
  call s:lock(1, a:opt, a:value, a:msg)
endfunction

function! optimal#unlock(opt, msg)
  call s:lock(0, a:opt, eval('&'.a:opt), a:msg)
endfunction

function! optimal#check_locked()
  for opt in items(s:optimal_options.lock)
    if (opt[1].locked == 1) && (eval('&'.opt[0]) != opt[1].value)
      echohl Error
      echom 'Cannot change locked option ' . opt[0] . '. Reset to ' . opt[1].value
      echohl None
      exe 'let &' . opt[0] . " = '" . substitute(opt[1].value, "'", "''", "g") . "'"
    endif
  endfor
endfunction

function! optimal#sync(optlist)
  for opt in a:optlist
  endfor
endfunction



function! optimal#update()
  call optimal#check_locked()
endfunction

command! -nargs=+ Lock call optimal#lock(<f-args>)

augroup Options
  au!
  au CursorHold * call optimal#update()
augroup END

" echo optimal#is_locked('ts')
" call optimal#log#view()
