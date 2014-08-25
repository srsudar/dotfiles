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


autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
# version control stuff.
zstyle ':vcs_info:hg*' use-simple true
zstyle ':vcs_info:hg*' formats "%{$FG[135]%}(%b%u)"
zstyle ':vcs_info:hg*' actionformats "(hg|%a%u)"
precmd() {
    vcs_info
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


# color vars
eval my_gray='$FG[237]'
eval my_orange='$FG[214]'
eval fino_green='$FG[040]'
eval purple='$FG[135]'

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
