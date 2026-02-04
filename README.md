# SETSM SDM
Surface Displacement Map(SDM) sofware esimates surface displanecements between two time series orthorectified tiff-format images by detecting pixel-based feature displacements. 
SDM is processed based on the method of feature similarity measurement derived from SETSM (Surface Extraction from TIN-based Searchspace Minimization) algorithm.

Please refer SETSM github or homepage for further information.
SETSM homepage, mjremotesensing.wordpress.com/setsm




## Installation instructions 
Please follow SETSM installation steps.




## How to run SDM software
Basic command

```
cd /directory-to-install-in
./setsm -SDM [1 | 2] -projection [ps | utm] -North [0 | 1] -SDM_file 0 -tilesize 10000000 -image [orthorectified image1(*.tif)] -image  [orthorectified image2(*.tif)] -outpath [outpath] -outres [sdm grid size] -sdm_as [average velocity between two input images] -sdm_days [time difference between two input image] -boundary_min_X [min_X] -boundary_max_X [max_X] -boundary_min_Y [min_Y] -boundary_max_Y[max_Y]
```

options

-SDM [1 | 2] : ‘1’ is for without image coregistration, and ‘2’ is for with image coregistration. Strongly recommand to use option '2' for removing potential horizontal misalignment between two orthorectified images caused by sensor accuracy discrepancy.

-projection : This option indicates the projection coordinate system for input and output. 'ps" is for Polar Stereographic projection, and 'utm' is for Universal Transverse Mercator projection.

-North [0 | 1] : '1' is for North regions, and '0' is for South regions.

-SDM_file 0 : default (for testing).

-tilesize [value] : processible tilesize depending on the computing system. If the computing system does not have enough physical memory to handle large amount of memory allocation within one tile procesing, this value [meters in unit] should be reduced to divide the target region into subregions defined by the tilesize. Then, the subregion tiles are merged into one output file at the final step of SDM processing by applying buffer area between tiles. To avoid potential artifacts in the merging processing, it is strongly recommended to use one tile by defining appropirate SDM target area.

-boundary_min_X : minimum X coordinates in meters of the defined input/output projection for SDM target area.

-boundary_max_X : maximum X coordinates in meters of the defined input/output projection for SDM target area.

-boundary_min_X : minimum Y coordinates in meters of the defined input/output projection for SDM target area.

-boundary_min_X : maximum Y coordinates in meters of the defined input/output projection for SDM target area.

-sdm_as [value] : maximum velocity between two input images, meter/day in unit. the value is used to decide an effective kernelsize for similarity measurement and limit maximum velocity in SDM field. if the value is lower than actual velocity, SDM intends to fail to extract correct velocities.

-sdm_days [value] : time difference (temporal baseline) between two input image, days in unit.

-outpath : SDM result path.

-outres : SDM target grid space, meter in unit.

following is the example of the command
```
cd /fs/project/howat.4/SETSM
./setsm -SDM 2 -projection ps -North 1 -SDM_file 0 -tilesize 1000000 -image /fs/project/howat.4-3/howat-data/subset_greenland_rift/orthocorrected/188_Steenby/20230422190844_LO80342472023112LGN00_LO08_L1TP_034247_20230422_20230425_02_T1_ortho.tif -image /fs/project/howat.4-3/howat-data/subset_greenland_rift/orthocorrected/188_Steenby/20230508173030_LC80340012023128LGN00_LC08_L1TP_034001_20230508_20230517_02_T1_ortho.tif -outpath /fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/landsat/188_Steenby/SETSM_SDM_300/vmap_20230422190844_20230508173030 -outres 300 -sdm_as 6.225756 -sdm_days 15.931782 -boundary_min_X -170780 -boundary_max_X -137480 -boundary_min_Y -964940 -boundary_max_Y -880640
```



## Specialized workflow for Greenland SDM processing



### Basics

Our target gridsize (horizontal resolution) of Greenland SDM is 100 meters for both Sentinel and Landsat.

For this project, there are MATLAB scipts to automatically generate SDM jobs, check SDM quality, and submit batch jobs in the SDM github repository.

Current job generation script is using 2016-2017 radarsat velocity maps as reference for deciding an effective kernelsize and limiting maximum velocity field. If surface movements of processing year is rapidly changed compared to the radasat velocity maps, the buffer of 5 for SDM processing should be appropiratly changed before starting processing. The -sdm_as is decided as 'maximum velocity of radarsat + buffer' in both 'batch_pair_find_SDM_sensor_intervaljob.m and batch_pair_find_SDM_goodlist_sensor_100.m'

Radarsat velocity map location:
```
/fs/project/howat.4-3/howat-data/gimp/insar/radarsat/greenland_vel_mosaic200_2016_2017_vel_v2.tif
```

