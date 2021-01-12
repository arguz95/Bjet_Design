% Estimate Wlg
% Created by Lucas
% Last Modified by Lucas
% Update: 2020/February/4
function [W_lg] = estimate_Wlg(airplane)

    % Import Data From Class
    MTOW = airplane.MTOW;

    % kgr - Fixed Assumption
    kgr = 1.0; % 1.0 for low-wing configuration
    
    % Main Landing Gear
    W_mlg = 1.3 * kgr * (33 + 0.04 * MTOW^0.75 + 0.021*MTOW);
    
    % Nose Landing Gear
    W_nlg = 1.3 * (12 + 0.06 * MTOW^0.75);
    
    % Landing Gear Total Weight
    W_lg = W_mlg + W_nlg;

end