# name: cyan
set -g cyan (set_color 33FFFF)
set -g yellow (set_color -o yellow)
set -g red (set_color -o red)
set -g green (set_color -o green)
set -g white (set_color -o white)
set -g blue (set_color -o blue)
set -g magenta (set_color -o magenta)
set -g normal (set_color normal)
set -g purple (set_color -o purple)

set -g FISH_GIT_PROMPT_EQUAL_REMOTE "$magenta=$normal"
set -g FISH_GIT_PROMPT_AHEAD_REMOTE "$magenta>$normal"
set -g FISH_GIT_PROMPT_BEHIND_REMOTE "$magenta<$normal"
set -g FISH_GIT_PROMPT_DIVERGED_REMOTE "$red<>$normal"

function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _git_short_sha
    echo (command git rev-parse --short HEAD ^/dev/null)
end

function _git_ahead
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)

  if [ $status != 0 ]
    return
  end

  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead (count (for arg in $commits; echo $arg; end | grep -v '^<'))

  switch "$ahead $behind"
    case '' # no upstream
        echo ""
    case '0 0' # equal to upstream
        echo "$FISH_GIT_PROMPT_EQUAL_REMOTE"
    case '* 0' # ahead of upstream
        echo "$FISH_GIT_PROMPT_AHEAD_REMOTE"
    case '0 *' # behind upstream
        echo "$FISH_GIT_PROMPT_BEHIND_REMOTE"
    case '*' # diverged from upstream
        echo "$FISH_GIT_PROMPT_DIVERGED_REMOTE"
  end
end

function fish_prompt
  set -l cwd $green(basename (prompt_pwd))

  if [ (_git_branch_name) ]
    set -l git_branch $blue(_git_branch_name)$normal
    set git_info "$green($git_branch$green)$normal"

    set -l git_branch_ahead (_git_ahead)
    set git_info "$git_info $git_branch_ahead"
  end

  echo -n -s $normal $cyan (whoami) '@' $normal $blue (hostname -s) $normal ' ' $cwd ' '  $git_info $yellow' ✗ '$normal
end