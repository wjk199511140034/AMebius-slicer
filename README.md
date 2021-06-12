# AMebius-slicer
AM slicer can generate gcode from STL file, you can define printer parameters, and some print settings<br>
However, this is only a basic version, filling path planing still in low efficiency.<br>
The slicer has passed the actual printing test.<br>
Please use Cura to preview slice result before real print<br>
https://ultimaker.com/software/ultimaker-cura<br>
One of key process triangle_plane_intersection is refers to Sunil Bhandari<br>
https://www.mathworks.com/matlabcentral/fileexchange/62113-slice_stl_create_path-triangles-slice_height<br>

# Usage
Run main.m, modify filenam gfilename

# Require
Matlab R2017b

# This Slicer also uploaded to Matlab FileExchange
https://www.mathworks.com/matlabcentral/fileexchange/76980-amebius-slicer-stl-slice-create-path-to-gcode-for-3d-print

Major update:
Major improvements for the overall framework
AMebius Slice now generate the solid layer properly
AMebius Slice now can gennerate support(silly, but its working!)
Auto detect STL file type
Two adaptive slice algorithm
New Fast External Adaptive methods, adptive only with shell part but no infill and support
Konwing issue:
Some thin-shell model may slice improperly
Next work:
Curved-layer slicing
