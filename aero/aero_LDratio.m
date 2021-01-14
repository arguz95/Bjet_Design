% Evolution of the Lift to Drag ratio
% Created by: Arnaud
% Last Modified by: Lucas
% Date: 2020/april/7
function [ LDratio ] = aero_LDratio(airplane, wgt, alt, mach, disa)
    
    % Import Data from Class
    S = airplane.wing_S;    % [ft2]
    b = airplane.wing_b;
    Neng = airplane.ppt_Neng;
    
    %% Calculations
    AR = b^2 / S;
    
    %% Assumptions
    e = 0.866;                  % Assumption
    cd_excrescence = 0.002; 

    %% Lift Cofficient     
    [~,~,~,~,dynQ] = speed_cvt(mach, 4, alt, disa);
    cl = wgt /(dynQ * S);
    
    %% Induced Drag Coefficient
    cdi = (cl^2)/(pi*AR*e);    
    
    %% Parasite Drag Coefficient    
    cd0_vtail = 0.00077;        % Assumption
    cd0_htail = 0.00185;        % Assumption
    cd0_pylon = 0.00016;        % Assumption
    cd0_nacel = 0.00096;        % Assumption
    cd0_fuse  = 0.00397;        % Assumption
    
    wing_cf = 0.00257;          % Assumption
    wing_A  = 1.45346;          % Assumption
    wing_Q  = 1.13;             % Assumption
    cd0_wing  = wing_cf * wing_A * wing_Q * ((S*1.75)/S);%0.00735;        % Assumption
    
    cd0 = cd0_wing + cd0_fuse + Neng*cd0_nacel + Neng*cd0_pylon + cd0_htail + cd0_vtail;
    
    %% Compressible Drag Coefficient
    wing_mach_critical  = 0.7996;     % Assumption
    pylon_mach_critical = 0.7623;     % Assumption
    htail_mach_critical = 0.9138;     % Assumption
    vtail_mach_critical = 0.9896;     % Assumption    
    cd_comp = 0;                      % Preallocation
    if mach > wing_mach_critical
        cd_comp = cd_comp + 20 * (mach - wing_mach_critical)^4;
    elseif mach > pylon_mach_critical
        cd_comp = cd_comp + 20 * (mach - pylon_mach_critical)^4;
    elseif mach > htail_mach_critical
        cd_comp = cd_comp + 20 * (mach - htail_mach_critical)^4;
    elseif mach > vtail_mach_critical
        cd_comp = cd_comp + 20 * (mach - vtail_mach_critical)^4;
    end
    
    %% Total Drag Coefficient
    cd = cd0 + cdi + cd_comp + cd_excrescence;
    
    %% Lift to Drag Ratio
    LDratio = cl/cd;
    
end
