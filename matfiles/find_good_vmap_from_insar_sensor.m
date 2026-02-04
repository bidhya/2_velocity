function [out] = find_good_vmap_from_insar(varargin)

f                                   = varargin{1};
year = varargin{2};
ID_roi = varargin{3};
sensor = varargin{4};

list_path = sprintf('%s/vmap*',f)
list = dir(list_path);
%ref_mag = '/home/noh.56/development/SDM_utility/sensor_scripts_final/greenland_vel_mosaic200_2016_2017_vel_v2.tif';
ref_mag = '/fs/project/howat.4-3/howat-data/gimp/insar/radarsat/greenland_vel_mosaic200_2016_2017_vel_v2.tif'

ref_m = readGeotiff(ref_mag);

%imagesc(ref_m.x,ref_m.y,ref_cp);
%colormap jet;
%colorbar;
%set(gca,'YDir','normal');
%axis equal;
%caxis([-20 30]);

%load selected SDM pairs from list_good.txt file
check_list_file = 0;
list_file = sprintf('%s/list_good_%d.txt',f,year)
%f_name_all = sprintf('%s/list_all_%d.txt',f,year)
%if exist(f_name_all,'file')
%    file = fopen(f_name_all,'r');
%    glist = textscan(file,'%d\t%s\t%f\t%f\n')
%    gval1 = glist{3}
%    gval2 = glist{4};
%    check_list_file = 1;

%    index_pos = find(gval1 > 30 & gval2 > 10)

%    fclose(file);
%end
num_vmap = numel(list);
f_name = sprintf('%s/list_good_%d.txt',f,year)
fid = fopen(f_name,'w');
%str = sprintf('vmap name\tcorrleation ratio\tarea ratio from reference\tgcp ratio\n');
%fprintf(fid,str);
check = 0;
count_good = 0;

grid_min_X = 9999999999999;
grid_max_X = -9999999999999;
grid_min_Y = grid_min_X;
grid_max_Y = grid_max_X;

BR_check = 0;
%file_region_BR = '/home/noh.56/development/SDM_utility/sensor_scripts_final/glaciers_roi_proj_v2_300m.txt';
file_region_BR = '/fs/project/howat.4-3/howat-data/VelocityResults/Greenland/SETSM_SDM/glaciers_roi_proj_v2_300m.txt'
if exist(file_region_BR,'file')
    BR_file = fopen(file_region_BR,'r');
    BR = textscan(BR_file,'%s\t%d\t%d\t%d\t%d\n');
    grid_min_X = single(BR{2}(ID_roi));
    grid_max_X = single(BR{3}(ID_roi));
    grid_min_Y = single(BR{4}(ID_roi));
    grid_max_Y = single(BR{5}(ID_roi));
    BR_check = 1;
    fclose(BR_file);
else

    %grid_min_X = -20020;
    %grid_max_X = 27980;
    %grid_min_Y = -948970;
    %grid_max_Y = -881170;

    for cnt=1:num_vmap
        vmap_year = list(cnt).name;
        
        if sensor == 1
            vmap_year = vmap_year(6:9);
        else
            vmap_year = vmap_year(17:20);
        end

        vmap_year = str2num(vmap_year);
        if vmap_year == year
            f_roh = [f,'/',list(cnt).name,'/',list(cnt).name,'_roh.tif'];
            f_mask = [f,'/',list(cnt).name,'/',list(cnt).name,'_mask.tif'];
            if exist(f_roh,'file') && exist(f_mask,'file')
                Tinfo       = imfinfo(f_roh);
                info.cols   = Tinfo.Width;
                info.rows   = Tinfo.Height;
                info.imsize = Tinfo.Offset;
                info.bands  = Tinfo.SamplesPerPixel;

                info.dx    = Tinfo.ModelPixelScaleTag(1);
                info.dy    = Tinfo.ModelPixelScaleTag(2);
                info.minx  = Tinfo.ModelTiepointTag(4);
                info.maxy  = Tinfo.ModelTiepointTag(5);
                info.maxx  = info.minx + (info.cols-1)*info.dx;
                info.miny  = info.maxy - (info.rows-1)*info.dy;

                grid_dx = info.dx;
                grid_dy = info.dy;

                if grid_min_X > info.minx
                    grid_min_X = info.minx;
                end

                if grid_min_Y > info.miny
                    grid_min_Y = info.miny;
                end

                if grid_max_X < info.maxx
                    grid_max_X = info.maxx;
                end

                if grid_max_Y < info.maxy
                    grid_max_Y = info.maxy;
                end
            end
        end
    end
end

