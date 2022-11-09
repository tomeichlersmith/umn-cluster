# New Cluster User
We always forget how to get new users started because we only ever have to do it once.

This page has manual notes on the process as of Fall 2022.
The time is important because the start-up process may change if the cluster backend changes.

### 0. Get a UMN Internet Account
For UMN students (grad or undergrad), this is automatic. For summer students, this may take a few days of paperwork.

**Test**: You have a UMN email and/or a UMN student ID.

### 1. Activate SPA Computing Account
Email `csehelp@umn.edu` and ask them to activiate your SPA computing account.
Provide the following information in your email:
- Which professor is your advisor (they may want to double-check with that person if they can't find your name in their system)
- That you would like a SPA computing account and have access to the "SPA OSG cluster" (that's their name for this cluster)

**Test**: You can SSH to the general-access node with your UMN credentials.
```
ssh <username>@spa-ssh-01.spa.umn.edu
```
_Note_: New users may be unfamiliar with SSH and so should be assisted in the test.

### 2. Access SPA OSG Cluster
In some instances in the past, CSE IT has not added the new user to the necessary computing groups to access the cluster.
This step merely consists of emailing `csehelp@umn.edu` again and re-asking for access to the cluster.

**Test**: You can SSH to a cluster node with your UMN credentials.
```
ssh <username>@spa-osg-login.spa.umn.edu
```
_Note_: If you are off campus, you will need to connect to the general-access node first, and then SSH again.

**Alternative Test**: You can log-in to one of the interactive desktops in the HEP-CMS offices.

## Quality of Life Improvements
This section is optional and is only helpful if you are frequently connecting to the cluster from a non-UMN computer.

### Setup SSH PubKey Authentication
The whole point of this authentication style is to avoid typing your password (and in our case, using Duo)
when attempting to establish an SSH connection.

1. Generate a SSH key: `ssh-keygen -t ed25519`
2. Copy that SSH key to our cluster: `ssh-copy-id <username>@spa-ssh-01.spa.umn.edu`

#### An Extended Aside About SSH Key Passwords
SSH keys can be password-locked to prevent anyone who gains access to your computer from using the SSH key to pretend to be you.
Password-locking is achieved by providing a non-empty password when generating the key.
Locking the SSH key _without any additional steps_, then means you have to unlock it everytime you wish to use it.
This still avoids the Duo step for us, but typing a password each time an SSH connection needs to be establish can become tedious.
This tedium is not new and so SSH Agents were born. These allow you to unlock an SSH key once and they stay unlocked until
the computer itself is turned off. This allows you to safely lock your SSH keys while also only having to type in a password
once-in-a-while. SSH Agents are complicated and so I do not try to explain how to set them up here. My best advice is to 
search online for "SSH Agent _your operating system_" to find some advice from more knowledgeable people.

All this being said, you can avoid this rigamarole by creating a password-less SSH key.
I am obligated to say that **this is not recommended** due to the security risk.

### Add Aliases to SSH Config
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
are still made so without PubKey authentication (above), you would still need to type
your password and authenticate with Duo twice.
