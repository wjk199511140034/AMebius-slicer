function [tri_r] = rotate_model(tri,ax,dgr)
global bed_hight bed_width bed_center00
if ax == 'x'
        tri_r(:,1:3) = tri(:,1:3)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
        tri_r(:,4:6) = tri(:,4:6)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
        tri_r(:,7:9) = tri(:,7:9)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
        tri_r(:,10:12) = tri(:,10:12)*[1 0 0;0 cosd(dgr) sind(dgr);0 -sind(dgr) cosd(dgr)];
elseif ax == 'y'
        tri_r(:,1:3) = tri(:,1:3)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
        tri_r(:,4:6) = tri(:,4:6)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
        tri_r(:,7:9) = tri(:,7:9)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
        tri_r(:,10:12) = tri(:,10:12)*[cosd(dgr) 0 -sind(dgr);0 1 0;sind(dgr) 0 cosd(dgr)];
elseif ax == 'z'
        tri_r(:,1:3) = tri(:,1:3)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
        tri_r(:,4:6) = tri(:,4:6)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
        tri_r(:,7:9) = tri(:,7:9)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
        tri_r(:,10:12) = tri(:,10:12)*[cosd(dgr) sind(dgr) 0;-sind(dgr) cosd(dgr) 0;0 0 1];
else
        error('axis should be x y or z')
end
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
    
end