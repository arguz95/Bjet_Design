function [ engdata_arr ] = read_thr_file( filename )
%Author: Luc St-Michel
%November 11, 2013
%
%Revision 1: February 21, 2015
%            Fix bug on disa vector. Force to use the disa vector in the
%            header of the file.
%


%This function reads climb and cruise thrust file format
%

% Open a text file
fid=fopen(filename,'r');

%skip the first five lines
for i = 1:5
    line=fgetl(fid);
end

ndisa = 0;
nmach = 0;
nalt  = 0;
npset = 0;

l = fgetl(fid);
dumdata = str2double(strsplit(strtrim(l),' '));
dumsize = size(dumdata);

if (dumsize(2) == 3) %Climb format file

    ndisa = dumdata(1);
    nmach = dumdata(2);
    nalt = dumdata(3);

    l = fgetl(fid);
    l = fgetl(fid);
    disavec = str2double(strsplit(strtrim(l),' '));

    engdata_arr = zeros(ndisa, nalt, nmach, 9);

    for idisa = 1: ndisa

        %skip five header lines
        for i = 1:4
            line=fgetl(fid);
        end
        for ialt = 1: nalt
            l = fgetl(fid);
            for imach = 1:nmach

                l = fgetl(fid);
                dumdata = str2double(strsplit(strtrim(l),' '));

                for idx = 1: 9
                    engdata_arr(idisa, ialt, imach,idx) = dumdata(idx);
                end
                engdata_arr(idisa, ialt, imach,2) = disavec(idisa);
            end
        end
    end
else   %Cruise format file
    ndisa = 1;
    disa = dumdata(1);
    nmach = dumdata(2);
    nalt = dumdata(3);
    npset = dumdata(4);
    
    engdata_arr = zeros(ndisa, nalt, nmach, npset, 9);
    idisa = 1;
    for ialt = 1: nalt

        %skip five header lines
        for i = 1:4
            line=fgetl(fid);
        end
        for imach = 1:nmach
            l = fgetl(fid);
            for ipset = 1:npset
                
                l = fgetl(fid);
                dumdata = str2double(strsplit(strtrim(l),' '));

                for idx = 1: 9
                    engdata_arr(idisa, ialt, imach,ipset,idx) = dumdata(idx);
                end
                engdata_arr(idisa, ialt, imach,ipset,2) = disa;
            end
        end
    end
   
end
    
    
fclose(fid);

end

