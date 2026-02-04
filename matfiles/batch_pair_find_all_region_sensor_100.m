function batch_pair_find_all_region_100(varargin)

outpath = '/home/noh.56/development/SDM_utility/Landsat';

sensor = 1;
if nargin > 3
    sensor = varargin{4};
end

if sensor == 2
    outpath = '/home/noh.56/development/SDM_utility/sentinel2';
end

datestart = sprintf('%d 1 1',varargin{3});
dateend = sprintf('%d 12 31',varargin{3});

filename = sprintf('%s/%d_JobList_100m_%d_%d.txt',outpath,varargin{3},varargin{1},varargin{2})
fid = fopen(filename,'w');

for i=varargin{1}:varargin{2}
	[out] = batch_pair_find_SDM_goodlist_sensor_100(sensor,i,[1 24],100,[datenum(datestart),datenum(dateend)],varargin{3});
    str = sprintf('Region %d\tcompleted pairs %d\treprocess pairs %d\t%d\t%d\n',i,out{1},out{2},out{3},out{4});
    fprintf(fid,str);
disp(i);	
end
fclose(fid);
