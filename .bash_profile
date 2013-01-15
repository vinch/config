LS_COLORS="no=00:fi=00:di=01;32:ln=01;33:pi=40;32:so=01;32:do=01;32:bd=40;33;01:cd=40;33;01:or=40;32;01:ex=01;30:*.tar=00:*.tgz=00:*.arj=00:*.taz=00:*.lzh=00:*.zip=00:*.z=00:*.Z=00:*.gz=00:*.bz2=00:*.deb=01;32:*.rpm=01;32:*.jpg=00;32:*.gif=00;32:*.bmp=00;32:*.ppm=00;32:*.tga=00;32:*.xbm=00;32:*.xpm=00;32:*.tif=00;32:*.png=00;32:*.mov=00;32:*.mpg=00;32:*.ogm=00;32:*.avi=00;32:*.fli=00;32:*.gl=01;32:*.dl=01;32:"; 
export LS_COLORS;

if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Colors
if [ -f ~/.dir_colors ]; then
  export LS_OPTIONS='--color=auto'
	eval `gdircolors ~/.dir_colors`
fi

if [ -f /opt/local/etc/bash_completion ]; then
  . /opt/local/etc/bash_completion
fi

# Aliases
alias ll="ls -lhFG"
alias ls="ls -FG"
alias dir="ll"
alias ..='cd ..'
alias ...='cd ../..'
alias ssh='ssh -C'
alias hosts="$EDITOR /etc/hosts"
alias profile="$EDITOR ~/.bash_profile"

RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
LIGHT_BLUE="\[\033[36m\]"
BLUE="\[\033[0;34m\]"
LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;39m\]"
COLOR_NONE="\[\e[0m\]"
 
prompt_end="★ "

function parse_git_dirty {
  if [ -n $1]
    then [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
  fi
}

function parse_git_branch {
  git_status="$(git status 2> /dev/null)"
  pattern="^# On branch ([^${IFS}]*)"
  if [[ ! ${git_status}} =~ "working directory clean" ]]; then
    state="⚡"
  fi

  if [[ ${git_status} =~ ${pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    echo "[${branch}${state}]"
  fi
}

function get_git_branch {
	git branch | awk '/^\*/ { print $2 }'
}

function get_git_dirty {
	git diff --quiet || echo '*'
}

function get_git_prompt {
	git branch &> /dev/null || return 1
	echo "[$(get_git_branch)$(get_git_dirty)] "
}

function parse_git_branch {
  git rev-parse --git-dir &> /dev/null
  git_status="$(git status 2> /dev/null)"
  branch_pattern="^# On branch ([^${IFS}]*)"
  remote_pattern="# Your branch is (.*) of"
  diverge_pattern="# Your branch and (.*) have diverged"

  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      remote="${YELLOW}↑"
    else
      remote="${YELLOW}↓"
    fi
  fi
  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="${YELLOW}↕"
  fi
  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch=${BASH_REMATCH[1]}
    if [[ ! ${git_status}} =~ "working directory clean" ]]; then
      echo "${RED}:${branch}${remote}"
    else
       echo "${GREEN}:${branch}${remote}"
    fi
  fi
}

function prompt_func {
  PS1="${LIGHT_GRAY}❨${LIGHT_BLUE}\w${GREEN}$(parse_git_branch)${LIGHT_GRAY}❩${COLOR_NONE}${YELLOW}${prompt_end}${COLOR_NONE}"
}

PROMPT_COMMAND=prompt_func