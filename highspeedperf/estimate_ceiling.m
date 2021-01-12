% Climb Gradient
% Created by Lucas
% Last Modified by Lucas
% Date: 2020/February/2
function [ceiling] = estimate_ceiling(airplane, MTOW, option)
    
    % Preallocation
    ceiling = -9999;
    
    % Data Entry
    Tsls    = airplane.ppt_Neng * airplane.ppt_Tsls;
    LDratio = airplane.LDratio_MRC;

    % Initial Value
    for ceiling_tentative = 30000:50:51000
        
        % Assumptions
        MCL = ((1-ceiling_tentative/41000) + 0.2) * Tsls; % Maximum Climb Thrust to use for Climb Ceiling
        MCR = 0.95 * MCL; % Maximum Cruise Thrust to use for Cruise Ceiling
        if strcmp(option, 'climb')
            T2 = MCL;
            W = 0.97 * MTOW; % MR&O Climb Ceiling at 97% of the MTOW
        elseif strcmp(option, 'cruise')
            T2 = MCR;
            W = 0.80 * MTOW; % ????
        end
        
        % Climb Speed
        [vtas, ~, ~, ~, ~ ] = speed_cvt(0.85, 4, ceiling_tentative, 0); % in knots
        vtas = vtas * 1.68781; % knots to ft/s

        % Rate of Climb
        TWratio = T2/W;
        RC = (TWratio - LDratio^-1) * vtas * 60;
        if RC > 300
            %fprintf('\nFor tentative ceiling %f\n', ceiling_tentative)
            %fprintf('RC is %f\n', RC)
            ceiling = ceiling_tentative;
        else
            %fprintf('\nInvalid RC %s\n', RC)
        end
        
    end
    
%     % Warning Messages
%     fprintf('Message from Ceiling Function:\n')
%     if RC < 300
%         fprintf('Warning: Insufficient RofC for MR&O Climb Ceiling.\n')
%     elseif RC >= 300 && RC < 500
%         fprintf('Adequate RofC for MR&O Climb Ceiling.\n')
%     elseif RC >= 500
%         fprintf('Excess of Thrust. Verify Thrust Levels.\n')
        
end