# Quickstart Guide

This guide will help you get up and running with the 2_velocity project.

## 1. Clone the Repository

```
git clone https://github.com/bidhya/2_velocity.git
cd 2_velocity
```

## 2. Project Structure
- `matfiles/` — MATLAB scripts for batch processing and analysis
- `jobs/` — slrum jobs created by matlab files live here (contents ignored by git)

## 3. Steps to run
One time setup  
1. Create jobs/Landsat and jobs/sentinel2 folders
2. Open matlab in terminal
3. batch_pair_find_all_region_sensor_invervaljob.m
    batch_pair_find_all_region_sensor_invervaljob(20, 25, 2025, 1, 12)

## 4. Run MATLAB Scripts
Open MATLAB and run scripts from the `matfiles/` directory for batch processing and velocity map analysis.

