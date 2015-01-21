" Vim global plugin for automating option settings
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Description:	1. Automates option settings based on expressions.
" 		2. Opinionated locks on "dangerous/deprecated" options
" License:	Vim License (see :help license)
" Location:	plugin/optimal.vim
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

"if exists("g:loaded_optimal")
"      \ || v:version < 700
"      \ || &compatible
"  let &cpo = s:save_cpo
"  finish
"endif
let g:loaded_optimal = 1

" Options: {{{1

let s:opinionated_options = [
      \  ['edcompatible', 0 , 'Altering this option is highly discouraged']
      \, ['gdefault'    , 0 , 'Altering this option is highly discouraged']
      \, ['magic'       , 1 , 'Locked for portability']
      \, ['remap'       , 1 , 'Locked for portability']
      \, ['smartindent' , 0 , 'This option has been deprecated']
      \, ['tabstop'     , 8 , 'Tabstop should never be changed']
      \, ['textauto'    , 0 , 'This option has been deprecated']
      \, ['textmode'    , 0 , 'This option has been deprecated']
      \]

if !exists('g:optimal_opinionated_options')
  let g:optimal_opinionated_options = s:opinionated_options
endif

" Private Functions: {{{1

function! s:lock(...)
  if a:0 < 2
    return
  endif
  let opt = a:1
  let val = a:2
  let msg = a:2 > 2 ? join(a:000[2:], ' ') : 'Option locked by the user.'
  call optimal#lock(opt, val, msg)
endfunction

function! s:unlock(...)
  if !a:0
    return
  endif
  let opt = a:1
  let msg = a:2 > 1 ? join(a:000[1:], ' ') : 'Option unlocked by the user.'
  call optimal#lock(opt, msg)
endfunction

" Public Interface: {{{1

function! LockOptions(options)
  for opt in a:options
    call optimal#lock(opt[0], opt[1], opt[2])
  endfor
endfunction

" Commands: {{{1

command! -nargs=+ OptimalLock call optimal#lock(<f-args>)
command! -nargs=+ OptimalUnlock call optimal#unlock(<f-args>)
command! -nargs=+ OptimalSync call optimal#sync([<f-args>])
command! -nargs=1 OptimalUnsync call optimal#unsync(<q-args>)

" Autocommands: {{{1

augroup OptimalInit
  au!
  au VimEnter * call LockOptions(g:optimal_opinionated_options)
  au CursorHold * call optimal#update()
augroup END

" Teardown: {{{1
" reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
