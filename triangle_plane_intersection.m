function [pts_out,size_pts_out] = triangle_plane_intersection(triangle_checklist,z_slices)

triangle_checklist = triangle_checklist';

p1 = triangle_checklist(1:3,:);
p2 = triangle_checklist(4:6,:);
p3 = triangle_checklist(7:9,:);
% p1每列是三角面片的第一个顶点坐标(x1 x2 ... xn; y1 y2 ... yn; z1 z2 ... zn)

c = ones(1,size(p1,2))*z_slices;
%长度为当前当前z值交面片数目，每一个元素都是当前z值
P = [zeros(1,size(p1,2));zeros(1, size(p1,2));ones(1,size(p1,2))];
%长度为当前当前z值交面片数目，第一二行全为0，第三行为1
%P.*p1点乘，对应元素相乘，得到的矩阵第一二行全为0，第三行为点的z值
%sum(P.*p1)每列的和，得到一行矩阵，每个元素为点的z值
%c-sum当前z值与每点z值做差
%sum(P.*(p1-p2))每两点的z值差
t1 = (c-sum(P.*p1))./sum(P.*(p1-p2));
t2 = (c-sum(P.*p2))./sum(P.*(p2-p3));
t3 = (c-sum(P.*p3))./sum(P.*(p3-p1));
intersect1 = p1+bsxfun(@times,p1-p2,t1);
intersect2 = p2+bsxfun(@times,p2-p3,t2);
intersect3 = p3+bsxfun(@times,p3-p1,t3);
i1 = intersect1(3,:)<max(p1(3,:),p2(3,:))&intersect1(3,:)>min(p1(3,:),p2(3,:));
i2 = intersect2(3,:)<max(p2(3,:),p3(3,:))&intersect2(3,:)>min(p2(3,:),p3(3,:));
i3 = intersect3(3,:)<max(p3(3,:),p1(3,:))&intersect3(3,:)>min(p3(3,:),p1(3,:));


imain = i1+i2+i3 == 2;

pts_out = [[intersect1(:,i1&i2&imain);intersect2(:,i1&i2&imain)],[intersect2(:,i2&i3&imain);intersect3(:,i2&i3&imain)], [intersect3(:,i3&i1&imain);intersect1(:,i3&i1&imain)]];
        
pts_out = pts_out';
size_pts_out = size(pts_out,1);
end






