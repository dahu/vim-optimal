" Vim library for automating option settings
" Maintainers:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.1
" Description:	Library for automating option settings.
" License:	Vim License (see :help license)
" Location:	autoload/optimal.vim
" Website:	https://github.com/dahu/vim-optimal
"
" See optimal.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help optimal

" Vimscript Setup: {{{1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" load guard
" uncomment after plugin development
" Remove the conditions you do not need, they are there just as an example.
"if exists("g:loaded_lib_optimal")
"      \ || v:version < 700
"      \ || v:version == 703 && !has('patch338')
"      \ || &compatible
"  let &cpo = s:save_cpo
"  finish
"endif
"let g:loaded_lib_optimal = 1

let s:optimal_options = {'lock' : {}, 'sync' : {}, 'options' : vimple#options#new()}

" Vim Script Information Function: {{{1

" Use this function to return information about your script.
function! optimal#info()
  let info = {}
  let info.name = 'optimal'
  let info.version = 1.0
  let info.description = 'Short description.'
  let info.dependencies = [{'name': 'plugin1', 'version': 1.0}]
  return info
endfunction

" Private Functions: {{{1
function! s:lock(lock, opt, value, msg)
  let [lock, opt, value, msg] = [a:lock, a:opt, a:value, a:msg]
  let lock_str = lock ? 'lock' : 'unlock'
  let was_locked = optimal#is_locked(opt)
  call extend(s:optimal_options.lock[opt], {'locked' : lock, 'value' : value})
  call optimal#log#add(opt, lock_str, [[was_locked, 1], value], msg)
endfunction


" Library Interface: {{{1
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

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
