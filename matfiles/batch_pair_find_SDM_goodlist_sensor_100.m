function [out] = batch_pair_find_SDM_goodlist_sensor_100(sensor,ID_roi,range_dt,grid,minmax_t,year)

[~,host_name]=system('hostname');

if sensor == 1
    %old path
    %param.path.subset='/fs/project/howat.4-3/howat-data/subset_greenland_rift/orthocorrected';
    
    %Mike path
    %param.path.subset='/fs/project/howat.4/gravina.2/greenland_glacier_flow/1_download_merge_and_clip/landsat';
    
    %Bidhya path
    param.path.subset='/fs/project/howat.4-3/greenland_glacier_flow/1_download_merge_and_clip/landsat';
    
    %SDM output path
    param.path.result='/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/landsat';
    
    %Reference insar path
    param.path.insar='/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/landsat';
else
    %old path
    %param.path.subset='/fs/project/howat.4/sentinel2/clipped2';
    
    %Mike path
    %param.path.subset='/fs/project/howat.4/gravina.2/greenland_glacier_flow/1_download_merge_and_clip/sentinel2';
    
    %Bidhya path
    param.path.subset='/fs/project/howat.4-3/greenland_glacier_flow/1_download_merge_and_clip/sentinel2';
    
    %SDM output path
    param.path.result='/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/sentinel2';
    
    %Reference insar path
    param.path.insar='/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/landsat';
end

path_subset_root=param.path.subset

string_regionname=dir([path_subset_root,'/',num2str(ID_roi,'%03d'),'*']);

if sensor == 1
    out_folder = [param.path.result,'/',string_regionname.name,'/SETSM_SDM_100'];
else
    out_folder = [param.path.result,'/',string_regionname.name,'/SETSM_SDM_100_new'];
end

seed_folder = [param.path.result,'/',string_regionname.name,'/SETSM_SDM'];
insar_file = [param.path.insar,'/',string_regionname.name,'/SETSM_SDM_100/SDM_insar.mat'];
IS = load(insar_file);
Max_sp = max(IS.Rz(:))

if ~exist(out_folder,'dir')
    [status, msg] = mkdir(out_folder);
end

%file = fopen('/fs/byo/howat-data/VelocityResults/Greenland/im2_mimc_hc_ortho/041_helheim/SETSM_SDM/list_good_t.txt');
if sensor == 1
    list_file = sprintf('%s/%s/SETSM_SDM_300/list_good_%d.txt',param.path.result,string_regionname.name,year)
else
    list_file = sprintf('%s/%s/SETSM_SDM_300_new/list_good_%d.txt',param.path.result,string_regionname.name,year)
end

file = fopen(list_file);
glist = textscan(file,'%s\t%f\t%f')
glist_s = numel(glist{1})
glist_c=zeros([glist_s,1]);

if ~exist('minmax_t','var')
    minmax_t=[-1/0,1/0];

end

%determine the paring range
if exist('range_dt','var')
    disp(['Temporal baseline designated by user: [',num2str(range_dt(1)),', ',num2str(range_dt(2)),'] days']);
    datediff_min=range_dt(1)-0.1;
    datediff_max=range_dt(2)+0.1;
else
    datediff_min=7;
    datediff_max=21;
    disp('Default Date range selected (7-21 days).');
end

if sensor == 1
    MDPP = ceil(15.0/Max_sp);
else
    MDPP = ceil(10.0/Max_sp);
end

if MDPP < 3
    MDPP = 3;
end

%datediff_min = MDPP;
%datediff_max = MDPP + 24;
datediff_min = MDPP;
datediff_max = 30;

%if MDPP > 10
%    datediff_max = 30;
%end

%if MDPP > 20
%    datediff_max = MDPP + 10;
%end

disp(['Temporal baseline designated by insar m/d: [',num2str(datediff_min),', ',num2str(datediff_max),']days']);

%find the region name
%string_regionname=dir([path_subset_root,'/',num2str(ID_roi,'%03d'),'*']);
%out_folder = [param.path.result,'/',string_regionname.name];
%seed_folder = [param.path.result,'/',string_regionname.name,'/SETSM_SDM_300'];

if sensor == 1
    jobfilepath = sprintf('/home/noh.56/development/SDM_utility/Landsat/%s_job_100_%d.sh',string_regionname.name,year);
else
    jobfilepath = sprintf('/home/noh.56/development/SDM_utility/sentinel2/%s_job_100_%d.sh',string_regionname.name,year);
end

fid = fopen(jobfilepath,'w');

str = sprintf('#!/usr/bin/env bash\n#SBATCH --time=140:00:00\n#SBATCH -N 1 -n 20\n#SBATCH --mem=20G\n#SBATCH --job-name="SDM_%d_100"\n#SBATCH --mail-user=yadav.111@osu.edu\n#SBATCH -p howat\n\nmodule load intel/2024.2.0\nexport COMPILER=intel\ncd /fs/project/howat.4/SETSM\n',ID_roi);
%str = sprintf('#!/usr/bin/env bash\n#SBATCH --time=48:00:00\n#SBATCH -N 1 -n 10\n#SBATCH --mem=10G\n#SBATCH --job-name="MJ_SDM"\n#SBATCH --mail-user=yadav.111@osu.edu\n\nmodule load intel/19.0.5\nexport COMPILER=intel\ncd /fs/project/howat.4/SETSM\n');
fprintf(fid,str);

path_subset=[path_subset_root,'/',string_regionname.name]
%load([path_subset,'/xyuvav_rect_interp.mat']);

if sensor == 1
    list_subset=[dir([path_subset,'/*ortho.tif']);dir([path_subset,'/*pct.tif'])];
else
    path_subset=[path_subset_root,'/',string_regionname.name,'/clipped']; %temporary
    list_subset=dir([path_subset,'/*.tif']);
