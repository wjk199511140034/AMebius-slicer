function triangles = read_binary_stl_file(filename)
%this function reads the binary stl file and gives out triangles as output
%to be processed by slice_stl_create_path function.
f = fopen(filename,'r');
rd = fread(f,inf,'uint8=>uint8');
numTriangles = typecast(rd(81:84),'uint32');
triangles = zeros(numTriangles,12);
sh = reshape(rd(85:end),50,numTriangles);
tt = reshape(typecast(reshape(sh(1:48,1:numTriangles),1,48*numTriangles),'single'),12,numTriangles)';
triangles(:,1:9) = tt(:,4:12);
triangles(:,10:12) = tt(:,1:3);
end