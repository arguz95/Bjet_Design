function [ fn, wf ] = interp_crz( engdata, alt, mach, option, param )
%Author: Luc St-Michel
%January 22, 2014
%
%Revision 1: March 9, 2015
%            Fixe typo in the fuel flow calculation with option > 1
%
%Revision 2: March 16, 2015
%            Allow extrapolation for robustness
%
% Interpolate in the CRUISE thrust files.
%
%
% Option = 1: Run at thrust with "param"
%        = 2: Run at MCL
%        = 3: Run at MCR
%        = 4: Run at Idle


    [ndisa, nalt, nmach, npset, ncol] = size(engdata);

    idisa = 1;
    
    %searching of altitude
    ialt0 = 1;
    while (engdata(1,ialt0, 1, 1,1) < alt && engdata(1,ialt0+1, 1, 1,1) <= alt && ialt0 < nalt-1 )
        ialt0 = ialt0 + 1;
    end

    %At altitude lower bound
    %Search for Mach Index
    imach0 = 1;
    while (engdata(1,ialt0, imach0, 1, 3) < mach && engdata(1, ialt0, imach0+1, 1, 3) < mach && imach0 < nmach-1 )
        imach0 = imach0 + 1;
    end

    %Get fuel flow and thrust for low altitude

    wflo = zeros(2);
    fnlo = zeros(2);

    switch option
        case 1
            %taken care of below
        case 2
            ipset = 1;
        case 3
            ipset = 2;
        case 4
            ipset = npset;
        otherwise
            stop
    end
    if option > 1 
        for imach = imach0: imach0 + 1
           wflo(imach - imach0 + 1) = engdata(idisa,ialt0, imach,ipset, 7);
           fnlo(imach - imach0 + 1) = engdata(idisa,ialt0, imach,ipset, 8);
        end
    else
        for imach = imach0: imach0 + 1

            xfn = engdata(idisa,ialt0, imach,1:npset, 8);
            ywf = engdata(idisa,ialt0, imach,1:npset, 7);

            fnlo(imach - imach0 + 1) = param;
            wflo(imach - imach0 + 1) = interp1(xfn(1,:),ywf(1,:), param,'linear', 'extrap');

        end

    end
    
    wfloalt = (mach - engdata(idisa,ialt0, imach0,1,3))/ (engdata(idisa,ialt0, imach0+1,1,3) - engdata(idisa,ialt0, imach0,1,3))* ...'
        (wflo(2) - wflo(1)) + wflo(1);

    fnloalt = (mach - engdata(idisa,ialt0, imach0,1,3))/ (engdata(idisa,ialt0, imach0+1,1,3) - engdata(idisa,ialt0, imach0,1,3))* ...
        (fnlo(2) - fnlo(1)) + fnlo(1);

    %Get fuel flow and thrust for high altitude
    %At altitude lower bound
    %Search for Mach Index
    imach0 = 1;
    while (engdata(idisa,ialt0+1, imach0,1,3) <= mach && engdata(idisa,ialt0+1, imach0+1,1,3) <= mach && imach0 < nmach-1 )
        imach0 = imach0 + 1;
    end

    wfhi = zeros(2);
    fnhi = zeros(2);

    if option > 1 
        for imach = imach0: imach0 + 1
% March 9, 2015 fix typo wfhu replaced by wfhi
           wfhi(imach - imach0 + 1) = engdata(idisa,ialt0+1, imach,ipset, 7);
           fnhi(imach - imach0 + 1) = engdata(idisa,ialt0+1, imach,ipset, 8);
        end
    else
        for imach = imach0: imach0 + 1

            xfn = engdata(idisa,ialt0+1, imach,1:npset, 8);
            ywf = engdata(idisa,ialt0+1, imach,1:npset, 7);

            fnhi(imach - imach0 + 1) = param;
            wfhi(imach - imach0 + 1) = interp1(xfn(1,:),ywf(1,:), param,'linear','extrap');

        end

    end

    wfhialt = (mach - engdata(idisa,ialt0+1, imach0,1,3))/ (engdata(idisa,ialt0+1, imach0+1,1,3) - engdata(idisa,ialt0+1, imach0,1,3))* ...
        (wfhi(2) - wfhi(1)) + wfhi(1);

    fnhialt = (mach - engdata(idisa,ialt0+1, imach0,1,3))/ (engdata(idisa,ialt0+1, imach0+1,1,3) - engdata(idisa,ialt0+1, imach0,1,3))* ...
        (fnhi(2) - fnhi(1)) + fnhi(1);

    wf = (alt - engdata(idisa,ialt0, imach0,1,1))/(engdata(idisa,ialt0+1, imach0,1,1)-engdata(idisa,ialt0, imach0,1,1))*(wfhialt - wfloalt) + wfloalt;
    fn = (alt - engdata(idisa,ialt0, imach0,1,1))/(engdata(idisa,ialt0+1, imach0,1,1)-engdata(idisa,ialt0, imach0,1,1))*(fnhialt - fnloalt) + fnloalt;


end

