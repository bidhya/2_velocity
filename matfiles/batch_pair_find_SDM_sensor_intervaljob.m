function [out] = batch_pair_find_SDM_sensor_intervaljob(sensor,ID_roi,range_dt,grid,minmax_t,year,monthrange)

[~,host_name]=system('hostname');

if sensor == 1 %Landsat
    %old path
    %param.path.subset='/fs/project/howat.4-3/howat-data/subset_greenland_rift/orthocorrected';
    
    %Mike path
    %param.path.subset='/fs/project/howat.4/gravina.2/greenland_glacier_flow/1_download_merge_and_clip/landsat';
    
    %Bidhya path
    param.path.subset='/fs/project/howat.4-3/greenland_glacier_flow/1_download_merge_and_clip/landsat';
    
    %SDM output path
    param.path.result='/fs/project/howat.4/yadav.111/greenland_glacier_flow/2_velocity/landsat_sdm';
    
    %Reference insar path
    param.path.insar='/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/landsat';
else %Sentinel
    %old path
    %param.path.subset='/fs/project/howat.4/sentinel2/clipped2';
    
    %Mike path
    %param.path.subset='/fs/project/howat.4/gravina.2/greenland_glacier_flow/1_download_merge_and_clip/sentinel2';
    
    %Bidhya path
    param.path.subset='/fs/project/howat.4-3/greenland_glacier_flow/1_download_merge_and_clip/sentinel2';
    
    %SDM ouput path
    param.path.result='/fs/project/howat.4/yadav.111/greenland_glacier_flow/2_velocity/sentinel2_sdm';
    
    %Reference insar path
    param.path.insar='/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/landsat';
end

path_subset_root=param.path.subset;
file_region_BR = '/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/glaciers_roi_proj_v2_300m.txt';

%find the region name
string_regionname=dir([path_subset_root,'/',num2str(ID_roi,'%03d'),'*']);

if sensor == 1 %Landsat
    out_folder = [param.path.result,'/',string_regionname.name,'/SETSM_SDM_300']
else %Sentinel
    out_folder = [param.path.result,'/',string_regionname.name,'/SETSM_SDM_300_new']
end

out_folder_2 = [param.path.result,'/',string_regionname.name];
if ~exist(out_folder,'dir')
    [status, msg] = mkdir(out_folder);
end

%insar infor load for estimating minimum required temporal baseline
insar_file = [param.path.insar,'/',string_regionname.name,'/SETSM_SDM_100/SDM_insar.mat'];
IS = load(insar_file);
Max_sp = max(IS.Rz(:))

if sensor == 1
    MDPP = ceil(15.0/Max_sp);
else
    MDPP = ceil(10.0/Max_sp);
end

if MDPP < 3
    MDPP = 3;
end

datediff_min = MDPP;

if datediff_min < range_dt(1)
    datediff_min = range_dt(1);
end

datediff_max = MDPP + range_dt(2);
if datediff_max > 30
    datediff_max = 30;
end

if ID_roi == 90
    datediff_max = 15;
end

disp(['Temporal baseline designated by insar m/d: [',num2str(datediff_min),', ',num2str(datediff_max),'] days']);

%define region SDM boundary
BR_check = 0;
if exist(file_region_BR,'file')
    BR_file = fopen(file_region_BR,'r');
    BR = textscan(BR_file,'%s\t%d\t%d\t%d\t%d\n');
    BR_region(1) = BR{2}(ID_roi);
    BR_region(2) = BR{3}(ID_roi);
    BR_region(3) = BR{4}(ID_roi);
    BR_region(4) = BR{5}(ID_roi);
    BR_check = 1;
    fclose(BR_file);
end

%load selected SDM pairs from list_good.txt file
check_list_file = 0;
list_file = sprintf('%s/list_good_%d.txt',out_folder,year)
%list_file = sprintf('%s/list_good_%d_no.txt',out_folder,year)
if exist(list_file,'file')
    file = fopen(list_file);
    glist = textscan(file,'%s\t%f\t%f')
    glist_s = numel(glist{1})
    glist_c=zeros([glist_s,1]);
    check_list_file = 1;
    fclose(file);
end
%check_list_file = 0;
%generate SDM job file *.sh
if sensor == 1
    jobfilepath = sprintf('/home/yadav.111/Github/2_velocity/jobs/Landsat/%s_job_%d_%d_%d.sh',string_regionname.name,year,monthrange(1),monthrange(2));
