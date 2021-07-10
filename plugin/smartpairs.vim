" smartpairs.vim - Sensible pairings
" Maintainer:	Federico Ramirez <fedra.arg@gmail.com>
" Version: 0.0.1
" Repository: https://github.com/gosukiwi/smartpairs

if exists('g:smartpairs_loaded')
  finish
endif

let g:smartpairs_loaded = 1
let g:smartpairs_default_pairs = { 
      \ '(': ')',
      \ '[': ']',
      \ '{': '}',
      \ '"': '"',
      \ "'": "'",
      \ }
let g:smartpairs_pairs = {}
let g:smartpairs_pairs['vim'] = { '(': ')', '[': ']', '{': '}', "'": "'" }
let g:smartpairs_pairs['javascript'] = { '(': ')', '[': ']', '{': '}', '"': '"', "'": "'", '`': '`' }

" KEYBINDED FUNCTIONS
" ==============================================================================
function! s:Jump(char) abort
  let remaining = getline('.')[col('.') - 1:]

  if remaining =~ '^\s*' . a:char
    return "\<Esc>f" . a:char .  "a"
  else
    return a:char
  endif
endfunction

function! s:InsertOrJump(open, close) abort
  let prevchar = nr2char(strgetchar(getline('.'), col('.') - 2))
  if prevchar == '\'
    return a:open
  endif

  let jump = s:Jump(a:open)
  if jump == a:open " jump failed
    return a:open . a:close . "\<Left>"
  else
    return jump
  endif
endfunction

function! s:Backspace() abort
  let prevchar = nr2char(strgetchar(getline('.'), col('.') - 2))
  let remaining = getline('.')[col('.') - 1:]

  if has_key(s:smartpairs_pairs, prevchar) && remaining =~ '^\s*' . s:smartpairs_pairs[prevchar]
    return "\<Esc>df" . s:smartpairs_pairs[prevchar] . 'i'
  else
    return "\<BS>"
  endif
endfunction

function! s:Space() abort
  let prevchar = nr2char(strgetchar(getline('.'), col('.') - 2))
  let nextchar = nr2char(strgetchar(getline('.'), col('.') - 1))

  if has_key(s:smartpairs_pairs, prevchar) && nextchar == s:smartpairs_pairs[prevchar]
    return "\<Space>\<Space>\<Left>"
  else
    return "\<Space>"
  endif
endfunction

" INITIALIZATION
" ==============================================================================
function! s:SetUpMappings() abort
  let keys = keys(s:smartpairs_pairs)
  for opening in keys
    execute 'inoremap <expr> <buffer> <silent> ' . opening . ' <SID>InsertOrJump("' . escape(opening, '"') . '", "' . escape(s:smartpairs_pairs[opening], '"') . '")'
    if opening != s:smartpairs_pairs[opening]
      execute 'inoremap <expr> <buffer> <silent> ' . s:smartpairs_pairs[opening] . ' <SID>Jump("' . escape(s:smartpairs_pairs[opening], '"') . '")'
    endif
  endfor

  inoremap <expr> <buffer> <silent> <BS> <SID>Backspace()
  inoremap <expr> <buffer> <silent> <Space> <SID>Space()
endfunction

function! SmartPairsInitialize() abort
  if has_key(g:smartpairs_pairs, &filetype)
    let s:smartpairs_pairs = g:smartpairs_pairs[&filetype]
  else
    let s:smartpairs_pairs = g:smartpairs_default_pairs
  endif

  call s:SetUpMappings()
endfunction

autocmd BufEnter * :call SmartPairsInitialize()