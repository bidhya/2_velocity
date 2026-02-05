# SDM Workflow Architecture Diagram

```mermaid
graph TD
    A[User Input: Regions, Year, Sensor] --> B["batch_pair_find_all_region_sensor_invervaljob.m\n(300m Job Lists)"]
    B --> C["batch_pair_find_SDM_sensor_intervaljob.m\n(Generates 300m SLURM scripts)"]
    C --> D["job_submit_sbatch.m\n(Submits 300m jobs)"]
    D --> E["find_good_vmap_from_insar_all_sensor.m\n(Filters 300m good SDMs)"]
    E --> F{Repeat 300m Loop?}
    F -->|Yes| B
    F -->|No| G["batch_pair_find_all_region_sensor_100.m\n(100m Job Lists)"]
    G --> H["job_submit_sbatch_100m.m\n(Submits 100m jobs)"]
    H --> I["find_good_vmap_from_insar_all_sensor_100m.m\n(Filters 100m good SDMs)"]
    I --> J[SETSM SDM Processing on HPC]
```

## Overview
- **300m Workflow**: Iterative loop for quality filtering of SDM pairs.
- **100m Workflow**: Final processing at target resolution using good pairs.
- All scripts are in `matfiles/`, with outputs to `jobs/` and HPC paths.