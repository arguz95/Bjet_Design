% Aerodynamic wing performance estimation
% Created by: Paul/Florian
% Last Modified by: Paul
% Date: 2020/mar/25

% input parameters
b = 78.65;  %ft
b2 = 78.65;  %ft
S = 755;  %ft^2
dfuse = 9.15;  %ft
MTOW = 62925;  %lbs
MFW = 41291;  %lbs
MLW = 55054;  %lbs
AR = 8.19;
phi25 = 30;  %°
FlappedaeraIB = 188.75;  %ft^2
FlappedareaOB = 188.75;  %ft^2
SlattedArea = 641.75;  %ft^2
mac = 13;  %ft
phiIBFlapHL = 6;  %°
phiOBFlapHL = 25;  %°
phiSlatHL = 37;  %°
Slatcc = 1.05;
Flapscfc = 0.26;
LandingFlapsdeltaccf = 0.55;
TOFlapsdeltaccf = 0.49;

tcaverage = 0.12;
xcmax = 0.5;
phiLE = 37.4;
phitcmax = 32;
CruiseMach = 0.87;
cruisealtitude = 45000;  %ft
LSmach = 0.22;
Swetwing = 1321.25;  %ft^2
InterferencefactorQwing = 1.125;
KornFactor = 0.95;

Vcruise = 842.2261; %ft/s 41000ft
rhoCruise = 0.00056;%slug/ft^3 41000ft
vCruise = 0.00053;%ft^^2/s 41000ft
CLmidcruise = (2*(MTOW - MFW/2)*32.0602)/(rhoCruise*S*Vcruise^2*32.2);
REcruise = 14500000;    %dfuse comme Lref

CL = 0.5;   %efficient flight at cruise
e = 0.866;      %Corke 4.17, 4.18
Cdi = 0.0112;
WingCDcompFactor = 1;

%------
%VALEURS A CHANGER (quand performances LS auront été faites)
LSMach = 0.22;
VLS = 245.62;
rhoLS = 0.002377;
vLS = 0.000157;
ReLS = 19996000;
Vref = 218.2338;
%------
CLvref = (2*MLW*32.0602)/(rhoLS*S*Vref^2*32.2);
CLTO = (2*MTOW*32.0602)/(rhoLS*S*Vref^2*32.2);

Excrescence_CD = 0.002
CD0_totLS = 0.01357 %Valeur obtenue avec le programme Aero_total, fonction aero_totLS() : A CHANGER MANUELLEMENT ICI

%LOW SPEED (LS)
function [CfwingLS, FWingLS, CD0wingLS] = aero_wingLS()
    %% Calculations
    CfwingLS = 0.455/(((log10(VLS*mac/vLS))^2.58)*((1+0.144*((LSMach*cos(phiLE)))^2))^0.65);
    FWingLS = (1+(0.6/xcmax)*tcaverage+100*tcaverage^4)*(1.34*(LSMach^0.18)*(cos(phitcmax))^0.28);
    CD0wingLS = CfwingLS*FWingLS*InterferencefactorQwing*(Swetwing/S);
end

%Cruise (CR)
function [CfwingCR, FWingCR, CD0wingCR, Mcrit_wing, CDcomp_wing] = aero_wingCR()
    %% Calculations
    CfwingCR = 0.455/(((log10(Vcruise*mac/vLS))^2.58)*((1+0.144*((CruiseMach*cos(phiLE)))^2))^0.65);
    FWingCR = (1+(0.6/xcmax)*tcaverage+100*tcaverage^4)*(1.34*(CruiseMach^0.18)*(cos(phitcmax))^0.28);
    CD0wingCR = CfwingCR*FWingCR*InterferencefactorQwing*(Swetwing/S);
    Mcrit_wing = KornFactor/cos(phitcmax)-tcaverage/(cos(phitcmax)^2)-CLmidcruise/(10*(cos(phitcmax)^3))-(0.1/80)^(1/3);
    CDcomp_wing = WingCDcompFactor*20*(CruiseMach-Mcrit_wing)^4;
end