else
    jobfilepath = sprintf('/home/yadav.111/Github/2_velocity/jobs/sentinel2/%s_job_%d_%d_%d.sh',string_regionname.name,year,monthrange(1),monthrange(2));
end

fid = fopen(jobfilepath,'w');

if sensor == 1
        str = sprintf('#!/usr/bin/env bash\n#SBATCH --time=140:00:00\n#SBATCH -N 1 -n 24\n#SBATCH --mem=20G\n#SBATCH --job-name="SDM_%d"\n#SBATCH --mail-user=yadav.111@osu.edu\n#SBATCH -p batch\n#SBATCH --output=%s_%d_%d_%d_landsat.log\n\nmodule load intel/2024.2.0\nexport COMPILER=intel\ncd /fs/project/howat.4/SETSM\n',ID_roi,string_regionname.name,year,monthrange(1),monthrange(2));
        fprintf(fid,str);
else
        str = sprintf('#!/usr/bin/env bash\n#SBATCH --time=140:00:00\n#SBATCH -N 1 -n 24\n#SBATCH --mem=20G\n#SBATCH --job-name="SDM_%d"\n#SBATCH --mail-user=yadav.111@osu.edu\n#SBATCH -p batch\n#SBATCH --output=%s_%d_%d_%d_sentinel.log\n\nmodule load intel/2024.2.0\nexport COMPILER=intel\ncd /fs/project/howat.4/SETSM\n',ID_roi,string_regionname.name,year,monthrange(1),monthrange(2));
        fprintf(fid,str);
end

%find orthoimages from subset folder
path_subset=[path_subset_root,'/',string_regionname.name];

if sensor == 1
    list_subset=[dir([path_subset,'/*ortho.tif']);dir([path_subset,'/*pct.tif'])];
else
    path_subset=[path_subset_root,'/',string_regionname.name,'/clipped']; %temporary
    list_subset=dir([path_subset,'/*.tif']);
end

num_subset=numel(list_subset);

vec_time=zeros([num_subset,1]);
vec_path=zeros([num_subset,1]);
vec_row=zeros([num_subset,1]);
mtrx_datediff=zeros([num_subset,num_subset])/0;
center_datediff=zeros([num_subset,num_subset])/0;
ts = sprintf('%d',year);
startdatenum = datenum(ts,'yyyy')

for cnt=1:num_subset
    t_str = list_subset(cnt).name;

    if strcmp('._',t_str(1:2))
        t_size = size(list_subset(cnt).name);
        temp = list_subset(cnt).name(3:t_size(2));
        list_subset(cnt).name = temp;
    end

    if sensor == 1
        vec_time(cnt)=datenum(list_subset(cnt).name(1:14),'yyyymmddHHMMSS');
        vec_path(cnt)=str2num(list_subset(cnt).name(19:21));
        vec_row(cnt)=str2num(list_subset(cnt).name(22:24));
    else
        vec_time(cnt)=datenum(list_subset(cnt).name(12:22),'yyyymmddTHH');
    end
end

%determine the valid image pairs
f_pairs = sprintf('%s/Pair_array_%d.mat',out_folder,year);
f_pairs = sprintf('%s/Pair_array_%d_no.mat',out_folder,year);
if exist(f_pairs,'file')
    load(f_pairs);
