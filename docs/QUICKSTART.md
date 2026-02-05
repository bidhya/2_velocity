# Quickstart Guide

This guide will help you get up and running with the 2_velocity project.

## 1. One-Time Setup
1. Create the following directories (MATLAB-generated SLURM job scripts will be stored here):
   - `jobs/Landsat`
   - `jobs/sentinel2`

   If these directories are missing, you will encounter errors such as:
   ```
   Error using fprintf
   Invalid file identifier. Use fopen to generate a valid file identifier.
   ```

   You can create these directories manually:
   ```
   mkdir -p jobs/Landsat jobs/sentinel2
   ```

2. Open MATLAB in the terminal:
   ```
   module load matlab
   matlab -nodesktop
   ```

## 2. Clone the Repository

```
git clone https://github.com/bidhya/2_velocity.git
cd 2_velocity
```

## 3. Project Structure
- `matfiles/` — MATLAB scripts for batch processing and analysis
- `jobs/` — SLURM job scripts created by MATLAB files live here (contents ignored by git).

## 4. Workflow Overview
The project involves generating Surface Displacement Maps (SDMs) at two resolutions: 300m (preprocessing) and 100m (final output). The following steps outline the script execution order:

### **Preprocessing at 300m Grid**
1. **Generate 300m SDM job files**:
   - Script: `batch_pair_find_all_region_sensor_invervaljob.m`
   - `sensor_type`: 1 = Landsat, 2 = Sentinel-2
   - Example:
     ```matlab
     cd matfiles
     batch_pair_find_all_region_sensor_invervaljob(region_start, region_end, year, sensor_type, start_month, end_month)
     batch_pair_find_all_region_sensor_invervaljob(1, 5, 2025, 1, 1, 12)
     ```

2. **Submit the 300m job files**:
   - Script: `job_submit_sbatch.m`
   - Example:
     ```matlab
     job_submit_sbatch(region_start, region_end, year, sensor_type)
     job_submit_sbatch(1, 50, 2025, 1)
     ```

3. **Find good-quality 300m SDMs**:
   - Script: `find_good_vmap_from_insar_all_sensor.m`
   - Example:
     ```matlab
     find_good_vmap_from_insar_all_sensor(region_start, region_end, year, sensor_type)
     find_good_vmap_from_insar_all_sensor(1, 50, 2025, 1)
     ```

4. **Repeat steps 1–3 until no pairs remain**.

### **Processing at 100m Grid**
1. **Generate 100m SDM job files**:
   - Script: `batch_pair_find_all_region_sensor_100.m`
   - `sensor_type`: 1 = Landsat, 2 = Sentinel-2
   - Example:
     ```matlab
     batch_pair_find_all_region_sensor_100(region_start, region_end, year, sensor_type, start_month, end_month)
     batch_pair_find_all_region_sensor_100(1, 50, 2025, 1, 1, 12)
     ```

2. **Submit the 100m job files**:
   - Script: `job_submit_sbatch_100m.m`
   - Example:
     ```matlab
     job_submit_sbatch_100m(region_start, region_end, year, sensor_type)
     job_submit_sbatch_100m(1, 50, 2025, 1)
     ```

3. **Find good-quality 100m SDMs**:
   - Script: `find_good_vmap_from_insar_all_sensor_100m.m`
   - Example:
     ```matlab
     find_good_vmap_from_insar_all_sensor_100m(region_start, region_end, year, sensor_type)
     find_good_vmap_from_insar_all_sensor_100m(1, 50, 2025, 1)
     ```

## 5. Notes
- Ensure SLURM is configured correctly for job submission.
- Refer to the `README.md` file for detailed SDM software usage and additional setup instructions.
- If any required files or scripts are missing, flag them for review and update the workflow accordingly.