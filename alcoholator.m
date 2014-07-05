clear all
close all
clc


abv = input('ABV : ');
abv = abv/100; %abv is now in percent
gender = input('1 = M, 2 = F : ');
if gender == 1
    BW = .58;
    MR = .015;
elseif gender == 2
    BW = .49;
    MR = .017;
end
num_beers = input('Number of drinks : ');
weight = input('Weight in pounds : ');
weight = weight / 2.2; % weight is now in kg
DP = input('Amount of time drinks were consumed over (hours) : ');


abw = abv /1.25;

%1 12 oz beer is approximately 358 g based on an average FG of 1.01 
%This does not hold for darker beers, but you gotta start somewhere

SD = 10; %grams of ethanol
al_beer = 358 * abw; %grams of alcohol in beer
SD_con = SD/al_beer;
num_drinks = num_beers * SD_con;
C1 = .806;
C2 = 1.2;

EBAC = ((C1 * num_drinks * C2) / (BW * weight)) - (MR * DP);
%gives peak alcohol by volume in grams per dL, which is percentage BAC by
%volume, which is what is used in the US

disp('Approx peak ABV')
disp(EBAC)
n = 1000;

max_time = 12; %12 hours past 30 mins after your last drink 
min_time = .5; % hours past last drink
%peak BAC is usually achieved within a half hour of finished consumption
elapsed = linspace(min_time,max_time,n);
BAC = zeros(1,length(elapsed));
met_rate = .015; % .015 points per hour
%each timepoint represents
tick_val = (max_time-min_time) / n; %hours per point
met_per_tick = met_rate * tick_val; %this is decay per time step
BAC(1) = EBAC;
for ii = 2:length(BAC)
    BAC(ii) = BAC(ii-1) - met_per_tick;
    if BAC(ii) < .0001
        BAC(ii) = 0;
    end
    
end
unsafe_to_drive = .04;
illegal_to_drive = .08;

first_zero = find(BAC == 0);
first_zero = first_zero(1);
alcohol_gone_after = elapsed(first_zero);

ok_to_drive = find(BAC>.04);
if isempty(ok_to_drive)
    option = 0;
else
    option = 1;
    ok_to_drive = ok_to_drive(end);
    ok_to_drive = elapsed(ok_to_drive);
end


figure(1)
hold on
title('BAC Decay Rate')
xlabel('Hours past final drink')
ylabel('BAC')
plot(elapsed,BAC,'--k')
set(gca,'XTick',[.5,1:12])
line([0,12],[.04,.04],'Color','y')
line([0,12],[.08,.08],'Color','r')
% axis([0.5,12,0,max(BAC)])
text(alcohol_gone_after,.007,['Completely Safe after ',num2str(round(10*alcohol_gone_after)/10),' hours.'])
plot(alcohol_gone_after,0,'*k')
if option
    plot(ok_to_drive,.04,'*k')
    text(ok_to_drive,.045,['If you must drive it is safe after about ',num2str(round(10*ok_to_drive)/10),' hours.'])
end




