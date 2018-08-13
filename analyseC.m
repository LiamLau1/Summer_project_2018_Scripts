% script to log chocolate vacuum data and to pull data from analyse.m and
% then plot on the same graph
S = load('vacuumdata.mat');
tC= 4320; % number of data points
pressureC = zeros(1,tC);
timeC = zeros(1,tC);


for i=1:tC
    tic;
    filename = '/home/labuser/status/edwardsagc1.status';
    delimiter = ':';
    %% 
    endRow = 1;
    formatSpec = '%*s%*s%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, endRow, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    edwardsagc1 = [dataArray{1:end-1}];
    clearvars filename delimiter endRow formatSpec fileID dataArray ans;
    pressureC(1,i) = edwardsagc1;
    pause(15); % in seconds
    if i == 1
        timeC(i) = toc;
    else
        timeC(i) = timeC(i-1) + toc;
    end
end


plot(log10(time),log10(pressure))
hold on
plot(log10(timeC),log10(pressureC))
legend('control','chocolate');
title('Plot of log(Pressures) against log(time) for chocolate and no chocolate','fontsize',8);
xlabel('log_10(time /s)');
ylabel('log_10(Pressure/mbar)');
grid on
hold off

save('chocolatedata');
