" ============================================================================
" Description: An ack/ag powered code search and view tool.
" Author: Ye Ding <dygvirus@gmail.com>
" Licence: Vim licence
" Version: 1.00
" ============================================================================

" List of paragraphs, paragraph is main object which stores parsed query result
let s:resultset = []

" cache contains ALL cacheable result
let s:cache = {}

"""""""""""""""""""""""""""""""""
" Getter
"""""""""""""""""""""""""""""""""

func! ctrlsf#db#ResultSet() abort
    return s:resultset
endf

func! ctrlsf#db#FileSet() abort
    " List of result files, generated by resultset
    let fileset   = []

    if has_key(s:cache, 'fileset')
        return s:cache['fileset']
    endif

    let cur_file = ''
    for par in s:resultset
        if cur_file !=# par.file
            let cur_file = par.file
            call add(fileset, {
                \ "file": cur_file,
                \ "paragraphs": [],
                \ })
        endif
        call add(fileset[-1].paragraphs, par)
    endfo

    let s:cache['fileset'] = fileset
    return fileset
endf

func! ctrlsf#db#MatchList() abort
    " List of matches, generated by resultset
    let matchlist = []

    if has_key(s:cache, 'matchlist')
        return s:cache['matchlist']
    endif

    for par in s:resultset
        call extend(matchlist, par.matches())
    endfo

    let s:cache['matchlist'] = matchlist
    return matchlist
endf

func! ctrlsf#db#MaxLnum()
    if has_key(s:cache, 'maxlnum')
        return s:cache['maxlnum']
    endif

    let max = 0
    for par in s:resultset
        let mlnum = par.lnum() + par.range() - 1
        let max = mlnum > max ? mlnum : max
    endfo

    let s:cache['maxlnum'] = max
    return max
endf

"""""""""""""""""""""""""""""""""
" Parser
"""""""""""""""""""""""""""""""""

" s:ParseParagraph()
"
" Notice that some fields are initialized with -1, which will be populated
" in render processing.
func! s:ParseParagraph(buffer, file) abort
    let paragraph = {
        \ 'file'    : a:file,
        \ 'lnum'    : function("ctrlsf#class#paragraph#Lnum"),
        \ 'vlnum'   : function("ctrlsf#class#paragraph#Vlnum"),
        \ 'range'   : function("ctrlsf#class#paragraph#Range"),
        \ 'lines'   : [],
        \ 'matches' : function("ctrlsf#class#paragraph#Matches"),
        \ }

    for line in a:buffer
        let matched = matchlist(line, '\v^(\d+)([-:])(.*)$')

        " add matched line to match list
        let match = {}
        let mat_col = match(matched[3], ctrlsf#opt#GetOpt("_vimregex")) + 1
        if mat_col > 0
            let match = {
                \ 'lnum'  : matched[1],
                \ 'vlnum' : -1,
                \ 'col'   : mat_col,
                \ 'vcol'  : -1
                \ }
        endif

        " add line content
        call add(paragraph.lines, {
            \ 'matched' : function("ctrlsf#class#line#Matched"),
            \ 'match'   : match,
            \ 'lnum'    : matched[1],
            \ 'vlnum'   : -1,
            \ 'content' : matched[3],
            \ })
    endfo

    return paragraph
endf

" ParseAckprgOutput()
"
func! ctrlsf#db#ParseAckprgResult(result) abort
    " reset
    let s:resultset = []
    call ctrlsf#db#ClearCache()

    let current_file = ""
    let next_file    = ""

    " ack/ag has a feature that if a single file is given as search path, then
    " there will be no explicit filename in search result.
    if len(ctrlsf#opt#GetOpt("path")) == 1
        let path = ctrlsf#opt#GetOpt("path")[0]
        if getftype(path) == 'file'
            let current_file = path
        endif
    endif

    let result_lines = split(a:result, '\n')

    let cur = 0
    while cur < len(result_lines)
        let buffer = []
        let pre_ln = -1

        while cur < len(result_lines)
            let line = result_lines[cur]
            let cur += 1

            " don't rely on division line any longer. ignore it.
            if line =~ '^--$'
                continue
            endif

            let matched = matchlist(line, '\v^(\d+)[-:]')

            " if line doesn't match [lnum:col] pattern, assume it is filename
            if empty(matched)
                let next_file = line

                if current_file !=# next_file
                    let cur -= 1
                    break
                else
                    continue
                endif
            endif

            " else regard this line as content line
            let cur_ln = matched[0]
            if (pre_ln == -1) || (cur_ln == pre_ln + 1)
                let pre_ln = cur_ln
                call add(buffer, line)
            else
                let cur -= 1
                break
            endif
        endwh

        if len(buffer) > 0
            let paragraph = s:ParseParagraph(buffer, current_file)
            call add(s:resultset, paragraph)
        endif

        let current_file = next_file
    endwh
endf

"""""""""""""""""""""""""""""""""
" Cache
"""""""""""""""""""""""""""""""""
" ClearCache
"
func! ctrlsf#db#ClearCache() abort
    let s:cache = {}
endf
