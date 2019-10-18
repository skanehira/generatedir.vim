" generatedir
" Version: 0.0.1
" Author: skanehira
" License: MIT

let s:sep = fnamemodify('.', ':p')[-1:]
let s:plug_template_dir = expand('<sfile>:p:h:h') .. s:sep .. 'generatedir-template'

function! s:echo_err(message) abort
	echohl ErrorMsg | echom a:message | echohl None
endfunction

function! s:mkfile(file) abort
	if has('win32') || has('win64')
		if !executable('type')
			throw '[generatedir] command "type" is not exist'
		endif
		for f in a:file
			call system('type nul > ' .. f)
		endfor
	else
		if !executable('touch')
			throw '[generatedir] command "touch" is not exist'
		endif
		call system('touch ' .. join(a:file, ' '))
	endif
endfunction

function! s:mkdir(dir) abort
	call system("mkdir -p " .. join(a:dir, ' '))
endfunction

function! s:parse_vars(args) abort
	let results = {}
	for arg in a:args
		let kv = split(arg, "=")
		if len(kv) < 2
			throw '[generatedir] invalid args ' .. arg
		endif
		let results[kv[0]] = expand(kv[1])
	endfor
	return results
endfunction

function! s:parse_args(args) abort
	if len(a:args) ==# 0
		return
	endif
	return {
				\ 'file': a:args[0],
				\ 'vars': s:parse_vars(a:args[1:])
				\ }
endfunction

function! s:bind_vars(vars, name) abort
	let file = a:name
	if stridx(file, '$') ==# -1
		return file
	endif

	for [k, v] in items(a:vars)
		let file = substitute(file, escape(k, '$'), v, "g")
	endfor

	if stridx(file, '$') !=# -1
		throw '[generatedir] invalid name, argment required: ' .. file
	endif
	return file
endfunction

function! s:parse_dir(vars, dir, ...) abort
	let path = get(a:000, 0, [])
	let results = get(a:000, 1, [])

	for elem in a:dir
		let name = s:bind_vars(a:vars, get(elem, 'name', ''))
		let type = get(elem, 'type', '')

		if empty(name) || empty(type)
			throw '[generatedir] "name" or "type" is empty in json'
		endif

		let children = get(elem, 'children', [])

		if type ==# 'dir'
			call s:parse_dir(a:vars, children, path+[name], results)
		else
			if empty(filter(copy(results), "v:val.name ==# join(path, s:sep)"))
				call add(results, {'name': join(path, s:sep), 'type': 'dir'})
			endif
			call add(results, {'name': join(path+[name], s:sep), 'type': type})
		endif
	endfor

	return results
endfunction

function! generatedir#generate_dir(...) abort
	echo 'generating'
	try
		let args = s:parse_args(a:000)
		if !filereadable(args.file)
			call s:echo_err('[generatedir] cannot read file ' .. args.file)
			return
		endif
		let elements = s:parse_dir(args.vars, json_decode(join(readfile(args.file),'')))
		call s:mkdir(map(filter(copy(elements), 'v:val.type ==# "dir"'), 'v:val.name'))
		call s:mkfile(map(filter(copy(elements), 'v:val.type ==# "file"'), 'v:val.name'))
	catch /.*/
		call s:echo_err(v:exception)
		return
	endtry
	redraw
	echo 'generate complete'
endfunction

function! s:generate_filter(ctx, id, key) abort
	if a:key ==# 'j'
		let idx = a:ctx.idx - 1
		if idx < len(a:ctx.templates)
			let a:ctx.idx = a:ctx.idx + 1
		endif
	elseif a:key ==# 'k'
		if a:ctx.idx > 0
			let a:ctx.idx = a:ctx.idx - 1
		endif
	elseif a:key ==# 'q'
		call popup_close(a:id)
		return 1
	elseif a:key ==# "\<CR>"
		let file =  a:ctx.templates[a:ctx.idx].path

		let args = []
		let vars = input('vars: ')
		call add(args, file)
		let args += split(vars)
		call call('generatedir#generate_dir', args)

		call popup_close(a:id)
		return 1
	endif

	return popup_filter_menu(a:id, a:key)
endfunction

function! generatedir#generate_from_template(...) abort
	let templates = map(
				\ readdir(s:plug_template_dir),
				\ '{"name": v:val, "path": s:plug_template_dir .. s:sep .. v:val}'
				\ )

	let user_template_dir = get(g:, 'generate_template_dir', '')

	if !empty(user_template_dir)
		let templates += map(
					\ readdir(user_template_dir),
					\ '{"name": v:val, "path": user_template_dir .. s:sep .. v:val}'
					\ )
	endif

	let ctx = {
		\ 'idx': 0,
		\ 'templates': templates,
		\ }

	call popup_menu(map(copy(ctx.templates), 'v:val.name'), {
				\ 'filter': function('s:generate_filter', [ctx]),
				\ 'border': [1, 1, 1, 1],
				\ 'borderchars': ['-','|','-','|','+','+','+','+'],
				\ })
endfunction
