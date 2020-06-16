function [infill_cell] = generate_infill(ploygon_cell,x_min,x_max,y_min,y_max)
global layer_hight shell_thick top_bottom_thick nozzle_dim infill_type top_bottom_type infill_density
infill_cell={};
shell_num=floor(shell_thick/nozzle_dim);
%if shell_num<1
    %infillshell=nozzle_dim/2;
%else
    infillshell=(shell_num+1)*nozzle_dim-nozzle_dim/2;
    %infill offset start distance
%end
solid_num=floor(top_bottom_thick/layer_hight);
%简单的通过高度来判断是内部还是外部
if strcmp(infill_type,'rec')
    %infill_type='offset';
    %fprintf('Warning: infill type rec still under construction, use offset to generate infill\n');
end
cc=1;
for i=1:size(ploygon_cell,1)
    if i<=solid_num || i>(size(ploygon_cell,1)-solid_num)
    %简单的通过高度来判断是内部还是外部,外部的情况
        if strcmp(top_bottom_type,'rec')
            if mod(cc,2)==0
                infill_cell{i}=infill_lines_rec(ploygon_cell{i},nozzle_dim,infillshell,-1,0,y_min,y_max);
                %plot(infill_cell{i}(:,1),infill_cell{i}(:,2))
            else
                infill_cell{i}=infill_lines_rec(ploygon_cell{i},nozzle_dim,infillshell,-1,90,x_min,x_max);
                %plot(infill_cell{i}(:,1),infill_cell{i}(:,2))
            end
            cc=cc+1;
            %infill_cell{i}='out-rec';
        elseif strcmp(top_bottom_type,'offset')
            infill_cell{i}=infill_lines_offset(ploygon_cell{i},nozzle_dim,infillshell,-1);
            %infill_cell{i}='out-offset';
        else 
            infill_cell{i}='NaN';
            fprintf('Warning: no infill generated due to infill_type\n');
        end
    else
    %外部填充的情况
        if strcmp(infill_type,'rec')
            %infill_cell{i}=infill_lines_rec(ploygon_cell{i},nozzle_dim,infillshell,infill_density);  
            %infill_cell{i}='inner-rec';
            infill_cell_1=infill_lines_rec(ploygon_cell{i},nozzle_dim,infillshell,infill_density,0,y_min,y_max);
            infill_cell_2=infill_lines_rec(ploygon_cell{i},nozzle_dim,infillshell,infill_density,90,x_min,x_max);
            infill_cell{i}=cat(1,infill_cell_1,infill_cell_2);
        elseif strcmp(infill_type,'offset')
            infill_cell{i}=infill_lines_offset(ploygon_cell{i},nozzle_dim,infillshell,infill_density);
            %infill_cell{i}='inner-offset';
        else
            infill_cell{i}='NaN';
            fprintf('Warning: no infill generated due to infill_type\n');
        end
    end
end