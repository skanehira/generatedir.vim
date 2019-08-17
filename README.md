# generatedir
This is a plugin that auto generates a directory structure.
You can use the json to define directory structure.

# Settings
```vim
let g:generate_template_dir = '/path/to/template'
```

# Usage
sample.json
```json
[
	{
		"name": "$root/$plugin.vim",
		"type": "dir",
		"children": [
			{
				"name": "plugin",
				"type": "dir",
				"children": [
					{
						"name": "$plugin.vim",
						"type": "file"
					}
				]
			},
			{
				"name": "autoload",
				"type": "dir",
				"children": [
					{
						"name": "$plugin.vim",
						"type": "file"
					}
				]
			},
			{
				"name": "syntax",
				"type": "dir",
				"children": [
					{
						"name": "$plugin.vim",
						"type": "file"
					}
				]
			},
			{
				"name": "doc",
				"type": "dir",
				"children": [
					{
						"name": "$plugin.txt",
						"type": "file"
					}
				]
			}
		]
	}
]
```

```vim
" generate directory using specified json
" argment's value will expand path like expand("~/")
:GenerateDir sample.json $root=$GOPATH/src/github.com/skanehira $plugin=gorilla

" generate directory using template
" tempalts will display popup window
:GenerateDirFromTemplate $root=$GOPATH/src/github.com/skanehira $plugin=gorilla
```

