function [ results_carpetplt, all_wingS, all_thrfct ] = ...
    carpetplt_airplanes(vector_MTOW, ppt_Tsls, vector_wingS, vector_thrfct)
    % Create multiple airplane configurations for the Carpet Plot
    % Created by Lucas
    % Last Modified by Lucas
    % Update: 2020/March/3rd
    
    % Preallocation of Results Matrix
    results_carpetplt   = zeros(length(vector_wingS), length(vector_thrfct), 20);
    all_wingS = zeros(1, length(vector_wingS) * length(vector_thrfct));
    all_thrfct = zeros(1, length(vector_wingS) * length(vector_thrfct));
    
    % Iterations
    k = 1;
    for i = 1:length(vector_wingS)
        for j = 1:length(vector_thrfct)
            
            % Modify Airplane Class
            try_MTOW = vector_MTOW(k);
            all_wingS(k)  = vector_wingS(i);
            all_thrfct(k) = vector_thrfct(j);
            k = k + 1;
            try_wingS = vector_wingS(i);
            try_thrfct = vector_thrfct(j);

            airplane = ourBjet([try_MTOW, try_wingS, try_thrfct * ppt_Tsls]);
            sf = try_thrfct;

            %% Estimated Outside of Matlab Code

            W_payload = airplane.W_payload;   
            W_ops     = airplane.W_ops;       
            W_sys     = airplane.W_sys;       
            W_int     = airplane.W_int;  

            %% Estimate Components Weights

            % Wing Empty Weight (Torenbeek)
            % Fixed Assumptions:
            W_wing = estimate_Wwing(airplane);

            % Tail Weight (Torenbeek/Raymer)
            % Fixed Assumptions: T-tail, design load
            W_tail = estimate_Wtail(airplane); 

            % Powerplant Weight
            % Fixed Assumptions: None
            W_ppt  = estimate_Wppt(airplane, sf);

            % Fuselage Weight (Torenbeek)
            % Fixed Assumptions: Wing-mounted landing gears, no cargo doors, one-deck
            W_fuse = estimate_Wfuse(airplane);

            % Landing Gear Weight (Torenbeek)
            % Fixed Assumptions: Low-Wing
            W_lg   = estimate_Wlg(airplane);   

            % Fuel Weight for Mission (Simplified Mission Breguet-Leduc)
            % Fixed Assumptions: Mission Requirements for Range, sfc, L/D, Mach
            W_fuel = estimate_Wfuel(airplane);

            %% Manufacturer Empty Weight
            % Attention: Update Technological Factors in function 
            % if choice of materials for wing, tail, fuselage, LD occurs

            MWE  = estimate_MWE(W_wing, W_tail, W_fuse, ...
                W_lg, W_ppt, W_sys, W_int);

            %% Operating Empty Weight
            
            OWE  = MWE + W_ops;

            %% Maximum Take-Off Weight

            MTOW = OWE + W_payload + W_fuel;
            MLW  = 0.80 * MTOW; % Approximation from Course Notes
            MZFW = 0.75 * MLW;  % Approximation from Course Notes

            %if (try_wingS == 752) && (try_thrfct == 1.3)
