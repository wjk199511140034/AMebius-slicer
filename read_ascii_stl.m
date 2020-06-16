%%% read ascii stl file
function triangles = read_ascii_stl(filename, header_lines_num)

%%%reads ASCII stl files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Author: Sunil Bhandari%%%%%%%%
%%%%Date: May 03, 2018 %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid = fopen(filename);
    for i = 1: header_lines_num
    tline = fgetl(fid);
    end
    i = 1;
    tline = fgetl(fid);
    z1 = {'proceed'};
    while ~strcmp(z1{1}, 'endsolid')
        normals = strsplit(tline,' ');
        triangles(i,10:12) = str2double(normals(end-2:end));
        tline = fgetl(fid);
        tline = fgetl(fid);
        vertex1 = strsplit(tline, ' ');
        triangles(i,1:3) = str2double(vertex1(end-2:end));
        tline = fgetl(fid);
        vertex2 = strsplit(tline, ' ');
        triangles(i,4:6) = str2double(vertex2(end-2:end));
        tline = fgetl(fid);
        vertex3 = strsplit(tline, ' ');
        triangles(i,7:9) = str2double(vertex3(end-2:end));
        tline = fgetl(fid);
        tline = fgetl(fid);
        i = i + 1;
        tline = fgetl(fid);
        z1 = strsplit(tline, ' ');        
    end
    fclose(fid);
end
%fclose(fid)