The SDM software has been installed in `/fs/project/howat.4/SETSM`. You do not need to reinstall it. However, you will need to set up your personal `~/.bash_profile` file in order to enable certain dependencies to run (see "Setup" below).



### Setup

- **Setting up .bash_profile for dependencies**: You will need to add the following lines to your `~/.bash_profile` file. Be sure to reload your terminal (`source ~/.bash_profile`) and MATLAB as necessary afterwards.
```
    export LD_LIBRARY_PATH=/fs/project/howat.4/SETSM/lib/tiff-4.0.3/lib:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=/fs/project/howat.4/SETSM/lib/libgeotiff-1.4.2/lib:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=/fs/project/howat.4/SETSM/lib/proj-5.1.0/lib:$LD_LIBRARY_PATH
```

- **Setting up the config file**: Configurable information like folder paths and user email (for error notifications) are set up in the file `get_greenland_config.m`. To create this file, copy and paste `get_greenland_config_TEMPLATE.m`, rename to `get_greenland_config.m`, and change the contents to match your own setup.

- **Creating folder structure**: Most of the working and output folders specified in `greenland_config.m` will be created automatically as the workflow proceeds. However, you will need to make sure that util, scratch and temp directories already exist, as well as the paths to any of the workflow's inputs.



### Processing steps:

This SDM processing involves following steps:

