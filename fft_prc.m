function [fv ft]=fft_prc(v,fs,bPlot)
%arguments:
%1 - double vector or string field name of data struct
%2 - double frequency
%3 - bool bPlot
%output:
%1 - double vector of spectr data
%2 - double vector of frequency 
ft = 0; fv = 0;
if nargin<3
    bPlot = 1;
end
%-------------------------------
if ischar(v)==1
    global data
    if nargin<2
        fs = data.Frequency;
    end
    if nargin<3
        if sum(strcmp(v,{'Gx','Gy','Gz'}))>0
            type = 'LG';
        elseif sum(strcmp(v,{'Ax','Ay','Az'}))>0
            type = 'AK';
        else
            type = 'Other';
        end
    end
    sname = v;
    if isfield(data,'tm')
        v = data.tm.(v).ar;
    else
       return;
    end
else
    type = 'Other';
    sname = '';
end
%-------------------------------
if isempty(fs)==1; fs = 1; end;
%-------------------------------
    if strcmp(type,'LG')
        v = dtrend(cumsum(v),1);
        N = length(v);
        ft =(0:N-1)/N*fs;
        s = abs(fft(v));
        fv = s(1:floor(end/2));
        ft = ft(1:floor(end/2));
        fv = fv/length(fv);
    elseif strcmp(type,'AK')
        N = length(v);
        ft =(0:N-1)/N*fs;
        s = abs(fft(v));
        fv = s(1:floor(end/2));
        ft = ft(1:floor(end/2));
        fv = (fv/length(fv));
    else
        N = length(v);
        ft =(0:N-1)/N*fs;
        s = abs(fft(v));
        fv = s(1:floor(end/2));
        ft = ft(1:floor(end/2));
        fv = fv/length(fv);
    end
    if bPlot == 1
        figure;
        plot(ft,fv); 
        xlabel('„астота,[√ц.]');
        title(sname);
        if strcmp(type,'LG')
            ylabel('”гловые секунды [``]'); grid;
            set(gca,'XLim',[3,100]);
            set(gca,'YLim',[0,5]);
        elseif strcmp(type,'AK')
            ylabel('”скорение [g]');
            set(gca,'XLim',[3,100]);
            set(gca,'YLim',[0,0.05]);
        end
    end
end
