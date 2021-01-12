% Estimate MTOW
% Created by Lucas
% Last Modified by Lucas
% Update: 2020/February/15
close all
clear variables
clc

%% Data Entry - Choice of Airplane

%airplane = GulfstreamG500;
%airplane = Falcon900LX;
airplane = ourBjet([68000,755,1.24*12018]);

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
W_ppt  = estimate_Wppt(airplane, 1.2);

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

%% Main Results

% Rate of Climb in Ceiling
ceiling_climb = estimate_ceiling(airplane, MTOW, 'climb');
%ceiling_cruise = estimate_ceiling(airplane, MTOW, 'cruise');

% Take-Off Field Lenght Performance
TOFL = estimate_TOFL( airplane, MTOW );

% Wing Loading
WingLoading = MTOW/(airplane.wing_S);

% Thrust to Weight Ratio
Thrust2WeightRatio = (airplane.ppt_Neng * airplane.ppt_Tsls)/MTOW;

% Aspect Ratio
AR = ((airplane.wing_b)^2) / (airplane.wing_S);

%% OEW Pie Chart

% Written Labels
labels = {'Wing', 'Tail', 'Fuselage', 'Landing Gear', ...
    'PowerPlant', 'Systems', 'Interior', 'Other'};

% Remaining Part of OWE
W_other = OWE - (W_wing+W_tail+W_fuse+W_lg+W_ppt+W_sys+W_int);

% Percentage for each component in graph
percentage = round([W_wing/OWE, W_tail/OWE, W_fuse/OWE, ...
    W_lg/OWE, W_ppt/OWE, W_sys/OWE, W_int/OWE, W_other/OWE].*100);

% Pie Chart active
pie([W_wing/OWE, W_tail/OWE, W_fuse/OWE, W_lg/OWE, ...
    W_ppt/OWE, W_sys/OWE, W_int/OWE, W_other/OWE], percentage)
legend(labels)

% Clear Variables
clear W_other;
clear labels;