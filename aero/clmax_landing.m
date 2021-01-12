function [Clmax_landing] = clmax_landing(airplane, MTOW, alt_ft, disa)
    
    ro_0 = 0.076474; %lb/ft3 sea level isa 
    %ro_0 = 0.0023772; %slug/ft3 
    
    g = 32.17; 
    
    MLW  = 0.80 * MTOW; % Approximation from Course Notes
    
    S = airplane.wing_S;    % [ft2]
    
    Clmax_landing = 2.45;
    
    [ ~, ~, sigma, ~ ] = atmos( alt_ft, disa );
    
    Vstall = sqrt((2*MLW) /((ro_0)*sigma*S*Clmax_landing)); 
    
    Delta_Vstall = 10;
    
    while Delta_Vstall > 0.1
        Vstall = Vstall + 0.01;
        Clmax_landing = (2*MLW)/(ro_0*sigma*Vstall^2*S);
        Vstall_2 = sqrt((2*MLW) /((ro_0)*sigma*S*Clmax_landing)); 
        Delta_Vstall = abs(Vstall-Vstall_2);
    end
    
end