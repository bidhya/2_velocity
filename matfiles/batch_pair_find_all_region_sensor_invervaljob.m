function batch_pair_find_all_region(varargin)

%outpath = '/home/noh.56/development/SDM_utility/Landsat';
outpath = '/home/yadav.111/Github/2_velocity/jobs/Landsat';
startmon = 1;
endmon = 12;
sensor = 1; % Landsat = 1, Sentinel = 2
if nargin > 3
    sensor = varargin{4};
    startmon = varargin{5};
    endmon = varargin{6};
end

if sensor == 2
    outpath = '/home/yadav.111/Github/2_velocity/jobs/sentinel2';
end

datestart = sprintf('%d %d 1',varargin{3},startmon);
dateend = sprintf('%d %d 31',varargin{3},endmon);

filename = sprintf('%s/%d_JobList_300m_%d_%d_%d_%d.txt',outpath,varargin{3},varargin{1},varargin{2},startmon,endmon)
fid = fopen(filename,'w');

for i=varargin{1}:varargin{2}
	[out] = batch_pair_find_SDM_sensor_intervaljob(sensor,i,[3 30],300,[datenum([datestart]),datenum([dateend])],varargin{3},[startmon endmon]);
    %if out{2} > 0
        str = sprintf('Region %d\ttotal_pairs %d\tcompleted_pairs %d\treprocess_pairs %d\tmin_TB %d\tmax_TB %d\tresult_pairs %d\tno_result_pairs %d\tselected_pairs %d\n',i,out{8},out{1},out{2},out{3},out{4},out{5},out{6},out{7});
        fprintf(fid,str);
    %end
disp(i);	
end
fclose(fid);
