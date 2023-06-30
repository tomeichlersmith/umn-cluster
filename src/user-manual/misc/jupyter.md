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

