function [ range, wgt_fuel, TOW_4mission ] = ...
    perf_mission(airplane, wgt_MTOW, wgt_OWE, wgt_fuel_max, sf, alt_TO, disa, cruise_type, range_goal)
% clear variables
% clc

%% Either Import from Class or Test Function
% Comment the following for integration

% Data Entry
% sf = 1.24;              % [-] Thrust Factor
% neng = 2;               % [-] Number of Engines
% bpr = 5;                % [-] By-pass Ratio
% wgt_MTOW = 74000;       % [lb]
% wgt_OWE = 42760;        % [lb]
% cruise_type = 2;        % [1 for MRC, 2 for LRC]
% disa = 0;               % [deg C]
% alt_TO = 4000;          % [ft]
% airplane = ourBjet;

%% Import Data From Class
% Leave this commented for testing purposes

neng = airplane.ppt_Neng;       % [-] Number of Engines
bpr = airplane.ppt_BPR;         % [-] By-pass Ratio

%% Mission Assumptions

ai = 1;                     % [-] 0 (AI off) or 1 (WCAI on)
wgt_payload = 8 * 225;     % [lb]
alt_end = 0;                % [ft]
alt_initialcruise = 41000;  % [ft]
alt_stepIncrement =  4000;  % [ft]
qty_stepclimb = 1;          % [-] only 1 valid
spd_vcas_ref = 250;         % [KCAS]
spd_mach_MRC = 0.83;        % [mach]
spd_mach_LRC = 0.86;        % [mach]
alt_alterncrz = 20000;      % [ft]
spd_mach_alte = 0.61;       % [mach]

%% Derived Conditions - Reference Mach
if cruise_type == 1     % MRC
    spd_mach_ref = spd_mach_MRC;
else                    % LRC
    spd_mach_ref = spd_mach_LRC;
end

%% Read Engine Data

if (bpr == 4)
    [engdata_clb] = read_thr_file('POLY_ldmf_bpr40_mcl_lo_off.dat' );
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr40_mto_off_off.dat');
    [engdata_crz] = read_thr_file('POLY_ldmf_bpr40_cr00_lo_off.dat');
elseif (bpr == 5)
    [engdata_clb] = read_thr_file('POLY_ldmf_bpr50_mcl_lo_off.dat' );
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr50_mto_off_off.dat');
    [engdata_crz] = read_thr_file('POLY_ldmf_bpr50_cr00_lo_off.dat');
elseif bpr == 6.5
    [engdata_clb] = read_thr_file('POLY_ldmf_bpr65_mcl_lo_off.dat' );
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr65_mto_off_off.dat');
    [engdata_crz] = read_thr_file('POLY_ldmf_bpr65_cr00_lo_off.dat');
end    

%% Assumed Fuel Allowances
    
% Taxi-out (15 min at SL idle)
[~, wf] = interp_crz(engdata_crz, alt_TO, 0, 4, 0);
wgt_fuel_taxiout = neng * sf * wf * 15/60;

% Take-Off (2 min at MTO, SL, ISA, Mach 0.20)
[~, wf] = interp_clb(engdata_mto, alt_TO, 0.20, 0);
wgt_fuel_TO = neng * sf * wf * 2/60;

% Approach and Landing (4 min at SL idle)
[~, wf] = interp_crz(engdata_crz, 0, 0, 4, 0);
wgt_fuel_appld = neng * sf * wf * 4/60;

% Taxi-in (5 min at SL idle)
[~, wf] = interp_crz(engdata_crz, 0, 0, 4, 0);
wgt_fuel_taxiin = neng * sf * wf * 5/60;

% Total Fuel Allowances
wgt_fuel_allowance = wgt_fuel_taxiout + wgt_fuel_TO + wgt_fuel_appld + wgt_fuel_taxiin;


%% End Conditions of Mission

t = 1;              % in minutes
dist(t) = 0;        % in nautical miles
alt(t) = alt_end;
wgt(t) = wgt_OWE + wgt_payload + wgt_fuel_allowance;

%% Alternate Descent

while alt(t) < alt_alterncrz

    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt(t), disa);
    [vtas_from_mach, ~, ~, mach_from_mach, ~] = speed_cvt(0.61, 4, alt(t), disa);

    mach(t)  = min(mach_from_vcas, mach_from_mach);
    vtas(t)  = min(vtas_from_vcas, vtas_from_mach);

    % convert kts to ft/min
    vtas_fpm(t) = vtas(t) * 6076.115 / 60.0;
    
    % Calibrated Airspeed
    [~, ~, vcas(t), ~, ~ ] = speed_cvt(vtas(t), 1, alt(t), disa );

    % Calculate thrust and apply "Scale Factor" on thrust and fuel flow
    % wf in pph
    [thr, wf] = interp_crz(engdata_crz, alt(t), mach(t), 4, 0);

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    
    % Rate of Climb
    roc = - (sf * thr * neng - wgt(t)/LDratio(t) )/wgt(t) * vtas_fpm(t);

    % Increments (+1 minute)
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t) + roc;
    wgt(t+1) = wgt(t) + neng * sf * wf/60;
    t = t + 1;
    
