function [thr, wf] = interp_clb(engdata, alt, mach, disa)
%Author: Luc St-Michel
%February 17, 2014

% Interpolate in the MTO and MCL thrust files.
%

    [ndisa, nalt, nmach, ncol] = size(engdata);

    %searching of altitude
    ialt0 = 1;
    while (engdata(1,ialt0, 1,1) < alt && engdata(1,ialt0+1, 1,1) <= alt && ialt0 < nalt-1 )
        ialt0 = ialt0 + 1;
    end
    
    %searching of disa
    idisa0 = 1;
    while (engdata(idisa0,1, 1,2) < disa && engdata(idisa0+1,1, 1,2) <= disa && idisa0 < ndisa-1 )
        idisa0 = idisa0 + 1;
    end
    %Interpolate at first disa and alt for mach

    wfalt = zeros(2);
    fnalt = zeros(2);


    for idisa = idisa0:idisa0+1


        %At altitude lower bound
        %Search for Mach Index
        imach0 = 1;
        while (engdata(idisa,ialt0, imach0,3) < mach && engdata(idisa,ialt0, imach0+1,3) < mach && imach0 < nmach-1 )
            imach0 = imach0 + 1;
        end
        
        %Get fuel flow and thrust for low altitude

        wflo = zeros(2);
        fnlo = zeros(2);

        for imach = imach0: imach0 + 1
           wflo(imach - imach0 + 1) = engdata(idisa,ialt0, imach,7);
           fnlo(imach - imach0 + 1) = engdata(idisa,ialt0, imach,8);
        end
        
        wfloalt = (mach - engdata(idisa,ialt0, imach0,3))/ (engdata(idisa,ialt0, imach0+1,3) - engdata(idisa,ialt0, imach0,3))* ...
            (wflo(2) - wflo(1)) + wflo(1);

        fnloalt = (mach - engdata(idisa,ialt0, imach0,3))/ (engdata(idisa,ialt0, imach0+1,3) - engdata(idisa,ialt0, imach0,3))* ...
            (fnlo(2) - fnlo(1)) + fnlo(1);

        %Get fuel flow and thrust for high altitude
        %At altitude lower bound
        %Search for Mach Index
        imach0 = 1;
        while (engdata(idisa,ialt0+1, imach0,3) <= mach && engdata(idisa,ialt0+1, imach0+1,3) <= mach && imach0 < nmach-1 )
            imach0 = imach0 + 1;
        end
        
        wfhi = zeros(2);
        fnhi = zeros(2);
        for imach = imach0: imach0 + 1
           wfhi(imach - imach0 + 1) = engdata(idisa,ialt0+1, imach,7);
           fnhi(imach - imach0 + 1) = engdata(idisa,ialt0+1, imach,8);
        end
        
        
        wfhialt = (mach - engdata(idisa,ialt0+1, imach0,3))/ (engdata(idisa,ialt0+1, imach0+1,3) - engdata(idisa,ialt0+1, imach0,3))* ...
            (wfhi(2) - wfhi(1)) + wfhi(1);

        fnhialt = (mach - engdata(idisa,ialt0+1, imach0,3))/ (engdata(idisa,ialt0+1, imach0+1,3) - engdata(idisa,ialt0+1, imach0,3))* ...
            (fnhi(2) - fnhi(1)) + fnhi(1);

        wfalt(idisa - idisa0 +1) = (alt - engdata(idisa,ialt0, imach0,1))/(engdata(idisa,ialt0+1, imach0,1)-engdata(idisa,ialt0, imach0,1))*(wfhialt - wfloalt) + wfloalt;
        fnalt(idisa - idisa0 +1) = (alt - engdata(idisa,ialt0, imach0,1))/(engdata(idisa,ialt0+1, imach0,1)-engdata(idisa,ialt0, imach0,1))*(fnhialt - fnloalt) + fnloalt;

    end %end for disa

    wf = (disa - engdata(idisa0,1, 1,2))/(engdata(idisa0+1,1, 1,2)- engdata(idisa0,1, 1,2))*(wfalt(2) - wfalt(1)) + wfalt(1);
    thr = (disa - engdata(idisa0,1, 1,2))/(engdata(idisa0+1,1, 1,2)- engdata(idisa0,1, 1,2))*(fnalt(2) - fnalt(1)) + fnalt(1);
    
end