function [ vtas, veas, vcas, mach, dynQ ] = speed_cvt( speed, type, alt_ft, disa_degC )
% Author: Luc St-Michel
% Date:   November 26, 2013
% Rev.:   Beta
%
%
% Function that concert speeds (mach and knots)
%
% Required function : atmos.m
%
% Inputs:   alt_ft    pressre altitude in feet
%           disa      air temperature, deviation from ISA in deg C
%
%           type:  1      VTAS in kts
%                  2      VEAS in kts
%                  3      VCAS in kts
%                  4      Mach
%
% Outputs   VTAS, VEAS, VCAS, Mach
%           dynQ      dynamic pressure 1/2 rho V?2 - lbf/ft?2   
%
%

    gamma = 1.4;

    [ tisa_cel, theta, sigma, delta ] = atmos( alt_ft, disa_degC );

    a0_fps = power((1.4 * 32.17 * 53.35 * 288.15 * 1.8),0.5); % speed of sound in ft/sec at SL, ISA
    a0_kts = a0_fps / 6076.115*3600.;

    oat_degK = tisa_cel + disa_degC + 273.115; % outside air temperature in Kelvin

    a_fps = power((1.4 * 32.17 * 53.35 * oat_degK * 1.8),0.5); % speed of sound at given coudition (Alt, temp)
    a_kts = a_fps / 6076.115*3600.;

    if (type == 1) % speed is given in VTAS
       vtas = speed;
       mach = vtas / a_kts;
       veas = vtas * power(sigma,0.5);
       vcas = power((power((power(1 + (gamma-1)/2 * power(mach,2),gamma/(gamma -1 )) - 1)*delta+1,(gamma-1)/gamma)-1)*2/(gamma-1),0.5)*a0_kts;
    elseif (type == 2) % speed is given in VEAS
        veas = speed;
        vtas = veas/power(sigma,0.5);
        mach = vtas / a_kts;
        vcas = power((power((power(1 + (gamma-1)/2 * power(mach,2),gamma/(gamma -1 )) - 1)*delta+1,(gamma-1)/gamma)-1)*2/(gamma-1),0.5)*a0_kts;
    elseif (type == 3) % speed is given in VCAS
        vcas = speed;
        mach = power((power(  (power(1+(gamma -1)/2*power(vcas/a0_kts,2), gamma/(gamma -1))-1)/delta+1,(gamma -1)/gamma)-1)*2/(gamma-1),0.5);
        vtas = mach * a_kts;
        veas = vtas*power(sigma,0.5);
    elseif (type == 4) % speed is given in Mach
        mach = speed;
        vtas = mach * a_kts;
        veas = vtas*power(sigma,0.5);
        vcas = power((power((power(1 + (gamma-1)/2 * power(mach,2),gamma/(gamma -1 )) - 1)*delta+1,(gamma-1)/gamma)-1)*2/(gamma-1),0.5)*a0_kts;
    end

    dynQ = 0.5 * gamma * 14.696 * delta * power(mach,2) * 144.; %lbf /sq ft
end

