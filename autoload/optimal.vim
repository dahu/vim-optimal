let s:optimal_options = {'lock' : {}, 'sync' : {}, 'options' : vimple#options#new()}

endfunction

function! s:lock(lock, opt, value, msg)
  let [lock, opt, value, msg] = [a:lock, a:opt, a:value, a:msg]
  let lock_str = lock ? 'lock' : 'unlock'
  let was_locked = optimal#is_locked(opt)
  call extend(s:optimal_options.lock[opt], {'locked' : lock, 'value' : value})
  call optimal#log#add(opt, lock_str, [[was_locked, 1], value], msg)
endfunction

function! optimal#is_locked(opt)
  let opt = a:opt
  if !has_key(s:optimal_options.lock, opt)
    let s:optimal_options.lock[opt] = {'locked' : -1}
  endif
  return s:optimal_options.lock[opt].locked
endfunction

function! optimal#set(opt, value)
  let ops = vimple#options#new().to_d()
  if ops[a:opt].type == 'bool'
    exe 'set ' (a:value == 1 ? '' : 'no') . a:opt
  else
    exe 'set ' a:opt . '=' . a:value
  endif
endfunction

function! optimal#lock(opt, value, msg)
  call optimal#set(a:opt, a:value)
  call s:lock(1, a:opt, a:value, a:msg)
endfunction

function! optimal#unlock(opt, msg)
  call s:lock(0, a:opt, eval('&'.a:opt), a:msg)
endfunction

function! optimal#sync(optlist)
  for opt in a:optlist
    call extend(s:optimal_options.sync, {opt : a:optlist})
  endfor
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

function! optimal#check_synced()
  let changed_ops = s:optimal_options.options.changed().to_d()
  call s:optimal_options.options.update()
  let new_op_values = s:optimal_options.options.to_d()
  for opt in items(s:optimal_options.sync)
    if has_key(changed_ops, opt[0])
      let v = new_op_values[opt[0]].value
      for o in opt[1]
        call optimal#set(o, v)
      endfor
    endif
  endfor
endfunction

function! optimal#stop_sync(opt)
  if !has_key(s:optimal_options, a:opt)
    return
  endif
  call filter(s:optimal_options.sync, 'v:val !=# s:optimal_options.sync[a:opt]')
endfunction

function! optimal#update()
  call optimal#check_locked()
  call optimal#check_synced()
endfunction

