function [solid_cell,normal_cell,support_cell] = generate_layer(polygon_angel)
global top_bottom_thick layer_hight nozzle_dim shell_thick support skirt_dis
solid_num=floor(top_bottom_thick/layer_hight);
offset_num=floor(shell_thick/nozzle_dim);
offset_end=offset_num*nozzle_dim+(nozzle_dim/2);
%offset_end已经算进去了solid起始的nozzle_dim/2
%在生成infill时，外轮廓不需要再次偏移
angle_cell=polygon_angel(:,1);
polygon_cell=polygon_angel(:,2);
for i=solid_num+1:size(polygon_cell,1)-solid_num
    poly_this=polygon_cell{i};
    poly_shell_end=polybuffer(poly_this,-offset_end);
    poly_shell=subtract(poly_this,poly_shell_end);
    %生成shell多边形
    poly_upper=polybuffer(polygon_cell{i+solid_num},-offset_end);
    poly_lower=polybuffer(polygon_cell{i-solid_num},-offset_end);
    normal_this=intersect(poly_this,poly_upper);
    normal_this=intersect(normal_this,poly_lower);
    %normal 本层和上下层交集
    normal_this=subtract(normal_this,poly_shell);
    %再用normal减去shell
    solid_this=subtract(poly_this,normal_this);
    %solid 本层减去normal
    solid_this=subtract(solid_this,poly_shell);
    %再用solid减去shell
    solid_cell{i,1}=solid_this;
    normal_cell{i,1}=normal_this;
%     plot(poly_shell,'FaceColor','blue','FaceAlpha',0.6);
%     hold on
%     plot(solid_this,'FaceColor','red','FaceAlpha',0.6);
%     plot(normal_this,'FaceColor','black','FaceAlpha',0.1);
%     close all
end

solid_layer_list1=[1:solid_num];
solid_layer_list2=[(size(polygon_cell,1)-solid_num+1):(size(polygon_cell,1))];
solid_layer_list=[solid_layer_list1,solid_layer_list2];
for j=solid_layer_list
    %first and last top layer dirct copy form original polygon
    poly_this=polygon_cell{j};
    poly_shell_end=polybuffer(poly_this,-offset_end);
%     poly_shell=subtract(poly_this,poly_shell_end);
%     solid_this=subtract(poly_this,poly_shell);
    solid_cell{j,1}=poly_shell_end;
    normal_cell{j,1}=polyshape(0,0);
end


support_cell=cell(size(polygon_cell,1),1);
if support==1
    angle_n=cellfun(@(x)x(:,1),angle_cell,'un',0);
    angle_n=cell2mat(angle_n);
    support_index=angle_n>-45 & angle_n<0;
    support_start=find(support_index==1,1,'last');
    support_statu=0;
    for i=support_start:-1:1
        if support_index(i)
            if i==support_start
                poly_all=polygon_cell{i};
            else
                poly_all=union(poly_all,polygon_cell{i});
            end
        end
        support_cell{i,1}=subtract(poly_all,polybuffer(polygon_cell{i},1));
%         plot(support_cell{i,1},'FaceColor','b')
%         hold on;
%         plot(polygon_cell{i,1},'FaceColor','r')
%         close all
    end
    
    
%     z=polygon_angel(:,3);
% %     for i=1:size(polygon_cell,1)
% %         if support_index(i)
% %             [x,y]=boundary(polygon_cell{i});
% %             zz=z{i};
% %             plot3(x,y,zz*ones(length(x),1))
% %             hold on
% %         end
% %     end
% 
%     support_index2=[0;support_index(1:end)];
%     s_e=[support_index;0]-support_index2;
%     endl=find(s_e==1);
%     start=[find(s_e==-1)]-1;
%     
%     poly_all=polyshape(0,0);
%     for i=1:size(polygon_cell,1)
%         support_cell{i,1}=poly_all;
%     end
%     %start=size(polygon_cell,1);
%     for m=length(start):-1:1
%         poly_all=polyshape(0,0);
%         for k=start(m):-1:endl(m)
%             add_poly=subtract(polygon_cell{k},polygon_cell{k-1});
%             poly_all=union(poly_all,add_poly);
%             %累加每一段需要支撑的层
%         end
%         for k=start(m):-1:1
%             support_poly_this=subtract(poly_all,polybuffer(polygon_cell{k},nozzle_dim));
%             support_cell{k,1}=union(support_poly_this,support_cell{k,1});
%             %每段所有支撑减去每一段截面得到每一段支撑
%         end  
%     end
%     model=polyshape(0,0);
%     for k=start(end):-1:1    
%         model=union(model,polygon_cell{k});   
%         support_poly_this=intersect(model,support_cell{k,1});    
%         support_cell{k,1}=support_poly_this;
%         %减去支撑多余部分
%     end
%     support_poly_1st=subtract(support_cell{1},polybuffer(polygon_cell{1},skirt_dis));
%     support_cell{1,1}=support_poly_1st;
%      
% %         if i==1  
% %             support_poly_1st=subtract(poly_all,polybuffer(polygon_cell{i},skirt_dis));
% %             support_cell{i,1}=support_poly_1st;
% %         else
% %             support_poly_this=subtract(poly_all,polybuffer(polygon_cell{i},nozzle_dim));
% %             support_cell{i,1}=support_poly_this;
% %         end
% %     end
% %     supportendthis=0;
% %     for i=1:size(polygon_cell,1)
% %         if i==supportendthis+1
% %             poly_all=polyshape(0,0);
% %             for j=i+1:size(polygon_cell,1)
% %                 if support_index(j)
% %                     poly_judge=subtract(poly_all,polygon_cell{j});
% %                     if isempty(poly_judge.Vertices)
% %                         poly_all=union(poly_all,polygon_cell{j});
% %                         supportendthis=j;
% %                     end
% %                 end
% %             end
% %         end
% %         if i==1  
% %             support_poly_1st=subtract(poly_all,polybuffer(polygon_cell{i},skirt_dis));
% %             support_cell{i,1}=support_poly_1st;
% %         else
% %             support_poly_this=subtract(poly_all,polybuffer(polygon_cell{i},nozzle_dim));
% %             support_cell{i,1}=support_poly_this;
% %         end
% %     end
else
    support_cell=cell(size(polygon_cell,1),1);
end
end