grid_min_X
grid_max_X
grid_min_Y
grid_max_Y

%f_name_all2 = sprintf('%s/list_all2_%d.txt',f,year);
%fid_all = fopen(f_name_all2,'w');

if check_list_file == 1
    num_vmap = numel(glist{1})
end

total_vmap_year = 0;
for cnt=1:num_vmap
    vmap_year = list(cnt).name;
    
    if sensor == 1
        vmap_year = vmap_year(6:9);
    else
        vmap_year = vmap_year(17:20);
    end
    
    vmap_year = str2num(vmap_year);
    if vmap_year == year
        total_vmap_year = total_vmap_year + 1; 
	%%vmap_year
    	f_roh = [f,'/',list(cnt).name,'/',list(cnt).name,'_roh.tif'];
        f_mask = [f,'/',list(cnt).name,'/',list(cnt).name,'_mask.tif'];

        list_check = 0;
        if check_list_file == 1
            count = 1;

            %idx = find(ismember(glist{1},list(cnt).name));
            %if(size(idx,1) > 0)
            %    list_check = 1;
            %    a=glist{2}(count);
            %    b=glist{3}(count);
            %    str = sprintf('%s\t%3.2f\t%3.2f\n',list(cnt).name,a,b);
            %    fprintf(fid,str);
            %    count_good = count_good + 1;
            %end

        end

    	if exist(f_roh,'file') && exist(f_mask,'file') && list_check == 0 
            r = readGeotiff(f_roh);

            if BR_check == 1
                Tinfo       = imfinfo(f_roh);
                info.cols   = Tinfo.Width;
                info.rows   = Tinfo.Height;
                info.imsize = Tinfo.Offset;
                info.bands  = Tinfo.SamplesPerPixel;

                info.dx    = Tinfo.ModelPixelScaleTag(1);
                info.dy    = Tinfo.ModelPixelScaleTag(2);
                info.minx  = Tinfo.ModelTiepointTag(4);
                info.maxy  = Tinfo.ModelTiepointTag(5);
                info.maxx  = info.minx + (info.cols-1)*info.dx;
                info.miny  = info.maxy - (info.rows-1)*info.dy;

                grid_dx = info.dx;
                grid_dy = info.dy;
            end
            if check == 0
                [Xq, Yq] = meshgrid(grid_min_X:grid_dx:grid_max_X,grid_max_Y:-grid_dy:grid_min_Y);
                %[Xq, Yq] = meshgrid(min(r.x):r.info.map_info.dx:max(r.x),max(r.y):-r.info.map_info.dy:min(r.y));
                Rz = interp2(ref_m.x,ref_m.y,ref_m.z,Xq,Yq);
                Rz = Rz/365;
                
                Max_sp = max(Rz(:));
                th_sp = 0.5;
                if(Max_sp < 0.5)
                    th_sp = 0.1;
                end
                str = sprintf('Max_sp th_sh %f\t%f\n',Max_sp,th_sp);
                disp(str);
             
                if check == 0
                    savefile = sprintf('%s/SDM_insar',f)
                    save(savefile,'Rz');
                end
                indexg = find(Rz > th_sp);
                ref_s = zeros(size(Rz));
                ref_s(indexg) = Rz(indexg);
            end
            
            r.z = interp2(r.x,r.y,r.z,Xq,Yq);
            check = 1;
            
            if size(r.z,1) == size(ref_s,1) && size(r.z,2) == size(ref_s,2)
                sizer = size(find(ref_s > 0));
                size0 = size(find(r.z > 0 & ref_s > 0));
                size1 = size(find(r.z > 0.6 & ref_s > 0));
                sizet = size(r.z);
                total_c = sizet(1) * sizet(2);	
                ratio = size1(1)/size0(1)*100;
                ratio_r = size0(1)/sizer(1)*100;

                str = sprintf('%s\t%3.2f\t%3.2f\n',list(cnt).name,ratio,ratio_r);
                if ratio > 30 && ratio_r > 10 
                    fprintf(fid,str);
                    %fprintf(fid_all,str);

                    count_good = count_good + 1; 
                %else
                %    fprintf(fid_all,str);
                end
            else
                
                %str = sprintf('%s\t0.0\t0.0\n',list(cnt).name);
                %fprintf(fid_all,str);
            end
        %else
        %    str = sprintf('%s\t0.0\t0.0\n',list(cnt).name);
        %    fprintf(fid_all,str);
    	end
    end
end

disp(count_good);
out{1} = total_vmap_year;
out{2} = count_good;
fclose(fid);
%fclose(fid_all);
%clear all;
