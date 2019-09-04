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
	end


	methods
		function obj = ResonatorAcousticData(adr)
			% Open, recognize and processing data
			% ===================================
			if nargin < 1
				[n p] = uigetfile('*.wav','Choose .WAV file for read');
				adr = [p,n];
				if n == 0
					return;
				end
            end
            Time_offset = 1000;
			[M Fs] = audioread(adr);
			% % % % % % % % % % % %
			obj.path = adr;
            obj.Fs = Fs;
			% % % % % % % % % % % %
			ResData = GetResFreqAmpl(obj,M,Time_offset,Fs);
			obj.Frequency = ResData.Frequency;
			obj.Amplitude = ResData.Amplitude;
			obj.R_fft_data = ResData.R_fft_data;
			obj.Discr = ResData.Discr;
			% % % % % % % % % % % %
			i_off = 6000;
			obj.QFactor = GetQFactor(obj,ResData,i_off);
			SoundData = GetSoundDecrease(obj,M);
			obj.DecreaseFit = SoundData.DecreaseFit;
			obj.DecreaseTime(1) = SoundData.DecreaseTime;
			% % % % % % % % % % % %
			obj = SortData(obj);
            obj = AlignFreqDiap(obj,1);
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
			% function distribute values between two resonanses

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
        

		function [xx, yy] = InterpFreq(obj,bplot)
			% [xx, yy] = InterpFreq(obj,bplot)
			% build and show real and interpolation freq data
            
			% initialisation
			if nargin<1
				bplot = 0;
			end
			Fs = obj.Fs; 
			step = obj.step;
            fq = obj.R_fft_data(:,1);
            A = obj.R_fft_data(:,2);
            
		    % interpolation data
		    xx = fq(1):step:fq(end);
		    yy = interp1(fq,A,xx,'spline');

		    % show reuslt
		    if bplot == 1
		    	figure; hold on; 
		    	plot(fq,A,'bo');
		    	plot(xx,yy,'r.');
                if obj.Frequency(1)~=0
                    plot([obj.Frequency(1) obj.Frequency(1)],...
                        get(gca,'YLim'),'r--');
                end
                if obj.Frequency(2)~=0
                    plot([obj.Frequency(2) obj.Frequency(2)],...
                        get(gca,'YLim'),'r--');
                end
		    	grid; set(gca,'GridAlpha',1);
		    	title(['FFt transform '])
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

	end % methods
end % classdef