end

%list_subset=dir([path_subset,'/*LC*.tif']);
%list_subset=dir([path_subset,'/*LE*.tif']);

num_subset=numel(list_subset);

vec_time=zeros([num_subset,1]);
vec_path=zeros([num_subset,1]);
vec_row=zeros([num_subset,1]);
vec_year=zeros([num_subset,1]);
mtrx_datediff=zeros([num_subset,num_subset])/0;

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
        vec_year(cnt)=str2num(list_subset(cnt).name(1:4));
    else
        vec_time(cnt)=datenum(list_subset(cnt).name(12:22),'yyyymmddTHH');
    end

end

%determine the valid image pairs
for cnt=1:num_subset
    for cnt1=cnt+1:num_subset
        datediff=vec_time(cnt1)-vec_time(cnt);
        %if round(datediff)>=datediff_min && round(datediff)<=datediff_max && abs(datediff-round(datediff))<4/24 && vec_row(cnt)==vec_row(cnt1)
        if round(datediff)>=datediff_min && round(datediff)<=datediff_max && abs(datediff-round(datediff))<4/24 
            if sensor == 1
                if isLandsat(list_subset(cnt).name) && isLandsat(list_subset(cnt1).name)
                    mtrx_datediff(cnt,cnt1)=datediff;
                end
            else
                if isSentinel(list_subset(cnt).name) && isSentinel(list_subset(cnt1).name)   
                    mtrx_datediff(cnt,cnt1)=datediff; 
                end
            end
            
        end
        
    end
end

mtrx_datediff(mtrx_datediff>=datediff_max | mtrx_datediff<=datediff_min)=0/0;

[gt1,gt0]=meshgrid(1:num_subset,1:num_subset);

ID_i0=gt0(~isnan(mtrx_datediff));
ID_i1=gt1(~isnan(mtrx_datediff));
%%

clear gt0 gt1

NumP = 0;
NumR = 0;

num_pair=numel(ID_i0);

%disp([num2str(num_pair),' pair(s) found.']);
vec_dt=mtrx_datediff(~isnan(mtrx_datediff));
vec_t=zeros(size(vec_dt));
num_select = 0;
for cnt=1:numel(vec_t)
    name_i0=list_subset(ID_i0(cnt)).name;
    name_i1=list_subset(ID_i1(cnt)).name;

    if sensor == 1
        t0=datenum(name_i0(1:14),'yyyymmddHHMMSS');
        t1=datenum(name_i1(1:14),'yyyymmddHHMMSS');
    else
        t0=datenum(name_i0(12:22),'yyyymmddTHH');
        t1=datenum(name_i1(12:22),'yyyymmddTHH');
    end

    days = t1 - t0;

    if sensor == 1
        result_path = [out_folder,'/vmap_',name_i0(1:14),'_',name_i1(1:14)];
        result_file_mask = [out_folder,'/vmap_',name_i0(1:14),'_',name_i1(1:14),'/vmap_',name_i0(1:14),'_',name_i1(1:14),'_mask.tif'];
        result_file = [out_folder,'/vmap_',name_i0(1:14),'_',name_i1(1:14),'/vmap_',name_i0(1:14),'_',name_i1(1:14),'_dmag.tif'];
    else
        result_path = [out_folder,'/vmap_',name_i0(1:22),'_',name_i1(1:22)];
        result_file_mask = [out_folder,'/vmap_',name_i0(1:22),'_',name_i1(1:22),'/vmap_',name_i0(1:22),'_',name_i1(1:22),'_mask.tif'];
        result_file = [out_folder,'/vmap_',name_i0(1:22),'_',name_i1(1:22),'/vmap_',name_i0(1:22),'_',name_i1(1:22),'_dmag.tif'];
    end

    timestamp_vmap=(t0+t1)/2;

    if timestamp_vmap<minmax_t(1) || timestamp_vmap>minmax_t(2)
        %disp('vmap out of temporal range. Skipping');
        continue;
    elseif exist(result_file,'file') && exist(result_file_mask,'file') 
        NumP = NumP + 1;
        %if exist(result_file_mask,'file')
        %    disp('Already processed with mask. Skipping the process');
        %end
    else
	count = 1;
	list_check = 0;
	while count <= glist_s && list_check == 0
		if sensor == 1
            vmap_name = ['vmap_',name_i0(1:14),'_',name_i1(1:14)];
        else
            vmap_name = ['vmap_',name_i0(1:22),'_',name_i1(1:22)];
		end

        %disp(['count ',count,vmap_name glist{1}(count)]);
		if strcmp(vmap_name,glist{1}(count))
			list_check = 1;
			%disp(['selected vmap ',vmap_name]);
            if ~exist(result_file_mask,'file') && exist(result_file,'file')
                disp('Already processed without mask. add job');
                disp(['selected vmap ',vmap_name]);
            end
		end
		count = count + 1;

	end

	if list_check == 1
        NumR = NumR + 1;
        str = sprintf('./setsm -SDM 2 -projection ps -North 1 -SDM_file 0 -tilesize 1000000 -image %s/%s -image %s/%s -outpath %s -outres %d -sdm_as %f -sdm_days %f \n',list_subset(ID_i0(cnt)).folder,name_i0,list_subset(ID_i1(cnt)).folder,name_i1,result_path,grid,Max_sp+5,days);
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
	end
    end
end
str = sprintf('echo "Finish"\n');
fprintf(fid,str);
str = sprintf('Processed pairs = %d\tRunning pairs = %d\n',NumP, NumR);
disp(str);
disp([num2str(num_select),' pair found.']);

fclose(fid);

out{1} = NumP;
out{2} = NumR;
out{3} = datediff_min;
out{4} = datediff_max;
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






