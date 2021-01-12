function [ ceiling, time2climb ] = ...
     perf_climbceiling(MTOW, airplane, sf)

% Luc St-Michel, February 24, 2019, Rev. --
% Example of cumumulative aircraft performance climb calculation
% To simplify example, a fix L/D of 15 is used throughout
% Aircraft is climbing following a climb speed schedule of 
% 250 KCAS / 0.75 M

% Modified: Lucas Monteiro Rosado
% Date: 2020/4/5

%% Comment This - For testing purposes only
% clear variables
% clc
% 
% MTOW = 75000.;
% airplane = ourBjet;
% sf = 1.2;

%% Import Data From Class

neng = airplane.ppt_Neng;       % [-] Number of Engines
bpr = airplane.ppt_BPR;         % [-] By-pass Ratio

%% Assumptions

disa = 0.;

% Speeds for Climb Schedule
vcas_clbsdl = 250.;
mach_clbsdl = 0.80;

%% Engine Data Import

if bpr == 4
    [ engdata_clb ] = read_thr_file( 'POLY_ldmf_bpr40_mcl_lo_off.dat' );
    [ engdata_mto ] = read_thr_file( 'POLY_ldmf_bpr40_mto_off_off.dat');
elseif bpr == 5
    [ engdata_clb ] = read_thr_file( 'POLY_ldmf_bpr50_mcl_lo_off.dat' );
    [ engdata_mto ] = read_thr_file( 'POLY_ldmf_bpr50_mto_off_off.dat');
elseif bpr == 6.5
    [ engdata_clb ] = read_thr_file( 'POLY_ldmf_bpr65_mcl_lo_off.dat' );
    [ engdata_mto ] = read_thr_file( 'POLY_ldmf_bpr65_mto_off_off.dat');
end

%% Preallocation

wgt = 0.97*MTOW;
alt = 0;
time = 0;  % Preallocation
roc = 301; % Preallocation just to get in the loop
time2climb = 0;

%% Loop
while roc > 300

    % get Mach number at each altitude step      
    [ vtas_clb_vcas, ~, ~, mach_clb_vcas, ~ ] = speed_cvt( vcas_clbsdl, 3, alt, disa );
    [ vtas_clb_mach, ~, ~, mach_clb_mach, ~ ] = speed_cvt( mach_clbsdl, 4, alt, disa );

    mach_clb  = min(mach_clb_vcas, mach_clb_mach);
    vtas_clb  = min(vtas_clb_vcas, vtas_clb_mach);

    % convert kts to ft/min
    vtas_clb_fpm = vtas_clb * 6076.115 / 60.0;

    % Climb Thrust
    if alt > 1500
        [thr, wf] = interp_clb(engdata_clb, alt, mach_clb, disa);
    else
        [thr, wf] = interp_clb(engdata_mto, alt, mach_clb, disa);
    end

    % Aerodynamics
    LDratio = aero_LDratio(airplane, wgt, alt, mach_clb, disa);
    
    % Rate of Climb
    roc = ((sf * thr * neng) / wgt - 1/LDratio) * vtas_clb_fpm;
        
    % Iteration
    alt = alt + roc/60;
    time = time + 1;
    %wgt = wgt - neng * sf * wf /(60*60);

    % Time 2 climb to 41000 ft
    if (alt > 41000) && (time2climb < time)
        time2climb = time;
    end
    
%     if alt > 40980 && alt < 41020
%        wgt
%        alt
%        roc
%     end
    
end

% Get Result
ceiling = alt;

% Section to provide results around target to avoid interpolation error
% during Carpet Plot
if time2climb == 0
    time2climb = 1501 + rand(); % Target of 1500 s
end

end

%% Unused
% while

%last_alt_index = ialt - 1;

%plot(roc(1:last_alt_index), alt(1:last_alt_index), lstyle, 'Color', lcolor,'LineWidth',1.5);

%hold all;
    
% grid on
% set(gca, 'GridLineStyle', '-');
% grid(gca,'minor')
% title('Maximum Climb Speed Schedule 250 / 0.75 M','FontWeight','Bold','FontSize',12)
% 
% xlabel('Rate of Climb (ft/min)','FontWeight','Bold','FontSize',12);
% ylabel('Altitude (ft)','FontWeight','Bold','FontSize',12);
% legend(legcell);
% 
% error = 0;
