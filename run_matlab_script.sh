#!/bin/bash

# This script automates the process of loading MATLAB and running a specific MATLAB script on the HPC.
# Usage: ./run_matlab_script.sh <MATLAB_SCRIPT_NAME> <ARG1> <ARG2> ...

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

# Check if a MATLAB script name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <MATLAB_SCRIPT_NAME> [ARG1] [ARG2] ..."
  exit 1
fi

# Extract the MATLAB script name and shift arguments
MATLAB_SCRIPT_NAME=$1
shift

# Run MATLAB in batch mode with the provided script and arguments
matlab -batch "$MATLAB_SCRIPT_NAME($@)"