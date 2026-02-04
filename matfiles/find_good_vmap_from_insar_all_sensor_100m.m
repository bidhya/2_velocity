function find_good_vmap_from_insar_all(varargin)

sensor = 1;
outpath = '/home/noh.56/development/SDM_utility/Landsat';
result = '/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/landsat';

if nargin > 3
    sensor = varargin{4};
end

if sensor == 2
    outpath = '/home/noh.56/development/SDM_utility/sentinel2';
    result = '/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/sentinel2';
end

filename = sprintf('%s/%d_goodlist_check_100m_%d_%d.txt',outpath,varargin{3},varargin{1},varargin{2})
fid = fopen(filename,'w');

path = '/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/im2_mimc_hc_ortho';
start_id = varargin{1};
end_id = varargin{2};
year = varargin{3};
for i=start_id:end_id
	string_regionname=dir([path,'/',num2str(i,'%03d'),'*']);
	%out_folder = [result,'/',string_regionname.name]

    if sensor == 1
        out_folder = [result,'/',string_regionname.name,'/SETSM_SDM_100']
    else
	    out_folder = [result,'/',string_regionname.name,'/SETSM_SDM_100_new']
    end

    [out] = find_good_vmap_from_insar_sensor(out_folder,year,i,sensor);
    str = sprintf('%d\t%d\t%d\n',i,out{1},out{2});
    disp(str);
    fprintf(fid,str);
end
fclose(fid);
