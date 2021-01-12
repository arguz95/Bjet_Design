% Engine weight estimation
% Created by: Paul/Florian
% Last Modified by: Lucas
% Date: 2020/feb/9

function [Wppt] = estimate_Wppt(airplane, sf)

    % Import Data From Class
    % MTOW = airplane.MTOW;
    BPR = airplane.ppt_BPR;     % Bypass ratio
    Neng = airplane.ppt_Neng;   % Number of Engines
    Tsls = sf * airplane.ppt_Tsls;   % (lbf) Sea Level Static Thrust for one engine

    %% Calculations
    Weng = 0.215 * Tsls; %(lbf) engine weight per engine
    Wnacelle = (0.0143*BPR+0.2143) * Weng; %(lbf) Nacelle weight per engine
    Wpylon = 0.7 * (Weng)^0.736; %(lbf) Pylon weight per engine
    Wppt = Neng * (Weng + Wpylon + Wnacelle); %(lbf) Powerplant total weight

end