else
    for cnt=1:num_subset
        max_pair_number = 50;
        count_pair_number = 1;
        cnt1 = cnt+1;
        while cnt1 <= num_subset && count_pair_number < max_pair_number
            datediff=vec_time(cnt1)-vec_time(cnt);
            
            if sensor == 1
                year1 = str2num(list_subset(cnt).name(1:4));
                year2 = str2num(list_subset(cnt1).name(1:4));
            else
                year1 = str2num(list_subset(cnt).name(12:15));
                year2 = str2num(list_subset(cnt1).name(12:15));
            end

            if round(datediff)>=datediff_min && round(datediff)<=datediff_max && abs(datediff-round(datediff))<4/24 && year1 == year && year2 == year
                if sensor == 1
                    if isLandsat(list_subset(cnt).name) && isLandsat(list_subset(cnt1).name)
                        mtrx_datediff(cnt,cnt1)=datediff;
                        center_datediff(cnt,cnt1)= round(vec_time(cnt) + datediff/2) - startdatenum;
                        count_pair_number = count_pair_number + 1; 
                    end
                else
                    if isSentinel(list_subset(cnt).name) && isSentinel(list_subset(cnt1).name)
                        mtrx_datediff(cnt,cnt1)=datediff;
                        center_datediff(cnt,cnt1)= round(vec_time(cnt) + datediff/2) - startdatenum;
                        count_pair_number = count_pair_number + 1;
                    end
                end
                
            end
            cnt1 = cnt1 + 1;
        end
    end

    mtrx_datediff(mtrx_datediff>=datediff_max | mtrx_datediff<=datediff_min)=0/0;

    [gt1,gt0]=meshgrid(1:num_subset,1:num_subset);

    ID_i0=gt0(~isnan(mtrx_datediff));
    ID_i1=gt1(~isnan(mtrx_datediff));
    pair_date = center_datediff(~isnan(mtrx_datediff));
    pair_TB = mtrx_datediff(~isnan(mtrx_datediff));
    %%

    pair_array = [ID_i0 ID_i1 pair_date pair_TB];
    pair_array_sort = sortrows(pair_array,4);
    ID_i0 = pair_array_sort(:,1);
    ID_i1 = pair_array_sort(:,2);
    pair_date = pair_array_sort(:,3);
    pair_TB = pair_array_sort(:,4);

    f_pairs = sprintf('%s/Pair_array_%d.mat',out_folder,year);
    save(f_pairs,'ID_i0','ID_i1','pair_date','pair_TB');
    clear gt0 gt1 pair_array_sort pair_array;
end

Job_lists_file = sprintf('%s/Job_lists_%d.txt',out_folder,year)
Job_lists_file = sprintf('%s/Job_lists_%d_no.txt',out_folder,year)
check_job_lists = 0;
if exist(Job_lists_file,'file')
    check_job_lists = 1;
    file_t = fopen(Job_lists_file,'r');
    glist_j = textscan(file_t,'%d\t%d\t%s\t%s\n')
    glist_js = numel(glist_j{1})
    glist_jc=zeros([glist_js,1]);  

    idx_pos = glist_j{1};
    idx_q = glist_j{2};

    index_q = find(idx_q == 1);
    index_c = find(idx_q == 2);
    index_b = find(idx_q == 3);
    index_n = find(idx_q == 4);    
    index_p = find(idx_q ~= 4);
    image_ID0 = glist_j{3}(index_n);
    image_ID1 = glist_j{4}(index_n);
    index_pos = idx_pos(index_n);
    fclose(file_t);
end

if check_job_lists == 1
    num_pair=size(index_n,1);
else
    num_pair=numel(ID_i0);
end

%[index_date check_QC_cal_date save_TB_QC check_cal_date save_TB_cal NumP NumR NumC NumB NumQ];
Interval_file = sprintf('%s/SDM_interval_Map_%d.mat',out_folder,year)
Interval_file = sprintf('%s/SDM_interval_Map_%d_no.mat',out_folder,year)
Num_file = sprintf('%s/SDM_num_%d.mat',out_folder,year)
Num_file = sprintf('%s/SDM_num_%d_no.mat',out_folder,year)
if exist(Interval_file,'file') && check_job_lists == 1
    load(Interval_file);
    load(Num_file);
    check_QC_cal_date = check_date(:,2);
    NumP = Numcount(1)
    NumR = 0;%check_date(:,7);
    NumC = Numcount(3)
    NumB = Numcount(4)
    NumQ = Numcount(5)
else
    check_QC_cal_date = zeros(365,1);
    NumP = 0;
    NumR = 0;
    NumB = 0;
    NumQ = 0;
    NumC = 0;
end
clear check_date;

check_cal_date = zeros(365,1);
save_TB_cal= zeros(365,1);
save_TB_QC = zeros(365,1);

disp([num2str(num_pair),' pair(s) found.']);
vec_t=zeros(size(ID_i0));
num_select = 0;

Job_lists_file2 = sprintf('%s/Job_lists_%d.txt',out_folder,year)
fid_job = fopen(Job_lists_file2,'w');

