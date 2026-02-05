# SDM Workflow Architecture Diagram

```mermaid
graph TD
    A[User Input: Regions, Year, Sensor] --> B["batch_pair_find_all_region_sensor_invervaljob.m (300m)"]
    B --> C["batch_pair_find_SDM_sensor_intervaljob.m (300m SLURM)"]
    C --> D["job_submit_sbatch.m (Submit 300m)"]
    D --> E["find_good_vmap_from_insar_all_sensor.m (Filter 300m)"]
    E --> F{Repeat 300m?}
    F -->|Yes| B
    F -->|No| G["batch_pair_find_all_region_sensor_100.m (100m)"]
    G --> H["job_submit_sbatch_100m.m (Submit 100m)"]
    H --> I["find_good_vmap_from_insar_all_sensor_100m.m (Filter 100m)"]
    I --> J[SETSM SDM Processing on HPC]
```

## Overview
- **300m Workflow**: Iterative loop for quality filtering of SDM pairs.
- **100m Workflow**: Final processing at target resolution using good pairs.
- All scripts are in `matfiles/`, with outputs to `jobs/` and HPC paths.