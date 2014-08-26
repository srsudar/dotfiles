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
eval my_purple='$FG[135]'
eval my_red='$fg[red]'
eval el_blue='$FG[075]'  # electric blue
eval my_pink='$FG[201]'
eval bright_green='$FG[082]'
eval my_silver='$FG[195]'

# Fascinating, you can't eval this one. hmm. should figure this out.
git_col=${el_blue}
hg_col=${my_silver}
hg_dirty_col=${bright_green}

eval PR_RESET="%{${reset_color}%}"

# version control stuff.
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg

# we're also going to check for changes, even though this could be slow on
# big repos

### git
zstyle ':vcs_info:git*' check-for-changes true

zstyle ':vcs_info:git*' stagedstr "${my_orange}*${PR_RESET}"
zstyle ':vcs_info:git*' unstagedstr "${my_pink}?${PR_RESET}"

# normal format should be something like:
# [my_branch*]
zstyle ':vcs_info:git*' formats "${git_col}[%b${PR_RESET}%c%u${git_col}]${PR_RESET}"
zstyle ':vcs_info:git*' actionformats "${git_col}[%b${PR_RESET}%c%u|${my_red}%a${PR_RESET}${git_col}]${PR_RESET}"

### end git

### hg
# Do not use use-simple, because it seems to disable the availability of
# dirty flag. Leaving because it can be enabled on a repo-specific level with
# something like: ':vcs_info:hg*:mybigrepo' or something along those lines.
# man 1 zshcontrib to have a look at the syntax.
#zstyle ':vcs_info:hg*' use-simple true
zstyle ':vcs_info:hg*' check-for-changes true

# get-revision seems to have to be true to get the dirty flag available.
# http://www.zsh.org/mla/users/2011/msg00318.html
zstyle ':vcs_info:hg*' get-revision true

# Going to leave the bookmark message here, just commented out, so I maybe
# don't have to look it up next time.
#zstyle ':vcs_info:hg*' get-bookmarks true

# show + symbol if something in the repo has changed. vcs_info doesn't make
# distinctions between untracked and tracked, it seems
zstyle ':vcs_info:hg*' unstagedstr "${hg_dirty_col}*${PR_RESET}"

# hg doesn't support stagedstr 
# http://www.zsh.org/mla/users/2011/msg00319.html

# only show branch, not hash and local rev
zstyle ':vcs_info:hg*:*' branchformat "%b"

# regular format should show something like:
# (default+)
zstyle ':vcs_info:hg*' formats "${hg_col}(%b${PR_RESET}%c%u${hg_col})${PR_RESET}"

# Action format should show something like:
# (default+|merging)
zstyle ':vcs_info:hg*' actionformats "${hg_col}(%b${PR_RESET}%c%u|${my_red}%a${PR_RESET}${hg_col})${PR_RESET}"

### end hg


precmd() {
    vcs_info
}

# Trying to add hook to show if not on a head:
# http://eseth.org/2010/hg-in-zsh.html
#zstyle ':vcs_info:hg*+set-message:*' hooks hg-storerev hg-branchhead

### Store the localrev and global hash for use in other hooks
#function +vi-hg-storerev() {
    #user_data[localrev]=${hook_com[localrev]}
    #user_data[hash]=${hook_com[hash]}
#}

### Show marker when the working directory is not on a branch head
# This may indicate that running `hg up` will do something
#function +vi-hg-branchhead() {
    #local branchheadsfile i_tiphash i_branchname
    #local -a branchheads

    #local branchheadsfile=${hook_com[base]}/.hg/branchheads.cache

    ## Bail out if any mq patches are applied
    #[[ -s ${hook_com[base]}/.hg/patches/status ]] && return 0

    #if [[ -r ${branchheadsfile} ]] ; then
        #while read -r i_tiphash i_branchname ; do
            #branchheads+=( $i_tiphash )
        #done < ${branchheadsfile}

        #if [[ ! ${branchheads[(i)${user_data[hash]}]} -le ${#branchheads} ]] ; then
            #hook_com[revision]="${c4}^${c2}${hook_com[revision]}"
        #fi
    #fi
#}


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