%Low speed HL System
%Lift
function [ClmaxCleanAverage, ClmaxClean, LandingFlapsdeltaC, TOFlapsdeltaC, LandingFlapscc, TOFlapscc, DeltaClLandingFlapFowler, DeltaClTOFlapFowler, DeltaClSlat, DeltaClmaxLanding, DeltaClmaxTO] = aero_wingLift()
    %% Calculations
    ClmaxCleanAverage = 2;   %2D
    ClmaxClean = 0.9*ClmaxCleanAverage*cos(phi25);   %3D/ Raymer 2.15
    LandingFlapsdeltaC = Flapscfc*LandingFlapsdeltaccf;
    TOFlapsdeltaC = Flapscfc*TOFlapsdeltaccf;
    LandingFlapscc = 1+LandingFlapsdeltaC;
    TOFlapscc = 1+TOFlapsdeltaC;
    DeltaClLandingFlapFowler = 1.3*LandingFlapscc;
    DeltaClTOFlapFowler = 0.8*DeltaClLandingFlapFowler;
    DeltaClSlat = 0.4*Slatcc;
    DeltaClmaxLanding = 0.9*DeltaClLandingFlapFowler*(FlappedaeraIB/S)*cos(phiIBFlapHL)+0.9*DeltaClLandingFlapFowler*(FlappedareaOB/S)*cos(phiOBFlapHL)+0.9*DeltaClSlat*(SlattedArea/S)*cos(phiSlatHL);
    DeltaClmaxTO = 0.8*DeltaClmaxLanding;
end


%CLmax LDG minus 3% for MLG, take credit for 90% of CLmax only if not using
%FBW
function [ClmaxFlapsSlatsLanding, ClmaxFlapsSlatsTO, ClmaxFlapsSlatsLandingnoFBW, ClmaxFlapsSlatsTOnoFBW] = aero_wingFBW()
    %% Calculations
    ClmaxFlapsSlatsLanding = ClmaxClean+DeltaClmaxLanding;     %minus 4% for trim
    ClmaxFlapsSlatsTO = 0.8*ClmaxFlapsSlatsLanding; %minus 4% for trim
    ClmaxFlapsSlatsLandingnoFBW = ClmaxFlapsSlatsLanding*0.9*0.97*0.96;
    ClmaxFlapsSlatsTOnoFBW = 0.8*ClmaxFlapsSlatsLanding*0.9*0.96;
end

%Drag
function [DeltaCD0FlapLDG, DeltaCD0FlapTO, DeltaCDiFlapLDG, DeltaCDiFlapTO, CleanCDiVref, CleanCDiTO, LSCD0tot, ExcrescenceCD, CDtotLDG, CDtotTO, LDLanding, LDTO] = aero_wingDrag()
    LandingGear = 0.03;
    %% Calculations
    DeltaCD0FlapLDG = 0.0074*Flapscfc*((FlappedaeraIB+FlappedareaOB)/S)*30;
    DeltaCD0FlapTO = 0.0074*Flapscfc*((FlappedaeraIB+FlappedareaOB)/S)*6;

    DeltaCDiFlapLDG = (0.21^2)*((ClmaxFlapsSlatsLanding*0.97*0.96)-ClmaxClean)^2*(cos(phi25));
    DeltaCDiFlapTO = (0.21^2)*((ClmaxFlapsSlatsTO*0.96)-ClmaxClean)^2*(cos(phi25));

    CleanCDiVref = (CLvref^2)/(pi*e*AR);
    CleanCDiTO = (CLTO^2)/(pi*e*AR);

    LSCD0tot = 0.01343;    %Paul
    ExcrescenceCD = 0.002;  %Paul
    CDtotLDG = LandingGear + DeltaCD0FlapLDG + DeltaCDiFlapLDG + LSCD0tot + CleanCDiVref + ExcrescenceCD;
    CDtotTO = LSCD0tot + DeltaCD0FlapTO + DeltaCDiFlapTO + CleanCDiTO + ExcrescenceCD;

    LDLanding = CLvref/CDtotLDG;
    LDTO = CLTO/CDtotTO;

end
