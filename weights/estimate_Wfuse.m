% Estimate Wfuse
% Created by Lucas
% Last Modified by Lucas
% Update: 2020/February/4
function [ W_fuse ] = estimate_Wfuse(airplane)

    % Import Data From Class
    % MTOW = airplane.MTOW;
    
    % Assumptions
    k_gear  = 1.0;  % 1.0 for wing-mounted landing gears
    k_floor = 1.0;  % 1.0 for conventional doors (not cargo)
    k_decks = 1.07; % 1.07 for one-deck airplanes (not double decker)
    
    % Dive Speed (VMO + 30 KCAS)
    V_D = airplane.speed_dive; 
    
    % Fuselage Wetted Area
    S_wetfuse = airplane.fuse_Swet;
    
    % h-Tail Arm
    % 1/2 wing MAC to 1/2 h-Tail MAC
    l_h = airplane.tail_lh;
    
    % Fuselage Height 
    h_fuse = airplane.fuse_h; % [ft] 4.5 in of skin thickness
    
    % Fuselage Diameter
    d_fuse = airplane.fuse_d; % [ft] 4.5 in of skin thickness
    
    % Calculations
    k_f = 1.1 * k_gear * k_floor * k_decks;
    W_fuse = 1.25 * 0.021 * k_f * ...
        sqrt((V_D * l_h)/(d_fuse + h_fuse)) * S_wetfuse ^ 1.2;

end