1. **Preprocessing at 300m grid to filter out bad-quality images**: Some locations have very large numbers of pairs to process. To prevent very long run times, we first do a "preprocessing" step at a lower grid resolution, just to filter out bad-quality images.

    1. Generate 300-meter-gridded SDM processing job files (*.sh) for all regions.

        - Example command: `batch_pair_find_all_regions_sensor_intervaljob(1, 192, 2023, 1, 1, 12)`

        - After the script finishes, check the corresponding joblist file (in the example above, `2023_JobList_300m_1 _192_1_12.txt`) to find how many pairs are available and how many pairs will be processed for each region this iteration. If "reprocess_pairs" is more than 0 in the .txt file, the region needs to be processed. (This information is mainly used for monitoring entire SDM procedure, and saved in a Google Sheet.)

    2. Submit the 300m job files by batch for all regions.

        - Example command: `job_submit_sbatch(1, 192, 2023, 1)`

        - Or, if you prefer, you can only process those job files having a "reprocess_pairs" count.
        
        - The script will give you a job ID that will allow you to monitor the status of the job on Unity. After the job completes, check the logfiles it generated to make sure there were no errors. (There may be failed pairs due to not enough matching points - that's to be expected.)

    3. Find good-quality 300m SDMs for each region: `find_good_vmap_from_insar_all_sensor.m`

    4. Rerun steps 1 - 3 until there are no available pairs in the region.

        - The goal is to get 2 good-quality pairs per day. The scripts run 10 pairs per day each iteration attempting to do this. Some of these days may fail because there aren't 2 good-quality pairs in those 10 pairs, so on the next iteration, the script skips those days that already have 2 good-quality pairs, and runs only those days that don't have that many yet, once again running 10 pairs in the attempt to do so.

        - These iterations continue until all days in the specified time interval have at least 2 good quality days (or there are simply no more days to process).

        - In practice, this means that you can stop iterating if:
            - After step 3 of an iteration, all the regions do not have a ‘reprocess_pairs’ count (or 0)...
            ...OR...
            - there are no available pairs in the job file for each region...
            
        - Once iterations are complete, you can go to next step (100m SDM processing).

2. **Processing at 100m grid (the actual output grid size)**

    1. Generate 100-meter-gridded SDM processing job files (*.sh) for all regions based on the list of good quality 300m SDMs derived by step 1.3: `batch_pair_find_all_region_sensor_100.m`

    2. Submit the 100m job files by batch for all regions: `job_submit_sbatch_100m.m`
        - If the jobs are not completed due to insufficient walltime, rerun the jobs.

    4. Find good quality 100m SDMs for each region: `find_good_vmap_from_insar_all_sensor_100m.m`



### Note regarding errors in logs

When reviewing the logfiles generated by this workflow, you will most likely see a significant number of errors mentioning that a file ending in "_dmag.tif" was not found. **This is expected and can be ignored.** (The workflow attempts to find corresponding points between pairs of ortho images; if there are not enough of these points, the "_dmag.tif" file is not generated.)


### Detailed explanations for each MATLAB script :

#### batch_pair_find_SDM_sensor_intervaljob.m

- input variables : region start ID, region end ID, data year, sensor_type, start month, end month

    1. region start and end ID : region range to process

    2. data year : data year for SDM image pairs

    3. sensor_type : '1' is for Landsat, and '2' is for Sentinel

    4. start and end month : data month range for SDM image pairs. 'start month' starts the first day of the month. 'end month' ends the last day of the month
    
    example run,

        batch_pair_find_all_region_sensor_invervaljob(1,192,2023,1,1,12) : generate job files and statistics ranging from region 1 and 192, between Jan and Dec, year 2023, for LandSat orthorectified images

- Editable variables in the script (as opposed to those in `greenland_config.m`):

    1. Under sub-script `batch_pair_find_SDM_sensor_intervaljob`, definition of batch server resources on lines 119 and 122.

- output files 

    1. #year_JobList_300m_#regionstartID_#regionendID_#startmonth_#endmonth.txt : shows statistics of SDMs pairs for each region. The file saved in the 'outpath' defined in line 3 and 15 in the script

        example,

        Region 182  total_pairs 4057    completed_pairs 3105    reprocess_pairs 0   min_TB 7    max_TB 30   result_pairs 769    no_result_pairs 2336    selected_pairs 608

        * total_pairs : total possible SDM pairs in the data pool (Maximum number of SDM pairs)

        * completed_pairs : the number of completed pairs in total. The value is accumulated after each iteration. no more than total_pairs (=result_pairs + no_result_pairs)

        * reprocess_pairs : the number of processing pairs at current iteration.

        * min_TB and max_TB : applied minimum and maximum temporal baseline defined by the reference RADAR velocity map

        * result_pairs : the number of successfully completed pairs with SDM ouput in total

        * no_result_pairs : the number of completed pairs with no SDM output in total

        * selected_pairs : the number of good quality pairs. less than result_pairs

    2. #RegionID_#regionname_job_#year_#startmonth_#endmonth.sh : job files between the region start and end ID. The file saved in the 'outpath' defined in line 3 and 15 in the script

        example for region 188,

        job file name  : 188_Steenby_job_2023_1_12.sh

    3. Job_lists_#year.txt : total possible pair lists with image Id and names. The file saved in the 'out_folder' variable path (it is used for testing. Ignore it)

        example for region 188,
        ```
        pair_count  flag    image1  image2
        1   2   20230426211126_LC90542442023116LGN00_LC09_L1TP_054244_20230426_20230427_02_T1_ortho.tif 20230509212907_LC80572432023129LGN00_LC08_L1TP_057243_20230509_20230517_02_T1_ortho.tif
        2   1   20230427183830_LC90292482023117LGN00_LC09_L1TP_029248_20230427_20230427_02_T1_ortho.tif 20230510185611_LC80322472023130LGN00_LC08_L1TP_032247_20230510_20230518_02_T1_ortho.tif
        3   2   20230427201635_LC90452462023117LGN00_LC09_L1TP_045246_20230427_20230428_02_T1_ortho.tif 20230510203416_LC80482452023130LGN00_LC08_L1TP_048245_20230510_20230518_02_T1_ortho.tif
        4   3   20230428174315_LC90360012023118LGN00_LC09_L1TP_036001_20230428_20230428_02_T1_ortho.tif 20230511180056_LC80232482023131LGN00_LC08_L1TP_023248_20230511_20230518_02_T1_ortho.tif
        5   2   20230428192121_LC90362472023118LGN00_LC09_L1TP_036247_20230428_20230428_02_T1_ortho.tif 20230511193902_LC80392462023131LGN00_LC08_L1TP_039246_20230511_20230518_02_T1_ortho.tif
        ...
        ```
    4. Pair_array_#year.mat and SDM_inverval_Map_#year.mat : The file saved in the 'out_folder' variable path (it is used for testing. Ignore it)


#### job_submit_sbatch.m

- input variables : region start ID, regions end ID, year, sensor_type

    example run,

        job_submit_sbatch(1,192,2023,1) : submit job files for regions from 1 to 192, year 2023, for LandSat. The job files (*.sh) are loaded from 'job_path' defined in line 5 and 13 in the script


#### find_good_vmap_from_insar_all_sensor.m

- input variables : region start ID, region end ID, year, sensor_type

        example run,

            find_good_vmap_from_insar_all_sensor(1,192,2023,1) : generate good SDM list files ranging from region 1 and 192, between Jan and Dec, year 2023, for LandSat orthorectified images

- output files 

    1. #year_goodlist_check_300m_#regionstartID_#regionendID.txt : shows number of good quality SDMs for each region. The file saved in the 'outpath' defined in line 4 and 12 in the script

        example of the txt file,
        ```
        regionID number_of_completed_pairs number_of_good_quality_pairs
        1   3511    702
        2   1098    315
        3   2267    528
        4   3612    977
        5   1967    258
        6   2498    887
        7   1575    431
        ...
        ```

    2. list_good_#year.txt : good quality pair lists at each region. saved in 'out_folder' defined in line 28 and 31 in the script

        example of the txt file,
        ```
        SDM_name statistic_1 statistic_2
        vmap_20230313173117_20230326174930  90.88   17.66
        vmap_20230313173117_20230326183844  86.49   17.66
        vmap_20230313173117_20230326192712  67.57   17.66
        vmap_20230313173117_20230326192735  71.96   17.66
        vmap_20230313173117_20230326201625  51.69   17.66
        vmap_20230313173117_20230327174329  81.76   17.66
        ...
        ```

        * statistic_1 and 2 are threshold for filtering good or bad quality SDMs     


#### batch_pair_find_all_region_sensor_100.m : same as batch_pair_find_SDM_sensor_intervaljob.m

- input variables : region start ID, region end ID, data year, sensor_type, start month, end month

    1. region start and end ID : region range to process

    2. data year : data year for SDM image pairs

    3. sensor_type : '1' is for Landsat, and '2' is for Sentinel

    4. start and end month : data month range for SDM image pairs. 'start month' starts the first day of the month. 'end month' ends the last day of the month
    
    example run,

        batch_pair_find_all_region_sensor_100(1,192,2023,1) : generate job files and statistics ranging from region 1 and 192, between Jan and Dec, year 2023, for LandSat orthorectified images

- Editable variables in the script (as opposed to those in `greenland_config.m`):

    1. Under sub-script `batch_pair_find_SDM_goodlist_sensor_100.m`, definition of batch server resources on line 120.

- output files 

    1. #year_JobList_100m_#regionstartID_#regionendID.txt : shows statistics of SDMs pairs for each region. The file saved in the 'outpath' defined in line 4 and 12 in the script

        example,
        ```
        Region 1    completed pairs 0   reprocess pairs 702 3   30
        Region 2    completed pairs 0   reprocess pairs 315 3   30
        Region 3    completed pairs 0   reprocess pairs 528 3   30
        Region 4    completed pairs 0   reprocess pairs 977 3   30
        Region 5    completed pairs 0   reprocess pairs 258 11  30
        Region 6    completed pairs 0   reprocess pairs 887 10  30
        Region 7    completed pairs 0   reprocess pairs 431 3   30
        ...
        ```

        * completed pairs : the number of completed pairs in total. The value is accumulated after each iteration. 

        * reprocess pairs : the number of processing pairs at current iteration.

        * min_TB and max_TB : applied minimum and maximum temporal baseline defined by the reference RADAR velocity map

        
    2. #RegionID_#regionname_job_100_#year.sh : job files between the region start and end ID 

        example for region 188,

        job file name  : 188_Steenby_job_100_2023.sh


#### job_submit_sbatch_100.m : same as job_submit_sbatch.m

- input variables : region start ID, regions end ID, year, sensor_type

    example run,

        job_submit_sbatch_100(1,192,2023,1) : submit job files for regions from 1 to 192, year 2023, for LandSat. The job files (*.sh) are loaded from 'job_path' defined in line 5 and 13 in the script

- modifiable variable in the script

    1. 'job_path' in line 5 or 13

find_good_vmap_from_insar_all_sensor_100m.m : same as find_good_vmap_from_insar_all_sensor.m

- input variables : region start ID, region end ID, year, sensor_type

        example run,

            find_good_vmap_from_insar_all_sensor_100m(1,192,2023,1) : generate good SDM list files ranging from region 1 and 192, between Jan and Dec, year 2023, for LandSat orthorectified images

- output files 

    1. #year_goodlist_check_100m_#regionstartID_#regionendID.txt : shows number of good quality SDMs for each region. The file saved in the 'outpath' defined in line 4 and 12 in the script

        example of the txt file,
        ```
        regionID number_of_completed_pairs number_of_good_quality_pairs
        1   3511    702
        2   1098    315
        3   2267    528
        4   3612    977
        5   1967    258
        6   2498    887
        7   1575    431
        ...
        ```

    2. list_good_#year.txt : good quality pair lists at each region. saved in 'out_folder' defined in line 28 and 31 in the script (The listed pairs are our final products, and used for further velocity correction and released)

        example of the txt file,
        ```
        SDM_name statistic_1 statistic_2
        vmap_20230313173117_20230326174930  93.24   17.60
        vmap_20230313173117_20230326183844  90.84   17.62
        vmap_20230313173117_20230326192712  77.30   17.62
        vmap_20230313173117_20230326192735  80.01   17.62
        vmap_20230313173117_20230326201625  54.08   17.61
        vmap_20230313173117_20230327174329  89.18   17.62
        ...
        ```

        * statistic_1 and 2 are threshold for filtering good or bad quality SDMs      




## Greenland SDM processing sheet

There is a google sheet summarizing all the SDM generating information for Sentinel and LandSat data . Please update the google sheet if updated. 
https://docs.google.com/spreadsheets/d/1a9JeNvS3l1QnMuoBiSQLvOg_G6w1G86B4w6opIv2Csc/edit#gid=0
