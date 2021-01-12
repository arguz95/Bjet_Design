function [TOFL, LFL] = perf_TOFLmain(airplane, MTOW, TOW, sf, alt, disa)

    % Assumptions
    g = 32.17; 
    rho_0 = 0.0023772;
    Clmax_landing = 2.68; %excel aero (Clean Cl 2D = 2.2)
    Clmax_20 = Clmax_landing * 0.8; %flap 20

    %% Data Entry from Object

    S = airplane.wing_S;            % [ft2] Wing Surface Area
    neng = airplane.ppt_Neng;       % [-] Number of Engines
    bpr = airplane.ppt_BPR;         % [-] By-pass Ratio

    %% Read Engine Data

    if (bpr == 4)
        [engdata_mto] = read_thr_file('POLY_ldmf_bpr40_mto_off_off.dat');
        [engdata_crz] = read_thr_file('POLY_ldmf_bpr40_cr00_lo_off.dat');
    elseif (bpr == 5)
        [engdata_mto] = read_thr_file('POLY_ldmf_bpr50_mto_off_off.dat');
        [engdata_crz] = read_thr_file('POLY_ldmf_bpr50_cr00_lo_off.dat');
    elseif bpr == 6.5
        [engdata_mto] = read_thr_file('POLY_ldmf_bpr65_mto_off_off.dat');
        [engdata_crz] = read_thr_file('POLY_ldmf_bpr65_cr00_lo_off.dat');
    end 
    
    %% TOW 
    
    % Taxi-out (15 min at SL idle)
    [~, wf] = interp_crz(engdata_crz, alt, 0, 4, 0);
    wgt_fuel_taxiout = neng * sf * wf * 15/60;

    % Take-Off (2 min at MTO, SL, ISA, Mach 0.20)
    [~, wf] = interp_clb(engdata_mto, alt, 0.20, disa);
    wgt_fuel_TO = neng * sf * wf * 2/60;
    
    % TOW
    TOW = TOW - wgt_fuel_taxiout - wgt_fuel_TO;

    %% Precalculations

    [~,~,sigma,~] = atmos(alt,disa);
    Vstall_20 = (sqrt( MTOW /( 0.5 * rho_0 * sigma * S * Clmax_20))) / 1.688;
    V2_20 = 1.23 * Vstall_20;
    [ ~, ~, ~, V2_mach, ~ ] = speed_cvt(V2_20, 3, alt, disa);

    %% LFL
    
    R = (V2_20^2)/(g*0.08);
    Air_dist = (50/tan(3*pi/180)) + R*sin(3/2*pi/180);

    Vtd = 1.15 * sqrt((2*MTOW) /((rho_0)*sigma*S*Clmax_landing));
    Sgl = 3 * Vtd;
    Sv = (Vtd^2)/(1.2*g);
    Ground_dist = Sgl + Sv;

    ALD = Ground_dist + Air_dist;
    LFL = ALD/0.6;
    
    %% TOFL 

    % Thrust determination for take off with given TOFL and Sref
    [thr, ~] = interp_clb(engdata_mto, alt, V2_mach, disa);

    TOP = (TOW^2)/(Clmax_20 * (sf*thr*neng) * S *sigma^0.8);
    TOFL = 150 + 28.43*TOP + 0.0185*TOP^2;
    
end