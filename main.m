%% starting initialization
clc; clear all; close all;format short;warning('off');
global bed_hight bed_width bed_temp nozzle_dim filament_dim filament_temp bed_center00
global layer_hight shell_thick top_bottom_thick infill_type top_bottom_type infill_density print_speed skirt_dis
%% define parameter
% printer parameter¡ý
bed_hight=400;bed_width=300; %bed hight and width(mm)
bed_temp=60; %bed temperature(C)
nozzle_dim=0.4; %nozzle diameter(mm)
filament_dim=1.75; %filament diameter(mm)
filament_temp=200; %filament temperature(C)
bed_center00=false; %bed center coordinate
% slice parameter¡ý
layer_hight=.2; %layer height(mm)
shell_thick=1; %shell thickness(mm)
top_bottom_thick=1; %top and bottom surface thickness(mm)
infill_type='rec'; %rec and offset is optional
top_bottom_type='rec'; %rec and offset is optional
infill_density=25; %0->100 by percent
print_speed=60; %nozzle move speed(mm/s)
skirt_dis=5; %skirt distance
% experiment function¡ý
adptive=0; %adptive:0 equal thickness, 1 adptive
% file input/output 
filename='col.stl';
gfilename='test.gcode';
% parameter¡ýdo not modify
%movelist={'layer type' 'layer hight' 'layer polygon' 'layer shell' 'layer infill'};
%I suggest not modify anything below except rotate option¡ý¡ý¡ý
%% file I/O
tic
triangles = read_stl_file(filename);
timeio=toc;
fprintf('File read done, %.4f sec elapsed\n',timeio);
%% model rotate
%triangles=triangles*2;
%model scale, 1 for 100%
triangles = rotate_model(triangles,'x',90);
triangles = [triangles(:,1:12),min(triangles(:,[3 6 9]),[],2), max(triangles(:,[ 3 6 9]),[],2)];
timemr=toc;
fprintf('Model rotate done, %.4f sec elapsed\n',timemr);
%% generate layer
if adptive==1
    [movelist(:,1), movelist(:,2), movelist(:,3)] = adptive_polygon(triangles);
else
    [movelist(:,1), movelist(:,2), movelist(:,3)] = generate_polygon(triangles);
end
timegl=toc;
fprintf('Generate layer done, %.4f sec elapsed\n',timegl);
%% generate shell
[movelist(:,4)] = generate_shell(movelist(:,3));
timegs=toc;
fprintf('Generate shell done, %.4f sec elapsed\n',timegs);
%% generate infill
x_min=min(min(triangles(:,1:3:9)));
x_max=max(max(triangles(:,1:3:9)));
y_min=min(min(triangles(:,2:3:9)));
y_max=max(max(triangles(:,2:3:9)));
row_index=find([movelist{:,1}]==1);
[movelist(row_index,5)] = generate_infill(movelist(row_index,3), x_min, x_max, y_min, y_max);
timegi=toc;
fprintf('Generate infill done, %.4f sec elapsed\n',timegi);
%% export gcode
statu=exp_gcode2(movelist(:,2), movelist(:,4), movelist(:,5), gfilename);
timeeg=toc;
if statu==1
    fprintf('Gcode file has written to %s\nElapsed time %.4f sec\n',gfilename,timeeg);
end
%% plot
hold on;
view(15,23);
axis equal;
plot_slices(movelist(:,2),movelist(:,4), 0)
%plot shell
plot_slices(movelist(:,2),movelist(:,5), 0)
%plot infill

        



