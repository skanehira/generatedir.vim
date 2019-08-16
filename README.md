# generatedir
This is a plugin that auto generates a directory structure.
You can use the json to define directory structure.

# Settings
```vim
let g:generate_template_dir = '/path/to/template'
```

# Usage
```vim
" generate directory using specified json
:GenerateDir sample.json

" generate directory using template
:GenerateDirFromTemplate
```

