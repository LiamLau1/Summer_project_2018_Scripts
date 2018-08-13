
t = 4320; % number of data points
pressure = zeros(1,t);
time = zeros(1,t);


for i=1:t
    tic;
    filename = '/home/labuser/status/edwardsagc1.status';
    delimiter = ':';
    endRow = 1;
    formatSpec = '%*s%*s%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    edwardsagc1 = [dataArray{1:end-1}];
    clearvars filename delimiter endRow formatSpec fileID dataArray ans;
    pressure(1,i) = edwardsagc1;
    pause(15); % in seconds
    if i == 1
        time(i) = toc;
    else
        time(i) = time(i-1) + toc;
    end
end

save('vacuumdata');

