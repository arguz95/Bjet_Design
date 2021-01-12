% Low speed calculation of LFL and TOFL
% Created by: Paul, , Arnaud
% Last Modified by: Paul, Lucas, Arnaud
% Date: 2020/april/9

%we took the TOFL of aspen and hitlon to calculate the Thrust

function [TOFL_Hilton] = perf_TOFLhilton(airplane, MTOW, TOW, sf)
%% Assumptions


% altft Aspen = 7815 disa = 30; alft hilton = 20, disa = 15
g = 32.17; 
ro_0 = 0.0023772;
%Aspen = flap 10 ; Hilton = flap 20
Clmax_landing = 2.68; %excel aero (Clean Cl 2D = 2.2)
Clmax_20 = Clmax_landing*0.8; %flap 20
Clmax_10 = Clmax_landing*0.7; %flap 10
ai = 0.75; % Anti-Ice Penalty

% at Hilton
alt_ft = 20; % [ft]
disa = 25;

%% Data Entry from Object

S = airplane.wing_S;
neng = airplane.ppt_Neng;       % [-] Number of Engines
bpr = airplane.ppt_BPR;         % [-] By-pass Ratio

%% Read Engine Data

if (bpr == 4)
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr40_mto_off_off.dat');
elseif (bpr == 5)
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr50_mto_off_off.dat');
elseif bpr == 6.5
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr65_mto_off_off.dat');
end    

%% Hilton Head


[~,~,sigma,~] = atmos( alt_ft, disa );

Vstall_20 = (sqrt( TOW /( 0.5 * ro_0 * sigma * S * Clmax_20))) / 1.688;
V2_20 = 1.23 * Vstall_20;

% R_Hilton=(V2_20^2)/(g*0.08); %ft
% %a_Hilton=(Vflare_Hilton^2)/R_Hilton;
% Air_dist_Hilton=(50/tan(3*pi/180))+R_Hilton*sin(3/2*pi/180);
% 
% Vtd_Hilton = 1.15*sqrt((2*MLW) /((ro_0)*sigma*S*Clmax_landing));
% Sgl_Hilton = 3 * Vtd_Hilton;
% Sv_Hilton = (Vtd_Hilton^2)/(1.2*g);
% Ground_dist_Hilton = Sgl_Hilton + Sv_Hilton;
% 
% ALD_Hilton = Ground_dist_Hilton + Air_dist_Hilton;
% LFL_Hilton = ALD_Hilton/0.6;

%Thrust determination for take off with given TOFL and Sref
[ ~, ~, ~, mach, ~ ] = speed_cvt( V2_20, 3, alt_ft, disa);
[thr, ~] = interp_clb(engdata_mto, alt_ft, mach, disa);

TOP_Hilton = (TOW^2)/(Clmax_20 * (ai*sf*thr*neng) * S *sigma^0.8);
TOFL_Hilton = 150 + 28.43*TOP_Hilton + 0.0185*TOP_Hilton^2;

end