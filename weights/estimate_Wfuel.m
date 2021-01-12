% Estimate Fuel Weight based on MTOW
% Created by Lucas
% Last Modified by Lucas
% Date: 2020/February/2
function [ Wfuel ] = estimate_Wfuel(airplane)

    % Import Data From Class
    MTOW = airplane.MTOW;
    LDratio_MRC = 0.85 * airplane.LDratio_MRC; % 85% of L/D max
    LDratio_LRC = 0.85 * airplane.LDratio_LRC; % 85% of L/D max
    
    %% Option 1 - Range of 5200 nm at M 0.80

    range = 5200+200;
    sfc = 0.62;
    [ tas, ~, ~, ~, ~] = speed_cvt(0.80, 4, 41000, 0);
    LD = LDratio_MRC;

    % Breguet-Leduc
    [ Wfuel_1 ] = breguet_leduc(MTOW, range, sfc, tas, LD);

    %% Option 2 - Range of 4900 nm at M 0.88

    range = 4900+200;
    sfc = 0.64;
    [ tas, ~, ~, ~, ~] = speed_cvt(0.88, 4, 41000, 0);
    LD = LDratio_LRC;

    % Breguet-Leduc
    [ Wfuel_2 ] = breguet_leduc(MTOW, range, sfc, tas, LD);
    
    %% Choose Greatest Wfuel
    Wfuel = max([ Wfuel_1, Wfuel_2 ]);
end