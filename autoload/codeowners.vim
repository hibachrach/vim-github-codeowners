scriptencoding utf-8

let s:cache = {}

let s:codeownersFilePath = 0

function! codeowners#reset()
  let s:cache = {}
endfunction

function! codeowners#setCodeownersFilePath()
  if filereadable(s:projectDir . '/.github/CODEOWNERS')
    let s:codeownersFilePath = s:projectDir . '/.github/CODEOWNERS'
  elseif filereadable(s:projectDir . '/CODEOWNERS')
    let s:codeownersFilePath = s:projectDir . '/CODEOWNERS'
  elseif filereadable(s:projectDir . '/docs/CODEOWNERS')
    let s:codeownersFilePath = s:projectDir . '/docs/CODEOWNERS'
  endif
endfunction

function! codeowners#isCodeownersFileExist()
  let s:projectDir = split(system('git rev-parse --show-toplevel'))[0]

  call codeowners#setCodeownersFilePath()
  return s:codeownersFilePath isnot 0 ? 1 : 0
endfunction

function! codeowners#whoBufname()
  return codeowners#who(bufname())
endfunction

function! codeowners#who(file)
  if !has_key(s:cache, a:file)
    if !codeowners#isCodeownersFileExist()
      let s:cache[a:file] = "Unloved"
    else
      let s:bin = globpath(&rtp, "node_modules/.bin/github-codeowners") 
      let l:output = system(s:bin . " who -c " . s:codeownersFilePath . " " . a:file)
      let s:cache[a:file] = get(split(l:output), 1, "Unloved") 
    endif
  endif

  return s:cache[a:file]
endfunction
