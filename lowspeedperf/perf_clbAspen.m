%Climb OEI


function [gamma1, gamma2] = perf_clbAspen(airplane, MTOW, TOW, sf)
%% Assumptions

% altft Aspen = 7815 disa = 30; alft hilton = 20, disa = 15
g = 32.17; 
rho0 = 0.002377; %0.076474; % lb/ft3 sea level isa 
%Aspen = flap 10 ; Hilton = flap 20
Clmax_landing = 2.61; %excel aero (Clean Cl 2D = 2.2)
Clmax_20 = Clmax_landing*0.8; %flap 20
Clmax_10 = Clmax_landing*0.7; %flap 10

% at Aspen
alt_SO = 9536;  % [ft]
alt_TO = 9225;  % [ft]
alt = 7815;     % [ft]
disa = 30;

%% Data Entry from Object

S = airplane.wing_S;
neng = airplane.ppt_Neng;       % [-] Number of Engines OEI
bpr = airplane.ppt_BPR;         % [-] By-pass Ratio

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
[~, wf] = interp_crz(engdata_crz, alt, 0, 4, 0);
wgt_fuel_taxiout = neng * sf * wf * 15/60;

% Take-Off (2 min at MTO, SL, ISA, Mach 0.20)
[~, wf] = interp_clb(engdata_mto, alt, 0.20, disa);
wgt_fuel_TO = neng * sf * wf * 2/60; %1 engine

% Initial Weight
wgt = TOW - wgt_fuel_taxiout - wgt_fuel_TO;

%% Gradient calculation

[~,~,sigma,~] = atmos( alt, disa );
Vstall_10 = (sqrt( MTOW /(0.5*rho0*sigma*S*Clmax_10))) / 1.688;
V2_10 = 1.23 * Vstall_10;

spd_vcas_ref = V2_10 + 10;         % [KCAS]

dist = 0;   
gamma_available = 0;

%%
while alt < alt_TO

    % First Segment Climb Gradient
    % Calculate Gradient for first obstacle
    if (dist > 7.5) && (gamma_available == 0)
        gamma1 = (alt-7815) / (dist * 6076.12) * 100;
        gamma_available = 1;
        alt_1seg = alt;
        dist_1seg = dist;
    end    
    
    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt, disa);

    % Thrust and Fuel Flow
    [thr, wf] = interp_clb(engdata_clb, alt, mach_from_vcas, 0);
    
    % convert kts to ft/min
    vtas_fpm = vtas_from_vcas * 6076.115 / 60.0;

    % Aerodynamics
    LDratio_oei = aero_LDratio_oei(airplane, wgt, alt, mach_from_vcas, disa);
    drag = wgt/LDratio_oei;
    
    % Rate of Climb
    roc = (sf * thr * 1 - drag)/wgt * vtas_fpm;

    % Increments (+1 minute)
    dist = dist + vtas_from_vcas/60;
    alt = alt + roc;
    wgt = wgt - 1 * sf*wf/60; 
    
end

%% Obstacle Altitude reached before 7.5 nm

if gamma_available == 0
    gamma1 = (alt - 7815) / (dist * 6076.12) * 100;
    gamma_available = 1;
    alt_1seg = alt;
    dist_1seg = dist;
end  

%%
while alt < alt_SO
    
    
    [vtas_from_vcas, ~, ~, mach_from_vcas, ~] = speed_cvt(spd_vcas_ref, 3, alt, disa);


    % Thrust and Fuel Flow
    [thr, wf] = interp_clb(engdata_clb, alt, mach_from_vcas, 0);
    
    
    % convert kts to ft/min
    vtas_fpm = vtas_from_vcas * 6076.115 / 60.0;

    % Aerodynamics
    LDratio_oei = aero_LDratio_oei(airplane, wgt, alt, mach_from_vcas, disa);
    drag = wgt/LDratio_oei;
    
    % Rate of Climb
    roc = (sf*thr*1 - drag)/wgt * vtas_fpm;

    % Increments (+1 minute)
    dist = dist + vtas_from_vcas/60;
    alt = alt + roc;
    wgt = wgt - 1 * sf*wf/60; 

end


%% Second Segment Climb Gradient
% alt
% alt_1seg
% dist
% dist_1seg
if gamma_available == 1
    gamma2 = (alt - alt_1seg) / ((dist - dist_1seg) * 6076.12) * 100;
else
    gamma2 = 0;
    gamma1 = 0;
end
end
