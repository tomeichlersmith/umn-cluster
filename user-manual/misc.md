# Tips and Tricks

This is a miscillaneous collection of notes about how to use the cluster we have designed here.

## ssh PubKey Auth
The cluster defaults to using password-based authentication tied together with Duo when attempting
to use `ssh` to connect to a machine. The Duo requirement is lifted when directly logging into a
computer (like a desktop workstation on campus); nevertheless, this security requirement can be
cumbersome for our workflows where we are `ssh`ing to and from machines frequently.

This is where [SSH Public Key Authentication](https://serverpilot.io/docs/how-to-use-ssh-public-key-authentication/)
comes in to save the day. The linked website goes through a very basic set up of SSH public key authentication.
After creating the SSH key, make sure to add it to your _local_ ssh agent with `ssh-add` so that you are not
required to unlock the SSH key everytime you wish to use it.

## How to Use Jupyter
[Jupyter](https://jupyter.org/) is a frequently used platform to do data science and HEP is no exception.
Using Jupyter on the cluster here can be done without too much hassle; however, if the amount of data
you are analyzing is small enough to fit on your desktop/laptop, you will see better response performance
if you simply copy the data there to analyze.

### Start Up
First you need to install various `python` libraries that will allow you to run jupyter.
This should be done _on the cluster_ where jupyter will be run. You will see improved performance of JupyterLab 
if you install it into a python virtual environmenton `/export/scratch`. 
This is because `/export/scratch` is not network mounted.
```
cd /export/scratch/users/
mkdir $USER
cd $USER
python3 -m venv pyvenv --prompt jlab
source pyvenv/bin/activate
pip install --upgrade pip
pip install --upgrade setuptools
pip install --upgrade jupyterlab
```

Next, _on your desktop/laptop_ update the SSH configuration settings to connect the port on the cluster
that jupyter will talk to to the same port on your laptop.
```
# inside of ~/.ssh/config on your desktop/laptop
Host <shortname> :
  User <umn-username>
  HostName <full-computer-name>.spa.umn.edu
  LocalForward 1234 localhost:1234
```

Finally, go to the cluster and launch jupyter to the same port that you put into your SSH configuration.
```
ssh <shortname>
cd <working directory>
# if you installed it to /export/scratch you need to re-enter the python virtual environment
source /export/scratch/users/$USER/pyvenv/bin/activate
jupyter lab --no-browser --port 1234
```
This last command will print out a few links which you can click on and open in the browser on your desktop/laptop.

### Comments
- Ports are shared between all users on a given computer, so the specific port you choose may be used by another person.
  In this case, jupyter will add one to the port number until an available port is found. This will cause you to not be
  able to connect to the jupyter session anymore since your SSH configuration points to one port while jupyter points to
  a different one. You can resolve this by either changing nodes or updating yoru SSH configuration.
- Jupyter runs from within a working directory and makes a lot of I/O operations in order to save progress and render
  images. This means running jupyter from a network-attached filesystem _will_ be noticeably slow. It is suggested to
  put your jupyter notebooks into `/export/scratch/...` and back them up to GitHub similar to other code.

## tmux and It's Extension smux
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
file for later use. I've also isolated it into a POSIX-compliant shell executable [on GitHub](https://github.com/tomeichlersmith/smux).

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