end

%% Alternate Cruise

while dist(t) < 160
    
    % Fixed Altitude 
    alt(t) = alt_alterncrz;

    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt(t), disa);
    [vtas_from_mach, ~, ~, mach_from_mach, ~] = speed_cvt(spd_mach_alte, 4, alt(t), disa);

    mach(t)  = min(mach_from_vcas, mach_from_mach);
    vtas(t)  = min(vtas_from_vcas, vtas_from_mach);
    
    % Speed
%     vcas(t) = spd_vcas_ref;
%     [vtas(t), ~, vcas(t), mach(t), ~] = speed_cvt(vcas(t), 3, alt(t), disa);
    [~, ~, vcas(t), ~, ~] = speed_cvt(mach(t), 4, alt(t), disa);
    
    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);    
    drag = wgt(t) / LDratio(t);
    
    % Thrust
    thr_reqrd = drag/neng;
    
    % Engine Data
    [~, wfe] = interp_crz(engdata_crz, alt(t), mach(t), 1, thr_reqrd/sf);
    
    % Verify Step Climb
    [thr_stp, ~] = interp_clb(engdata_clb, alt(t), mach(t), 0);
    roc = (sf * thr_stp * neng - drag)/wgt(t) * vtas(t) * 6076.115 / 60.0;
    
    % Increment
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t);
    wgt(t+1) = wgt(t) + neng * sf * wfe/60;
    t = t + 1;   
    
end


%% Alternate Climb

while alt(t) > 5000
    
    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt(t), disa);
    [vtas_from_mach, ~, ~, mach_from_mach, ~] = speed_cvt(0.61, 4, alt(t), disa);

    mach(t)  = min(mach_from_vcas, mach_from_mach);
    vtas(t)  = min(vtas_from_vcas, vtas_from_mach);

    % Thrust and Fuel Flow
    [thr, wf] = interp_clb(engdata_clb, alt(t), mach(t), 0);
    
    % Calibrated Airspeed
    [~, ~, vcas(t), ~, ~ ] = speed_cvt(vtas(t), 1, alt(t), disa );
    
    % convert kts to ft/min
    vtas_fpm = vtas(t) * 6076.115 / 60.0;

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);

    % Rate of Climb
    roc = (sf*thr*neng - drag)/wgt(t) * vtas_fpm;

    % Increments (+1 minute)
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t) - roc;
    wgt(t+1) = wgt(t) + neng * sf * wf/60; 
    t = t + 1;
    
end

%% Alternate Holding

for t2 = 1:1:5
    
    % Fixed Altitude 
    alt(t) = 5000;
    
    % Speed
    vcas(t) = spd_vcas_ref;
    [vtas(t), ~, ~, mach(t), ~] = speed_cvt(vcas(t), 3, alt(t), disa);

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);
    
    % Thrust
    thr_reqrd = drag/neng;
    
    % Engine Data
    [~, wfe] = interp_crz(engdata_crz, alt(t), mach(t), 1, thr_reqrd/sf);
    
    % Verify Step Climb
    [thr_stp, ~] = interp_clb(engdata_clb, alt(t), mach(t), 0);
    roc = (thr_stp*neng - drag)/wgt(t) * vtas(t) * 6076.115 / 60.0;
    
    % Increment
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t);
    wgt(t+1) = wgt(t) + neng*sf*wfe/60;
    t = t + 1;   
    
end

%% Alternate Climb

while alt(t) > 35
    
    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt(t), disa);
    [vtas_from_mach, ~, ~, mach_from_mach, ~] = speed_cvt(spd_mach_ref, 4, alt(t), disa);

    mach(t)  = min(mach_from_vcas, mach_from_mach);
    vtas(t)  = min(vtas_from_vcas, vtas_from_mach);

    % Thrust and Fuel Flow
    [thr, wf] = interp_clb(engdata_clb, alt(t), mach(t), 0);

    % Calibrated Airspeed
    [~, ~, vcas(t), ~, ~ ] = speed_cvt(vtas(t), 1, alt(t), disa );
    
    % convert kts to ft/min
    vtas_fpm = vtas(t) * 6076.115 / 60.0;
    
    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);
    
    % Rate of Climb
    roc = (sf*thr*neng - drag)/wgt(t) * vtas_fpm;

    % Increments (+1 minute)
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t) - roc;
    wgt(t+1) = wgt(t) + neng * sf*wf/60; 
    t = t + 1;
    
