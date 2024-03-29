let s:Promise = vital#fern#import('Async.Promise')
let s:F = vital#fern#import('System.Filepath')

function! fern#mapping#rgsearch#init(disable_default_mappings) abort
  nnoremap <buffer><silent> <Plug>(fern-action-rgsearch) :<C-u>call <SID>call('rgsearch')<CR>
endfunction

function! s:call(name, ...) abort
  return call(
        \ 'fern#mapping#call',
        \ [funcref(printf('s:map_%s', a:name))] + a:000,
        \)
endfunction


function! s:map_rgsearch(helper) abort

    let nodes = a:helper.sync.get_selected_nodes()
    let paths = map(copy(nodes), { -> v:val._path })

    let pattern = input('The following '.len(paths).' nodes will be searched in. Enter the search pattern: ')
    if pattern ==# ''
        return s:Promise.reject('Aborted.')
    endif

    let pattern = substitute(pattern, '\$', '\\\\\\$', '')
    let pattern = substitute(pattern, '(', '\\\\(', '')
    let pattern = substitute(pattern, ')', '\\\\)', '')

    let commands = []
    for path in paths
        if isdirectory(path)
            call add(commands, 'rg --follow --glob "!.git*" --column --line-number --no-heading --color=always --colors "path:fg:190,220,255" --colors "line:fg:128,128,128" --smart-case "' . pattern . '" "' . path . '"')
        endif
    endfor
    
    
    if len(commands) == 0
        return s:Promise.reject('Invalid selection.')
    endif
    
    exe "normal! \<c-w>\<c-w>"
    call fzf#vim#grep(
    \  '('.join(commands,' ; ').') | sort -u',
    \  1,
    \  fzf#vim#with_preview('right:40%', '?')
    \ )
  
  return s:Promise.resolve()
        \.then({ -> a:helper.async.redraw() })
endfunction
