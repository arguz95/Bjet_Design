%% Carpet Plot Routine
clear variables
clc

%% Data Entry (Range of Values to Try)

% Range of Values to Iterate
vector_wingS    = 680:20:780; %720:20:840               % Wing Surface Area [sqft]
baseline_thrust = 12018;                      % Baseline Thrust at SL[lbf]
vector_thrfct   = 0.9:0.12:1.5;                % Thrust Factor [-]
vector_MTOW     = linspace(62000, 75000, ...  % Range of initial MTOW [lb]
    length(vector_wingS)*length(vector_thrfct));

% Results Loaded from carpetplt_airplanes.m is a 3D Matrix 
%  - results(nswing, ntfac, j);
%  - where j is:
%
%  1: MTOW
%  2: Thrust to Weight Ratio
%  3: --
%  4: --
%  5: AEO Ceiling (min 41000 ft)
%  6: Time to Climb to FL410 (MR&O under 25 min)
%  7: Range of Mission 1 (4700 nm with 8 pax and 200 nm at 0.85)
%  8: Range of Mission 2 (5000 nm with 8 pax and 200 nm at 0.80)
%  9: Range out of Aspen (2600 nm disa 30 alt 7821.522 ft)
% 10: Range out of Hilton Head (3600 nm disa 25 alt 15)

% MR&O Targets (High Speed)
target_aeoceiling   = 41000;
target_time2climb   = 25*60;
target_mission1     = 4700;
target_mission2     = 5000;
target_outAspen     = 2600;
target_outHiltonH   = 3600;

% MR&O Target (Low Speed)
target_TOFLaspen    = 8000;
target_TOFLhilton   = 4300;
target_clbAspen     = 3.6 + 0.8;
target_TOFL_SL      = 5100;
target_TOFL_5000    = 7000;
target_LFL          = 5000;

%% load matrix containing aircraft performance data
[ results, all_wingS, all_thrfct ] = ...
    carpetplt_airplanes(vector_MTOW, baseline_thrust, ...
    vector_wingS, vector_thrfct);

%% Carpet Plot

target_1 = target_mission1;
dim3rd_1 = 7;
target_2 = target_mission2;
dim3rd_2 = 8;
target_3 = target_aeoceiling;
dim3rd_3 = 5;
target_4 = target_time2climb;
dim3rd_4 = 6;
target_5 = target_TOFLaspen;
dim3rd_5 = 11;
target_6 = target_TOFLhilton;
dim3rd_6 = 12;
target_7 = target_clbAspen;
dim3rd_7 = 13;
target_8 = target_TOFL_SL;
dim3rd_8 = 20;
target_9 = target_TOFL_5000;
dim3rd_9 = 19;
target_10 = target_LFL;
dim3rd_10 = 18;

% Create all instances vector
k = 1;
all_MTOW = zeros(1, size(results,1)*size(results,2));
for i = 1:size(results,1)
    for j = 1:size(results, 2)
        all_MTOW(k) = results(i,j,1);
        k = k + 1;
    end
end
clear i
clear j
clear k

for i = 1:length(vector_wingS)
    constraint1(i) = interp1(results(i,:, dim3rd_1), vector_thrfct, target_1, 'linear', 'extrap');
end
for i = 1:length(vector_wingS)
    constraint2(i) = interp1(results(i,:,dim3rd_2), vector_thrfct, target_2, 'linear', 'extrap');
end
for i = 1:length(vector_wingS)
    constraint3(i) = interp1(results(i,:, dim3rd_3), vector_thrfct, target_3, 'linear', 'extrap');
end
for i = 1:length(vector_wingS)
    constraint4(i) = interp1(results(i,:, dim3rd_4), vector_thrfct, target_4, 'linear', 'extrap');
end
for i = 1:length(vector_thrfct)
    constraint5(i) = interp1(results(:,i, dim3rd_5),  vector_wingS, target_5, 'linear', 'extrap');
end
% for i = 1:length(vector_wingS)
%     constraint5(i) = interp1(results(:,i, dim3rd_5), vector_thrfct, target_5, 'linear', 'extrap');
% end
for i = 1:length(vector_wingS)
    constraint6(i) = interp1(results(i,:, dim3rd_6),  vector_thrfct, target_6, 'linear', 'extrap');
end
for i = 1:length(vector_wingS)
    constraint7(i) = interp1(results(i,:, dim3rd_7),  vector_thrfct, target_7, 'linear', 'extrap');
end
for i = 1:length(vector_wingS)
    constraint8(i) = interp1(results(i,:, dim3rd_8),  vector_thrfct, target_8, 'linear', 'extrap');
end
for i = 1:length(vector_wingS)
    constraint9(i) = interp1(results(i,:, dim3rd_9),  vector_thrfct, target_9, 'linear', 'extrap');
end
for i = 1:length(vector_thrfct)
    constraint10(i) = interp1(results(:,i, dim3rd_10),  vector_wingS, target_10, 'linear', 'extrap');
end

% Create the object and plot it
hold off;
o = carpetplot(all_wingS, all_thrfct, all_MTOW);

ylabel('MTOW (lb)')
try
    alabel(o,'Wing Area (ft2)');
catch exception
end
try
    label = strcat('Thrust factor (Ref. Thrust = ', num2str(baseline_thrust), ' lbf)');
    blabel(o,label);
catch exception
end

hold on

% Range Mission 1 and 2
% a = hatchedline(o, vector_wingS, constraint1, '-r',  -45*pi/180);
% b = hatchedline(o, vector_wingS, constraint2, '-g',  -45*pi/180);

% AEO Ceiling
c = hatchedline(o, vector_wingS, constraint3, '-m',  -45*pi/180);
% Time to climb
%d = hatchedline(o, vector_wingS, constraint4, '-k',  -45*pi/180);

% TOFL at Aspen
%e = hatchedline(o,  constraint5, vector_thrfct, '-.m',  -45*pi/180);

% TOFL at Hilton Head
f = hatchedline(o,  vector_wingS, constraint6, '-.c',  -45*pi/180);

% Climb Gradient at Aspen
g = hatchedline(o,  vector_wingS, constraint7, '-.r',  -45*pi/180);
% TOFL at SL
h = hatchedline(o,  vector_wingS, constraint8, '-.g',  -45*pi/180);
% TOFL at 5000 ft
i = hatchedline(o,  vector_wingS, constraint9, '-.b',  -45*pi/180);
% LFL
j = hatchedline(o, constraint10, vector_thrfct, '-.k',  45*pi/180);

%%
% plot(3,1,'-m',4,1,'-k',6,1,'-.r',7,1,'-.g',8,1,'-.b')
% legend('AEO Ceiling','Time to Climb to FL410','Climb Gradient Aspen','TOFL SL','TOFL 5000 ft')