end

%% Descent

alt_finalcruise = alt_initialcruise + qty_stepclimb * alt_stepIncrement;

while alt(t) < alt_finalcruise

    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt(t), disa);
    [vtas_from_mach, ~, ~, mach_from_mach, ~] = speed_cvt(spd_mach_ref, 4, alt(t), disa);

    mach(t)  = min(mach_from_vcas, mach_from_mach);
    vtas(t)  = min(vtas_from_vcas, vtas_from_mach);

    % Calibrated Airspeed
    [~, ~, vcas(t), ~, ~ ] = speed_cvt(vtas(t), 1, alt(t), disa );
    
    % convert kts to ft/min
    vtas_fpm(t) = vtas(t) * 6076.115 / 60.0;

    
    % Calculate thrust and apply "Scale Factor" on thrust and fuel flow
    % wf in pph
    [thr, wf] = interp_crz(engdata_crz, alt(t), mach(t), 4, 0);

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);
    
    % Rate of Climb
    roc = - (sf*thr * neng - drag)/wgt(t) * vtas_fpm(t);
    
    % Increments (+1 minute)
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t) + roc;
    wgt(t+1) = wgt(t) +  neng*sf*wf/60; %*neng;
    t = t + 1;
    wgt_fuel = wgt(end) - wgt(1);
    
end

%% Cruise After Step Climb

while roc > 300 && (wgt(t) < 0.97 * wgt_MTOW) && ((dist(t)-200) < (range_goal-100)) && (wgt_fuel < wgt_fuel_max)
    
    % Fixed Altitude 
    alt(t) = alt_finalcruise;
    
    % Speed Definition
    if cruise_type == 1     % MRC
        mach(t) = spd_mach_MRC;
    else                    % LRC
        mach(t) = spd_mach_LRC;
    end

    % Speed Conversion
    [vtas(t), ~, ~, ~, ~]  = speed_cvt(mach(t), 4, alt(t), disa);
    [~, ~, vcas(t), ~, ~ ] = speed_cvt(vtas(t), 1, alt(t), disa );

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);
    
    % Thrust
    thr_reqrd = drag/neng;
    
    % Engine Data
    [~, wfe] = interp_crz(engdata_crz, alt(t), mach(t), 1, thr_reqrd/sf);
    %thr_avail = neng * sf * thr_avail;
    wf_total = neng * sf * wfe;
    
    % Ratio of Thrust
%     ratioTrTa = thr_reqrd / thr_avail;
%     if ratioTrTa > 1
%         ratioTrTa = 1;
%     else
%         ratioTrTa = 1.5 * ratioTrTa;
%     end
%    ratioTrTa = 1;
    
    % Verify Step Climb
    [thr_stp, ~] = interp_clb(engdata_clb, alt(t), mach(t), 0);
    roc = (sf*thr_stp*neng - drag)/wgt(t) * vtas(t) * 6076.115 / 60.0;
    
    % Increment
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t);
    wgt(t+1) = wgt(t) + (wf_total)/60;
    t = t + 1;
    wgt_fuel = wgt(end) - wgt(1);
    
end
     
%% Step Climb

while alt(t) > alt_initialcruise

    % Speed Definition
    if cruise_type == 1     % MRC
        mach(t) = spd_mach_MRC;
    else                    % LRC
        mach(t) = spd_mach_LRC;
    end

    % Speed Conversion
    [vtas(t), ~, ~, ~, ~] = speed_cvt(mach(t), 4, alt(t), disa);
    [~, ~, vcas(t), ~, ~ ] = speed_cvt(vtas(t), 1, alt(t), disa );
    
    % Thrust and Fuel Flow
    [thr, wf] = interp_clb(engdata_clb, alt(t), mach(t), 0);

    % convert kts to ft/min
    vtas_fpm = vtas(t) * 6076.115 / 60.0;

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);

    % Rate of Climb
    roc = (sf*thr*neng - drag)/wgt(t) * vtas_fpm;

    % Increments (+1 minute)
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t) - roc;
    wgt(t+1) = wgt(t) + neng * sf*wf/60; 
    t = t + 1;
    
end

%% Cruise Before Step Climb

