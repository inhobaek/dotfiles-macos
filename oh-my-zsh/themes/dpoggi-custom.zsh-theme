if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

#PROMPT='%{$fg[$NCOLOR]%}%n%{$reset_color%}@%{$fg[cyan]%}%m\
PROMPT='
%D{%H:%M:%S} %{$fg[$NCOLOR]%}[@%n]%{$reset_color%}\
%{$fg[blue]%} %~\
$(dc_git_prompt_info)
%{$fg[blue]%}%(!.#.❯)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%} ("
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%} ✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} ⚡︎%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[yellow]%})%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_AHEAD=" ⇡"
ZSH_THEME_GIT_PROMPT_BEHIND=" ⇣"
ZSH_THEME_GIT_PROMPT_DIVERGED=" ⇕"

function dc_git_prompt_info() {
    local ref
    if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
        ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$(dc_git_prompt_status)$ZSH_THEME_GIT_PROMPT_SUFFIX"
    fi
}

# Get the status of the working tree
function dc_git_prompt_status() {
    local INDEX STATUS
    INDEX=$(command git status --porcelain -b 2> /dev/null)
    STATUS=""
    if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
    fi
    if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
    elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
    fi
    if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
    elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
    elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
    fi
    if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
    fi
    if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
    elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
    elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
    fi
    if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
        STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
    fi
    if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
    fi
    if $(echo "$INDEX" | grep '^## [^ ]\+ .*ahead' &> /dev/null); then
        AHEAD=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
        STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$AHEAD$STATUS"
    fi
    if $(echo "$INDEX" | grep '^## [^ ]\+ .*behind' &> /dev/null); then
        BEHIND=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l | tr -d ' ')
        STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$BEHIND$STATUS"
    fi
    if $(echo "$INDEX" | grep '^## [^ ]\+ .*diverged' &> /dev/null); then
        STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
    fi
    echo $STATUS
}
