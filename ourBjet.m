classdef ourBjet
    
    % Class ourBjet
    % Definition: Controls all airplane data used in code
    % This is the hybrid model used for weight and performance calculation
    % hybrid between G500 and LX900
    % Date: 2020-02-15
    
    properties
        
        vector_entry = [];   % Preallocation 
        MTOW = 62925;        % [lb] - Hybrid  
        wing_S = 755;        % [ft2] Wing Surface Area - Hybrid
        ppt_Tsls = 12018;    % (lbf) Sea Level Static Thrust for one engine - Hybrid       
    
    end
    
    properties (Constant)
        
        % Weight Breakdown
        W_payload = 2700;       % [lb] Source: Weight Breakdown Table - Hybrid % - Paul 2020-02-13
        W_ops = 1150;           % [lb] Source: Weight Breakdown Table - Hybrid % - Paul 2020-02-13
        W_sys = 4825;           % [lb] Source: Weight Breakdown Table - Hybrid % - Paul 2020-02-13
        W_int = 8392.5;         % [lb] Source: Weight Breakdown Table - Hybrid % - Paul 2020-02-13
        
        % Geometry - Wing
        wing_b = 78.65;         % [ft] Wingspan - Hybrid
        wing_troot = 0.5;       % [ft] Wing Root Thickness in ft
        wing_phi50 = 0.4267;    % Can be estimated from the plane_parameters.m - varie de 0 à 1 - This need TBC
        
        % Geometry - Tail
        tail_lh = 32.325;       % [ft] h-Tail Arm - 1/2 wing MAC to 1/2 h-Tail MAC
        tail_Sh = 180.9;        % [ft2] Horizontal Tail Surface Area
        tail_Sv = 93.45;        % [ft2]- Hybrid
        tail_lv = 32.325;       % [ft]- Hybrid
        tail_ARv = 1;           % From Preliminary tail sizing table
        tail_tcratio = 0.10;    % From Preliminary tail sizing table: 10%

        % Geometry - Fuselage
        fuse_Swet = 1612.3;                % [ft2] OLD: for LX900 % - Hybrid with assumption of 13221 ft2 for LX900
        fuse_h = (96 + (2*4.5))*0.0833333; % [ft] Height (4.5 in of skin thickness)   %MR&O
        fuse_d = (96 + (2*4.5))*0.0833333; % [ft] Diametre (4.5 in of skin thickness) %MR&O

        % Aerodynamics
        CLmax = 2.68;
        
        % PowerPlant
        ppt_Neng = 2;        % Number of Engines - Hybrid
        ppt_BPR  = 6.5;        % Bypass Ratio (Options: 4,5 or 6.5)

        % Performance - Speeds
        speed_dive = 330 + 30; % [knots] Dive Speed: VMO + 30 KCAS Cahier de charge S1
        
        % Performance - L/D
        LDratio_MRC = 18; % L/D max in MRC
        LDratio_LRC = 17; % L/D max in LRC
        
    end

    
    % Variable Entries: MTOW, wing_S, ppt_Tsls
    methods
        function obj = ourBjet(vector)
            if nargin > 0
                obj.vector_entry = vector;
            end
        end      
        function obj = set.vector_entry(obj,vector)
            obj.MTOW = vector(1);
            obj.wing_S = vector(2);
            obj.ppt_Tsls = vector(3);
            %fprintf( '* MTOW, wing_S and ppt_Tsls modified.\n');
        end
    end     
end
