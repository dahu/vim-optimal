function! optimal#log#clear()
  let s:optimal_options_log = []
endfunction

function! optimal#log#add(opt, op, values, msg)
  let vt = type(a:values)
  let values = (((vt == type([])) || (vt == type({}))) ? a:values : [a:values])
  call add(s:optimal_options_log, [localtime(), a:opt, a:op, values, a:msg])
endfunction

function! optimal#log#view(...)
  if !empty(s:optimal_options_log)
    echohl Title
    echo 'Options Log:'
    echohl None
    for log in s:optimal_options_log
      echo printf("%s\t%s\t%s\t%s\t%s\n", strftime("%d%H%M", log[0]), log[1], log[2], string(log[3]), log[4])
    endfor
  endif
endfunction

if ! has_key(s:, 'optimal_options_log')
  call optimal#log#clear()
endif
