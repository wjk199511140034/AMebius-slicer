function [solid_infill_cell,normal_infill_cell,support_infill_cell] = generate_infill(solid_and_normal_and_support,x_min,x_max,y_min,y_max)

%solid起始的nozzle_dim/2已经算进去了。外轮廓不需要再次偏移

global  solid_type infill_density nozzle_dim support
solid_cell=solid_and_normal_and_support(:,1);
normal_cell=solid_and_normal_and_support(:,2);
support_cell=solid_and_normal_and_support(:,3);
solid_infill_judge=[];
% shell_num=floor(shell_thick/nozzle_dim);
% infillshell=(shell_num+1)*nozzle_dim-nozzle_dim/2;
% infill_lines_rec(输入多边形,多边形偏移,密度,角度,y_min,y_max)
% infill_lines_offset(输入多边形,多边形偏移,偏移一次,密度)
for i=1:size(solid_cell,1)  
    %generate solid infill
    if strcmp(solid_type,'rec')
        if mod(i,2)==0    
            infill_1=infill_lines_rec(solid_cell{i},-(nozzle_dim/2-0.03),-1,0,y_min,y_max);
        else
            infill_1=infill_lines_rec(solid_cell{i},-(nozzle_dim/2-0.03),-1,90,x_min,x_max);
        end
        infill_2=infill_lines_offset(solid_cell{i},0,1,-1);
        solid_infill_cell{i,1}=[infill_1;infill_2];
        solid_infill_judge(i)=isempty(infill_1);
    else
        infill_1=infill_lines_offset(solid_cell{i},0,0,-1);
        solid_infill_cell{i,1}=[infill_1];
    end
end

for i=1:size(normal_cell,1) 
    %generate normal infill
    if isempty(solid_cell{i}.Vertices) 
        %无实体填充区域
        infill_1=infill_lines_rec(normal_cell{i},-(0.5*nozzle_dim),infill_density,0,y_min,y_max);
        infill_2=infill_lines_rec(normal_cell{i},-(0.5*nozzle_dim-0.03),infill_density,90,x_min,x_max);
        infill_3=infill_lines_offset(normal_cell{i},0,1,-1);
        normal_infill_cell{i,1}=[infill_1;infill_2;infill_3];
        solid_infill_cell{i,1}=[];
    elseif solid_infill_judge(i)
        %实体填充区域太小，实际路径为空
        normal_cell{i}=union(solid_cell{i},normal_cell{i});
        infill_1=infill_lines_rec(normal_cell{i},-(0.5*nozzle_dim),infill_density,0,y_min,y_max);
        infill_2=infill_lines_rec(normal_cell{i},-(0.5*nozzle_dim-0.03),infill_density,90,x_min,x_max);
        infill_3=infill_lines_offset(normal_cell{i},0,1,-1);
        normal_infill_cell{i,1}=[infill_1;infill_2;infill_3];
        solid_infill_cell{i,1}=[];
    else
        infill_1=infill_lines_rec(normal_cell{i},-(0.5*nozzle_dim),infill_density,0,y_min,y_max);
        infill_2=infill_lines_rec(normal_cell{i},-(0.5*nozzle_dim-0.03),infill_density,90,x_min,x_max);
        normal_infill_cell{i,1}=[infill_1;infill_2];
    end
end

if support==1
    for i=1:size(support_cell,1)
        if ~isempty(support_cell{i})
            infill_2=infill_lines_offset(support_cell{i},0,1,-1);
            infill_1=infill_lines_rec(support_cell{i},0,20,0,y_min,y_max);
            support_infill_cell{i,1}=[infill_1;infill_2];
        else
            support_infill_cell{i,1}=[];
        end
    end
else
    support_infill_cell=cell(size(solid_and_normal_and_support,1),1);
end
