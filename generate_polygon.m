function [layertype,z_slices_cell,layerangle,polygon_cell] = generate_polygon(triangles)
global layer_hight 
polygon_cell ={};
z_slices_cell={};
layerangle={};
layertype={};
% min_z = min([triangles(:,3); triangles(:,6);triangles(:,9)]);
% max_z = max([triangles(:,3); triangles(:,6);triangles(:,9)])+1e-4;

triangles = [triangles,zeros(length(triangles),3),min(triangles(:,[3 6 9]),[],2), max(triangles(:,[ 3 6 9]),[],2),ones(length(triangles),1)];
min_z = min(triangles(:,13))+1e-4;
max_z = max(triangles(:,14))+1e-4;
z_slices = min_z+layer_hight: layer_hight :max_z;
%triangles_new = [triangles(:,1:12),min(triangles(:,[3 6 9]),[],2), max(triangles(:,[ 3 6 9]),[],2)];
%max(A)和max(A,[],1)取矩阵A每列最大的值返回行向量，max(A,[],2)取矩阵A每行最大的值返回列向量
%故triangles_new是一个14列矩阵，最后两列是每个面片的Z最小和最大值

slices = z_slices;
z_triangles = zeros(size(z_slices,2),4000);
z_triangles_size=zeros(size(z_slices,2),1);
%size(A,2)返回A的列数，这里是总层数，预先开辟空间

for i = 1:size(triangles,1)
    %author's old algorithm ↑↑↑
    %my new algorithm ↓↓↓
    node_low = triangles(i,13);
    node_high = triangles(i,14);
    z_high_index2=find(slices<=node_high,1,'last')+1;
    z_low_index2=find(slices>=node_low,1);
    %end of my new algorithm ↑↑↑   
    if z_high_index2 > z_low_index2 
        for j = z_low_index2:z_high_index2-1
            z_triangles_size(j) = z_triangles_size(j) + 1;
            %z_triangles_size是列向量，长度为总层数
            %与当前面片相交的z编号+1，循环完成所有面片之后，z_triangles_size的每一行表示对应z相交的面片数
            z_triangles(j,z_triangles_size(j)) = i;
            %z_triangles每一行代表每一个z值
            %每行表示与对应z相交的面片编号(triangles行号)，
            %z_triangles每一行的有效数据个数等于z_triangles_size每行的值
        end
    end
end
%list formed
triangle_checklist2 = z_triangles;
for  k = 1:size(z_slices,2)
  
    triangle_checklist = triangle_checklist2(k,1:z_triangles_size(k));
    %triangle_checklist是一个行向量，长度等于与当前z相交的面片个数，每一个元素表示相交的面片编号
    tri=triangles(triangle_checklist,:);
    %tri就是所有与当前z相交的面片
    [lines,linesize] = triangle_plane_intersection(tri, z_slices(k));
%     if k==23
%         view(3)
%         for i=1:size(tri,1)
%             patch(tri(i,[1 4 7 1]),tri(i,[2 5 8 2]),tri(i,[3 6 9 3]),[0.9290 0.6940 0.1250],...
%                 'FaceAlpha',1,'LineWidth',1.5,'AlignVertexCenters','on')
%             hold on
%         end
%         for i=1:size(lines,1)
%             plot3(lines(i,[1 4]),lines(i,[2 5]),lines(i,[3 6]),'k--','LineWidth',1)
%             hold on
%         end
%         z=lines(1,3);
%         xi=min(min(lines(:,[1 4])))-2;
%         xa=max(max(lines(:,[1 4])))+2;
%         yi=min(min(lines(:,[2 5])))-2;
%         ya=max(max(lines(:,[2 5])))+2;
%         patch([xi xa xa xi],[yi yi ya ya],[z z z z],'c','FaceAlpha',0.3,'LineWidth',1)
%         %axis equal;
%         daspect([1 1 0.4])
%         %axis([-Inf Inf -Inf Inf 0 10]);
%         axis off;
%      end
    
     if linesize ~= 0
            %find all the points assign nodes and remove duplicates
            start_nodes = lines(1:linesize,1:2);
            end_nodes = lines(1:linesize,4:5);
            nodes = [start_nodes; end_nodes];
            %connectivity = [];
            tol_uniquetol = 1e-8;
            tol = 1e-8;

            nodes = uniquetol(nodes,tol_uniquetol,'ByRows',true);
            nodes = sortrows(nodes,[1 2]);

            [~, n1] = ismembertol(start_nodes, nodes, tol, 'ByRows',true);
            [~, n2] = ismembertol(end_nodes, nodes,tol,  'ByRows',true);
            conn1 = [n1 n2];
%check for bad stl files. repeated edges, too thin surfaces, unclosed loops
%enable if error encountered
            conn2 = [n2 n1];
            check = ismember(conn2,conn1,'rows');
            conn1(check == 1,:)=[];
%end check
  
            G = graph(conn1(:,1),conn1(:,2));

            %create subgraph for connected components
            bins = conncomp(G);
            
            movelist =[];
            for i = 1: max(bins)
                    startNode = find(bins==i, 1, 'first');
                    %path =[];
                    path = dfsearch(G, startNode);
                    path = [path; path(1)];
                    %list of x and y axes
                    movelist1 = [nodes(path,1) nodes(path,2)];
                    if ~isempty(path)
                        if movelist1(1,1)>movelist1(2,1) || movelist1(1,2)>movelist1(2,2)
                            movelist1 = movelist1(end:-1:1,:);
                        end
                    end                    
                    %connect to the first point
                    %polygon = [polygon;movelist1; [NaN NaN]];
                    movelist = [movelist;movelist1; [NaN NaN]];
                    
                    
            end
          %polygon_cell(k,:) = {polygon};
          polygon_cell{k,1}=polyshape(movelist);
          %z_slices_cell(k,:)=num2cell(z_slices(k));
          z_slices_cell{k,1}=z_slices(k);
          %[~,index]=min(abs(tri(:,15)));
          %layerangle{k,1}=tri(index,15);
          layerangle_p=min(tri(tri(:,15)>0,15));
          layerangle_n=max(tri(tri(:,15)<0,15));
          layerangle{k,1}=[layerangle_n,layerangle_p];
          layertype{k,1}=1;
     end
    
end
end




