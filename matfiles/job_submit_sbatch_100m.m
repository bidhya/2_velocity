function find_good_vmap_from_insar_all(varargin)

sensor = 1;
path = '/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/im2_mimc_hc_ortho';
job_path = '/home/noh.56/development/SDM_utility/Landsat';

if nargin > 3
    sensor = varargin{4};
end

if sensor == 2
    path = '/fs/project/howat.4/sentinel2/clipped2';
    job_path = '/home/noh.56/development/SDM_utility/sentinel2';
end

start_id = varargin{1};
end_id = varargin{2};
year = varargin{3};

job_year = sprintf('_job_100_%d.sh',year);
for i=start_id:end_id
	string_regionname=dir([path,'/',num2str(i,'%03d'),'*']);
	jobfile = [job_path,'/',string_regionname.name,job_year]
	command = sprintf('sbatch %s',jobfile)
	system(command);
end
