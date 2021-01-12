function [ tisa_cel, theta, sigma, delta ] = atmos( alt_ft, disa )
% Author: Luc St-Michel
% Date:   November 18, 2013
% Rev.:   1.0
%
%
% Function that compute atmosphere properties (delta, sigma, and theta)
%
% Inputs:   alt_ft    pressre altitude in feet
%           disa      air temperature, deviation from ISA in deg C
%
% Outputs:  tisa_cel  ISA air temperature at the given altitude in deg C
%           theta     air temperature to reference temperature ratio (Tamb
%           / 288.15 K)
%           sigma     air density to reference density ratio rho / rho0
%           delta     ambient pressure to reference pressure ratio (pamb /
%           14.696 psia)

    tisa_cel = max(-56.5,15.-0.0019812* alt_ft);
    
    theta = (disa + tisa_cel + 273.15) / 288.15;
    theta_isa = (tisa_cel + 273.15) / 288.15;
    
    if (alt_ft < 36089.) 
        delta = theta^2.121123;
    else
        delta = exp((alt_ft - 36089)/434234);
    end
    
    if (alt_ft < 36089.24)
        delta = power(theta_isa, 5.2561);
    else
        delta = 0.223358 * exp(-( alt_ft - 36089.24 )/20806.7 );
    end
    
    sigma = delta/theta;
        
end

