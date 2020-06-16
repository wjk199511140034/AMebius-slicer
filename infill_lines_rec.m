function [infill_line] = infill_lines_rec(polygonin,nozzle_dim,infillshell,density,angle,min_l,max_l)
%polyin=polyshape(polygon);
%plot(polygonin)
%hold on;
%plot(0,0,'o')

if angle~=0
     polygonin=rotate(polygonin,angle);
     %plot(polygonin)
     %plot(min_l,0,'ob')
     %plot(max_l,0,'o')
     r_limit_min=[cosd(angle) -sind(angle);sind(angle) cosd(angle)]*[min_l;0];
     r_limit_max=[cosd(angle) -sind(angle);sind(angle) cosd(angle)]*[max_l;0];
     %plot(0,r_limit_max(2),'o')
     %plot(0,r_limit_min(2),'ob')
     min_l=r_limit_min(2);
     max_l=r_limit_max(2);
end
polyout=polybuffer(polygonin,-infillshell);

[x,y]=boundary(polyout);
polygon=horzcat(x,y);
if isempty(polygon)
    infill_line=[];
    return;
end
if density<0
    step=nozzle_dim;
else
    step=200*nozzle_dim/density;
end
%step=nozzle_dim;
%y_list=(min(polygon(:,2)):step:max(polygon(:,2)))';
y_list=(min_l:step:max_l)';
%�߶ȱ�
% if max(polygon(:,2))-y_list(end)>=0.2
%     y_list(length(y_list)+1,:)=max(polygon(:,2));
% end
poly_line=[];
for p=1:size(polygon,1)-1
    %�������Ӷ���������γ��߶�
    k=(polygon(p,2)-polygon(p+1,2))/(polygon(p,1)-polygon(p+1,1));
    if isnan(polygon(p,1)) || isnan(polygon(p+1,1)) || k==0
        continue;
    end
    %ɾ����Ч�ߺ�б��Ϊ0����
    poly_line=[poly_line;polygon(p,:),polygon(p+1,:),k];
end
c_poly_line=NaN(size(y_list,1),100);
c_poly_line_size=zeros(size(y_list,1),1);
for i=1:size(poly_line,1)
    node_low = min(poly_line(i,[2 4]));
    node_high = max(poly_line(i,[2 4]));
    %��ǰ�ߵ���͵����ߵ�
    y_high_index2=find(y_list<=node_high,1,'last');
    y_low_index2=find(y_list>=node_low,1);
    %�뵱ǰ���ཻ��ɨ������ʼ�к���ֹ��
    
    if y_high_index2 >= y_low_index2 
        for j = y_low_index2:y_high_index2
            c_poly_line_size(j,:) = c_poly_line_size(j,:) + 1;
            %c_poly_line_size��������������Ϊ�ܲ���
            %�뵱����α����ཻ�ĸ߶ȱ��+1��ѭ�����������Ƭ֮��c_poly_line_size��ÿһ�б�ʾ��Ӧy�ཻ�Ķ���α�����
            c_poly_line(j,c_poly_line_size(j)) = i;
            %c_poly_lineÿһ�д���ÿһ��yֵ
            %ÿ�б�ʾ���Ӧy�ཻ�Ķ���α��߱��(pline�к�)��
            %c_poly_lineÿһ�е���Ч���ݸ�������c_poly_line_sizeÿ�е�ֵ
        end
    end
end
c_lineout=[];
for k=1:size(y_list,1),h=y_list(k);
    %ѭ��ÿһ���߶�ֵ
    c_c_p_line_checklist = c_poly_line(k,1:c_poly_line_size(k));
    c_c_p_line=poly_line(c_c_p_line_checklist,:);
    %c_p_c_line�����뵱ǰ�߶��ཻ���߶�
    c_point=[];
    for c2=1:size(c_c_p_line,1)
        %�ҵ�ÿ���ཻ���߶��뵱ǰ�߶�ֵ�Ľ���
        if c_c_p_line(c2,5)==-Inf || c_c_p_line(c2,5)==-Inf
            c_point=[c_point;c_c_p_line(c2,1),h];
        else
            c_point=[c_point;c_c_p_line(c2,1)+(h-c_c_p_line(c2,2))/c_c_p_line(c2,5),h];
        end
        %c_point=[c_point;(h-c_c_p_line(c2,2))*(c_c_p_line(c2,3)-c_c_p_line(c2,1))/(c_c_p_line(c2,4)-c_c_p_line(c2,2))+c_c_p_line(c2,1),h];
        %����ʽ
    end
    [c_point_t,~,ib] = unique(c_point,'rows');
    c_point = c_point_t(accumarray(ib,1)==1,:);
    %����cpoint��ɾ�������ظ���
    c_line=[];
    if ~isempty(c_point)      
