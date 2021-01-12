%Weight Miscellaneous

%Date: 2020-02-13 - Freeze of Preliminary Design

%Payload
Pax                     =195;
Lugage                  =30;
Qty_Pax                 =(6+2*3);

W_Payload = (Pax+Lugage)*Qty_Pax

%Systems Weights
Fuel_System             =800 *1;
Avionics                =500 *1;
Flight_Control_Systems 	=1300*1;
APU                     =325 *1;
Hydraulics              =500 *1;
Electrics               =1400*1;

W_Systems = Fuel_System + Avionics + Flight_Control_Systems + APU + Hydraulics + Electrics

%Interior component weights
Entertainment           =350 *1; % - Paul
Single_Seat             =85  *6; % - Paul
Divan_Seat              =200 *2; % 3 places - Paul
Pullout_table           =20  *2; % - Paul
Pullout_work_table      =35  *1; % larger - Paul
Lavatory                =300 *2; % - Paul
Microwave               =40  *1; % - Paul
Oven                    =60  *1; % - Paul
Espresso                =25  *1; % - Paul
Chiller                 =45  *1; % - Paul
Lighting                =120 *1; % - Paul
Galley                  =65  *6; % lb/ft % - Paul 
Wardrobe                =150 *2; % - Paul
Furniture               =3.5 *(1260+1670)*0.5; %F900LX:1260; %G500:1670 % 3.5 to 5.5 lb/ft3 - Average
Various_options         =500 *1; % - Paul

W_Interiors = Entertainment+Single_Seat+Divan_Seat+Pullout_table+Pullout_work_table+Lavatory+Microwave+Oven+Espresso+Chiller+Lighting+Galley+Wardrobe+Furniture+Various_options 

%Operation items
Pilots                  =450 *1; %incl. luggage, manuals
Water                   =150 *2;
Consumables             =100 *1;
Emergency_Equipment 	=250 *1;
Containers              =50  *1;

W_Ops = Pilots+Water+Consumables+Emergency_Equipment+Containers  