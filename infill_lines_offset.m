function [infill_line] = infill_lines_offset(polygonin,nozzle_dim,infillshell,density)
i=0;
lines56=[];
lines_this=[0];
if density<0
    step=nozzle_dim;
    %density<0实体层
else
    step=100*nozzle_dim/density;
    %density<0内部填充层
end
%ployin=polyshape(ploygon(:,1),ploygon(:,2));
polyout=polygonin;
while ~isempty(lines_this)
    polyout=polybuffer(polygonin,-(infillshell+i*step));
    if isempty(polyout.Vertices)
        lines_this=[];
    else
        [x,y]=boundary(polyout);
        lines56=[lines56;x,y;NaN,NaN];
        lines_this=lines56;
    end
    i=i+1;
end
 infill_line=[lines56];
end