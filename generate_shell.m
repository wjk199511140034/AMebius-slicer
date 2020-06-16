function [shell_cell] = generate_shell(polygon_cell)
global shell_thick nozzle_dim
shell_cell={};
offset_num=floor(shell_thick/nozzle_dim);
if offset_num<1
    fprintf('warning: No shell need to generate due to shell_thick and nozzle_dim parameter')
    shell_cell=cell(size(polygon_cell,1),1);
    return;
else
    offset_end=offset_num*nozzle_dim-(nozzle_dim/2);
    offset_list=[(nozzle_dim/2):nozzle_dim:offset_end];
end


for i=1:size(polygon_cell,1)
    %shell=[];
    shell=[];
    %ploypoint=ploygon_cell{i};
    %ployg=polyshape(ploypoint(:,1),ploypoint(:,2));
    poly_this=polygon_cell{i};
    for j=1:offset_num
        polyg_offset = polybuffer(poly_this,-offset_list(j));
        if isempty(polyg_offset.Vertices)
            x=[];
            y=[];
        else
            [x,y]=boundary(polyg_offset);
        end
        shell=[shell;x,y;NaN,NaN];
    end
    shell_cell{i}=[shell];
    %shell_cell{i}=shell;
end
end