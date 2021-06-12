function [infill_line] = infill_lines_rec(polygonin,isoffset,density,angle,min_l,max_l)
global nozzle_dim
%plot(polygonin)
if angle~=0
     polygonin=rotate(polygonin,angle);
     r_limit_min=[cosd(angle) -sind(angle);sind(angle) cosd(angle)]*[min_l;0];
     r_limit_max=[cosd(angle) -sind(angle);sind(angle) cosd(angle)]*[max_l;0];
     min_l=r_limit_min(2);
     max_l=r_limit_max(2);
end
if isoffset~=0
    polyout=polybuffer(polygonin,isoffset);
else
    polyout=polygonin;
end
if isempty(polyout.Vertices)
    infill_line=[];
    return;
end
[x,y]=boundary(polyout);
polygon=horzcat(x,y);
if density<0
    step=nozzle_dim;
else
    step=200*nozzle_dim/density;
end
%step=nozzle_dim;
%y_list=(min(polygon(:,2)):step:max(polygon(:,2)))';
y_list=(min_l:step:max_l)';
%高度表
% if max(polygon(:,2))-y_list(end)>=0.2
%     y_list(length(y_list)+1,:)=max(polygon(:,2));
% end
poly_line=[];
for p=1:size(polygon,1)-1
    %依次连接多边形两点形成线段
    k=(polygon(p,2)-polygon(p+1,2))/(polygon(p,1)-polygon(p+1,1));
    if isnan(polygon(p,1)) || isnan(polygon(p+1,1)) || k==0
        continue;
    end
    %删除无效线和斜率为0的线
    poly_line=[poly_line;polygon(p,:),polygon(p+1,:),k];
end
c_poly_line=NaN(size(y_list,1),100);
c_poly_line_size=zeros(size(y_list,1),1);
for i=1:size(poly_line,1)
    node_low = min(poly_line(i,[2 4]));
    node_high = max(poly_line(i,[2 4]));
    %当前边的最低点和最高点
    y_high_index2=find(y_list<=node_high,1,'last');
    y_low_index2=find(y_list>node_low,1);
    %与当前边相交的扫面线起始行和终止行
    
    if y_high_index2 >= y_low_index2 
        for j = y_low_index2:y_high_index2
            c_poly_line_size(j,:) = c_poly_line_size(j,:) + 1;
            %c_poly_line_size是列向量，长度为总层数
            %与当多边形边线相交的高度编号+1，循环完成所有面片之后，c_poly_line_size的每一行表示对应y相交的多边形边线数
            c_poly_line(j,c_poly_line_size(j)) = i;
            %c_poly_line每一行代表每一个y值
            %每行表示与对应y相交的多边形边线编号(pline行号)，
            %c_poly_line每一行的有效数据个数等于c_poly_line_size每行的值
        end
    end
end
c_lineout=[];
for k=1:size(y_list,1),h=y_list(k);
    %循环每一个高度值
    c_c_p_line_checklist = c_poly_line(k,1:c_poly_line_size(k));
    c_c_p_line=poly_line(c_c_p_line_checklist,:);
    %c_p_c_line所有与当前高度相交的线段
    c_point=[];
    for c2=1:size(c_c_p_line,1)
        %找到每条相交边线段与当前高度值的交点
        if c_c_p_line(c2,5)==-Inf || c_c_p_line(c2,5)==-Inf
            c_point=[c_point;c_c_p_line(c2,1),h];
        else
            c_point=[c_point;c_c_p_line(c2,1)+(h-c_c_p_line(c2,2))/c_c_p_line(c2,5),h];
        end
        %c_point=[c_point;(h-c_c_p_line(c2,2))*(c_c_p_line(c2,3)-c_c_p_line(c2,1))/(c_c_p_line(c2,4)-c_c_p_line(c2,2))+c_c_p_line(c2,1),h];
        %两点式
    end
    [c_point_t,~,ib] = unique(c_point,'rows');
    c_point = c_point_t(accumarray(ib,1)==1,:);
    %整理cpoint，删除所有重复点
    c_line=[];
    if ~isempty(c_point)      
        c_point=sortrows(c_point,1)';
        %整理cpoint，按x递增,每行一个坐标
        c_line=reshape(c_point,4,[])';
        %重塑矩阵，每行是一个线段，交线数目等于行数，相当于reshape(cpoint2',[],4，'by rows')
    end
     c_lineout=[c_lineout;c_line];
end
if isempty(c_lineout)
    infill_line=[];
    %如果c_lineout为空继续执行排序，会生成错误的结果
    return
else
    c_lineout(:,[5,6])=0;
end
count=0;
oldp=[];
while sum(c_lineout(:,5)==0)
    if isempty(oldp)
        oldp_ind=find(c_lineout(:,5)~=1,1);  
        c_lineout(oldp_ind,5)=1;   
        oldp=c_lineout(oldp_ind,:);    
        count=count+1;      
        c_lineout(oldp_ind,6)=count;
    end
    for ii=1:size(c_lineout,1)
        newp=c_lineout(ii,:);
        %if newp(2)-oldp(2)<(step+0.01) && newp(2)-oldp(2)>(step-0.01) && newp(5)==0
        if newp(2)-oldp(2)<(step+0.01) && newp(2)-oldp(2)>(step-0.01) && newp(5)==0
            if abs(newp(1)-oldp(1))<0.4
                count=count+1;
                c_lineout(ii,5)=1;
                c_lineout(ii,6)=count;
                oldp=newp;  
                continue;
            end
            for i=oldp(1):0.25:oldp(3)
               % 'right'
                if abs(newp(1)-i)<0.4
                    count=count+1;
                    c_lineout(ii,5)=1;
                    c_lineout(ii,6)=count;
                    oldp=newp;  
                    continue;
                end
            end
            for i=newp(3):-0.25:newp(1)
               % 'left'
                if abs(i-oldp(1))<0.4 
                    count=count+1;
                    c_lineout(ii,5)=1;
                    c_lineout(ii,6)=count;
                    oldp=newp;  
                    continue;
                end
            end
        end
    end
    oldp=[];
end
if angle~=0
    start=c_lineout(:,[1 2])';
    endl=c_lineout(:,[3 4])';
    start=[cosd(-angle) -sind(-angle);sind(-angle) cosd(-angle)]*start;     
    endl=[cosd(-angle) -sind(-angle);sind(-angle) cosd(-angle)]*endl;
    c_lineout2=[start',endl'];
    c_lineout=[c_lineout2,c_lineout(:,[5 6])];
end
cpf=sortrows(c_lineout,6);
infill_line=[];
for i=1:1:size(cpf,1)
    if mod(i,2) == 1
        infill_line=[infill_line;cpf(i,[1 2]);cpf(i,[3 4]);NaN NaN];
    else
        infill_line=[infill_line;cpf(i,[3 4]);cpf(i,[1 2]);NaN NaN];
    end
end

end