% Assumptions
% 200 nm for alternate
% 100 nm for climb
while (roc > 300) && (wgt(t) < 0.97 * wgt_MTOW) && ((dist(t)-200) < (range_goal-100)) && (wgt_fuel < wgt_fuel_max)
    
    % Fixed Altitude 
    alt(t) = alt_initialcruise;
    
    % Speed Definition
    if cruise_type == 1     % MRC
        mach(t) = spd_mach_MRC;
    else                    % LRC
        mach(t) = spd_mach_LRC;
    end
    
    % Speed Conversion
    [vtas(t), ~, ~, ~, ~] = speed_cvt(mach(t), 4, alt(t), disa);
    [~, ~, vcas(t), ~, ~] = speed_cvt(vtas(t), 1, alt(t), disa );    

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);
    
    % Thrust
    thr_reqrd = drag/neng;
    
    % Engine Data
    [~, wfe] = interp_crz(engdata_crz, alt(t), mach(t), 1, thr_reqrd/sf);
    %thr_avail = neng * sf * thr_avail;
    wf_total = neng * sf * wfe;
    
    % Ratio of Thrust
%     ratioTrTa = thr_reqrd / thr_avail;
%     if ratioTrTa > 1
%         ratioTrTa = 1;
%     else
%         ratioTrTa = 1.5 * ratioTrTa;
%     end
     
    % Verify Step Climb
    [thr_stp, ~] = interp_clb(engdata_clb, alt(t), mach(t), 0);
    roc = (sf*thr_stp*neng - drag)/wgt(t) * vtas(t) * 6076.115 / 60.0;

    % Increment
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t);
    wgt(t+1) = wgt(t) + (wf_total)/60;
    t = t + 1;
    wgt_fuel = wgt(end) - wgt(1);
    
end

%% Climb

time2climb = 0;

while alt(t) > alt_TO
    
    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt(t), disa);
    [vtas_from_mach, ~, ~, mach_from_mach, ~] = speed_cvt(spd_mach_ref, 4, alt(t), disa);

    mach(t)  = min(mach_from_vcas, mach_from_mach);
    vtas(t)  = min(vtas_from_vcas, vtas_from_mach);

    % Thrust and Fuel Flow
    [thr, wf] = interp_clb(engdata_clb, alt(t), mach(t), 0);

    % Calibrated Airspeed
    [~, ~, vcas(t), ~, ~ ] = speed_cvt(vtas(t), 1, alt(t), disa );
    
    % convert kts to ft/min
    vtas_fpm = vtas(t) * 6076.115 / 60.0;

    % Aerodynamics
    LDratio(t) = aero_LDratio(airplane, wgt(t), alt(t), mach(t), disa);
    drag = wgt(t)/LDratio(t);
    
    % Rate of Climb
    roc = (sf*thr*neng - drag)/wgt(t) * vtas_fpm;

    % Increments (+1 minute)
    dist(t+1) = dist(t) + vtas(t)/60;
    alt(t+1) = alt(t) - roc;
    wgt(t+1) = wgt(t) + neng * sf*wf/60; 
    t = t + 1;
    time2climb = time2climb + 1;
    
end

%% Results
range = dist(end) - 200;        % Range without 200 nm of reserves
wgt_fuel = wgt(end) - wgt(1);
TOW_4mission = wgt(end);

%% Plot

x = 0:1:(t-2);

subplot(3,2,1)
plot(x, flip(alt(1:length(x))))
ylabel('Altitude (ft)')
% xlim([0 40])
ylim([0 50000])
xlabel('Time (min)')
legend('Altitude (ft)', 'location', 'Southwest')
grid on

subplot(3,2,3)
%yyaxis left
plot(0:1:(length(vtas)-1), flip(vtas), 'k', 0:1:(length(vcas)-1), flip(vcas), '-b')
ylabel('Airspeed (knots)')
% xlim([0 40])
ylim([200 500])
xlabel('Time (min)')
legend('True Airspeed (knots)', 'Calibrated Airspeed (knots)', 'location', 'Southeast')
grid on

subplot(3,2,5)
%yyaxis right
plot(0:1:(length(mach)-1), flip(mach), '-.r')
ylabel('Mach')
% xlim([0 40])
ylim([0.2 0.88])
legend('Mach', 'location', 'Southeast')
grid on

subplot(3,2,2)
plot(0:1:(length(wgt)-1), flip(wgt))
legend('Aircraft Weight', 'location', 'Southwest')
% xlim([0 40])
ylabel('Weight (lb)')
xlabel('Time (min)')
grid on

subplot(3,2,4)

dist2 = dist(end) - flip(dist);
plot(0:1:(length(dist2)-1), dist2)
legend('Air Distance', 'location', 'Southeast')
% xlim([0 40])
ylabel('Distance (nm)')
xlabel('Time (min)')
grid on

subplot(3,2,6)
plot(0:1:(length(LDratio)-1), flip(LDratio))
legend('L/D Ratio', 'location', 'Southwest')
% xlim([0 40])
ylabel('L/D Ratio')
xlabel('Time (min)')
grid on

end

