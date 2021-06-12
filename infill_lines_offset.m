function [infill_line] = infill_lines_offset(polygonin,isoffset,onlyone,density)
global nozzle_dim
i=0;
lines_o=[];
lines_h=[];
lines_this=[0];
if isoffset~=0
    polygonin=polybuffer(polygonin,isoffset);
end
if isempty(polygonin.Vertices)
    infill_line=[];
    return;
end
if density<0
    step=nozzle_dim;
    %density<0实体层
else
    step=100*nozzle_dim/density;
    %density<0内部填充层
end
%ployin=polyshape(ploygon(:,1),ploygon(:,2));
%polyout=polygonin;
%while ~isempty(lines56)
while ~isempty(lines_this)
    polyout=polybuffer(polygonin,-(i*step));
    polyout_h=holes(polyout);
    polyout_o=rmholes(polyout);
    %if length(polyout_h)==0 
    if isempty(polyout_h)
        xh=[];
        yh=[];
    else 
        for i=1:size(polyout_h,1)
            [xh,yh]=boundary(polyout_h(i));
            lines_h=[lines_h;xh,yh;NaN,NaN];
        end
        %有时polyout_h会变成一个多边形数组？？？
    end
    %if length(polyout_o)==0
    if isempty(polyout_o)
        xo=[];
        yo=[];
    else
        [xo,yo]=boundary(polyout_o);
        lines_o=[lines_o;xo,yo;NaN,NaN];
    end
    lines_this=[xh,yh;xo,yo];
    %[x,y]=boundary(polyout);
    %lines56=horzcat(x,y);
    %infill_line=[infill_line;lines56;NaN NaN];
    i=i+1;
    if onlyone==1
        %只生成一个外轮廓给rec使用
        break;
    end
end
 infill_line=[lines_o;lines_h];
end
