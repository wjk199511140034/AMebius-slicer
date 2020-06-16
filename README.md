# AMebius-slicer
AM slicer can generate gcode from STL file, you can define printer parameters, and some print settings
However, this is only a basic version, it is impossible to judge solid layer(judge by z-hight at present), and it is can't generate support, filling path plan algorithm is low efficiency.
The slicer has passed the actual printing test, and has built an adaptive algorithm based on the areas difference(not guarantee accurate).
Please use Cura to preview slice result before real print
https://ultimaker.com/software/ultimaker-cura
One of key process triangle_plane_intersection is copy from by Sunil Bhandari
https://www.mathworks.com/matlabcentral/fileexchange/62113-slice_stl_create_path-triangles-slice_height
# Usage
Run main.m, modify filenam gfilename

# Require
Matlab R2017b

# Notice
Read binary stl file by default, change file i/o part if you are trying read ascii stl file.
