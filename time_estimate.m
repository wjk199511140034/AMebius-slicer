function [totaltime_h]= time_estimate(gfilename)
fid = fopen(gfilename,'r');
i=0;
opointx=0;
opointy=0;
time=[];
totaltime=0;
while ~feof(fid)
    str = fgetl(fid);
    i=i+1;
    if (strcmp(str(1:2),'G1') || strcmp(str(1:2),'G0'))
        p = strfind(str, 'X');
        if p
            cpointx=str2num(str(p+1:p+8));
            cpointy=str2num(str(p+11:p+18));
            speed = strfind(str, 'F');
            if speed
                ff=str2num(str(speed+1:speed+4));
            end
            dis_this=sqrt((cpointx-opointx)^2+(cpointy-opointy)^2);
            time_this=dis_this/(ff/30);
            %time=[time;time_this];
            totaltime=totaltime+time_this;
            opointx=cpointx;
            opointy=cpointy;
        end  
    else
        continue;
    end
end
% fprintf('second= %f \n',totaltime);
% fprintf('mins= %f \n',totaltime/60);
% fprintf('hours= %f \n',totaltime/3600);
totaltime_h=totaltime/3600;
fclose all;