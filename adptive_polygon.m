function [layertype, height, polygon] = adptive_polygon(triangles)
[layertypein, heightin, polygonin] = generate_polygon(triangles);
layertype=layertypein; 
height=heightin;
polygon=polygonin;
k_adj=0;
threshold=0.045;
for k=2:size(polygonin,1)
    aab=area(polygonin{k});
    aaa=area(polygonin{k-1});
    adp={heightin{k-1};heightin{k}};
    adp_poly={polygonin{k-1};polygonin{k}};
    delta=abs(aab-aaa)/aaa;
    t=0;
    added_layer=0;
    %sum(delta(1,:)>0.1)
    while sum(delta(1,:)>threshold)
        t=t+1;
        if t>4
            break;
        end
        %细分超过4次终止细分
        index=find(delta>threshold);
        %index返回delta中大于设定误差的行，
        i_adj=0;
        %i需要调整，因为每一次的indx不一定是一个值
        added_layer=added_layer+length(index);
        %add_layer最后会统计出总共细分出了多少层
        for i=index'
            i=i+i_adj;
            in_z=(adp{i}+adp{i+1})/2;
            in_poly=gen_pol(triangles,in_z);
            adp=cat(1,adp(1:i,:),in_z,adp(i+1:end,:));
            adp_poly=cat(1,adp_poly(1:i,:),{in_poly},adp_poly(i+1:end,:));
            aaa = area(adp_poly{i});
            aab = area(adp_poly{i+1});
            aac = area(adp_poly{i+2});
            delta_this_f=abs(aab-aaa)/aaa;
            delta_this_r=abs(aac-aab)/aab;
            delta(i)=delta_this_f;
            delta=cat(1,delta(1:i,:),delta_this_r,delta(i+1:end,:));
            i_adj=i_adj+1;
        end  
    end
%     if k>268
%         pause
%     end
    k=k+k_adj-1;
    %if t~=0
    %mat=zeros(added_layer,1);
    layertype=cat(1,layertype(1:k,:),num2cell(ones(added_layer,1)),layertype(k+1:end,:)); 
    %end
    height=cat(1,height(1:k,:),adp(2:end-1,:),height(k+1:end,:));
    polygon=cat(1,polygon(1:k,:),adp_poly(2:end-1,:),polygon(k+1:end,:));
    k_adj=k_adj+added_layer;
    
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