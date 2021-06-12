function triangles = read_stl_file(filename)
ff = fopen(filename,'r');
rdrd = fread(ff,84,'uint8=>uint8');
DD = dir(filename);
facet_num = typecast(rdrd(81:84),'uint32');
% file_head=char(rdrd(1:80)');
% if contains(file_head,'facet normal')
%     'ascii'
% else
%     'binary'
% end
% if DD.bytes==facet_num*50+84
%     'bin'
% else
%     'ascii'
% end
if DD.bytes==facet_num*50+84
    triangles=read_binary_file(filename);
    fclose all;
else
    triangles=read_ascii_file(filename);
    fclose all;
end


function tr=read_binary_file(fn)
f = fopen(fn,'r');
rd = fread(f,inf,'uint8=>uint8');
numTriangles = typecast(rd(81:84),'uint32');
tr = zeros(numTriangles,12);
sh = reshape(rd(85:end),50,numTriangles);
tt = reshape(typecast(reshape(sh(1:48,1:numTriangles),1,48*numTriangles),'single'),12,numTriangles)';
tr(:,1:9) = tt(:,4:12);
tr(:,10:12) = tt(:,1:3);
end


function tr=read_ascii_file(fn)
fid = fopen(fn,'r');
tr=[];
tr_n=[];
tline='start';
while ~contains(tline,'endsolid')
    tline = fgetl(fid);
    if contains(tline, 'facet normal')
        tr_n = [tr_n; sscanf(tline, '%*s %*s %f %f %f')'];
    elseif contains(tline, 'vertex')
        tr = [tr; sscanf(tline, '%*s %f %f %f')'];
    end
end
tr=reshape(tr',9,[])';
tr=[tr,tr_n];
end
end
