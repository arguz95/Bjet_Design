% Tail weight estimation
% Created by Arnaud
% Last Modified by Lucas
% Date: 2020/February/9

function [ Wtail] = estimate_Wtail(airplane)
       
    % Htail (Torenbeek)
    % Sh - Htail Area - ft2
    % VD - Dive Speed = VMO + 30 knots - KCAS
    % Phi50 hstab - Htail 50% Chord Sweep - deg
    
    % Vtail (Raymer)
    % Sv - Vtail Area - ft2
    % Lv - Vtail Arm = 0.5 Wing MAC to 0.5 Vtail MAC - ft - MAC: Mean Aerodynamic Chord
    % ARv - Vtail Aspect Ratio - n/a
    % t/c vroot - Vtail Root Relative Thickness - n/a
    % Phi25 vstab Vtail 25% Chord Sweep - deg

    %% Data Entry
    % Import Data From Class
    MTOW = airplane.MTOW;

    % Htail (Torenbeek)
    Sh = airplane.tail_Sh;      % From picture measurement G500
    VD = airplane.speed_dive;   % VMO: maximum operating speed - From G500 : MA 0.889 = 587.54 kts
    Phi50_hstab = 25.5*pi/180;  % From picture measurement G500

    % Vtail (Raymer)
    Sv = airplane.tail_Sv; % From picture measurement G500
    Lv = airplane.tail_lv; %From picture measurement G500
    ARv = airplane.tail_ARv; % From Preliminary tail sizing table
    t_c = airplane.tail_tcratio; % From Preliminary tail sizing table: 10%
    
    %% Assumptions and Calculations

    W_H_tail=Sh*((3.81*(Sh^0.2)*VD)/(1000*sqrt(cos(Phi50_hstab)))-0.287)*1.1;
    Phi25_vstab = 40.5*pi/180; % From picture measurement G500
    Nult = 1.5*2.5;     % Ultimate design load with a SF of 1.5
    hv = 1.0;           % "T" Configuration
    
    W_V_tail = 0.0026*((1+hv)^0.225)*(MTOW^0.556)*(Nult^0.536)*(Lv^-0.5)*(Lv^0.875)*(Sv^0.5)*((cos(Phi25_vstab))^-1)*(ARv^0.35)*(t_c^-0.5);

    % Total Weight:
    Wtail = W_H_tail + W_V_tail;

end