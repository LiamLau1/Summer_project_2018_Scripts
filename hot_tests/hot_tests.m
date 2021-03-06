% open connection to power supply and turn on
clear all
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
s1 = serial('/dev/ttyUSB1','baudrate',9600);  fopen(s1);
%s2 = serial('COM5','baudrate',9600);  fopen(s2);
fprintf(s1,'v 1.1;'); %set maximum voltage to 0.90V
fprintf(s1,'i 0.01;'); %maximum operational current to 1.8A, max current tolerated by module is 2.2A
fprintf(s1,'op 1;'); %set output status on
t= 700;
tempC=zeros(1,t); %cold side temperature
tempH=zeros(1,t); %hot side temperature
tempA=zeros(1,t); %ambient temperature
timeT=zeros(1,t);
% make our measurement
current = linspace(0,0.4,5);
j = 2;
figure;
h= animatedline('Color','b');%cold side
h2= animatedline('Color','r');%hot side
h3= animatedline;%ambient temperature
K = 0.15;
P = 0.2;

try
    for i = 1:t
        tic; %to plot real time on x axis
        [~,bvar]=system('/home/labuser/bin/client localhost 2017 S'); % calls data from picolog
        C = strsplit(bvar, ',');
        D = str2double(C);%stores values in an array
        tempC(1,i) = D(1,3); %pico socket 2
        tempH(1,i) = D(1,2); %pico socket 1 %swapped the sides of the peltier module
        tempA(1,i) = D(1,4); %pico socket 3
        pause(1.5);
        % increment 
        if i < 3 || (resid2(i-2) > P || ((abs(resid1) < K) && (abs(resid2(i-2)) < K))) % checks the 2 data points before it to see if a plateau has been reached
            if i < t
                    % set the power supply
                    commandstring1 = ['i ' num2str(current(j))];
                    fprintf(s1,commandstring1);

                    % allow the power supply to settle, original value:
                    % 0.05
                    pause(1)

                    %{
                    read the current
                    fprintf(s2,':meas:curr:dc?\n');
                    reply = fscanf(s2);
                    data(j) = str2num(reply(3:end-2));
                    %}

                    %{
                    plot the results
                    plot(current(1:j),data(1:j),'o');
                    xlabel('Applied Voltage (V)');
                    ylabel('Measured Current (A)');
                    axis([0 30 0 1.2e-3]
                    %}
                    if j < length(current)
                        j = j +1;
                    end
            else
                % turn off power supply, close devices and finish
                fprintf(s1,'v 0;');  fprintf(s1,'i 0;'); fprintf(s1,'op 0');
                fclose(s1); %fclose(s2);
                break;
            end
        end

         if i == 1
            timeT(i) = toc;
        else
            timeT(i) = timeT(i-1) + toc;
         end
         if i >= 4
            foo = fit((timeT((i-3):(i-1)))',(tempH((i-3):(i-1)))','poly1'); %changed from (i-2):i %changed from tempC to tempH for sample heating7tyy
            resid1 = tempH(i) - foo(timeT(i));
            resid2 = diff(tempH);
         else
             resid1 = 0;
             resid2 = zeros(1,t-1); %resid1 and resid2 to check if the temperature has plateaued
         end
         addpoints(h,timeT(i), tempC(i)) %animated plot of cold side
         addpoints(h2,timeT(i),tempH(i)) %animated plot of hot side
         addpoints(h3,timeT(i),tempA(i)) %animated plot of ambient temperature)
         drawnow
    end

catch
    fprintf(s1,'i 0.1');
    fprintf(s1,'op 0');
    fclose(s1);
end
