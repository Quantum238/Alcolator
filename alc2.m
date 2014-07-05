clear all
close all
clc

A = input('Num of drinks: ');
r = input('1 = M, 2 = F: '); %L/Kg
if r==1
    r1 = .68;
    r2 = .58;
else
    r1 = .55;
    r2 = .49;
end

W = input('Weight (lbs): ');
W = W * 16; %weight is in oz
beta = .015/100;
t = input('Time between first and last drink (hrs): ');
z = input('Oz of alcohol per drink: ');


lhs = (.8 * z * A) / (W * r1);
rhs = beta * t;
C = lhs - rhs;
PBAC = C*100;
disp(PBAC)



%for original widmark, we need to convert number of drinks and ounces of
%alcohol into number of 10g servings of alcohol
oz_alc = A*z;
ml_alc = oz_alc * 29.6;
g_alc = ml_alc * .789;
num_SD = g_alc/10;

PBAC2 = (.806 * num_SD * 1.2) / (r2 * W/(16*2.2)) - t*beta;
disp(PBAC2)

 n= 1000;

max_time = 12; %12 hours past 30 mins after your last drink 
min_time = .5; % hours past last drink
%peak BAC is usually achieved within a half hour of finished consumption
elapsed = linspace(min_time,max_time,n);
BAC = zeros(2,length(elapsed));
met_rate = .015; % .015 points per hour
%each timepoint represents
tick_val = (max_time-min_time) / n; %hours per point
met_per_tick = met_rate * tick_val; %this is decay per time step
BAC(1,1) = PBAC;
BAC(2,1) = PBAC2;
for ii = 2:length(BAC)
    BAC(:,ii) = BAC(:,ii-1) - met_per_tick;
    if BAC(1,ii) < .0001
        BAC(1,ii) = 0;
    end
    if BAC(2,ii) <.001
        BAC(2,ii) = 0;
    end
    
end

zero1 = find(BAC(1,:) == 0);
zero1 = zero1(1);
zero1 = elapsed(zero1);

slope1 = BAC(1,1) / (.5 - zero1);

zero2 = find(BAC(2,:) == 0);
zero2 = zero2(1);
zero2 = elapsed(zero2);

slope2 = BAC(2,1) / (.5 - zero2);

d1 = find(BAC(1,:)>.04);

if isempty(d1)
    option1 = 0;
else
    option1 = 1;
    d1 = d1(end);
    d1 = elapsed(d1);
end

d2 = find(BAC(2,:)>.04);
if isempty(d2)
    option2 = 0;
else
    option2 = 1;
    d2 = d2(end);
    d2 = elapsed(d2);
end


figure(1)
hold on
title('BAC Decay Rate')
xlabel('Hours past final drink')
ylabel('BAC')

plot(elapsed,BAC(1,:),':k')

plot(elapsed,BAC(2,:),'--k')
legend('Widmark - Common','Widmark - Conservative','Location','BEST')

line([0,12],[.04,.04],'Color','y')
line([0,12],[.08,.08],'Color','r')

plot(zero1,0,'*k',zero2,0,'*k')
text(zero1,.005,[num2str(round(zero1 * 10)/10),' hrs'])
text(zero2,.005,[num2str(round(zero2 * 10)/10), ' hrs'])
if option1 && option2
    plot(d1,0.04,'*k',d2,0.04,'*k')
    text(d1,.045,[num2str(round(d1 * 10)/10),' hrs'])
    text(d2,.045,[num2str(round(d2 * 10)/10), ' hrs'])
end


set(gca,'XTick',[.5,1:12])






