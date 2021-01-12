% Low speed calculation of thrust, LFL and TOFL
% Created by: Paul, Pierre, Arnaud
% Last Modified by: Paul, Pierre, Arnaud
% Date: 2020/april/8

%we took the TOFL of aspen and hitlon to calculate the Thrust

function [TOFL_Aspen] = perf_TOFLaspen(airplane, MTOW, MLW, sf)

%% Data Entry for Testing Purposes
% Leave this section commented when function is ready

% airplane = ourBjet;
% MTOW = 75000;
% MLW = 0.8 * MTOW;
% sf = 1.2;

%% Assumptions

% 8 pax au lieu de 12 pax
MTOW = MTOW - 4 * 225;

% altft Aspen = 7815 disa = 30; alft hilton = 20, disa = 15
g = 32.17; 
ro_0 = 0.002377; % lb/ft3 sea level isa 
%Aspen = flap 10 ; Hilton = flap 20
Clmax_landing = 2.68; %excel aero
Clmax_20 = Clmax_landing*0.8; %flap 20
Clmax_10 = Clmax_landing*0.7; %flap 10

% at Aspen
alt_ft = 7815; % [ft]
disa = 30;

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

%% Aspen

[~,~,sigma,~] = atmos( alt_ft, disa );

Vstall_10=sqrt((2*MTOW) /((ro_0)*sigma*S*Clmax_10));
V2_10=1.2*Vstall_10;
%Vflare_Aspen=sqrt((2*MLW*g*1.08) /((ro_0)*sigma*S*Clmax_landing));

R_Aspen=(V2_10^2)/(g*0.08); %ft
%a_Aspen=(Vflare_Aspen^2)/R_Aspen;
Air_dist_Aspen=(50/tan(3*pi/180))+R_Aspen*sin(3/2*pi/180);

Vtd_Aspen=1.15*sqrt((2*MLW) /((ro_0)*sigma*S*Clmax_landing));
Sgl_Aspen=3*Vtd_Aspen;
Sv_Aspen=(Vtd_Aspen^2)/(1.2*g);
Ground_dist_Aspen=Sgl_Aspen+Sv_Aspen;

ALD_Aspen=Ground_dist_Aspen+Air_dist_Aspen;
LFL_Aspen=ALD_Aspen/0.6;

%Thrust determination for take off with given TOFL and Sref
[ ~, ~, ~, mach, ~ ] = speed_cvt( V2_10, 1, alt_ft, disa);
[thr, ~] = interp_clb(engdata_mto, alt_ft, mach, disa);

TOP_Aspen=(MTOW^2)/(Clmax_10* (sf*thr*neng) *S*sigma^0.8);
TOFL_Aspen = 150+28.43*TOP_Aspen+0.0185*TOP_Aspen^2;

end

%% Unused
% %% Hilton
% alt_ft=20; %ft
% disa=15;
% [ tisa_cel, theta, sigma, delta ] = atmos( alt_ft, disa );
% 
% MLW=MTOW-15000; %A MODIFER
% %Vstall_20=sqrt((2*MTOW*g) /((ro_0)*sigma*S*Clmax_20));
% %V2_20=1.2*Vstall_20;
% 
% Vflare_Hilton=sqrt((2*MLW*g*1.08) /((ro_0)*sigma*S*Clmax_landing));
% 
% R_Hilton=(Vflare_Hilton^2)/(g*0.08); %ft
% %a_Hilton=(Vflare_Hilton^2)/R_Hilton;
% Air_dist_Hilton=(50/tan(3*pi/180))+R_Hilton*sin(3/2*pi/180);
% 
% Vtd_Hilton=1.15*sqrt((2*MLW*g) /((ro_0)*sigma*S*Clmax_landing));
% Sgl_Hilton=3*Vtd_Hilton;
% Sv_Hilton=(Vtd_Hilton^2)/(1.2*g);
% Ground_dist_Hilton=Sgl_Hilton+Sv_Hilton;
% 
% ALD_Hilton=Ground_dist_Hilton+Air_dist_Hilton;
% LFL_Hilton=ALD_Hilton/0.6;
% 
% 
% %Thrust determination for take off with given TOFL and Sref
% Thrust_Hilton=7000;
% TOP_Hilton=(MTOW^2)/(Clmax_20*Thrust_Hilton*n*S*sigma^0.8);
% TOFL_Hilton=150+28.43*TOP_Hilton+0.0185*TOP_Hilton^2;
% while TOFL_Hilton >= 4300;
%     Thrust_Hilton=Thrust_Hilton+50;
%     TOP_Hilton=(MTOW^2)/(Clmax_20*Thrust_Hilton*n*S*sigma^0.8);
%     TOFL_Hilton=150+28.43*TOP_Hilton+0.0185*TOP_Hilton^2;
% end;
% Thrust_Hilton;
% %%
% %Sea level
% 
% alt_ft=0; %ft
% disa=0;
% [ tisa_cel, theta, sigma, delta ] = atmos( alt_ft, disa );
% 
% MLW=MTOW-15000; %A MODIFER
% %Vstall_10=sqrt((2*MTOW*g) /((ro_0)*sigma*S*Clmax_10));
% %V2_10=1.2*Vstall_10;
% Vflare_SL=sqrt((2*MLW*g*1.08) /((ro_0)*sigma*S*Clmax_landing));
% 
% R_SL=(Vflare_SL^2)/(g*0.08); %ft
% %a_SL=(Vflare_SL^2)/R_SL;
% Air_dist_SL=(50/tan(3*pi/180))+R_SL*sin(3/2*pi/180);
% 
% Vtd_SL=1.15*sqrt((2*MLW*g) /((ro_0)*sigma*S*Clmax_landing));
% Sgl_SL=3*Vtd_SL;
% Sv_SL=(Vtd_SL^2)/(1.2*g);
% Ground_dist_SL=Sgl_SL+Sv_SL;
% 
% ALD_SL=Ground_dist_SL+Air_dist_SL;
% LFL_SL=ALD_SL/0.6;
% 
% %Thrust determination for take off with given TOFL and Sref
% Thrust_SL=8000;
% TOP_SL=(MTOW^2)/(Clmax_10*Thrust_SL*n*S*sigma^0.8);
% TOFL_SL=150+28.43*TOP_SL+0.0185*TOP_SL^2;
% while TOFL_SL >=8000;
%     Thrust_SL=Thrust_SL+50;
%     TOP_SL=(MTOW^2)/(Clmax_10*Thrust_SL*n*S*sigma^0.8);
%     TOFL_SL=150+28.43*TOP_SL+0.0185*TOP_SL^2;
% end;
% Thrust_SL;
% end



