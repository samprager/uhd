function [dataI, dataQ] = readComplexData(filename,bitformat)

byteoffset = 0;
packetsize = 512; %528;
headersize = 0;%16;

if (strcmp(bitformat,'uint8')||strcmp(bitformat,'int8'))
    bytesperword = 1;
elseif (strcmp(bitformat,'uint16')||strcmp(bitformat,'int16'))
    bytesperword = 2;
elseif (strcmp(bitformat,'uint32')||strcmp(bitformat,'int32'))
    bytesperword = 4;
else 
    bytesperword = 1;
end

fileID = fopen(filename,'r');
fseek(fileID,byteoffset,'bof');
A=fread(fileID,bitformat);
fclose(fileID);
numbytes = (packetsize-headersize)/bytesperword;

dataI = A(1:2:end)';
dataQ = A(2:2:end)';

end