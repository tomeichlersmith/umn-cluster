# Add Aliases to SSH Config
**Full Reference**: `man ssh_config`
The file at `~/.ssh/config` in Linux and MacOS (I have no idea where it is for Windoze) is helpful for shortening
what you need to type after the `ssh` program on the command line. At its most basic, you can shorten a specific
"host name" to be called something else on your computer.
```
# example section of a ~/.ssh/config
Host umn-cluster
  HostName spa-ssh-01.spa.umn.edu
```
Now, this allows me to type `ssh umn-cluster` which is the same as `ssh spa-ssh-01.spa.umn.edu` on my computer.
Basically, SSH looks through the config file for any `Host` matching what your typed on the command line.
It then applies the settings underneath that `Host`. This allows use to do fancier things like grouping together
servers that share the same settings. A more complicated example config is the one 
[I use](https://gitlab.com/tbeichlersmith/config/-/blob/main/.ssh/config).

#### User
This sets a default username for SSH to use for the host so you don't have to type it on the command line.
```
Host *.spa.umn.edu
  User <username>
```

#### LocalForward
This allows your computer to "share" a specific TCP port with the host.
Most commonly, this is useful for running a JupyterLab instance on the cluster 
and viewing the resulting window on your computer after a connection with the proper port has been made.
```
Host zebra01
  User <username>
  HostName zebra01.spa.umn.edu
  LocalForward 8888 locahost:8888
```

#### ProxyJump
This tells SSH to connect to a specific server before continuing on to the next one.
In our situation, it is helpful to avoid having to SSH twice when connecting from
a non-UMN computer to the cluster.
```
Host zebra01
  User <username>
  HostName zebra01.spa.umn.edu
  ProxyJump spa-ssh-01.spa.umn.edu
```
which means I can simply do `ssh zebra01`. It is important to note that two authentications
are still made so without [PubKey authentication](ssh_pubkey_auth.md), you would still need to type
your password and authenticate with Duo twice.
