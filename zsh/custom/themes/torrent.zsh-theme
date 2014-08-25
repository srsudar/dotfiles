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


if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# primary prompt
PROMPT='$FG[237]------------------------------------------------------------%{$reset_color%}
$FG[226]${PWD/#$HOME/~}\
$(git_prompt_info) \
$FG[105]%(!.#.$)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'


# color vars
eval my_gray='$FG[237]'
eval my_orange='$FG[214]'
eval fino_green='$FG[040]'

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
