# luau-vim
Congratulations.
You too can experience Luau and Roblox Luau syntax highlighting in your Vim / Neovim text editor.

![three, add method](screenshots/three-add.png)

![geoplane, Box type](screenshots/geoplane-box-type.png)

![geoplane, Mesh3.CSCMatrix](screenshots/geoplane-mesh3-cscmat-nfn.png)

## Installation
via Vundle.vim

``Plugin 'polychromatist/luau-vim'``

via neobundle.vim

``NeoBundleFetch 'polychromatist/luau-vim'``

## Init Variables

`let g:luau_roblox = 0 | 1 (default)`

## Coverage
y: implemented

y%: mostly implemented / implemented, but target is volatile

%: partially implemented (i.e. somewhat works)

n: not yet implemented / implementation status unknown

y!: implemented, recent issues

x: no intention to implement

### Core
- base Lua syntax: y
  - inherited from default Lua vim style
- base Luau syntax: y%
  - inline "if"-style x-ary operator: n
  - type: %
- Roblox functions: y%
  - auto-generate: n

### Other
- method invocations: y%
  - need to make optional
- linting: n
