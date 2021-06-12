%% starting initialization
clc; clear all; close all;format short;warning('off');
global bed_hight bed_width bed_temp nozzle_dim filament_dim filament_temp bed_center00
global model_scale model_rotate_ax model_rotate_dg
global layer_hight shell_thick top_bottom_thick solid_type infill_density print_speed skirt_dis 
global adptive min_layer_hight adptive_shell_only support adptive_no_support curved
%% define parameter
% printer parameter↓
bed_hight=300;bed_width=300; %bed hight and width(mm)
bed_temp=60; %bed temperature(C)
nozzle_dim=.4; %nozzle diameter(mm)
filament_dim=1.75; %filament diameter(mm)
filament_temp=200; %filament temperature(C)
bed_center00=false; %bed center coordinate true
% model process↓
model_scale=1; %zoom in model
model_rotate_ax='x'; %model rotate axis
model_rotate_dg=0; %model rotate degree
% slice parameter↓
layer_hight=.2; %layer height(mm)
shell_thick=1; %shell thickness(mm)
top_bottom_thick=.3; %top and bottom surface thickness(mm)
solid_type='rec'; %rec and offset is optional
infill_density=12; %0->100 by percent
print_speed=60; %nozzle move speed(mm/s)
skirt_dis=0; %skirt distance
% experiment function↓
adptive=0; %adptive:0 equal thickness, 1 area diff adptive,2 mesh angle adptive
min_layer_hight=0.02; %minimal layer height for adptive
adptive_shell_only=0; %only outer shell adaptive
support=0; %generate support
adptive_no_support=0; %keep this value 0!!
curved=0; %curved slice
% file input/output 
filename='handle.stl';
gfilename='test.gcode';
% parameter↓do not modify
%layerlist={'layer type' 'layer hight' 'worst angle' 'layer polygon' 'solid polygon' 'normal polygon' 'support polygon'};
%movelist={'layer type' 'layer hight' 'layer shell' 'layer solid' 'layer infill' 'layer support'};
%I suggest not modify anything below except rotate option↓↓↓
%% file I/O
tic
triangles = read_stl_file(filename);
timeio=toc;
fprintf('File read done, %.4f sec elapsed\n',timeio);
%% model process
[triangles,x_min,x_max,y_min,y_max]=model_process(triangles);
%            1   2   3   4   5   6   7   8   9  10 11 12  13   14   15
%triangles=[vx1 vy1 vz1 vx2 vy2 vz2 vx3 vy3 vz3 nx xy xz minz maxz angle]
timemp=toc;
fprintf('Model process done, %.4f sec elapsed\n',timemp);
%% generate polygon
if adptive==2
    [layerlist(:,1),layerlist(:,2),layerlist(:,3),layerlist(:,4)] = adptive_mesh_angle(triangles);
elseif adptive==1
    [layerlist(:,1),layerlist(:,2),layerlist(:,3),layerlist(:,4)] = adptive_area_diff(triangles);
else
    [layerlist(:,1),layerlist(:,2),layerlist(:,3),layerlist(:,4)] = generate_polygon(triangles);
end
timegp=toc;
fprintf('Generate polygon done, %.4f sec elapsed\n',timegp);
%% generate layer
[layerlist(:,5),layerlist(:,6),layerlist(:,7)]=generate_layer(layerlist(:,[3,4,2]));
timegl=toc;
fprintf('Generate layer done, %.4f sec elapsed\n',timegl);
%% generate shell
movelist=layerlist(:,1:2);
[movelist(:,3)] = generate_shell(layerlist(:,4));
timegs=toc; 
fprintf('Generate shell done, %.4f sec elapsed\n',timegs);
%% generate infill
row_index=find([layerlist{:,1}]==1);
[movelist(row_index,4),movelist(row_index,5),movelist(row_index,6)] = generate_infill(layerlist(row_index,[5 6 7]), x_min, x_max, y_min, y_max);
timegi=toc;
fprintf('Generate infill done, %.4f sec elapsed\n',timegi);
%% export gcode
gfile_statu=exp_gcode(movelist(:,2), movelist(:,3), movelist(:,4), movelist(:,5), movelist(:,6),gfilename);
timeeg=toc;
if gfile_statu==1
    fprintf('Gcode file has written to %s\nElapsed time %.4f sec\n',gfilename,timeeg);
end
%% plot
hold on;
view(15,23);
axis equal off;
plot_slices(movelist(:,2),movelist(:,3), 0)
%% print time estimate
printtime= time_estimate(gfilename);
fprintf('Print time estimate %.0f hours %.0f minute\n',fix(printtime),rem(printtime,1)*60);
