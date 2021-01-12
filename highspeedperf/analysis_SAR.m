clear variables
clc

%% Data Entry

airplane = ourBjet([76733, 752, 1.35*12018]);
bpr = airplane.ppt_BPR;
neng = airplane.ppt_Neng;
sf = 1.3;

mach = 0.6:0.005:0.89;             % Mach Range

disa = 0;
alt = [43000, 43000, 43000, 43000];
wgt = [66000, 63000, 60000, 57000];


LDratio = zeros(1, length(mach)); % Preallocation
sar     = zeros(1, length(mach)); % Preallocation

%% Read Engine Data

if (bpr == 4)
    [engdata_clb] = read_thr_file('POLY_ldmf_bpr40_mcl_lo_off.dat' );
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr40_mto_off_off.dat');
    [engdata_crz] = read_thr_file('POLY_ldmf_bpr40_cr00_lo_off.dat');
elseif (bpr == 5)
    [engdata_clb] = read_thr_file('POLY_ldmf_bpr50_mcl_lo_off.dat' );
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr50_mto_off_off.dat');
    [engdata_crz] = read_thr_file('POLY_ldmf_bpr50_cr00_lo_off.dat');
elseif bpr == 6.5
    [engdata_clb] = read_thr_file('POLY_ldmf_bpr65_mcl_lo_off.dat' );
    [engdata_mto] = read_thr_file('POLY_ldmf_bpr65_mto_off_off.dat');
    [engdata_crz] = read_thr_file('POLY_ldmf_bpr65_cr00_lo_off.dat');
end  

%%

for j = 1:length(alt)
    
    [~,~,~, delta ] = atmos( alt(j), disa );
    wgtdelta = wgt(j)/delta
    str4legend{j} = strcat(num2str(wgt(j)), ' lb - W/\delta : ', sprintf('%0.0f',wgtdelta)); 

    for i = 1:length(mach)

        % Aerodynamics
        LDratio(i) = aero_LDratio(airplane, wgt(j), alt(j), mach(i), disa);
        drag(i) = wgt(j) / LDratio(i);

        % Engine Data
        [fn_e(i), wf_e(i)] = interp_crz(engdata_crz, alt(j), mach(i), 3, 0);
        wf_e(i) = sf * wf_e(i);
        fn_e(i) = sf * fn_e(i);

        % Ratio of Power Required
        T_avail(i)    = neng * fn_e(i);
        T_req(i)      = drag(i);
        ratio_TrTa(i) = T_req(i)/ T_avail(i);

        % Real Values for wf
        wf(i) = ratio_TrTa(i) * neng * wf_e(i);

        [vtas, ~, ~, ~, ~] = speed_cvt(mach(i), 4, alt(j), disa);
        sar(i) = vtas/wf(i);

    end


    % Plot Results found
    plot(mach, sar, 'LineWidth', 1)
    hold on
    
end

%% Finish Plot
axis([0.74 0.90 0.18 0.22])
title(strcat('Specific Air Range (',sprintf('%0.0f', alt(j)), ' ft)'))
ylabel('SAR ( nm/lb )')
xlabel('Mach')
legend(str4legend, 'location', 'Southeast')
grid on