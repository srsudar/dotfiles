echo "Sourcing $0"
# Sam Sudar based on the af-magic theme and gleaned colors and things from
# elsewhere. Named torrent for the venerable torrent duck.
#
# Some of the magic here is also taken from this site:
# http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
#
# af-magic.zsh-theme
# Repo: https://github.com/andyfleming/oh-my-zsh
# Direct Link: https://github.com/andyfleming/oh-my-zsh/blob/master/themes/af-magic.zsh-theme
#
# original af-magic prompt. Well not quite original, but original colors. I
# think the $ was originally a ! or something.
#PROMPT='$FG[237]------------------------------------------------------------%{$reset_color%}
#$FG[032]%~\
#$(git_prompt_info) \
#$FG[105]%(!.#.$)%{$reset_color%} '
#PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
#RPS1='${return_code}'

# color vars
eval my_gray='$FG[237]'
eval my_orange='$FG[214]'
eval fino_green='$FG[040]'
eval purple='$FG[135]'
eval red='$FG[RED]'

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
# we're also going to check for changes, even though this could be slow on
# big repos
zstyle ':vcs_info:(hg*|git*):*' check-for-changes true

zstyle ':vcs_info:git*' formats "[%b%u*]"
zstyle ':vcs_info:git*' actionformats "[%b|$fg[red]%a%{$reset_color%}%u*]"

# version control stuff.
zstyle ':vcs_info:hg*' use-simple true
zstyle ':vcs_info:hg*' formats "%{$FG[135]%}(%b%u)"
zstyle ':vcs_info:hg*' actionformats "(hg|%a%u)"
precmd() {
    vcs_info
}

zstyle ':vcs_info:hg*+set-message:*' hooks hg-storerev hg-branchhead

### Store the localrev and global hash for use in other hooks
function +vi-hg-storerev() {
    user_data[localrev]=${hook_com[localrev]}
    user_data[hash]=${hook_com[hash]}
}

### Show marker when the working directory is not on a branch head
# This may indicate that running `hg up` will do something
function +vi-hg-branchhead() {
    local branchheadsfile i_tiphash i_branchname
    local -a branchheads

    local branchheadsfile=${hook_com[base]}/.hg/branchheads.cache

    # Bail out if any mq patches are applied
    [[ -s ${hook_com[base]}/.hg/patches/status ]] && return 0

    if [[ -r ${branchheadsfile} ]] ; then
        while read -r i_tiphash i_branchname ; do
            branchheads+=( $i_tiphash )
        done < ${branchheadsfile}

        if [[ ! ${branchheads[(i)${user_data[hash]}]} -le ${#branchheads} ]] ; then
            hook_com[revision]="${c4}^${c2}${hook_com[revision]}"
        fi
    fi
}


if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# primary prompt
PROMPT='$FG[237]------------------------------------------------------------%{$reset_color%}
${vcs_info_msg_0_}$FG[226]${PWD/#$HOME/~}\
$(git_prompt_info) \
$FG[105]%(!.#.$)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'



# right prompt
if type "virtualenv_prompt_info" > /dev/null
then
	RPROMPT='$(virtualenv_prompt_info)$fino_green%n@%m%{$reset_color%}%'
else
	RPROMPT='$fino_green%n@%m%{$reset_color%}%'
fi

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX=" $FG[075]["
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="$my_orange*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$FG[075]]%{$reset_color%}"
