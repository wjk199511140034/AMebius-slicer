function []= plot_slices(z_slices_cell, movelist_all,delay)

hold on;
%movelist_all=movelist_all';
%view(15,23);
view([0,1,0])
%axis([-Inf Inf -Inf Inf z_slices(1) z_slices(end)])
axis equal;
xlabel('X');ylabel('Y');zlabel('Z');
for i = 1: size(movelist_all,1)
    mlst_all = movelist_all{i};
    z_c = z_slices_cell{i};
    if delay >0
    if ~isempty(mlst_all)
        for j = 1:size(mlst_all,1)-1
            plot3(mlst_all(j:j+1,1),mlst_all(j:j+1,2),ones(2,1)*z_c,'b')
            pause(delay)
        end
    end  
    else
        if ~isempty(mlst_all)
            plot3(mlst_all(:,1),mlst_all(:,2),ones(size(mlst_all,1),1)*z_c,'b')
        end
    end
end   
end