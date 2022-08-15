# proto-cluster
Testing different configurations and nodes on the cluster.

### Table of Contents
- `job_timing_study.ipynb` : Plots comparing the transfer time to the executing time of different jobs
- `cwd.sub` : Print the current working directory (make sure `EXECUTE` got moved to `/export/scratch/..`)
  - uses `print-details.sh`
- `touch.sub` : Touch a file as the job (make sure job timing stagger is functioning)
- `multicore.sub` : See what happens when a job requests multiple cores
- `sleep.sub` : Submit a simple set of sleep jobs
- wadud : re-running Mohammad's analysis on the new cluster
- logs : logging of what I did while playing with a clean Rocky Linux install
