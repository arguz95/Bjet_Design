% Wing weight estimation
% Created by Pierre
% Last Modified by Lucas 
% Date: 2020/February/8

function [Wwing] = estimate_Wwing(airplane)

    % Import Data From Airplane Class
    MZFW = 0.8 * 0.75 * airplane.MTOW;
    S = airplane.wing_S;
    b = airplane.wing_b;
    troot = airplane.wing_troot;
    phi50 = airplane.wing_phi50;
    
    %Wing Parameters
    %examples based on the Falcon LX900
    %   S=527.432; %Wing are in ft2
    %   b=70.177165; %Wingspan in feet
    %   troot = 10; %Root thickness in feet
    %   phi50 = 1; %Can be estimated from the plane_parameters.m
    %30.864 lb = MZFW of the Falcon LX900
    
    % Fixed Assumptions for Business Jet
    Kflap = 1; %1.02 if fowler flaps
    Kspoiler = 1.02; %1 if no spoiler
    Kgear = 0.95; %1 if mounted gear
    Keng = 1; %0.95 if mounted engine
    
    A = b/cos(phi50);
    B = 1+sqrt(6.3*cos(phi50)/b);
    C = (b*S)/((troot*MZFW*cos(phi50)));
    
    Wwing = 1.3 * 0.0017 * MZFW * (A)^0.75 * ...
        (B) * ((1.5*2.5)^0.55) * (C)^0.3 * ...
        Kflap * Keng * Kgear * Kspoiler;
end