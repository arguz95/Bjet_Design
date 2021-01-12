% Estimate MWE
% Created by Lucas
% Last Modified by Lucas
% Update: 2020/February/4
function [ MWE ] = estimate_MWE(W_wing, W_tail, W_fuse, ...
    W_LG, W_ppt, W_sys, W_interior)

    % Technological Factors Chosen
    K_wing1   = 0.88; % Composite Wing K_wing1 = 0.88
    K_wing2   = 0.98; % Fly-by-Wire K_wing2 = 0.98
    K_tail    = 1.00; % Composite Tail K_tail = 0.85
    K_fuse    = 1.00; % Composite Fuselage K_fuse = 0.92
    K_LG      = 1.00; % Composite Landing Gear K_LG = 0.98
    K_ppt     = 0.95; % New Materials K_ppt = 0.95
    delta_sys = -200; % Fly-by-Wire delta_sys = -200
    
    % Course Assumptions 
    % Based on empirical & 2000?s technology
    eta_tuning = 1.1;
    
   
    MWE = eta_tuning * (K_wing1 * K_wing2 * W_wing + ...
        K_tail * W_tail + K_fuse * W_fuse + K_LG * W_LG + ...
        K_ppt * W_ppt + + W_sys + delta_sys) + W_interior;

end