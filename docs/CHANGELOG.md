# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure with MATLAB scripts for SDM processing
- HPC job submission scripts for SLURM
- Documentation in `docs/` folder (QUICKSTART.md, TROUBLESHOOTING.md)
- Bash script for running MATLAB functions (`run_matlab_script.sh`)
- Architecture diagram (`docs/ARCHITECTURE.md`) visualizing the 300m and 100m workflows

### Changed
- Improved `run_matlab_script.sh` for better MATLAB execution and HPC compatibility
  - Added dynamic script directory to MATLAB path
  - Simplified function call handling
  - Enhanced argument parsing and error handling
  - Updated usage examples and documentation
- Added automatic directory creation in `batch_pair_find_all_region_sensor_invervaljob.m` to prevent file write errors when output paths don't exist

### Fixed
- Various fixes in bash script for calling MATLAB on HPC

### Technical Details
- Project focuses on generating Surface Displacement Maps (SDMs) from Landsat and Sentinel-2 satellite data
- Uses SETSM software for SDM computation
- Two-step workflow: 300m preprocessing followed by 100m final processing
- Automated job generation and submission for HPC clusters

---

## [0.1.0] - 2026-02-05

### Added
- Initial release with core functionality
- MATLAB scripts for batch processing and job management
- Basic documentation and setup guides
- Git repository with clean history