for cnt=1:num_pair
    if check_job_lists == 1
        %cnt = idx_pos(cnt);
        name_i0 = char(image_ID0(cnt));
        name_i1 = char(image_ID1(cnt));
        cnt = index_pos(cnt);
    else
        name_i0=list_subset(ID_i0(cnt)).name;
        name_i1=list_subset(ID_i1(cnt)).name;
    end

    if sensor == 1
        t0=datenum(name_i0(1:14),'yyyymmddHHMMSS');
        t1=datenum(name_i1(1:14),'yyyymmddHHMMSS');
    else  
        t0=datenum(name_i0(12:22),'yyyymmddTHH');
        t1=datenum(name_i1(12:22),'yyyymmddTHH');
    end

    days = t1 - t0;
    days = pair_TB(cnt);

    if sensor == 1
        result_path = [out_folder,'/vmap_',name_i0(1:14),'_',name_i1(1:14)];
        result_file = [out_folder,'/vmap_',name_i0(1:14),'_',name_i1(1:14),'/vmap_',name_i0(1:14),'_',name_i1(1:14),'_dmag.tif'];
        result_file_GCPs = [out_folder,'/vmap_',name_i0(1:14),'_',name_i1(1:14),'/GCPs_1.tif'];
        result_file_mask = [out_folder,'/vmap_',name_i0(1:14),'_',name_i1(1:14),'/vmap_',name_i0(1:14),'_',name_i1(1:14),'_mask.tif'];
        result_file_2 = [out_folder_2,'/vmap_',name_i0(1:14),'_',name_i1(1:14),'/vmap_',name_i0(1:14),'_',name_i1(1:14),'_dmag.tif'];
    else
        result_path = [out_folder,'/vmap_',name_i0(1:22),'_',name_i1(1:22)];
        result_file = [out_folder,'/vmap_',name_i0(1:22),'_',name_i1(1:22),'/vmap_',name_i0(1:22),'_',name_i1(1:22),'_dmag.tif'];
        result_file_GCPs = [out_folder,'/vmap_',name_i0(1:22),'_',name_i1(1:22),'/GCPs_1.tif'];
        result_file_mask = [out_folder,'/vmap_',name_i0(1:22),'_',name_i1(1:22),'/vmap_',name_i0(1:22),'_',name_i1(1:22),'_mask.tif'];
        result_file_2 = [out_folder_2,'/vmap_',name_i0(1:22),'_',name_i1(1:22),'/vmap_',name_i0(1:22),'_',name_i1(1:22),'_dmag.tif'];
    end

    timestamp_vmap=(t0+t1)/2;

    if timestamp_vmap<minmax_t(1) || timestamp_vmap>minmax_t(2)
        %disp('vmap out of temporal range. Skipping');
        %fprintf(fid_job,'%d\t2\t%s\t%s\n',cnt,name_i0,name_i1);
        %timestamp_vmap - startdatenum
        %name_i0
        %name_i1
        %pair_date(cnt)
        %continue;
    else
        count = 1;
        list_check = 0;
        if check_list_file == 1
            while count <= glist_s && list_check == 0
                %count
                if sensor == 1
                    vmap_name = ['vmap_',name_i0(1:14),'_',name_i1(1:14)];
                else
                    vmap_name = ['vmap_',name_i0(1:22),'_',name_i1(1:22)];
                end

                %glist{1}(count)
                if strcmp(vmap_name,glist{1}(count))
                    if exist(result_file_mask,'file') && exist(result_file,'file')
                        %disp('Already processed without mask. add job');
                        %disp(['selected vmap ',vmap_name]);
                        list_check = 1; 
                        NumP = NumP + 1;
                        NumQ = NumQ + 1;
                        NumC = NumC + 1;
                        check_cal_date(pair_date(cnt)) = check_cal_date(pair_date(cnt)) + 1;
                        check_QC_cal_date(pair_date(cnt)) = check_QC_cal_date(pair_date(cnt)) + 1;
                        save_TB_QC(pair_date(cnt)) = days;

                        fprintf(fid_job,'%d\t1\t%s\t%s\n',cnt,name_i0,name_i1);
                    end
                end
                count = count + 1;
            end
        end

        if list_check == 0
            if exist(result_file,'file')
                NumP = NumP + 1;
                NumC = NumC + 1;
                fprintf(fid_job,'%d\t2\t%s\t%s\n',cnt,name_i0,name_i1);
                %disp('Already processed. Skipping the process');
            %elseif exist(result_file_2,'file')
            %    NumP = NumP + 1;
            elseif exist(result_file_GCPs,'file')
                NumP = NumP + 1;
                NumB = NumB + 1;
                fprintf(fid_job,'%d\t3\t%s\t%s\n',cnt,name_i0,name_i1);
                %disp('no result');
                %result_file_GCPs
            elseif check_cal_date(pair_date(cnt)) < 10 && check_QC_cal_date(pair_date(cnt)) < 2  %total 10 jobs and 2 sucessful results 
            %elseif check_cal_date(pair_date(cnt)) < 30 && check_QC_cal_date(pair_date(cnt)) < 1   %total 50 jobs and 1 sucessful result 
                NumR = NumR + 1;
                save_TB_cal(pair_date(cnt)) = days;
                fprintf(fid_job,'%d\t4\t%s\t%s\n',cnt,name_i0,name_i1);
                if BR_check == 0
                    str = sprintf('./setsm -SDM 2 -projection ps -North 1 -SDM_file 0 -tilesize 1000000 -image %s/%s -image %s/%s -outpath %s -outres %d -sdm_as %f -sdm_days %f \n',list_subset(ID_i0(cnt)).folder,name_i0,list_subset(ID_i1(cnt)).folder,name_i1,result_path,grid,Max_sp+10,days);
                else
                    str = sprintf('./setsm -SDM 2 -projection ps -North 1 -SDM_file 0 -tilesize 1000000 -image %s/%s -image %s/%s -outpath %s -outres %d -sdm_as %f -sdm_days %f -boundary_min_X %d -boundary_max_X %d -boundary_min_Y %d -boundary_max_Y %d\n',list_subset(ID_i0(cnt)).folder,name_i0,list_subset(ID_i1(cnt)).folder,name_i1,result_path,grid,Max_sp+10,days,BR_region(1),BR_region(2),BR_region(3),BR_region(4));
                end
                fprintf(fid,str);
                %disp(str);
                temp = ['tif'];

                str = sprintf('TIFFILE="%s"\n',result_file);
                fprintf(fid,str);
                str = sprintf('if [ ! -f "$TIFFILE" ]\nthen\n  echo "Error: $TIFFILE does not exist."\nelse\n  echo "complete: $TIFFILE"\nfi\n');
                fprintf(fid,str);

                str = sprintf('rm -rf %s/txt\nrm -rf %s/tmp\nrm -rf %s/%s\n',result_path,result_path,result_path,temp);
                fprintf(fid,str);
                
                %disp(str);
                num_select = num_select + 1;
                check_cal_date(pair_date(cnt)) = check_cal_date(pair_date(cnt)) + 1;
                %disp(pair_date(cnt));
            else
                fprintf(fid_job,'%d\t4\t%s\t%s\n',cnt,name_i0,name_i1);
            end
        end
    end