%             MTOW
%             MLW
%             OWE
            %end
            %% High Speed Performance
                       
            % Thrust to Weight Ratio
            T2W_ratio = (sf * airplane.ppt_Neng * airplane.ppt_Tsls)/MTOW;

            % Climb Ceiling Results (Previous Method Commented)
            [ climb_ceiling, climb_time2fl410 ] = ...
                perf_climbceiling(MTOW, airplane, sf);           
            
            % No Longer Used - Initial Estimate
            %climb_ceiling = estimate_ceiling(airplane, MTOW, 'climb');

            % No Longer Used - Mission 1 
            % 4700 nm with 8 pax and 200 nm at 0.85
            [range_mission1, ~, TOW_m1] = perf_mission(airplane, ...
                MTOW, OWE, MTOW-OWE, sf, 0, 0, 2, 4700);

            % No Longer Used - Mission 2 
            % 5000 nm with 8 pax and 200 nm at 0.80 
            [range_mission2, ~, TOW_m2] = perf_mission(airplane, ...
                MTOW, OWE, MTOW-OWE, sf, 0, 0, 1, 5000);
            
            % Redefine MTOW
            MTOW_req = max(TOW_m1, TOW_m2);
            
            % Mission Aspen
            [range_aspen, ~, TOW_aspen] = perf_mission(airplane, ...
                MTOW, OWE, MTOW-OWE, sf, 7821, 0, 1, 2600);

            % Mission Hilton Head
            [range_hilton, ~, TOW_hilton] = perf_mission(airplane, ...
                MTOW, OWE, MTOW-OWE, sf, 15, 0, 1, 3600);
            
            %% Low-Speed Performance
            
            % Take-Off Field Lenght Performance at Aspen
            % [TOFL_aspen] = perf_TOFLaspen(airplane, MTOW, MLW, sf);
            [TOFL_aspen, ~] = ...
                perf_TOFLmain(airplane, MTOW, TOW_aspen, sf, 7821, 30);
            
            % Take-Off Field Lenght Performance of Hilton Head
            % TOFL_hilton = perf_TOFLhilton(airplane, MTOW, MTOW, sf);
            [TOFL_hilton, ~] = ...
                perf_TOFLmain(airplane, MTOW, TOW_hilton, sf, 20, 25);
            
            % Take-Off Field Length
            % [ TOFL_SL, TOFL_5000, LFL ] = perf_TOFL(airplane, MTOW, sf);            
            [TOFL_SL,~] = perf_TOFLmain(airplane, MTOW, MTOW, sf, 0, 15);
            [TOFL_5000,~] = perf_TOFLmain(airplane, MTOW, MTOW, sf, 5000, 25);
            [~,LFL] = perf_TOFLmain(airplane, MTOW, MTOW, sf, 0, 0);
            
            % OEI Climb Gradient at Aspen
            [gamma1, ~] = perf_clbAspen(airplane, MTOW, TOW_aspen, sf);
            
            
            %% Other Results
            
            % Wing Loading
            % WingLoading = MTOW/(airplane.wing_S);

            % Aspect Ratio
            % AR = ((airplane.wing_b)^2) / (airplane.wing_S);

            results_carpetplt(i,j, 1) = MTOW;
            results_carpetplt(i,j, 2) = T2W_ratio;
            
            % High Speed Save
            results_carpetplt(i,j, 5) = climb_ceiling;
            results_carpetplt(i,j, 6) = climb_time2fl410;            
            results_carpetplt(i,j, 7) = range_mission1;
            results_carpetplt(i,j, 8) = range_mission2;
            %results_carpetplt(i,j, 9) = range_missionAspen;
            %results_carpetplt(i,j,10) = range_missionHiltonHead; 
            
            % Low Speed SAve
            results_carpetplt(i,j,11) = TOFL_aspen; 
            results_carpetplt(i,j,12) = TOFL_hilton;
            results_carpetplt(i,j,13) = gamma1; 
            %results_carpetplt(i,j,14) = gamma2;           
            
            results_carpetplt(i,j,20) = TOFL_SL; 
            results_carpetplt(i,j,19) = TOFL_5000;
            results_carpetplt(i,j,18) = LFL; 
            
            %% Print Results
            fprintf('\n')
            fprintf('MTOW %5.0f / S %3.0f / sf %1.2f / Range: %4.0f / %4.0f\n', MTOW, try_wingS, try_thrfct, range_mission1, range_mission2)
            fprintf('ceil: %0.0f / time2clb: %0.0f\n', climb_ceiling, climb_time2fl410 )
            fprintf('TOFL at Hilton:  %4.0f (4300) \n', TOFL_hilton)
            fprintf('TOFL at Aspen:   %4.0f (8000) \n', TOFL_aspen)
            fprintf('gamma at Aspen:  %1.2f (4.4)\n', gamma1)
            fprintf('TOFL at SL:      %4.0f (5100) \n', TOFL_SL)
            fprintf('TOFL at 5000:    %4.0f (7000) \n', TOFL_5000)            
            fprintf('LFL at SL:       %4.0f (5000) \n', LFL)  
            
        end
    end
end

