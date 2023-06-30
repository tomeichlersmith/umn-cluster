# tmux and It's Extension smux

`tmux` is short for Terminal MUltipleXer and, conceptually, lets you "split" one terminal into many different terminals.
It is a _very_ powerful program with a lot of different features, below I have simply listed two resources I've found
helpful.
- [tmux Cheat Sheet](https://tmuxcheatsheet.com/) for remembering how to do certain things
- [tmux Wiki](https://github.com/tmux/tmux/wiki/Getting-Started) on GitHub is helpful for learnign the vocabulary and how to use it

One of the features that `tmux` offers is the ability to "detach" from a terminal session and allow the program to continue running
in the background. This is very helpful when connected with ssh, allowing us to go to the cluster, start a program that takes
a long time to run, detach from that terminal, disconnect from ssh, and only reconnect when we want to check on our long-running
program. This ssh+tmux workflow is so common for me that I wrote a small bash wrapper connecting the two called `smux`.

Below, I have copied the bash code which I've been using for a few years now. Feel free to put it in your `.bashrc` or some other
file for later use. I've also isolated it into a POSIX-compliant shell executable [on GitHub](https://github.com/tomeichlersmith/smux)
which is light enough to install into your home directory pretty much anywhere.
```
curl -s https://raw.githubusercontent.com/tomeichlersmith/smux/main/install | sh 
```

### smux
```bash
#!/bin/bash

# ssh+tmux = smux

__smux_help() {
  cat <<\HELP

  Using ssh and tmux on remote computers.

  NOTE: <TAB> completion for smux only works after it is attempted for ssh.

 USAGE: 
  smux [-h|--help] [-l|--list] <host> [session]

 OPTIONS:
  -h|--help : print this help and exit
  -l|--list : list the sessions on the input host and exit

 ARGUMENTS:
  host      : (required) hostname of computer you wish to attach to
  session   : (optional) name of session to attach to on the input host 

HELP
}
__smux_list() {
  local _host="$1" #required
  ssh -t ${_host} "tmux ls 2> /dev/null"
  return $?
}
__smux_attach() {
  local _host="$1" #required
  local _session="$2" #optional
  ssh -t ${_host} "tmux attach ${_session:+-t} ${_session} || tmux new ${_session:+-s} ${_session}"
  return $?
}
smux() {
  case "$1" in
    ""|-h|--help)
      __smux_help
      return 0
      ;;
    -l|--list)
      __smux_list "$2"
      return 0
      ;;    
    -*)
      echo "ERR: Unknown option $1"
      return 1
      ;;
  esac
  
  __smux_attach "$1" "$2"
  return $?
}

__complete_smux() {
  if ! hash _ssh &> /dev/null; then
    # __load_completion is a bash internal that is used
    #   to expand the tab completion set of functions if
    #   no function is defined
    #   it defines the ssh completion function _ssh
    __load_completion ssh || return $?
  fi 

  # disable readline filename completion
  compopt +o default

  local __curr_word="${COMP_WORDS[$COMP_CWORD]}"

  if [[ "$COMP_CWORD" == "1" ]]; then
    if [[ "${__curr_word}" == -* ]]; then
      # option
      COMPREPLY=($(compgen -W "-h --help -l --list" -- "${__curr_word}"))
    else
      # host, use ssh tab completion
      _ssh
      return $?
    fi
  else
    case "${COMP_WORDS[1]}" in
      -l|--list)
        # shift inputs so _ssh tab complete works
        COMP_WORDS=(${COMP_WORDS[@]:1})
        COMP_CWORD=$((COMP_CWORD - 1))
        _ssh
        return $?
        ;;
      *)
        # no other tab complete implemented,
        #   we /could/ try tab completing tmux sessions on the host
        #   that is already selected, but that would make tab complete
        #   slow since it would have to ssh there to find out the list
        COMPREPLY=()
        ;;
    esac
  fi
}
complete -F __complete_smux smux
```

