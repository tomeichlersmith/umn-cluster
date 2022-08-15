# container
In this example, we run a singularity container providing it with the command
it should run inside of it corresponding to a specific LDMX workflow.

We use HTCondor's Python API to to the job submission and this python package
provides some helper functions for watching and managing the jobs as well.

### Setup
Install the our wrapper around the python API.
```bash
python3 -m pip install --user python/
```

### Running
Besides the wrapper python package, an executable is also installed to `~/.local/bin` which
(if this is in your `PATH`) you can launch from anywhere.
```bash
submit_jobs --help
```
to list all of the arguments it can receive.