%         [c_point_t,ind]=unique(c_point,'stable','rows');
%         ind=setdiff(1:size(c_point,1),ind);
%         c_point=setdiff(c_point_t,c_point(ind,:),'rows');
        c_point=sortrows(c_point,1)';
        %����cpoint����x����,ÿ��һ������
        c_line=reshape(c_point,4,[])';
        %���ܾ���ÿ����һ���߶Σ�������Ŀ�����������൱��reshape(cpoint2',[],4��'by rows')
    end
     c_lineout=[c_lineout;c_line];
end
if angle~=0
%     c_start=c_lineout(:,[1 2])';
%     c_end=c_lineout(:,[3 4])';
%     c_start=[cosd(-angle) -sind(-angle);sind(-angle) cosd(-angle)]*c_start;
%     c_end=[cosd(-angle) -sind(-angle);sind(-angle) cosd(-angle)]*c_end;
%     c_lineout=[c_start',c_end'];
%     c_lineout(:,[5,6])=0;
%     count=0;
%     oldp=[];
%     while sum(c_lineout(:,5)==0)
%         if isempty(oldp)
%             oldp_ind=find(c_lineout(:,5)~=1,1);  
%             c_lineout(oldp_ind,5)=1;   
%             oldp=c_lineout(oldp_ind,:);    
%             count=count+1;      
%             c_lineout(oldp_ind,6)=count;
%         end
%         for ii=1:size(c_lineout,1)
%             newp=c_lineout(ii,:);
%             if newp(1)-oldp(1)<(step+0.01) && newp(1)-oldp(1)>(step-0.01) && newp(5)==0
% %                 if abs(newp(1)-oldp(1))<0.4
% %                 count=count+1;
% %                 c_lineout(ii,5)=1;
% %                 c_lineout(ii,6)=count;
% %                 oldp=newp;  
% %                 continue;
% %                 end
%                 for i=oldp(2):-0.25:oldp(4)
%                     % 'down'
%                     if abs(newp(2)-i)<0.4
%                     count=count+1;
%                     c_lineout(ii,5)=1;
%                     c_lineout(ii,6)=count;
%                     oldp=newp;  
%                     continue;
%                     end       
%                 end
%                 for i=newp(4):0.25:newp(2)
%                     % 'left'
%                     if abs(i-oldp(1))<0.4 
%                     count=count+1;
%                     c_lineout(ii,5)=1;
%                     c_lineout(ii,6)=count;
%                     oldp=newp;  
%                     continue;
%                     end
%                 end
%             end
%         end 
%         oldp=[];
%     end
%     cpf=sortrows(c_lineout,6);
%     hold on;
%     infill_line=[];
%     for i=1:1:size(cpf,1)
%         if mod(i,2) == 1
%         infill_line=[infill_line;cpf(i,[1 2]);cpf(i,[3 4]);NaN NaN];
%         else
%         infill_line=[infill_line;cpf(i,[3 4]);cpf(i,[1 2]);NaN NaN];
%         end
%     end
%     return
end



c_lineout(:,[5,6])=0;
count=0;
oldp=[];
while sum(c_lineout(:,5)==0)
%     if isempty(oldp)
%         for i=1:size(c_lineout,1)
%             if c_lineout(i,5)~=1    
%                 c_lineout(i,5)=1;
%                 %c_lineout(i,7)=1;
%                 oldp=c_lineout(i,:);    
%                 count=count+1;      
%                 c_lineout(i,6)=count;   
%                 break;    
%             end
%         end
%     end
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
hold on;
infill_line=[];
for i=1:1:size(cpf,1)
    if mod(i,2) == 1
        infill_line=[infill_line;cpf(i,[1 2]);cpf(i,[3 4]);NaN NaN];
    else
        infill_line=[infill_line;cpf(i,[3 4]);cpf(i,[1 2]);NaN NaN];
    end
end


end