function [tri_r,x_min,x_max,y_min,y_max] = model_process(tri_in)
global bed_hight bed_width bed_center00 model_scale model_rotate_ax model_rotate_dg 
ax=model_rotate_ax;
dgr=model_rotate_dg;
if model_scale~=1
    tri_in=tri_in*model_scale;
end
%zoom model
if dgr~=0
    if ax == 'x'
        tri_r(:,1:3) = tri_in(:,1:3)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
        tri_r(:,4:6) = tri_in(:,4:6)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
        tri_r(:,7:9) = tri_in(:,7:9)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
        tri_r(:,10:12) = tri_in(:,10:12)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
    elseif ax == 'y'
        tri_r(:,1:3) = tri_in(:,1:3)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
        tri_r(:,4:6) = tri_in(:,4:6)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
        tri_r(:,7:9) = tri_in(:,7:9)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
        tri_r(:,10:12) = tri_in(:,10:12)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
    elseif ax == 'z'
        tri_r(:,1:3) = tri_in(:,1:3)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
        tri_r(:,4:6) = tri_in(:,4:6)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
        tri_r(:,7:9) = tri_in(:,7:9)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
        tri_r(:,10:12) = tri_in(:,10:12)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
    else
        error('axis should be x y or z')
    end
else
    tri_r=tri_in;
end
%rotate model
if bed_center00
        x_adj=(min(min(tri_r(:,1:3:9)))+max(max(tri_r(:,1:3:9))))/2;
        y_adj=(min(min(tri_r(:,2:3:9)))+max(max(tri_r(:,2:3:9))))/2;
        z_adj=min(min(tri_r(:,3:3:9)));
        tri_r(:,1:3:9) = tri_r(:,1:3:9) - x_adj;
        tri_r(:,2:3:9) = tri_r(:,2:3:9) - y_adj;
        tri_r(:,3:3:9) = tri_r(:,3:3:9) - z_adj;
else
        x_adj=(min(min(tri_r(:,1:3:9)))+max(max(tri_r(:,1:3:9)))-bed_width)/2;
        y_adj=(min(min(tri_r(:,2:3:9)))+max(max(tri_r(:,2:3:9)))-bed_hight)/2;
        z_adj=min(min(tri_r(:,3:3:9)));
        tri_r(:,1:3:9) = tri_r(:,1:3:9) - x_adj;
        tri_r(:,2:3:9) = tri_r(:,2:3:9) - y_adj;
        tri_r(:,3:3:9) = tri_r(:,3:3:9) - z_adj;
end
%relocate model
tri_r = [tri_r(:,1:12),min(tri_r(:,[3 6 9]),[],2), max(tri_r(:,[ 3 6 9]),[],2)];
%cac min_z and max_z for each mesh
tri_r = [tri_r,atand(sqrt(tri_r(:,10).^2+tri_r(:,11).^2)./tri_r(:,12))];
%cac angle for each mesh(not the normal)
x_min=min(min(tri_r(:,1:3:9)));
x_max=max(max(tri_r(:,1:3:9)));
y_min=min(min(tri_r(:,2:3:9)));
y_max=max(max(tri_r(:,2:3:9)));
%cac model x_min x_max y_min y_max for whole model
end
