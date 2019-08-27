function main()
	% function main
	%
    ScrSize=get(0,'screensize');
    FigSize=[1600 800];
%     FigSize=[1200 600];
    h = FigSize(2);
    FigPos(1)=(ScrSize(3)/2)-(FigSize(1)/2);
    FigPos(2)=(ScrSize(4)/2)-(FigSize(2)/2);
    FigPos(3:4)=FigSize;
    F = figure('position',FigPos,'NumberTitle','off','Name','GyroSoundAnalysis','MenuBar','None','Tag','TMwind','Resize','off');
    F.KeyPressFcn = @StartFcn;
    F.UserData.UInames = getDataStr('stringfile.t xt');
    % ---------------------------------------------------------
    % frame 1 with Control 
    pn1 = uipanel('Units','normalize','tag','frm1','Position',[0.01 0.52 0.2 0.47],'Title','','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','text','Units','Normalized','tag','devices','position',[0.01 0.95 0.6 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);
    lbx1 = uicontrol('Parent',pn1,'style','listbox','Units','Normalized','tag','lbx_1','Position',[0.01 0.75 0.95 0.2],'Visible','on','String','Listbox','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','pushbutton','Units','Normalized','tag','btnStart','position',[0.01 0.65 0.4 0.07],'string','','callback',@Start,'UserData','start','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','text','Units','Normalized','tag','time','position',[0.42 0.66 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);
     uicontrol('Parent',pn1,'style','text','Units','Normalized','tag','temp','position',[0.20 0.58 0.6 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','edit','Units','Normalized','tag','etime','position',[0.8 0.656 0.16 0.06],'string','5','HorizontalAlignment','left','backgroundcolor','y','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','edit','Units','Normalized','tag','etermo','position',[0.8 0.576 0.16 0.06],'string','25','HorizontalAlignment','left','backgroundcolor','y','CreateFcn',@setStrByTag);
    
    uicontrol('Parent',pn1,'style','pushbutton','Units','Normalized','tag','btnSetT','position',[0.8 0.5 0.16 0.07],'string','','callback',@TermoSet,'UserData','start','CreateFcn',@setStrByTag);    
    
    uicontrol('Parent',pn1,'style','pushbutton','Units','Normalized','tag','btnSave','position',[0.01 0.48 0.4 0.07],'string','','callback',@Save,'CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','pushbutton','Units','Normalized','tag','btnLoad','position',[0.01 0.40 0.4 0.07],'string','','callback',@Load,'CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','pushbutton','Units','Normalized','tag','btnClear','position',[0.01 0.32 0.6 0.07],'string','','callback',@btn_clear,'CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','pushbutton','Units','Normalized','tag','btnClear2','position',[0.01 0.24 0.6 0.07],'string','','callback',@btn_clear,'CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','text','Units','Normalized','tag','Fq_diap','position',[0.01 0.15 0.6 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','edit','Units','Normalized','tag','Fq_1','position',[0.57 0.15 0.16 0.06],'string','1800','HorizontalAlignment','left','backgroundcolor','y','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','edit','Units','Normalized','tag','Fq_2','position',[0.77 0.15 0.16 0.06],'string','6000','HorizontalAlignment','left','backgroundcolor','y','CreateFcn',@setStrByTag);
    
    uicontrol('Parent',pn1,'style','checkbox','Units','Normalized','tag','chbCircle','position',[0.01 0.085 0.7 0.05],'string','','HorizontalAlignment','left','callback',@chb_circle,'CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','text','Units','Normalized','tag','tStep','position',[0.01 0.010 0.2 0.06],'string','','HorizontalAlignment','left','enable','off','CreateFcn',@setStrByTag);    
    uicontrol('Parent',pn1,'style','edit','Units','Normalized','tag','eStep','position',[0.20 0.020 0.10 0.06],'string','0','HorizontalAlignment','left','backgroundcolor','y','enable','off','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','text','Units','Normalized','tag','tNum','position',[0.32 0.010 0.25 0.06],'string','','HorizontalAlignment','left','enable','off','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','edit','Units','Normalized','tag','eNum','position',[0.53 0.020 0.10 0.06],'string','1','HorizontalAlignment','left','backgroundcolor','y','enable','off','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','text','Units','Normalized','tag','tPos','position',[0.70 0.080 0.5 0.05],'string','','HorizontalAlignment','left','enable','off','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn1,'style','edit','Units','Normalized','tag','ePos','position',[0.70 0.015 0.25 0.07],'string','0','HorizontalAlignment','center','FontSize',16,'FontWeight','bold','enable','off','CreateFcn',@setStrByTag);    
    % ---------------------------------------------------------
    % frame 2 with time diagram
    pn2 = uipanel('Units','normalize','tag','frm2','Position',[0.21 0.52 0.4 0.47],'Title','','CreateFcn',@setStrByTag);
    axes('Parent',pn2,'Units','normalize','tag','time_axes','Position',[0.04 0.06 0.94 0.84],'Color',[0.7569 0.8667 0.7765],'XGrid','on','YGrid','on')
    uicontrol('Parent',pn2,'style','pushbutton','Units','Normalized','tag','btnSignal','position',[0.9 0.06 0.08 0.07],'string','','callback',@OpenFigure,'CreateFcn',@setStrByTag);
    % ---------------------------------------------------------
    % frame 3 with Frequency diagram
    pn3 = uipanel('Units','normalize','tag','frm3','Position',[0.21 0.02 0.4 0.5],'Title','','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn3,'style','pushbutton','Units','Normalized','tag','btnFreq','position',[0.9 0.06 0.08 0.07],'string','','callback',@OpenFigure,'CreateFcn',@setStrByTag);
    axes('Parent',pn3,'Units','normalize','tag','freq_axes','Position',[0.04 0.11 0.94 0.85],'Color',[0.7569 0.8667 0.7765],'XGrid','on','YGrid','on')
    % ---------------------------------------------------------
    % frame 4 with Results of analyse
    pn4 = uipanel('Units','normalize','tag','frm4','Position',[0.01 0.01 0.2 0.5],'Title','','CreateFcn',@setStrByTag);    
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','Fq1','position',[0.05 0.92 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eFq1','position',[0.4 0.91 0.3 0.06],'string','0','HorizontalAlignment','left','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','Fq2','position',[0.05 0.82 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eFq2','position',[0.4 0.81 0.3 0.06],'string','0','HorizontalAlignment','left','CreateFcn',@setStrByTag); 
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','Qa1','position',[0.05 0.72 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eQa1','position',[0.4 0.71 0.3 0.06],'string','0','HorizontalAlignment','left','CreateFcn',@setStrByTag); 
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','Qa2','position',[0.05 0.62 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eQa2','position',[0.4 0.61 0.3 0.06],'string','0','HorizontalAlignment','left','CreateFcn',@setStrByTag); 
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','Qa3','position',[0.05 0.52 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eQa3','position',[0.4 0.51 0.3 0.06],'string','0','HorizontalAlignment','left','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','Zt','position',[0.05 0.42 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eZt','position',[0.4 0.41 0.3 0.06],'string','0','HorizontalAlignment','left','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','Qa4','position',[0.05 0.32 0.4 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eQa4','position',[0.4 0.31 0.3 0.06],'string','0','HorizontalAlignment','left','CreateFcn',@setStrByTag);
    uicontrol('Parent',pn4,'style','text','Units','Normalized','tag','tNres','position',[0.05 0.22 0.6 0.04],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);   
    uicontrol('Parent',pn4,'style','edit','Units','Normalized','tag','eNres','position',[0.55 0.22 0.4 0.06],'string','','HorizontalAlignment','left','CreateFcn',@setStrByTag);

    uicontrol('Parent',pn4,'style','pushbutton','Units','Normalized','tag','btnLoad1','position',[0.05 0.12 0.65 0.07],'string','','callback',@Protocol,'CreateFcn',@setStrByTag);
    uicontrol('Parent',pn4,'style','pushbutton','Units','Normalized','tag','btnLoad2','position',[0.05 0.02 0.65 0.07],'string','','callback',@Protocol2,'CreateFcn',@setStrByTag);

    % ---------------------------------------------------------
    % frame 5 Rezonance frequency
    pn5 = uipanel('Units','normalize','tag','frm5','Position',[0.61 0.01 0.39 0.98],'Title','','CreateFcn',@setStrByTag);
    axes('Parent',pn5,'Units','normalize','tag','axes3','Position',[0.04 0.06 0.95 0.89],'Color',[0.7569 0.8667 0.7765],'XGrid','on','YGrid','on')
    uicontrol('Parent',pn5,'style','text','Units','Normalized','tag','txtDiscr','position',[0.90 0.08 0.08 0.02],'string','','HorizontalAlignment','right','enable','off','CreateFcn',@setStrByTag);
    % ---------------------------------------------------------    
    
    a = audiodevinfo;
    
    list = {''};
    for i = 1:length(a.input)
        list{i} = a.input(i).Name;
    end
    set(F.Children.findobj('tag','lbx_1'),'String',list);
    F.UserData.counter = 1;
end


function Start(src, evt)
  % -----------------------------------------------------------
  % The main function of the program it start the sound record
  % and then processing sound data from microphone
  % -----------------------------------------------------------

  % get figure handleses
  % -----------------------------------------------------------
  F = gcf;
  btn = evt.Source;
  handles = guihandles(src);
  F2 = F;
  D = F2.UserData.UInames;
  D = getTagStruct(D);
  F3 = F2.Children;
  pn1 = F3(4).Children; ax1 = pn1(2);  % time axes
  pn2 = F3(3).Children; ax2 = pn2(2);  % freq axes
  pn3 = F3(1).Children; ax3 = pn3(2);  % res axes
  
  % set properties for axes
  % -----------------------------------------------------------
  plot(ax1,[0 0],[0 0]); % initial plot data
  plot(ax2,[0 0],[0 0]);
  ln = ax1.Children;
  ln2 = ax2.Children;
  set(ax1,'XGrid','on','YGrid','on');
  set(ax2,'XGrid','on','YGrid','on');
  ax1.Color = [0.7569 0.8667 0.7765];
  ax2.Color = [0.7569 0.8667 0.7765];
  ln.Tag = 'SoundPlot';
  
  % initial sets from user interface
  % -----------------------------------------------------------
  Fs = 44100;
  Nb = 16;
  time = str2num(F.Children.findobj('tag','etime').String);
  if isempty(time)
      time = 10;
      F.Children.findobj('tag','etime').String = '10';
  end
  
  % -----------------------------------------------------------  
  % recording audio and processing data
  % -----------------------------------------------------------  
  rec = audiorecorder(Fs,Nb,1,1);
  rec.TimerFcn = {@plot_sample,rec,ln,Fs};
  rec.TimerPeriod = 1.0;
  recordblocking(rec,time);
  % get data from axes
  data = ln.YData;
  time = [1/Fs:1/Fs:length(data)/Fs];
  ln.YData = data;
  ln.XData = time;
  ax1.XLim = [time(1); time(end)];

  % -------------------------------------------------------
  % processing sound for find decrease time
  % -------------------------------------------------------
  Sound = data;
  Time = [1:length(Sound)]/Fs;
  offset_time = 500;
  modfunc = 'exp1';
  MinPeakDist = 0.01;
  % -----------------------------------------------------
  % Find point with max.sound
  [val, max_ind] = max(abs(Sound));
  % build sound decrease model
  % find peaks values from Sound
  pt_begin = max_ind + offset_time; 
  pt_end = floor((length(Sound)-max_ind)/2);
  peaks_time = pt_begin : pt_end;
  [peaks_val, peaks_ind] = findpeaks(abs(Sound(peaks_time)),...
    Time(peaks_time),'MinPeakDistance',MinPeakDist);
  % build model sound decrease
  sDecr_model = fit(peaks_ind',peaks_val',modfunc);
  sDecr_time = Time(max_ind:pt_end);
  sDecr_data = feval(sDecr_model, sDecr_time);
  % find e-time decrease sound 
  [val e_decrease_ind] = min(abs(sDecr_data)-sDecr_data(1)/exp(1));
  % time of the decrease
  e_decr_time = sDecr_time(e_decrease_ind)-sDecr_time(1);
  F.Children.findobj('tag','eQa4').String = num2str(e_decr_time);

  % -------------------------------------------------------
  % FFT processing
  % -------------------------------------------------------  
  % set frequency diapazon from interface for processing
  Fq_1 = str2num(F.Children.findobj('tag','Fq_1').String);
  if isempty(Fq_1)||Fq_1 == 0
      Fq_1 = 1800;
      F.Children.findobj('tag','Fq_1').String = '1800';
  end
  Fq_2 = str2num(F.Children.findobj('tag','Fq_2').String);
  if isempty(Fq_2)||Fq_2 == 0
      Fq_2 = 6000;
      F.Children.findobj('tag','Fq_2').String = '6000';
  end
  % -----------------------------------------------------
  % calc and plot fft+frequency:
  [A, fq] = fft_prc(data(pt_begin:end),Fs,0);
  discr_fq_step = fq(2) - fq(1);
  F.Children.findobj('tag','txtDiscr').String = [num2str(discr_fq_step),D.Hz_];
  A(1:71)=0;
  ln2(1).YData = A; 
  ln2(1).XData = fq;
  % find resonanse frequency diapazons in fft data
  [v, min_freq_ind] = min(abs(fq-Fq_1));
  [v, max_freq_ind] = min(abs(fq-Fq_2));
  [max_amp, ind_max_fq_base] = max(A(min_freq_ind:max_freq_ind));
  % resonanse base frequency index in fft_data
  ind_max_fq_base = min_freq_ind + ind_max_fq_base - 1; 
    
  % find resonanse frequency
  % -----------------------------------------------------
  fq_offset = 150; % points
  fq_diap = [fq(ind_max_fq_base-fq_offset) fq(ind_max_fq_base+fq_offset)];
  fq_diap_ind = [(ind_max_fq_base-fq_offset) (ind_max_fq_base+fq_offset)];
  ax2.XLim = fq_diap;
  [val_fq_peaks, ind_fq_peaks] = findpeaks(A(fq_diap_ind(1):fq_diap_ind(2)),...
    'MinPeakDistance',0.1);
  ind_fq_peaks = ind_fq_peaks + ind_max_fq_base - fq_offset - 1;
  arr  = sortrows([val_fq_peaks', ind_fq_peaks'],1);
  if size(arr,1) < 2
      two_peaks = arr(end,:);
  else
      two_peaks = arr(end-1:end,:);
  end
  % get two largest peaks
  arr = sortrows([two_peaks(:,2) two_peaks(:,1)],1);

  % analyze value of the frequencies:
        % compare distance in Hz      % compare amplitudes
  if  (abs(diff(fq(arr(:,1))))>10 || (max(arr(:,2))/min(arr(:,2)))>3)
      % set frequency with maximum value
      [iii iiii] = max(arr(:,2));
      arr = arr(iiii,:);
      mi = arr(1,1);
      F.Children.findobj('tag','eFq1').String = num2str(fq(mi));
      F.Children.findobj('tag','eFq2').String = '0';
      F.Children.findobj('tag','eQa1').String = '0';
  else
      mi = arr(:,1);
      dif_fq = diff(fq(mi));
      F.Children.findobj('tag','eFq1').String = num2str(fq(mi(1)));
      F.Children.findobj('tag','eFq2').String = num2str(fq(mi(2)));
      F.Children.findobj('tag','eQa1').String = num2str(abs(dif_fq));       
  end
  
  hold(ax2,'on');

  ax2.Children(1).UserData.p = (mi);
  ax2.Children(1).UserData.mi = fq(mi);
  ax2.Children(1).UserData.A = A(mi);
  assignin('base','fq',fq);
  assignin('base','A',A);
  assignin('base','Sound',data);

  % find Q-quality
  Y = ax2.Children(1).YData;
  X = ax2.Children(1).XData;
  P = ax2.Children(1).UserData.p;
  A = ax2.Children(1).UserData.A;
  Fq = ax2.Children(1).UserData.mi;
  
  % take part of signal:
  ss = 0.0001; % scan step
  
  if length(P)==2;
     sampleX = X(P(1)-30:P(2)+30);
     sampleY = Y(P(1)-30:P(2)+30);
     cla(ax3,'reset');
     set(ax3,'Color',[0.7569 0.8667 0.7765],'XGrid','on','YGrid','on');
     hold(ax3,'on');
     plot(ax3,sampleX,sampleY,'o-');
     xx = sampleX(1):ss:sampleX(end);
     yy = interp1(sampleX,sampleY,xx,'spline');
     plot(ax3,xx,yy,'r.');
     [Val, Ind] = findpeaks(yy);
     Arr  = sortrows([Val', Ind'],1);
     Ind = Arr(end-1:end,2);
     Val = Arr(end-1:end,1);
     Arr = sortrows([Val, Ind],1);
     Ind = Arr(:,2); 
     Val = Arr(:,1);
     [min_Val, min_Ind] = min(yy(min(Ind):max(Ind)));
     min_Ind = min_Ind + min(Ind);
     plot(ax3,xx(min_Ind),yy(min_Ind),'^g');
     plot(ax3,xx(Ind),yy(Ind),'gv');
     % find 1 quality
     dist = min_Ind - min(Ind);
     v_v = 0.707 * A(1);
     [vvv, ind1] = min(abs(yy(1:min(Ind))-v_v));
     [vvv, ind2] = min(abs(yy(min(Ind):min(Ind)+dist)-v_v));
     ind2 = ind2 + min(Ind)-1;
     plot(ax3, [xx(ind1) xx(ind2)],[yy(ind1),yy(ind2)],'-m');
     Q1 = Fq(1)/(abs(xx(ind2) - xx(ind1)));
     xx(ind2) - xx(ind1)
     gca = ax3;
     text(xx(min(Ind))+0.5,yy(min(Ind)),['F1 = ',num2str(xx(min(Ind)))])
     text(xx(ind2)+0.5,yy(ind2),['Q1 = ',num2str(round(Q1))])
     grid;
     % find 2 quality
     v_v = 0.707 * A(2);
     dist = max(Ind)-min_Ind;
     [vvv, ind3] = min(abs(yy(max(Ind)-dist:max(Ind))-v_v));
     ind3 = max(Ind) - dist + ind3 - 1;
     if dist + max(Ind) + 1 > length(yy)
         dist = length(yy)-max(Ind)-1;
     end
     [vvv, ind4] = min(abs(yy(max(Ind):max(Ind)+dist)-v_v));
     ind4 = ind4 + max(Ind) - 1;
     plot([xx(ind3) xx(ind4)],[yy(ind3),yy(ind4)],'-m'); grid;
     Q2 = Fq(2)/(abs(xx(ind4) - xx(ind3)));
     text(xx(max(Ind))+0.5,yy(max(Ind)),['F2 = ',num2str(xx(max(Ind)))])
     text(xx(ind4)+0.5,yy(ind4),['Q2 = ',num2str(round(Q2))])
      F.Children.findobj('tag','eQa2').String = num2str(Q1);
      F.Children.findobj('tag','eQa3').String = num2str(Q2);
      F.Children.findobj('tag','eQa1').String = num2str(abs(xx(Ind(1))-xx(Ind(2))));
     ax2.Children(1).UserData.F1 = [xx(Ind(1))];
     ax2.Children(1).UserData.F2 = [xx(Ind(2))];
     ax2.Children(1).UserData.Q1 = Q1;
     ax2.Children(1).UserData.Q2 = Q2;
     ax2.Children(1).UserData.dFq = abs(diff(xx(Ind)));
  elseif length(P) == 1
     % if we have one resonance frequency
     sampleX = X(P-30:P+30);
     sampleY = Y(P-30:P+30);
     cla(ax3,'reset');
     set(ax3,'Color',[0.7569 0.8667 0.7765],'XGrid','on','YGrid','on');
     hold(ax3,'on');
     plot(ax3,sampleX,sampleY,'o-');
     xx = sampleX(1):ss:sampleX(end);
     yy = interp1(sampleX,sampleY,xx,'spline');
     plot(ax3,xx,yy,'r.');
     [Val, Ind] = findpeaks(yy);
     Arr  = sortrows([Val', Ind'],1);
     Ind = Arr(end,2);
     Val = Arr(end,1);
     [min_Val, min_Ind1] = min(yy(1:Ind));
     [min_Val, min_Ind2] = min(yy(Ind:end));
     min_Ind2 = min_Ind2+Ind-1;
     plot(ax3,xx(min_Ind1),yy(min_Ind1),'^g');
     plot(ax3,xx(min_Ind2),yy(min_Ind2),'^g');
     plot(ax3,xx(Ind),yy(Ind),'gv');
     % find 1 quality
     dist1 = Ind - min_Ind1;
     dist2 = min_Ind2 - Ind;
     v_v = 0.707 * A;
     [vvv, ind1] = min(abs(yy(min_Ind1:Ind)-v_v));
     ind1 = ind1 + min_Ind1-1;
     [vvv, ind2] = min(abs(yy(Ind:min_Ind2)-v_v));
     ind2 = ind2 + Ind-1;
     plot(ax3,[xx(ind1) xx(ind2)],[yy(ind1),yy(ind2)],'-m'); grid;
     Q1 = Fq/(abs(xx(ind2) - xx(ind1)));
     gca = ax3;
     text(xx(Ind)+0.5,yy(Ind),['F1 = ',num2str(xx(Ind))])
     text(xx(ind2)+0.5,yy(ind2),['Q1 = ',num2str(round(Q1))])
     grid;
      F.Children.findobj('tag','eFq1').String = num2str(xx(Ind));
      F.Children.findobj('tag','eQa1').String = num2str(0);
      F.Children.findobj('tag','eQa2').String = num2str(Q1);
      F.Children.findobj('tag','eQa3').String = num2str(0);       
     ax2.Children(1).UserData.F1 = xx(Ind);
     ax2.Children(1).UserData.F2 = 0;
     ax2.Children(1).UserData.Q1 = Q1;
     ax2.Children(1).UserData.Q2 = 0;
     ax2.Children(1).UserData.dFq = 0;
  end
  termo = F.Children.findobj('tag','etermo').String;
  ax2.Children(1).UserData.termo = termo;

  % Round position uicounter
  if handles.chbCircle.Value == 1
    disp(F.UserData.counter);
    Step = str2num(handles.eStep.String);
    Num = str2num(handles.eNum.String);
    Pos = str2num(handles.ePos.String);
    counter = F.UserData.counter;
    Counter = floor(counter/Num);
    F.UserData.counter = counter + 1;
    F.UserData.Step = Step;
    F.UserData.Num = Num;
    F.UserData.Pos = Pos;

    handles.ePos.String = num2str(Step*Counter);
    if (Step*Counter) >= 360
      handles.ePos.String = num2str(Step*Counter-360);
      F.UserData.Pos = Pos-360;
    end
  end
end % function Start


function plot_sample(src,evt,rec,ln,Fs)
    ln.YData = getaudiodata(rec);
    ln.XData = 1:length(getaudiodata(rec));
end

% function Stop(src, evt)
%     F = gcf;
%     set(F.Children.findobj('tag','btnStart'),'UserData','stop');
% end

function OpenFigure(src,evt)
%     btn = evt.Source;
%     tg = btn.Tag; 
%     F1 = src.get('Parent');
%     h = F1.Children(2);
%     set(0,'showhiddenhandles','on')
%     newF = figure;
%     s = copyobj(h,newF);
    F1 = src.Parent;
    F2 = F1.Parent;  % figure;
    F3 = F2.Children;
    pn1 = F3(4).Children; ax1 = pn1(2);  % time axes
    pn2 = F3(3).Children; ax2 = pn2(2);  % freq axes
    if strcmp(evt.Source.Tag,'btnFreq')
        Ln = ax2.Children;
        figure; plot(Ln(1).XData,Ln(1).YData); grid;
    else
        Ln = ax1.Children;
        figure; plot(Ln(1).XData,Ln(1).YData); grid;
    end
end

function Save(src,evt)
    F1 = src.Parent;
    F2 = F1.Parent;  % figure;
    F3 = F2.Children;
    pn1 = F3(4).Children; ax1 = pn1(2);  % time axes
    pn2 = F3(2).Children; ax2 = pn2(2);  % freq axes
    ln = ax1.Children;
    
    a = clock;
    name = ['wave_signal_','date_',num2str(a(3)),'_',num2str(a(2)),'_',num2str(a(1)),'__time_',num2str(a(4)),'h',num2str(a(5)),'m__resonator_N'];
    var = ln.YData;
    uisave('var',name);
end

function Load(src,evt)
    F1 = src.Parent;
    F2 = F1.Parent;  % figure;
    D = F2.UserData.UInames;
    F3 = F2.Children;
    pn1 = F3(4).Children; ax1 = pn1(2);  % time axes
    pn2 = F3(3).Children; ax2 = pn2(2);  % freq axes
    ln = ax1.Children;
    [n, p] = uigetfile('*.mat',getStr(D,'f_Load'));
    if ~isnumeric(p)&&~isnumeric(n)
        data = load(strcat(p,n));
        data = data.var;
    
        Fs = 44100;
        rem = length(data) - floor(length(data)/Fs)*Fs;
        data = data(rem+1:end);
        time = [1/Fs:1/Fs:length(data)/Fs];

        plot(ax1,time,data);

        [A, fq] = fft_prc(data,Fs,0);
         A(1:2000) = 0;
        plot(ax2,fq,A);

        ax1.Color = [0.7569 0.8667 0.7765];
        ax2.Color = [0.7569 0.8667 0.7765];
        ax1.XLim = [time(1); time(end)];
        
        [max_amp, max_ind] = max(A);
        ax2.XLim = [fq(max_ind-50) fq(max_ind+50)];
        set(ax1,'XGrid','on','YGrid','on');
        set(ax2,'XGrid','on','YGrid','on');
    end
end

function Protocol(src,evt)
  % create protocol for stability temperature
    handles = guihandles(src);
    F = gcf;
    F1 = src.Parent;
    F2 = F1.Parent;  % figure;
    D = F2.UserData.UInames;
    D = getTagStruct(D);
    F3 = F2.Children;
    pn1 = F3(4).Children; ax1 = pn1(2);  % time axes
    pn2 = F3(3).Children; ax2 = pn2(2);  % freq axes
    pn4 = F3(2).Children;
    Ln = ax2.Children;
    
    dFq = [];
    F1 = [];
    F2 = [];
    for i = 1:length(Ln)
        if isfield(Ln(i).UserData,'dFq') && ~isempty(Ln(i).UserData.dFq)
            dFq(i) = Ln(i).UserData.dFq;
        else
            dFq(i) = 0;
        end
        if ~isempty(Ln(i).UserData)
            F1(i) = Ln(i).UserData.F1;
            F2(i) = Ln(i).UserData.F2;
            Q1(i) = Ln(i).UserData.Q1;
            Q2(i) = Ln(i).UserData.Q2;
        else
            F1(i) = F1(i-1);
            F2(i) = Ln(i-1);
            Q1(i) = Ln(i-1);
            Q2(i) = Ln(i-1);
        end
        if F1(i)>F2(i)
            temp = F1(i);
            F1(i) = F2(i);
            F2(i) = temp;
            temp = Q1(i);
            Q1(i) = Q2(i);
            Q2(i) = temp;
        end
    end

    a = clock;
    resonator_name = F.findobj('tag','eNres').String;
    name = ['Protocol_','date_',num2str(a(3)),'_',num2str(a(2)),'_',num2str(a(1)),'__time_',num2str(a(4)),'h',num2str(a(5)),'m__resonator_N.txt'];
    
    fid = fopen(name,'w');
    
    fprintf(fid,'\n\n\n\n \t\t %30s %s \n \t\t\t %s %d/%d/%d %d:%d \n',...
      D.prot1_1,resonator_name,D.prot1_2,a(1),a(2),a(3),a(4),a(5));
    fprintf(fid,'\n\n\n');
    fprintf(fid,'\t\t\t %s \n\n',D.prot1_3);
    fprintf(fid,'--------------------------------------------------------------\n');
    fprintf(fid,'%s\t%9s%10s%12s%7s%9s\n',D.prot1_4,D.prot1_5,D.prot1_6,D.prot1_7,D.prot1_8,D.prot1_9);
    fprintf(fid,'--------------------------------------------------------------\n');

    if handles.chbCircle.Value == 0
    % standart protocol
        for i = 1:length(dFq)
            fprintf(fid,'%d.%12.2f%12.2f%10.2f%10.0f%10.0f\n',i,F1(i),F2(i),dFq(i),Q1(i),Q2(i));
        end
    else
        % protocol for circle
        Num = F.UserData.Num;
        Step = F.UserData.Step;
        F1_c = [ ];
        F2_c = [ ];
        dF_c = [ ];
        Q1_c = [ ];
        Q2_c = [ ];
        dQ_c = [ ];
        for i = 1:floor(length(dFq)/Num)
            fprintf(fid,'\t%s %d\n',D.prot1_10,Step*(i-1));
            for j = 1:Num
                m = (i-1)*Num+j;
                F_1(j) = F1(m);
                F_2(j) = F2(m);
                Q_1(j) = Q1(m);
                Q_2(j) = Q2(m);
                fprintf(fid,'%d.%12.2f%12.2f%10.2f%10.0f%10.0f\n',m,F1(m),F2(m),dFq(m),Q1(m),Q2(m));
            end
            d_Fq = 0;
            for j = 1:Num
                %--------------------
                if F_1(j) ~= 0 && F_2(j) ~= 0
                  d_Fq(j) = abs(F_1(j)-F_2(j));
                else
                  d_Fq(j) = 0;
                end
                %--------------------
                if Q_1(j) ~= 0 && Q_2(j) ~= 0
                  d_Q(j) = abs(Q_1(j)-Q_2(j));
                else
                  d_Q(j) = 0;
                end
            end

            F_1m = F_1;  F_1m(F_1==0)=[]; if isempty(F_1m); F_1m = 0; end
            F_2m = F_2;  F_2m(F_2==0)=[]; if isempty(F_2m); F_2m = 0; end
            d_Fqm = d_Fq;  d_Fqm(d_Fq==0)=[]; if isempty(d_Fqm); d_Fqm = 0; end
            Q_1m = Q_1;  Q_1m(Q_1==0)=[]; if isempty(Q_1m); Q_1m = 0; end
            Q_2m = Q_2;  Q_2m(Q_2==0)=[]; if isempty(Q_2m); Q_2m = 0; end
            d_Qm = d_Q;  d_Qm(d_Q==0)=[]; if isempty(d_Qm); d_Qm = 0; end

            F1_c(i)=mean(F_1m);
            F2_c(i)=mean(F_2m);
            dF_c(i)=mean(d_Fqm);
            Q1_c(i)=mean(Q_1m);
            Q2_c(i)=mean(Q_2m);
            dQ_c(i)=mean(Q_2m);

            fprintf(fid,'---------------mean results---------------------------\n');
            fprintf(fid,'%13.2f%12.2f%10.2f%10.0f%10.0f\n\n', F1_c(i), F2_c(i), dF_c(i), Q1_c(i), Q2_c(i));
        end
    end
    
    if handles.chbCircle.Value == 1
        figure;
        A = (Step*(0:length(F1_c)-1));
        b = plot(A,F1_c,'bo-',A,F2_c,'r*-','linewidth',2); 
        F = [F1_c(F1_c~=0) F2_c(F2_c~=0)]; 
        set(gca,'YLim',[min(F)-std(F) max(F)+std(F)],...
            'XLim',[min(A)-1 max(A)+1],...
            'XTick',A); 
        grid; 
    end

    fprintf(fid,'--------------------------------------------------------------\n');
    fprintf(fid,'-------------------- Mean values and tolerances  -------------\n');
    fprintf(fid,'--------------------------------------------------------------\n');
    F1(F1==0)=[];
    F2(F2==0)=[];
    dFq(dFq==0)=[];
    Q1(Q1==0)=[];
    Q2(Q2==0)=[];
    
    fprintf(fid,'%s%10.2f%12.2f%10.2f%10.0f%10.0f\n',D.prot1_11,mean(F1),mean(F2),mean(dFq),mean(Q1),mean(Q2));
    fprintf(fid,'--------------------------------------------------------------\n');
    fprintf(fid,'%s%7.2f%12.2f%10.2f%12.2f%10.2f\n',D.prot1_12,std(F1),std(F2),std(dFq),std(Q1),std(Q2));
    fprintf(fid,'\n\n\n');
    fprintf(fid,'\t\t\t %s \n\n',D.prot1_13);
    fprintf(fid,'--------------------------------------------------------------\n');
    fprintf(fid,'%s\t%7.2f %s\n\n',D.prot1_14,mean(F1),D.Hz_);
    fprintf(fid,'%s\t%7.2f %s\n\n',D.prot1_15,mean(F2),D.Hz_);
    fprintf(fid,'%s %7.2f %s \n\n',D.prot1_16,mean(dFq),D.Hz_);
    fprintf(fid,'%s\t\t\t%7.2f\n\n',D.prot1_17,mean(Q1));
    fprintf(fid,'%s\t\t\t%7.2f\n\n',D.prot1_18,mean(Q2));
    
    fprintf(fid,'\n\n\n\n\n\n %10s  %25s \n\n',D.prot1_19,D.prot1_20);
   
    fclose(fid);
    
    dos(['start wordpad "', name, '"']);
    
end

function Protocol2(src,evt)
    
    F1 = src.Parent;
    F2 = F1.Parent;  % figure;
    D = F2.UserData.UInames;
    D = getTagStruct(D);
    F3 = F2.Children;
    pn1 = F3(4).Children; ax1 = pn1(2);  % time axes
    pn2 = F3(3).Children; ax2 = pn2(2);  % freq axes
    pn4 = F3(2).Children;
    Ln = ax2.Children;
    Fig = F2;
    dFq = [];
    F1 = [];
    F2 = [];
    for i = 1:length(Ln)
        if isfield(Ln(i).UserData,'dFq') && ~isempty(Ln(i).UserData.dFq)
            dFq(i) = Ln(i).UserData.dFq;
        else
            dFq(i) = 0;
        end
        if isfield(Ln(i).UserData,'F1') && ~isempty(Ln(i).UserData.F1)
            F1(i) = Ln(i).UserData.F1;
        else
            F1(i) = 0;
        end
        if isfield(Ln(i).UserData,'F2') && ~isempty(Ln(i).UserData.F2)
            F2(i) = Ln(i).UserData.F2;
        else
            F2(i) = 0;
        end
        if isfield(Ln(i).UserData,'Q1')&&~isempty(Ln(i).UserData.Q1)
            Q1(i) = Ln(i).UserData.Q1;
        else
            Q1(i) = 0;
        end
        if isfield(Ln(i).UserData,'Q2')&&~isempty(Ln(i).UserData.Q2)
            Q2(i) = Ln(i).UserData.Q2;
        else
            Q2(i) = 0;
        end
        if isfield(Ln(i).UserData,'termo')&&~isempty(Ln(i).UserData.termo)
            Termo(i) = str2num(Ln(i).UserData.termo);
        else
            Termo(i) = 0;
        end
        if F1(i)>F2(i)
            temp = F1(i);
            F1(i) = F2(i);
            F2(i) = temp;
            temp = Q1(i);
            Q1(i) = Q2(i);
            Q2(i) = temp;
        end
    end
    
    if length(Termo) < 2
        errordlg(D.err1);
        return; 
    end
    
    a = clock;
    
    name = ['ProtocolTK4_','date_',num2str(a(3)),'_',num2str(a(2)),'_',num2str(a(1)),'__time_',num2str(a(4)),'h',num2str(a(5)),'m__resonator_N.txt'];
    
    fid = fopen(name,'w');
    
    fprintf(fid,'\n\n\n\n \t %30s %s %s %d/%d/%d %d:%d \n',D.prot1_1, Fig.findobj('tag','eNres').String, D.prot2_1, a(1),a(2),a(3),a(4),a(5));
    fprintf(fid,'\n\n\n');
    fprintf(fid,'\t\t\t %s \n\n',D.prot2_2);
    fprintf(fid,'--------------------------------------------------------------\n');
    fprintf(fid,'%s\t%9s%10s%12s%7s%11s%7s\n',D.prot1_4,D.prot1_5,D.prot1_6,D.prot1_7,D.prot1_8,D.prot1_9,D.prot2_3);
    fprintf(fid,'--------------------------------------------------------------\n');
    for i = 1:length(dFq)
        fprintf(fid,'%d.%12.2f%12.2f%10.2f%10.0f%10.0f\t%d\n',i,F1(i),F2(i),dFq(i),Q1(i),Q2(i),Termo(i));
    end
    fprintf(fid,'--------------------------------------------------------------\n');
    
    fprintf(fid,'%s:%10.2f%12.2f%10.2f%10.0f%10.0f\n',D.prot1_11,mean(F1),mean(F2),mean(dFq),mean(Q1),mean(Q2));
    fprintf(fid,'--------------------------------------------------------------\n');
    fprintf(fid,'%s:%7.2f%12.2f%10.2f%12.2f%10.2f\n',D.prot1_12,std(F1),std(F2),std(dFq),std(Q1),std(Q2));
    fprintf(fid,'\n\n\n');
    fprintf(fid,'\t %s\n\n',D.prot2_4);
    fprintf(fid,'--------------------------------------------------------------\n');
    
    
    fprintf(fid,'%s ',D.prot2_5);
    if length(Termo)>1
        for i = 1:length(Termo)-1
            fprintf(fid,'%3.1f, ',Termo(i));
        end
        fprintf(fid,'%3.1f \n', Termo(end));
    else
        fprintf(fid,'%3.1f \n', Termo(end));
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\t%7.2f...%7.2f %s\t(dF1= %2.2f %s)\n\n',D.prot2_6,min(F1),max(F1),D.Hz_,max(F1)-min(F1),D.Hz_);
    fprintf(fid,'%s\t%7.2f...%7.2f %s\t(dF2= %2.2f %s)\n\n',D.prot2_7,min(F2),max(F2),D.Hz_,max(F2)-min(F2),D.Hz_);
    fprintf(fid,'%s %7.2f %s\n\n',D.prot2_8,mean(dFq),D.Hz_);
    fprintf(fid,'%s \t\t\t%7.2f\n\n',D.prot2_9,mean(Q1));
    fprintf(fid,'%s \t\t\t%7.2f\n\n',D.prot2_10,mean(Q2));

    
    % calculate TK4
    
    for i = 1:length(F1)
        if F1(i)~=0 && F2(i) ~= 0
            mF(i) = (F1(i)+F2(i))/2;
        else
            mF(i) = (F1(i)+F2(i));
        end
        
    end
    
    F_poly = polyfit(Termo,mF,1);
    F_lin = polyval(F_poly,Termo);
    figure;
    
    plot(Termo,mF,'*r');
    hold on;
    plot(Termo,F_lin,'o-');
    grid;
    legend({D.plot_1,D.plot_2});
    title(D.plot_3);
    xlabel(D.prot2_3);
    ylabel(D.Hz_);
    TK4 = (max(F_lin)-min(F_lin))/(max(Termo)-min(Termo));
    
    fprintf(fid,'%s %6.6f %s \n',D.plot2_11,TK4,D.plot2_12);
    
    
    fprintf(fid,'\n\n\n\n\n\n %10s  %25s \n\n',D.prot1_19,D.prot1_20);
   

    fclose(fid);
    
    
    dos(['start wordpad "', name, '"']);
    
end

function Play(src, evt)
    F1 = src.Parent;
    F2 = F1.Parent;  % figure;
    F3 = F2.Children;
    pn1 = F3(3).Children; ax1 = pn1(2);  % time axes
    pn2 = F3(2).Children; ax2 = pn2(2);  % freq axes
    ln = ax1.Children;
    sound(ln.YData,44100,16);
end

function btn_clear(src,evt)
    F = get(gcf);
%     F = src.Parent.Parent;
    ax = F.Children(3).Children(2);
    if strcmp(src.Tag,'btnClear')
        cla(ax);
        drawnow
    else
        Lines = ax.Children;
        delete(Lines(1));
    end
    ax_res = F.Children(1).Children;
    cla(ax_res,'reset');
    set(ax_res,'Color',[0.7569 0.8667 0.7765],'XGrid','on','YGrid','on');
end

function StartFcn(src,evt)
    handles = guihandles(src);
    if get(gcf,'CurrentCharacter')==32
        disp('super');
        Start(src,evt);
    elseif get(gcf,'CurrentCharacter')==8
        btn_clear(src,evt);
    end
end

function TermoSet(src,evt)
    handles = guihandles(src);
    Lines = handles.frm3.Children(2).Children;
    str = handles.etermo.String;
    Lines(1).UserData.termo = str;
end

function chb_circle(src, evt)
    handles = guihandles(src);
    F = gcf;
    if handles.chbCircle.Value == 0
        handles.eStep.Enable = 'off';
        handles.tStep.Enable = 'off';
        handles.eNum.Enable = 'off';
        handles.tNum.Enable = 'off';
        handles.tPos.Enable = 'off';
        handles.ePos.Enable = 'off';
        F.UserData.counter = 1;
        handles.ePos.String = '0';
    else
        handles.eStep.Enable = 'on';
        handles.tStep.Enable = 'on';
        handles.eNum.Enable = 'on';
        handles.tNum.Enable = 'on';
        handles.tPos.Enable = 'on';
        handles.ePos.Enable = 'on';
    end
end

function setStrByTag(src,evt)
  %-------------------------------------------------------------
  % Set strings from file for uicontrol elements and protocols
  %-------------------------------------------------------------
  if strcmp(src.Type,'uipanel')
    D = src.Parent.UserData.UInames;
    Param = 'Title';
  elseif strcmp(src.Type,'uicontrol')
    D = src.Parent.Parent.UserData.UInames;
    Param = 'String';
  end
  ind = find(not(cellfun('isempty',(strfind(D.Tags,src.Tag)))));
  Name = D.Strings{ind};
  src.(Param) = Name;
  
end

function D = getDataStr(filename)
  %--------------------------------------------------------------
  % Get strings from file for uicontrol elements and protocols
  %------------------------------------------------------------- 
  D = struct();
  fid = fopen('stringfile.txt','r');
  s = fgetl(fid); % skip first head line 
  strCA = {};
  i = 0;
  while ~feof(fid)
    i = i+1;
    s = fgetl(fid);
    strCA{i} = textscan(s,'%s %s','delimiter',';');
  end
  fclose(fid);
  Tags = {};
  Strings = {};
  for i = 1:length(strCA)
    Tags{i} = strCA{i}{1}{1};
    Strings{i} = strCA{i}{2}{1};
  end
  D.Tags = Tags;
  D.Strings = Strings;
end

function S = getTagStruct(D)
  S = struct();
  for i = 1:length(D.Tags)
    S.(D.Tags{i}) = D.Strings{i};
  end
end

function Data = LoadData_FromMatFile(FileName)
% Function îpen UserData in current Figure
% Data = LoadData_FromMatFile(FileName)
% inputs:
% FileName - name of the mat file that must contain such data

% data - cell array with the data structures
    % data structure have such possible fields:
    % Numeration - integer vector with current number of the attemp
    % SoundArr - signal recorded from microphone
    % SoundTime - vector with time points in second
    % PrcOffsetTime - Offset in second between detect and
                    % processing sound of the hit 
    % PrcSoundBegin - point SoundArr from what begin processing
    % SoundDampingAmpl - approx process of the damping
    % SoundDampingTime - time points in second
    % E_DampingVal - amplitude damped in e times
    % E_DampingTime - time point in second
    % FFT_Ampl - results of the procession by FFT
    % FFI_freq - vector of the frequency points
    % FFT_AmplAprox - aproximation model
    % FFT_freqAprox - freq vector for FFT_AmplAprox
    % Peak1 - [Frequency, Amplitude]
    % Peak2 - [Frequency, Amplitude]
    % Q1 - Q factor for Peak1
    % Q2 - Q factor for Peak2 
    % Q3 - Q factor by damping sound
    % dT - damping time
    % A_time - time of the attempt
    % A_data - data of the attempt
    Data = load(FileName);
end