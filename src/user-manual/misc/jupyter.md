# How to Use Jupyter

[Jupyter](https://jupyter.org/) is a frequently used platform to do data science and HEP is no exception.
Using Jupyter on the cluster here can be done without too much hassle; however, if the amount of data
you are analyzing is small enough to fit on your desktop/laptop, you will see better response performance
if you simply copy the data there to analyze.

## Start Up
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

## Comments
- Ports are shared between all users on a given computer, so the specific port you choose may be used by another person.
  In this case, jupyter will add one to the port number until an available port is found. This will cause you to not be
  able to connect to the jupyter session anymore since your SSH configuration points to one port while jupyter points to
  a different one. You can resolve this by either changing nodes or updating yoru SSH configuration.
- Jupyter runs from within a working directory and makes a lot of I/O operations in order to save progress and render
  images. This means running jupyter from a network-attached filesystem _will_ be noticeably slow. It is suggested to
  put your jupyter notebooks into `/export/scratch/...` and back them up to GitHub similar to other code.


## Newer Python
There are two methods available on the cluster for obtaining a different version of Python compared to
the version installed at the system level. Either may fit your use case.

Since Jupyter is running on the cluster, the other steps from the start-up section above are not changed.
The only steps that are changed are how jupyter is installed and how it is run.

### CVMFS
The cluster has access to [CVMFS](https://cernvm.cern.ch/fs/) which is a way to distribute pre-built software
that was developed at CERN for the large experiments like CMS.
This is a helpful method because it contains a variety of pre-built Python versions while also allowing you
to have access to the system libraries that do not interfere with this pre-built Python version.
One example is LaTeX: one could use this method to enable plotting using a newer version of matplotlib
(or some other Python package) while also allowing for matplotlib to access the system installation
of `latex` for constructing any equation-based labels.
The major downside of this method is that it is often difficult to find what Python verisons are
available and how to activate them - below is just an example to help guide you and may not work
out of the box.
```
# setup Python 3.9.14 from CVMFS
. /cvmfs/cms.cern.ch/el8_amd64_gcc12/external/python3/3.9.14-4612d00f9f0430a19291545f1e47b4a4/etc/profile.d/init.sh
# initialize a python venv with this python version
python3 -m venv venv
# make sure the original init is always source when the venv is activated
# the follow prepends the source command above into the venv activation file
sed -i.bak \
  '1s|^|. /cvmfs/cms.cern.ch/el8_amd64_gcc12/external/python3/3.9.14-4612d00f9f0430a19291545f1e47b4a4/etc/profile.d/init.sh\n|' \
  venv/bin/activate
```
Then you can install jupyterlab (along with any other python packages you want) after activating the venv.
```
. venv/bin/activate
pip install jupyterlab # and anything else
```
and run it only after activating the venv.
```
. venv/bin/activate
jupyter lab --no-browser --port 1234
```

### Containers
We can use containers in order to aquire a newer python version that isn't currently available on the cluster.
The example below uses [denv](https://tomeichlersmith.github.io/denv) similar to [the case study](../container-case-study/denv.md)
which focused more on using command line tools.

The benefit of using containers is that they provide a truly isolated environment and, specifically for Python,
an image is built for each Python release so you can pick whatever Python release you wish.
No packages from the system clutter the environment which is nice for reproducibility;
however, it may mean you "lose" access to certain packages from the host system (like `latex` in the example above).

Rather than using a virtual environment in `/export/scratch`, we can create a denv within `/export/scratch`
referencing the newest python version available. _Note_: before using `denv` (or any containers), make
sure to move the caching directory to a larger directory than your home (e.g. with `export APPTAINER_CACHEDIR=/export/scratch/users/${USER}`).
```
cd /export/scratch/users/${USER}
denv init python:3 # or whatever version you want https://hub.docker.com/_/python/tags
denv python3 -m pip install --user --upgrade jupyterlab
```

Then, whenever you wish to launch jupyter lab you just need to prefix the program with `denv`.
```
cd /export/scratch/users/${USER}
denv jupyter lab --port 1234
```
