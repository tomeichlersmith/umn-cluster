# Container Case Study: denv

This case study is focused on explaining how one can use [denv](https://tomeichlersmith.github.io/denv/)
on the cluster to simplify handling of dependencies you wish to use for different projects.
One of the main issues I run into regularly is the fact that the system install of python is a
very old version and I want to use python packages that require newer python versions.

This document assumes you've followed the instructions on the denv website on installing it.
`denv` is a very light (~21K) file that can be kept in your home directory so it is accessible
from everywhere on the cluster.

Just for comparison, there is a default installation of python available.
```
eichl008@spa-osg-login ~> python3
Python 3.6.8 (default, Jun 22 2023, 05:10:43) 
[GCC 8.5.0 20210514 (Red Hat 8.5.0-18)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> quit()
```

## Basics
Let's jump to the newest python available by using `denv`.
```
eichl008@spa-osg-login ~> mkdir /export/scratch/users/${USER}
eichl008@spa-osg-login ~> cd /export/scratch/users/${USER}
eichl008@spa-osg-login ~> denv init python:3
# download output is omitted
eichl008@spa-osg-login /export/scratch/users/eichl008> denv python3
Python 3.12.0 (main, Nov 21 2023, 17:38:35) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> quit()
```
Now that the `python:3` image has been downloaded on the `spa-osg-login` node,
it will stay available unless the directory the denv is in is removed.
`denv` chooses to mount the workspace directory (where you ran `denv init`) as
the home directory within the container, so you can install python packages as
a normal user within the denv and they will be available upon future connections.
```
eichl008@spa-osg-login /export/scratch/users/eichl008> denv python3
Python 3.12.0 (main, Nov 21 2023, 17:38:35) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ModuleNotFoundError: No module named 'numpy'
>>> quit()
eichl008@spa-osg-login /export/scratch/users/eichl008> denv python3 -m pip install --user numpy
# installation output is omitted
eichl008@spa-osg-login /export/scratch/users/eichl008> denv python3
Python 3.12.0 (main, Nov 21 2023, 17:38:35) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy
>>> quit()
```
The final feature of `denv` that I should point out is that you can enter a shell if you don't provide a command
for it to run within the containerized environment. This is helpful if you need to do more complicated tasks that
require a series of commands.
```
eichl008@spa-osg-login /export/scratch/users/eichl008> denv
eichl008@eichl008:~$ python3 --version
Python 3.12.0
```
`denv` chooses to change the hostname to align with the workspace it is attached to which in this
case means it is the same as my username. One can change this name with the `--name` flag to `denv init`
(or use a more helpful directory name for the workspace).

## Additional Mounts
`denv` can also add other mounts to be attached to the container when running. If I am using a denv to
read or write data within our group directory, I can mount it so that I don't have to perform an extra
copy outside of the denv.
```
# from within the denv workspace
denv mount /local/cms/user/${USER}
```
