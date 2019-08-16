" generatedir
" Version: 0.0.1
" Author: skanehira
" License: MIT

let s:sep = fnamemodify('.', ':p')[-1:]

function! s:echo_err(message) abort
	echohl ErrorMsg | echo a:message | echohl None
endfunction

function! s:parse_dir(dir, ...) abort
	let path = get(a:000, 0, [])
	let results = get(a:000, 1, [])

	for elem in a:dir
		let name = get(elem, 'name', '')
		let type = get(elem, 'type', '')

		if empty(name) || empty(type)
			throw 'generatedir: "name" or "type" is empty in json'
		endif
		let children = get(elem, 'children', [])

		if type ==# 'dir'
			call s:parse_dir(children, path+[name], results)
		else
			if empty(filter(copy(results), "v:val.name ==# join(path, s:sep)"))
				call add(results, {'name': join(path, s:sep), 'type': 'dir'})
			endif
			call add(results, {'name': join(path+[name], s:sep), 'type': type})
		endif
	endfor

	return results
endfunction

function! s:mkfile(file) abort
	if has('win32') || has('win64')
		if !executable('type')
			throw 'generatedir: command "type" is not exist'
		endif
		for f in a:file
			call system('type nul > ' .. f)
		endfor
	else
		if !executable('touch')
			throw 'generatedir: command "touch" is not exist'
		endif
		call system('touch ' .. join(a:file, ' '))
	endif
endfunction

function! s:mkdir(dir) abort
	call system("mkdir -p " .. join(a:dir, ' '))
endfunction

function! generatedir#generate_dir(file) abort
	if !filereadable(a:file)
		call s:echo_err('cannot read file ' .. a:file)
		return
	endif
	echo 'generating...'
	try
		let elements = s:parse_dir(json_decode(join(readfile(a:file), "\n")))
		call s:mkdir(map(filter(copy(elements), 'v:val.type ==# "dir"'), 'v:val.name'))
		call s:mkfile(map(filter(copy(elements), 'v:val.type ==# "file"'), 'v:val.name'))
	catch /.*/
		call s:echo_err(v:exception)
	endtry
	redraw
	echo 'generate complete'
endfunction


function! s:generate_cb(files, id, idx) abort
	call generatedir#generate_dir(a:files[a:idx-1].path)
endfunction

function! generatedir#generate_from_template() abort
	let plug_template_dir = expand('<sfile>:p:h') .. s:sep .. 'template'
	let templates = map(
				\ readdir(plug_template_dir),
				\ '{"name": v:val, "path": plug_template_dir .. s:sep .. v:val}'
				\ )

	let user_template_dir = get(g:, 'generate_template_dir', '')

	if !empty(user_template_dir)
		let templates += map(
					\ readdir(user_template_dir),
					\ '{"name": v:val, "path": user_template_dir .. s:sep .. v:val}'
					\ )
	endif

	call popup_menu(map(copy(templates), 'v:val.name'), {
				\ 'filter': 'popup_filter_menu',
				\ 'callback': function('s:generate_cb', [templates]),
				\ 'border': [1, 1, 1, 1],
				\ 'borderchars': ['-','|','-','|','+','+','+','+'],
				\ })
endfunction

