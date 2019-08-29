classdef ResonatorAcousticData
	properties(SetObservable)
		path = '';
		Frequency = [];
		QFactor = [];
		Angle = [];
		Temperature = [];
		Amplitude = [];
		DecreaseTime = [];
		DecreaseFit = [];
		Discr = [];
		R_fft_data = [];
		ln = 0;
		Fs = 0;
		step = 0.0001;
		FreqDiap = [2000 4000];
		AngleStep = 9; % degree 
        F1 = 0;
        F2 = 0;
        maxQ1 = 0;
        maxQ2 = 0;
        dF = 0;
        dQ = 0;
	end


	methods
		function obj = ResonatorAcousticData(adr,angleStep)
			% Open, recognize and processing data
			% ===================================
            [format, normList] = checkFileFormat(obj,adr);
			if nargin < 1
				[n p] = uigetfile('*.wav','Choose .WAV file for read');
				adr = [p,n];
				if n == 0
					return;
				end
            end
            if nargin > 1 
                obj.AngleStep = angleStep;
            end
            
			Time_offset = 1000; % points
			if strcmp(format,'old')
				[M, Fs]= SeparateSound(obj,adr,Time_offset);
			end
			if strcmp(format,'norm')
				for i = 1:length(normList)
					[M{i}, Fs] = audioread([adr, normList{i}, '.wav']);
				end
			end
			obj.ln = length(M);
			obj.path = adr;
            obj.Fs = Fs;
            
			for i = 1:length(M)
				% % % % % % % % % % % %
				ResData = GetResFreqAmpl(obj,M{i},Time_offset,Fs);
				obj.Frequency(i,:) = ResData.Frequency;
				obj.Amplitude(i,:) = ResData.Amplitude;
				obj.R_fft_data{i} = ResData.R_fft_data;
				obj.Discr(i) = ResData.Discr;
				% % % % % % % % % % % %
				i_off = 6000;
				obj.QFactor(i,:) = GetQFactor(obj,ResData,i_off);
				SoundData = GetSoundDecrease(obj,M{i});
				obj.DecreaseFit{i} = SoundData.DecreaseFit;
				obj.DecreaseTime(i,1) = SoundData.DecreaseTime;
			end
			clear M
			obj = SortData(obj);
            obj = AlignFreqDiap(obj,1);
            obj.Angle = GetAngles(obj);
            obj.dF = obj.GetStat('mean','Frequency',2)-obj.GetStat('mean','Frequency',1);
            obj.dQ = obj.GetStat('max','QFactor',1)-obj.GetStat('min','QFactor',1);
            obj.dQ(2) = obj.GetStat('max','QFactor',2)-obj.GetStat('min','QFactor',2);
            obj.F1 = obj.GetStat('mean','Frequency',1);
            obj.F2 = obj.GetStat('mean','Frequency',2);
            obj.maxQ1 = obj.GetStat('max','QFactor',1);
            obj.maxQ2 = obj.GetStat('max','QFactor',2);
		end


		function [M, Fs] = SeparateSound(obj,adr,Time_offset)
			% M = SeparateSound(adr) 
			% adr - file adress

			[Sound, Fs] = audioread(adr);
			obj.Fs = Fs;   

			% prepare initial data
			Sound(:,2) = [];
			Time = 1/Fs:1/Fs:length(Sound)/Fs;

			% Find peaks
			MinPeakDist = 50*Fs;
			MinPeakHeight = 0.025;
			[peaks_val, peaks_ind] = findpeaks(abs(Sound),...
			    'MinPeakDistance',MinPeakDist,...
			    'MinPeakHeight',MinPeakHeight);
            
			% Check number of the items

			% Separate and sort each items
			M = {}; % array for items samples
			counter = 0;
			Time_offset = 1000;
			for i = 1:length(peaks_ind)
				M{i} = Sound(peaks_ind(i)-Time_offset:peaks_ind(i)+16*Fs);
			    counter = counter + length(M{i});
            end
            clear Sound
		end


		function ResData = GetResFreqAmpl(obj,Sound,Time_offset,Fs) 
			% ResData = GetResFreqAmpl(Sound,Time_offset,Fs)

			% Initialisation
			step = obj.step;
			FreqDiap = obj.FreqDiap;

			% Find resonance frequency
			[A, fq] = fft_prc(Sound(Time_offset+50:end),Fs,0);
			ResData.Discr = fq(2) - fq(1);
		    [v, d1] = min(abs(fq-FreqDiap(1)));
		    [v, d2] = min(abs(fq-FreqDiap(2)));
		    [ra_1, ri_1] = max(A(d1:d2));
		    % find ONE resonanse frequency:
		    ri_1 = d1+ri_1+1; % convert to absolute index
		    % set diapason for interpolate:
		    dd = [floor(ri_1-10/ResData.Discr) floor(ri_1+10/ResData.Discr)];
		    % interpolation data
		    xx = fq(dd(1)):step:fq(dd(2));
		    yy = interp1(fq(dd(1):dd(2)),A(dd(1):dd(2)),xx,'spline');

			% find FIRST and SECOND resonance frequencies:
			[ra_all, ri_all] = findpeaks(yy,'MinPeakDistance',0.1,'MinPeakHeight',0.0005);
			arr = sortrows([ra_all', ri_all']);
			ra_all = arr(:,1);
			rf_all = arr(:,2); clear arr;
		    if length(ra_all)>1
				arr = sortrows([rf_all(end-1:end),ra_all(end-1:end)]);
				ra_1 = arr(1,2);
				ri_1 = arr(1,1);
				ra_2 = arr(2,2);
				ri_2 = arr(2,1);
		        ResData.Frequency = [xx(ri_1) xx(ri_2)];
		        ResData.Amplitude = [ra_1 ra_2];
			else
				% Sort and find algorithm for 1 peak:
				ra_1 = ra_all;
				ri_1 = rf_all;
				ra_2 = 0;
				ri_2 = 0;
		        ResData.Frequency = [xx(ri_1) 0];
		        ResData.Amplitude = [ra_1 0];
		    end


			ResData.R_fft_data = [fq(dd(1):dd(2))', A(dd(1):dd(2))];
            ResData.ri_1 = ri_1;
            ResData.ri_2 = ri_2;
            
		end


		function QFactor = GetQFactor(obj,Data,i_off)
			% QFactor = GetQFactor(obj,Data,i_off) 

			% Initialisation
			if nargin < 2
				i_off = 6000
			end
			Fs = obj.Fs; 
			step = obj.step;
			FreqDiap = obj.FreqDiap;
            fq = Data.R_fft_data(:,1);
            A = Data.R_fft_data(:,2);
            ri_1 = Data.ri_1;
            ri_2 = Data.ri_2;
            
            
		    % interpolation data
		    xx = fq(1):step:fq(end);
		    yy = interp1(fq,A,xx,'spline');

			% get QFactor 1
		    v_v = 0.707 * Data.Amplitude(1);
		    [v, ind_1] = min( abs(yy(ri_1-i_off:ri_1) - v_v)  );
		    [v, ind_2] = min( abs(yy(ri_1:ri_1+i_off) - v_v)  );
		    ind_1 = ri_1 - (i_off - ind_1) -1;
		    ind_2 = ri_1 + (ind_2) -1;
		    QFactor(1) = Data.Frequency(1)/(xx(ind_2)-xx(ind_1));
		    %  get QFactor 2
			if Data.Frequency(2) ~= 0
			    v_v = 0.707 * Data.Amplitude(2);
			    [v, ind_3] = min( abs(yy(ri_2-i_off:ri_2) - v_v)  );
			    [v, ind_4] = min( abs(yy(ri_2:ri_2+i_off) - v_v)  );
			    ind_3 = ri_2 - (i_off - ind_3) -1;
			    ind_4 = ri_2 + (ind_4) -1;
			    QFactor(2) = Data.Frequency(2)/(xx(ind_4)-xx(ind_3));
			else
				QFactor(2) = 0;
			end

		end


		function obj = SortData(obj)
			% obj = SortData(obj)

			ind = find(obj.Frequency(:,2)==0);
			Fq = obj.Frequency;
			Fq(ind,:)=[];
			mFq = mean(Fq);
			Q = obj.QFactor;
			Q(ind,:)=[];

			for i = 1:length(ind)
			    if abs(obj.Frequency(ind(i),1)-mFq(1)) > abs(obj.Frequency(ind(i),1)-mFq(2))
			        obj.Frequency(ind(i),2) = obj.Frequency(ind(i),1);
			        obj.Amplitude(ind(i),2) = obj.Amplitude(ind(i),1);
			        obj.Frequency(ind(i),1) = 0;
			        obj.Amplitude(ind(i),1) = 0;
			        obj.QFactor(ind(i),2) = obj.QFactor(ind(i),1);
			        obj.QFactor(ind(i),1) = 0; 
			    else
			        obj.Frequency(ind(i),2) = 0;
			        obj.Amplitude(ind(i),2) = 0;
			        obj.QFactor(ind(i),2)= 0;
			    end
			end
		end


		function [xx, yy] = InterpFreq(obj,N,bplot)
			% [xx, yy] = InterpFreq(obj,N,bplot)
			% build and show real and interpolation freq data

			% initialisation
			if nargin<2
				N = 1;
			end
			if nargin<3
				bplot = 0;
			end
			Fs = obj.Fs; 
			step = obj.step;
            fq = obj.R_fft_data{N}(:,1);
            A = obj.R_fft_data{N}(:,2);
            
		    % interpolation data
		    xx = fq(1):step:fq(end);
		    yy = interp1(fq,A,xx,'spline');

		    % show reuslt
		    if bplot == 1
		    	figure; hold on; 
		    	plot(fq,A,'bo');
		    	plot(xx,yy,'r.');
                if obj.Frequency(N,1)~=0
                    plot([obj.Frequency(N,1) obj.Frequency(N,1)],...
                        get(gca,'YLim'),'r--');
                end
                if obj.Frequency(N,2)~=0
                    plot([obj.Frequency(N,2) obj.Frequency(N,2)],...
                        get(gca,'YLim'),'r--');
                end
		    	grid; set(gca,'GridAlpha',1);
		    	title(['FFt transform for ',num2str(N),' sample'])
		    end

        end


        function obj = AlignFreqDiap(obj,Hz)
            % obj = AlignFreqDiap(obj)
            % function for cut and align R_fft_data;

            % find mean Frequency 1 and 2 
            ind_1 = find(obj.Frequency(:,1)~=0);
            mF1 = mean(obj.Frequency(ind_1,1));

            ind_2 = find(obj.Frequency(:,2)~=0);
            mF2 = mean(obj.Frequency(ind_2,2));

            for i = 1:obj.ln
	            % initialisation 
	            fq = obj.R_fft_data{i}(:,1);
	            A = obj.R_fft_data{i}(:,2);

    	    	[v d(1)] = min(abs(fq - mF1));
				[v d(2)] = min(abs(fq - mF2));
				d(1) = d(1) - floor(Hz/obj.Discr(i)); % -2 Hz
				d(2) = d(2) + floor(Hz/obj.Discr(i)); % +2 Hz
				obj.R_fft_data{i} = obj.R_fft_data{i}(d(1):d(2),:);
            end
        end


        function AnimFreq(obj)
        	% AnimFreq()

        	% Initialisation
        	step = obj.step;

        	figure;  grid; 
            set(gca,'GridAlpha',1);
            set(gca,'YLim',[0 max(max(obj.Amplitude))]);
        	for i = 1:obj.ln
	        	fq = obj.R_fft_data{i}(:,1);
	        	A = obj.R_fft_data{i}(:,2);
	        	xx = fq(1):step:fq(end);
	        	yy = interp1(fq,A,xx,'spline');
        		plot(fq,A,'ob');
        		plot(xx,yy,'.r');
        		pause(0.2)
        	end
        end
        
        
        function Angles = GetAngles(obj)
            % Angles = GetAngles(obj)

            Angles = [];
            counter = 0;
            for i = 1:obj.ln
                Angles(i) = counter;
            	counter = counter + obj.AngleStep;
            end
        end


		function Data = GetSoundDecrease(obj,Sound)
			% Data = GetSoundDecrease(Sound)

			% Initialise
			Fs = obj.Fs;
		    Time = [1:length(Sound)]/Fs;
		    offset_time = floor(0.01*Fs);
		    offset_time = 0.01; % second
		    modfunc = 'exp1';
		    MinPeakDist = 0.01;
		    sound_time = 6; % second
		    
		    % Find point with max.sound
		    offset_time = floor(offset_time*Fs);
		    [val_max, max_ind] = max(abs(Sound));
		    % build sound decrease model
		    % find peaks values from Sound
		    pt_begin = max_ind + offset_time; 
		    pt_end = floor(pt_begin + floor(sound_time*Fs));
		    peaks_time = pt_begin : pt_end;
		    [peaks_val, peaks_ind] = findpeaks(abs(Sound(peaks_time)),...
		    Time(peaks_time),'MinPeakDistance',MinPeakDist);
		    % build model sound decrease
		    sDecr_model = fit(peaks_ind',peaks_val,modfunc);
		    sDecr_time = Time(max_ind:pt_end);
		    sDecr_data = feval(sDecr_model, sDecr_time);
            
            sDecr_model2 = fit(peaks_ind',peaks_val,'exp2');
            sDecr_data2 = feval(sDecr_model2, sDecr_time);
		    % find e-time decrease sound 
		    [val e_decrease_ind] = min(abs((sDecr_data)-sDecr_data(1)/exp(1)));
            [val e_decrease_ind2] = min(abs((sDecr_data2)-sDecr_data2(1)/exp(1)));
		    % time of the decrease
		    e_decr_time = sDecr_time(e_decrease_ind)-sDecr_time(1);
            e_decr_time2 = sDecr_time(e_decrease_ind2)-sDecr_time(1);
		    Data.DecreaseFit = sDecr_model;
		    Data.DecreaseTime = e_decr_time;

% % 		    % diagnostic
% 		    figure(1); hold on; cla;
% 		    set(gca,'XLim',[0 Time(pt_end)]);
% 		    set(gca,'YLim',[-abs(val_max) abs(val_max)]);
% 		    plot(Time,Sound);
% 		    plot(peaks_ind,peaks_val,'or-');
% 		    plot(sDecr_time,sDecr_data,'g-','linewidth',2);
%             plot(sDecr_time,sDecr_data2,'y-','linewidth',2);
% 		    plot([sDecr_time(e_decrease_ind) sDecr_time(e_decrease_ind)],...
% 		    	[-sDecr_data(e_decrease_ind) sDecr_data(e_decrease_ind)],'k-');
%             plot([sDecr_time(e_decrease_ind2) sDecr_time(e_decrease_ind2)],...
% 		    	[-sDecr_data2(e_decrease_ind2) sDecr_data2(e_decrease_ind2)],'k--');
% 		    grid;
%             set(gca,'GridAlpha',1);
%             text(sDecr_time(e_decrease_ind),sDecr_data(e_decrease_ind)+0.01,['te = ',num2str(sDecr_time(e_decrease_ind)-sDecr_time(1))]);
%             text(sDecr_time(e_decrease_ind2),sDecr_data2(e_decrease_ind2)+0.02,['te2 = ',num2str(sDecr_time(e_decrease_ind2)-sDecr_time(1))]);
%             disp('diagnostic');
        end

        
		function statValue = GetStat(obj,stat,name,column)
			% statValue = GetStat(obj,stat,name,column)

			% Initialise
			if nargin < 2
				stat = 'mean';
			end
			if nargin < 3
				name = 'Frequency';
			end
			if nargin < 4
				column = [1,2];
			end
			
			% get values
			for i = 1:length(column)
                data = obj.(name)(:,column(i));
				ind{i} = find(data~=0);
				if strcmp(stat,'mean')
					statValue(i) = 	mean(data(ind{i}));
				elseif strcmp(stat,'min')
					statValue(i) = 	min(data(ind{i}));
				elseif strcmp(stat,'max')
					statValue(i) = 	max(data(ind{i}));
				end
			end

		end


		function Show(obj,name,column)
			% Show(name)

			% Initialisation
			if nargin<2
				name = 'Frequency';
			end
			if nargin<3
				column = [1,2];
			end

			% build plot
			figure; hold on; grid; set(gca,'GridAlpha',1)
			for i = 1:length(column)
				ind = find(obj.(name)(:,column(i))~=0);
				plot(obj.Angle(ind),obj.(name)(ind,column(i)),'o-');
				str{i} = [name,' column #',num2str(column(i))];
			end
			title([name]);
			xlabel('degree');
			ylabel(name);
			legend(str);
        end


        function SubPlot(obj, name, number, varargin)
        	% SubPlot(obj, name, number, varargin)

        	if nargin < 3
        		return;
        	end

        	figure; hold on; grid; set(gca,'GridAlpha',1);
        	for i = 1:length(varargin)
        		if isa(varargin{i},'ResonatorAcousticData')
        			s = varargin{i}.(name)(:,number);
        			ind = find(s~=0);
        			plot(varargin{i}.Angle(ind),s(ind),'-o','linewidth',1.5);
        		end
        	end
        end


        function PlotByList(obj)
        	f = figure;

        	axs = axes('Parent',f,'Units','Normalized','Position',[0.1 0.1 0.7 0.8]);
        	plot(obj.Frequency(:,1)); grid;

        	ppmGraph = uicontrol('Parent',f,'Style','popupmenu','Units','Normalized',...
        		'Position',[0.8 0.82 0.2 0.07],'tag','ppmGraph',...
        		'String',{'Frequency','QFactor','Amplitude'},...
        		'tag','lstName','backgroundcolor','r','callback',@(src,evt)PopupList_Func(src,evt));
            chbColumn1 = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.85 0.72 0.07 0.05],...
        		'String','1','Value', 1, ...
        		'tag','chbColumn1','backgroundcolor','b')
    		chbColumn2 = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.93 0.72 0.07 0.05],...
        		'String','2','Value', 1, ...
        		'tag','chbColumn2','backgroundcolor','r') 
        	uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.8 0.6 0.2 0.05],'callback',@(src,evt)CheckFFT_Func(src,evt),...
        		'String','FFT','Value', 0, ...
        		'tag','FFT_check','backgroundcolor','r')
            chbGrid = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.8 0.2 0.2 0.05],'callback',@(src,evt)CheckGrid_Func(src,evt),...
        		'String','Grid','Value', 1, ...
        		'tag','chbGrid','backgroundcolor','r') 
        	sld = uicontrol('Parent',f,'Style','slider','tag','sld','Units','Normalized',...
        		'Position',[0.92 0.4 0.04 0.2],'callback',@(src,evt)SliderFunc(src,evt),...
        		'min',1,'max',obj.ln,'Value',1,'sliderstep',[1/obj.ln 3/obj.ln],...
        		'Enable','off');
        	txt = uicontrol('Parent',f,'Style','text','tag','sldValue','Units','Normalized',...
        		'Position',[0.85 0.46 0.05 0.07],'fontsize',16,'String','1');

        	cla(axs); 
        	hold on;
        	ind = find(obj.Frequency(:,1)~=0);
        	plot(obj.Angle(ind),obj.Frequency(ind,1),'bo--','linewidth',1.5);
            ind = find(obj.Frequency(:,2)~=0);
        	plot(obj.Angle(ind),obj.Frequency(ind,2),'ro--','linewidth',1.5);
        	set(axs,'GridAlpha',1,'XGrid','on','YGrid','on'); 

        	% UI functions
        	%----------------------------------------------

            function SliderFunc(src,evt)
                num = round(get(sld,'Value'));
                txt.String = num2str(num);
                cla(axs);
                p = PlotCurrentFft(axs);
            end
            
            function PopupList_Func(src,evt)
                p = PlotCurrentPar(axs);
            end

            function CheckFFT_Func(src,evt)
                Value = get(src,'Value');
                if Value == 0
	                ppmGraph.Enable = 'on';
	                sld.Enable = 'off';
	                p = PlotCurrentPar(axs);
                else 
	                ppmGraph.Enable = 'off';
	                sld.Enable = 'on';
	                p = PlotCurrentFft(axs);
                end
            end  

            function CheckGrid_Func(src,evt)
            	if chbGrid.Value == 0 
		        	set(axs,'XGrid','off','YGrid','off'); 
		        else
		        	set(axs,'GridAlpha',1,'XGrid','on','YGrid','on'); 
		        end
            end
			
			% Plot functions             
        	%----------------------------------------------

            function p = PlotCurrentPar(hAx)
            	cla(hAx);
            	p = [];
            	s = obj.(ppmGraph.String{ppmGraph.Value});
            	columns = [chbColumn1.Value, chbColumn2.Value];
            	columns = find(columns~=0);
            	for i = 1:length(columns)
            		ind = find(s(:,i)~=0);
            		color_axes = '--ob';
            		if columns(i) == 2; color_axes = '--or'; end 
	            	p = plot(obj.Angle(ind),s(ind,i),color_axes,'linewidth',1.5,'Parent',hAx);  
	            end
            end

            function p = PlotCurrentFft(hAx)
            	p = [];
            	cla(hAx);
                num = str2num(txt.String);
                [xx, yy] = InterpFreq(obj,num,0);
                fq = obj.R_fft_data{num}(:,1);
                A = obj.R_fft_data{num}(:,2);
                plot(xx, yy,'r.')
            	plot(fq,A,'ob','Parent',hAx);
                % find resonance 1 parameters
                if obj.Frequency(num,1) ~= 0
                	F1 = obj.Frequency(num,1);
                	diap = [0 0]; % diapason for find res freq
                	[v diap(1)] = min(abs(xx-(F1-0.02)));
                	[v diap(2)] = min(abs(xx-(F1+0.02)));
                	[fr1 fr1_ind] = min(abs(yy(diap(1):diap(2))-F1));
                	fr1_ind = diap(1) + fr1_ind + 1;
                	Q1 = obj.QFactor(num,1);

                	plot(xx(fr1_ind),yy(fr1_ind),'bv','MarkerSize',10);
                	text(xx(fr1_ind)+0.05,yy(fr1_ind)+0.0002,['F1 = ',num2str(F1)]);
                	text(xx(fr1_ind)+0.15,yy(fr1_ind)*0.707,['Q1 = ',num2str(Q1)]);
                end

                if obj.Frequency(num,2) ~= 0
                	F2 = obj.Frequency(num,2);
                	diap = [0 0]; % diapason for find res freq
                	[v diap(1)] = min(abs(xx-(F2-0.02)));
                	[v diap(2)] = min(abs(xx-(F2+0.02)));
                	[fr2 fr2_ind] = min(abs(yy(diap(1):diap(2))-F2));
                	fr2_ind = diap(1) + fr2_ind + 1;
                	Q2 = obj.QFactor(num,2);

                	plot(xx(fr2_ind),yy(fr2_ind),'rv','MarkerSize',10);
                	text(xx(fr2_ind)+0.05,yy(fr2_ind)+0.0002,['F2 = ',num2str(F2)]);
                	text(xx(fr2_ind)+0.15,yy(fr2_ind)*0.707,['Q2 = ',num2str(Q2)]);
                end       
            end
        end
        
        
        function [format, normList] = checkFileFormat(obj, adr)
        	% function format = checkFileFormat(adr)
        	% return such file format:
        	% 'norm'
        	% 'old'
        	% if format 'norm' function return normList
            format = '';
        	[path,name] = fileparts(adr);
            j = 0; normList = [];
        	if isempty(name) && ~isempty(path)
        		% check contents of the directory
        		listFiles = dir(path);
        		for i = 1:length(listFiles)
    				str = listFiles(i).name;
        			if ~strcmp(str,'.')&&~strcmp(str,'..')
        				% check format for normal by using reqexp
						expression = '^d\d+_a\d+(\.\d+)*';
						matchStr = regexp(str,expression,'match');
        				if ~isempty(matchStr)
	        				j = j+1;
	        				normList{j} = matchStr{1};
        				end
        			end
                end
            end
            
            if ~isempty(normList)
                format = 'norm';
            else
                format = 'old';
            end
            
        end

        
	end % methods
end % classdef