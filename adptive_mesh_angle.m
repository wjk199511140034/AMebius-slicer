function [layertype, height, layerangle, polygon] = adptive_mesh_angle(triangles)
global layer_hight adptive_shell_only min_layer_hight support adptive_no_support
[layertypein, heightin,layeranglein, polygonin] = generate_polygon(triangles);
layertype=layertypein; 
height=heightin;
polygon=polygonin;
layerangle=layeranglein;
n=floor(layer_hight/min_layer_hight);
start_angle=90;
end_angle=0;
threshold=0.5;
angle_list=linspace(start_angle*threshold,end_angle*threshold,(n+1)*threshold);
k_adj=0;
for k=1:size(polygonin,1)-1
    add_poly={};
    times=find(angle_list<=min(abs(layeranglein{k})),1);
    %delta_hight=layer_hight/times;
    add_hight=linspace(heightin{k},heightin{k+1},times+1);
    add_hight=add_hight(2:end-1);
    for i=1:length(add_hight)
        add_poly{i,1}=gen_pol(triangles,add_hight(i));
    end
    added_layer=times-1;
%     size(add_poly,1)
    add_hight_cell=mat2cell(add_hight',ones(length(add_hight),1),1);
    k=k+k_adj;
    if adptive_shell_only==1
        layertype=cat(1,layertype(1:k,:),num2cell(zeros(added_layer,1)),layertype(k+1:end,:)); 
    else
        layertype=cat(1,layertype(1:k,:),num2cell(ones(added_layer,1)),layertype(k+1:end,:));
    end
    height=cat(1,height(1:k,:),add_hight_cell,height(k+1:end,:));
    layerangle=cat(1,layerangle(1:k,:),num2cell(NaN(added_layer,1)),layerangle(k+1:end,:)); 
    polygon=cat(1,polygon(1:k,:),add_poly,polygon(k+1:end,:));
    k_adj=k_adj+added_layer;
end

if support==1 && adptive_no_support==0
    for i=1:size(layerangle,1)
        this_angle=layerangle{i};
        if isnan(this_angle)
            layerangle{i}=layerangle{i-1};
        end
    end
end


function polygonout=gen_pol(triangles,z)
tri=triangles((triangles(:,13)<=z & triangles(:,14)>=z),:);
[lines,linesize] = triangle_plane_intersection(tri, z);
if linesize ~= 0
    start_nodes = lines(1:linesize,1:2);
    end_nodes = lines(1:linesize,4:5);
    nodes = [start_nodes; end_nodes];
    tol_uniquetol = 1e-8;
    tol = 1e-8;
    nodes = uniquetol(nodes,tol_uniquetol,'ByRows',true);
    nodes = sortrows(nodes,[1 2]);
    [~, n1] = ismembertol(start_nodes, nodes, tol, 'ByRows',true);
    [~, n2] = ismembertol(end_nodes, nodes,tol,  'ByRows',true);
    conn1 = [n1 n2];
    conn2 = [n2 n1];
    check = ismember(conn2,conn1,'rows');
    conn1(check == 1,:)=[];
  
    G = graph(conn1(:,1),conn1(:,2));
    bins = conncomp(G);
    movelist =[];
    for k = 1: max(bins)           
        startNode = find(bins==k, 1, 'first');
                path = dfsearch(G, startNode);
                path = [path; path(1)];
                movelist1 = [nodes(path,1) nodes(path,2)];
                if ~isempty(path)
                     if movelist1(1,1)>movelist1(2,1) || movelist1(1,2)>movelist1(2,2)
                         movelist1 = movelist1(end:-1:1,:);
                     end
                 end                    
                 movelist = [movelist;movelist1; [NaN NaN]];  
    end
    polygonout=polyshape(movelist);      
end  