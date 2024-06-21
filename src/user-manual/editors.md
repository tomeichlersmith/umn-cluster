# Editors

Whenever using a remote computing cluster, the natural next question is how to edit the code files.
There are a few options within our cluster and I've roughly separated them into groups based on
how "close" the program is to the files that it is editing.

## on Cluster
Almost as long as terminals have existed, terminal-based editors have existed as well allowing
users to edit files from within a terminal (i.e. without having to spawn a different program
or graphical window).

There are many terminal editors in existence all with their benefits and difficults;
however, there are a few standard ones that exist on all[^1] Linux clusters that you
will interact with.

The two major camps of terminal editors at the time of this writing are [vim](https://www.vim.org/)
and [emacs](https://www.gnu.org/software/emacs/). Both have their quirks and learning
curves; however, I would encourage you to learn the basics of at least one so that you
are not "stuck" after connecting to a remote computer with a desire to edit a text file.

[nano](https://www.nano-editor.org/) is also included and (as the name suggests) is focused
on being "bare-bones" so that it can be included on even the smallest systems. The reason
I mentioned it here is because it is the default editor used when running `git commit`
and so knowing its basics is helpful.
(Sidenote: you can defined the `EDITOR` environment variable to tell `git` and other
programs which text editor you prefer to use. For example, `export EDITOR=vim` in your
`~/.bashrc` file.)

Finally, I want to mention [nvim](https://neovim.io/).
It is installed on the Rocky8 cluster nodes and
is a rewrite of vim focused on modernizing the underlying plugin code. This has made
it more user-friendly in some respects.

[^1]: While I'm certain a hardworking person could find a specific Linux OS that does not
have one or all of these editors, they are the de-facto standard and so are included on
all the major Linux OS's.

## on Cluster Workstations
The workstation desktops within the HEP-CMS offices have a Linux OS installed on them
are and maintained by CSE-IT. This allows them to be shared amongst us users and gives
them direct access to our shared data directory `/local/cms`.

While these workstations being a different OS than more common ones like MacOS and Windoze,
they do offer a graphical user interface (GUI) that can be easier for many first time users
compared to the terminal user interface (TUI) offered by SSH-ing to the cluster from a personal
laptop or computer.

At the time of this writing, we are transitioning from CentOS7 to Rocky8 as the primary OS
installed on these desktops, so the specific GUI editors installed may change.
Just like TUI editors, there are many GUI editors and so I only list a subset of them here.

- [gedit](https://help.gnome.org/users/gedit/stable/)
- [geany](https://www.geany.org/)
- [joe](https://joe-editor.sourceforge.io/)
