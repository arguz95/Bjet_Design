% Breguet-Leduc Equation
% Created by Lucas
% Last Modified by Lucas
% Date: 2020/February/2
function [ Wfuel ] = breguet_leduc(MTOW, range, sfc, tas, LD)

    % weights [lb]
    % airspeed [KTAS]
    % sfc [lb/h/lbf]
    % thrust [lbf]
    % range [nm]
    
    W1W0 = 0.99;
    W2W1 = 0.98;
    W3W2 = exp(-range * sfc/(tas * LD));
    W4W3 = 0.985;
    W4W0 = W4W3 * W3W2 * W2W1 * W1W0;
    Wfuel = 1.06 * (1 - W4W0) * MTOW;

end