end

fclose(fid_job);

str = sprintf('echo "Finish"\n');
fprintf(fid,str);
str = sprintf('Total pairs = %d\tProcessed pairs = %d\tRunning pairs = %d\tresult pairs = %d\tno result pairs = %d\tselected pairs = %d\n',numel(ID_i0),NumP, NumR,NumC, NumB, NumQ);
%fprintf(fid_check,str);
%fclose(fid_check);
disp(str);
disp([num2str(num_select),' pair found.']);

index_date = [1:365]';
check_date = [index_date check_QC_cal_date save_TB_QC check_cal_date save_TB_cal];
save(Interval_file,'check_date');

Numcount = [NumP NumR NumC NumB NumQ];
save(Num_file,'Numcount');

fclose(fid);

out{1} = NumP;
out{2} = NumR;
out{3} = datediff_min;
out{4} = datediff_max;
out{5} = NumC;
out{6} = NumB;
out{7} = NumQ;
out{8} = numel(ID_i0);

end

function flag=isLandsat(name_i0)
    %if contains(name_i0,'LT') || contains(name_i0,'LE') || contains(name_i0,'LC') || contains(name_i0,'LO')
    if ~isempty(strfind(name_i0,'LT')) || ~isempty(strfind(name_i0,'LE')) || ~isempty(strfind(name_i0,'LC')) || ~isempty(strfind(name_i0,'LO'))
        flag=true;
    else
        flag=false;
    end
end



function flag=isSentinel(name_i0)
    if ~isempty(strfind(name_i0,'S2A')) || ~isempty(strfind(name_i0,'S2B'))
        flag=true;
    else
        flag=false;
    end
end




