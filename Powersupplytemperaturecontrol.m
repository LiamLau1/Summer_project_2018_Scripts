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
temp=zeros(1,t);
timeT=zeros(1,t);
% make our measurement
current = linspace(0,1.8,19);
j = 2;
figure;
h= animatedline;
K = 0.15;
P = 0.2;

try
    for i = 1:t+1
        tic;
        [~,bvar]=system('/home/labuser/bin/client localhost 2017 S'); % calls data from picolog
        C = strsplit(bvar, ',');
        D = str2double(C);%stores values in an array
        temp(1,i) = D(1,2);
        pause(1.5);
        % increment 
        if i < 3 || (resid2(i-2) > P || ((abs(resid1) < K) && (abs(resid2(i-2)) < K)))
            while i <= t
                if j <= length(current)
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
                        j = j +1;
                else
                    % maintain 1.8V
   
                end
            end
        else
             % turn off power supply, close devices and finish only when
             % time t has been reached.
                    fprintf(s1,'v 0;');  fprintf(s1,'i 0;'); fprintf(s1,'op 0');
                    fclose(s1);
                    break;
        end
        end

         if i == 1
            timeT(i) = toc;
        else
            timeT(i) = timeT(i-1) + toc;
         end
         if i >= 4
            foo = fit((timeT((i-3):(i-1)))',(temp((i-3):(i-1)))','poly1'); %changed from (i-2):i
            resid1 = temp(i) - foo(timeT(i));
            resid2 = diff(temp);
         else
             resid1 = 0;
             resid2 = zeros(1,t-1); %resid1 and resid2 to check if the temperature has plateaued
         end
         addpoints(h,timeT(i), temp(i))
         drawnow
    end

catch
    fprintf(s1,'i 0.1');
    fprintf(s1,'op 0');
    fclose(s1);
end
