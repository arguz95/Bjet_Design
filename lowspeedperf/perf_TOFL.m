function [TOFL_SL, TOFL_5000, LFL] = perf_TOFL(airplane, MTOW, sf)

    % Assumptions
    g = 32.17; 
    ro_0 = 0.0023772;
    Clmax_landing = 2.68; %excel aero (Clean Cl 2D = 2.2)
    Clmax_20 = Clmax_landing*0.8; %flap 20

    %% Data Entry from Object

    S = airplane.wing_S;
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
    [~, wf] = interp_crz(engdata_crz, 0, 0, 4, 0);
    wgt_fuel_taxiout = neng * sf * wf * 15/60;

    % Take-Off (2 min at MTO, SL, ISA, Mach 0.20)
    [~, wf] = interp_clb(engdata_mto, 0, 0.20, 15);
    wgt_fuel_TO = neng * sf * wf * 2/60;
    
    % TOW
    TOW = MTOW - wgt_fuel_taxiout - wgt_fuel_TO;

    %% LFL 5000 ft @ MTOW SL ISA

    disa = 0;

    [~,~,sigma,~] = atmos( 0, disa );
    Vstall_20 = (sqrt( TOW /( 0.5 * ro_0 * sigma * S * Clmax_20))) / 1.688;
    V2_20 = 1.23 * Vstall_20;

    R=(V2_20^2)/(g*0.08);
    Air_dist=(50/tan(3*pi/180))+R*sin(3/2*pi/180);

    Vtd = 1.15*sqrt((2*0.8*MTOW) /((ro_0)*sigma*S*Clmax_landing));
    Sgl = 3 * Vtd;
    Sv = (Vtd^2)/(1.2*g);
    Ground_dist = Sgl + Sv;

    ALD = Ground_dist + Air_dist;
    LFL = ALD/0.6;
    
    %% TOFL 5000 ft @ MTOW SL ISA +15

    disa = 15;

    [~,~,sigma,~] = atmos( 0, disa );

    Vstall_20 = (sqrt( TOW /( 0.5 * ro_0 * sigma * S * Clmax_20))) / 1.688;
    V2_20 = 1.23 * Vstall_20;

    %Thrust determination for take off with given TOFL and Sref
    [ ~, ~, ~, mach, ~ ] = speed_cvt( V2_20, 3, 0, disa);
    [thr, ~] = interp_clb(engdata_mto, 0, mach, disa);

    TOP = (TOW^2)/(Clmax_20 * (sf*thr*neng) * S *sigma^0.8);
    TOFL_SL = 150 + 28.43*TOP + 0.0185*TOP^2;
    
    %% TOW 
    
    % Taxi-out (15 min at SL idle)
    [~, wf] = interp_crz(engdata_crz, 5000, 0, 4, 0);
    wgt_fuel_taxiout = neng * sf * wf * 15/60;

    % Take-Off (2 min at MTO, SL, ISA, Mach 0.20)
    [~, wf] = interp_clb(engdata_mto, 5000, 0.20, 25);
    wgt_fuel_TO = neng * sf * wf * 2/60;
    
    % TOW
    TOW = MTOW - wgt_fuel_taxiout - wgt_fuel_TO;
    
    %% TOFL 7000 @ MTOW 5000 ft ISA +25

    disa = 25;

    [~,~,sigma,~] = atmos( 5000, disa );

    Vstall_20 = (sqrt( TOW /( 0.5 * ro_0 * sigma * S * Clmax_20))) / 1.688;
    V2_20 = 1.23 * Vstall_20;

    %Thrust determination for take off with given TOFL and Sref
    [ ~, ~, ~, mach, ~ ] = speed_cvt( V2_20, 3, 5000, disa);
    [thr, ~] = interp_clb(engdata_mto, 5000, mach, disa);

    TOP = (TOW^2)/(Clmax_20 * (sf*thr*neng) * S *sigma^0.8);
    TOFL_5000 = 150 + 28.43*TOP + 0.0185*TOP^2;



end