####################################################################################################
# umn-server/env.sh
#   Environment script for interacting with UMN SPA cluster containers
####################################################################################################

# move cache dire to larger /export/scratch
export SINGULARITY_CACHEDIR=/export/scratch/users/$USER/.singularity

__umn_spa_cluster_instance_start__() {
  singularity instance start \
    --no-home \
    --cleanenv \
    --env SLURM_CPUS_ON_NODE=1 \
    --fakeroot \
    $@
  return $?
}

__umn_spa_cluster_up__() {
  local version=$1
  __umn_spa_cluster_instance_start__ --net --network-args "portmap=6817:6817/tcp,6818:1818/tcp,6819:6819/tcp" docker://tomeichlersmith/umn-server:master${version:+-$version} master || return $?
  __umn_spa_cluster_instance_start__ docker://tomeichlersmith/umn-server:node${version:+-$version} node1 || return $?
  __umn_spa_cluster_instance_start__ docker://tomeichlersmith/umn-server:node${version:+-$version} node2 || return $?
  __umn_spa_cluster_instance_start__ --net --network-args "portmap=8888:8888/tcp" docker://tomeichlersmith/umn-server:jupyter${version:+-$version} jupyter || return $?
}

__umn_spa_cluster_dn__() {
  singularity instance stop --all
}
