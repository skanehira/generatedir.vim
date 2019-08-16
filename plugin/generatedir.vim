" generatedir
" Version: 0.0.1
" Author: skanehira
" License: MIT

if exists('g:loaded_generatedir')
    finish
endif

let g:loaded_generatedir = 1

let s:save_cpo = &cpo
set cpo&vim

command! GenerateDirFromTemplate call generatedir#generate_from_template()
command! -nargs=1 -complete=file GenerateDir call generatedir#generate_dir(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
