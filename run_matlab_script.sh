#!/bin/bash

# This script automates the process of loading MATLAB and running a specific MATLAB script on the HPC.
# Usage: ./run_matlab_script.sh <MATLAB_SCRIPT_NAME> <ARG1> <ARG2> ...
#
# Example:
# To run the MATLAB script `batch_pair_find_all_region_sensor_invervaljob.m` located in the `matfiles` subfolder with arguments 1, 5, 2025, 1, 1, 12:
# ./run_matlab_script.sh matfiles/batch_pair_find_all_region_sensor_invervaljob 1 5 2025 1 1 12
#
# To run the MATLAB script `job_submit_sbatch.m` located in the `matfiles` subfolder with arguments 1, 50, 2025, 1:
# ./run_matlab_script.sh matfiles/job_submit_sbatch 1 50 2025 1
#
# To run the MATLAB script `find_good_vmap_from_insar_all_sensor.m` located in the `matfiles` subfolder with arguments 1, 50, 2025, 1:
# ./run_matlab_script.sh matfiles/find_good_vmap_from_insar_all_sensor 1 50 2025 1

# Load MATLAB module
module load matlab

# Extract directory and function name
DIR=$(dirname "$1")
FUNC=$(basename "$1" .m)  # Remove .m extension if present

# Build argument list
shift
if [ $# -gt 0 ]; then
    ARGS=$(printf '%s,' "$@")
    ARGS=${ARGS%,}  # Remove trailing comma
    CALL="$FUNC($ARGS)"
else
    CALL="$FUNC"
fi

# Change to the script's directory and run MATLAB
cd "$DIR" || exit 1
matlab -batch "$CALL"