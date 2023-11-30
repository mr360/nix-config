# Development 

## Tmux
|Base|Key | Description   |
|---|------|----------------|
 C-a | c   |         create window
 C-a | n   |         next window
 C-a | p   |         prev window
 C-a | ,   |         rename window
 C-a | %   |         split pane virtically
 C-a |     |         split pane horizontally
 C-a | z   |         toggle pane fullscreen
 C-a | <arrow_key> | move/resize pane(s)
 C-a | hjkl     | move between pane(s)
 C-d       |     | close pane (can type exit)
 C-a | 01234    | move to window 

## NeoVim
### Editor
|Key|Reason | Description   |
|---|   --- |   ---         |
| r |   replace | replaces the current character in-place
| w,e| move to word | moves to first / last character of next word.
| s | insert | insert mode
| ctrl-c | exit | can exit modes|
| o | next line | insert new line and present in insert mode
|$ b | previous word | first char 
|$ Vyp| paste current line below | comprised of 3 commands - visual, yank and paste
|$ f<_char>; | find <_char> | 
|$ ci<_char> | clear within <_char> boundary ?
|$ V | select whole line

### File Explorer
|xxx|xxx|xxx|
|---|---|---|
  % | create file
  d | create directory
  Ex| open netrw
