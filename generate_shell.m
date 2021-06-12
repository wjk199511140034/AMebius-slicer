function [shell_cell] = generate_shell(polygon_cell)
global shell_thick nozzle_dim skirt_dis support
shell_cell={};
offset_num=floor(shell_thick/nozzle_dim);
if offset_num<1
%     fprintf('warning: No shell need to generate due to shell_thick and nozzle_dim parameter')
%     shell_cell=cell(size(polygon_cell,1),1);
%     return;
    offset_list=[nozzle_dim/2];
else
    offset_end=offset_num*nozzle_dim-(nozzle_dim/2);
    offset_list=[(nozzle_dim/2):nozzle_dim:offset_end];
end

if skirt_dis>0
    shell_o=[];
    move=-offset_end;
    while move<skirt_dis
        poly_brim=polybuffer(rmholes(polygon_cell{1}),move);
        [xo,yo]=boundary(poly_brim);
        shell_o=[shell_o;xo,yo;NaN,NaN];
        move=move+nozzle_dim;
        %generate skirt for 1st layer
    end
    shell_cell{1}=flip(shell_o);
end

for i=2:size(polygon_cell,1)
    %shell=[];
    shell_o=[];
    shell_h=[];
    %ploypoint=ploygon_cell{i};
    %ployg=polyshape(ploypoint(:,1),ploypoint(:,2));
    poly_this=polygon_cell{i};
    for j=1:offset_num
        polyg_offset = polybuffer(poly_this,-offset_list(j));
        polyg_offset_h=holes(polyg_offset);
        polyg_offset_o=rmholes(polyg_offset);
        %if length(polyg_offset_h)==0 
        if isempty(polyg_offset_h)
            xh=[];
            yh=[];
        else 
            for k=1:size(polyg_offset_h,1)
            [xh,yh]=boundary(polyg_offset_h(k));
            shell_h=[shell_h;xh,yh;NaN,NaN];
            end
            %有时polyout_h会变成一个多边形数组？？？
        end
        %if length(polyg_offset_o)==0
        if isempty(polyg_offset_o)
            xo=[];
            yo=[];
        else
            [xo,yo]=boundary(polyg_offset_o);
            shell_o=[shell_o;xo,yo;NaN,NaN];
        end
    end
    %shell_o
    %shell_h
    shell_cell{i}=[shell_o;shell_h];
    %shell_cell{i}=shell;
end
end
