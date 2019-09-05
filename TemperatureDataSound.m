classdef TemperatureDataSound 
	properties
		path = '';
        data = '';
        T = '';
	end

	methods
		function obj = TemperatureDataSound(adr)
			% adr - directory adress
			if isstr(adr)
				[format, normList] = getFileList(obj, adr);
				if ~strcmp(format,'norm')
					errordlg('unsupported format','unsupported format');
					return;
				end
				[temprVect,angleArr,nameArr] = ScanNormList(obj,normList);
				% Sort data by temperature and angle 
				for i = 1:length(temprVect)
					T_str = ['T',num2str(temprVect(i))];
					for j = 1:length(nameArr{i})
                        % name of angle consist of symbol A and angle in
                        % minutes
						A_str = ['A',num2str(angleArr{i}(j)*60)];
                        obj.data.(T_str).(A_str) = [];
						obj.data.(T_str).(A_str) = ResonatorAcousticData([adr,nameArr{i}{j}]);
                    end
                    obj.data.(T_str).angles = angleArr{i};
                    obj.data.(T_str).names = nameArr{i};
                    obj.data.(T_str) = obj.SortData(obj,i);
                end
                obj.T = temprVect;
                obj.path = adr;
%                 obj.dF = obj.GetStat('mean','Frequency',2)-obj.GetStat('mean','Frequency',1);
%                 obj.dQ = obj.GetStat('max','QFactor',1)-obj.GetStat('min','QFactor',1);
%                 obj.dQ(2) = obj.GetStat('max','QFactor',2)-obj.GetStat('min','QFactor',2);
%                 obj.F1 = obj.GetStat('mean','Frequency',1);
%                 obj.F2 = obj.GetStat('mean','Frequency',2);
%                 obj.maxQ1 = obj.GetStat('max','QFactor',1);
%                 obj.maxQ2 = obj.GetStat('max','QFactor',2);
            end
		end


		function TKF = Get_TKF(obj,column,bplot)
			TKF = [];
			if nargin < 2
				column = 1;
			end
			if nargin < 3
				bplot = 0;
			end
			T = obj.T;
			for j = 1:length(T)
    			curNm = ['d',num2str(T(j))];
				mFq(j) = obj.D.(curNm).getStat('mean','Frequency',column);
			end
			TKF = (max(mFq)-min(mFq))/(max(T)-min(T));
			if bplot ~= 0 
				figure; hold on; 
				plot(T,mFq,'o--b','linewidth',1.5);
				set(gca,'XGrid','on','YGrid','on','GridAlpha',1);
				fit_model = polyfit(T,mFq,1);
				fit_data = polyval(fit_model,[T(1):0.1:T(end)]);
				plot([T(1):0.1:T(end)],fit_data,'.r','linewidth',1.5);
				text(mean(T)-5,mean(mFq)-0.1,['TK4 exp = ',num2str(TKF)]);
				text(mean(T)-5,mean(mFq)-0.2,['TK4 fit = ',num2str(fit_model(1))]);
				ylabel('Hz');
				xlabel('Celsium degree')
				legend({'experemental','fit'})
                TKF = fit_model(1);
			end
		end


		function [format, normList] = getFileList(obj, adr)
        	% function format = getFileList(adr)
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
						expression = '^d\d+(\.\d+)*_a\d+(\.\d+)*';
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
                format = 'long';
            end
        end


		function [temprVect,angleArr,nameArr] = ScanNormList(obj,normList)
			% function [temprVect,angleArr,nameArr] = ScanNormList(normList)
			temprVect = [];
			angleArr = {};
			nameArr = {};
            nameArr_ = {};
			% find temperatures
			expression = '^d(\d)+';
			for i = 1:length(normList)
				matchStr = regexp(normList{i},expression,'match');
				temprVect(i) = str2num(matchStr{1}(2:end));
			end
			[temprVect, ia, ic] = unique(temprVect,'stable');
			ind = {};
			for i = 1:length(temprVect)
				ind{i} = find(ic==i);
			end
			% find angles
			expression = '_a\d+(\.\d+)*';
			for i = 1:length(temprVect)
				for j = 1:length(ind{i})
					matchStr = regexp(normList{ind{i}(j)},expression,'match');
					angleArr{i}(j) = str2num(matchStr{1}(3:end));
					nameArr_{i}{j} = [normList{ind{i}(j)},'.wav'];
				end
				[res, ind_] = sort(angleArr{i});
				angleArr{i} = angleArr{i}(ind_);
                for n = 1:length(nameArr_{i})
                    nameArr{i}{n} = nameArr_{i}{ind_(n)};
                end
            end
		end


		function statValue = getStat(obj,stat,name,column)
			% statValue = getStat(obj,stat,name,column)

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


		function data = getData(obj,name,temperature,column);
			% function data = getData(obj,name,temperature,column)
			% function collect data for definite parameter from definite temperatures
			% Temperature can be a vector not only one single nuber 
			% in this case function return array with collected data

			% Initialisation
			if nargin < 2
				name = 'Frequency';
			end
			if nargin < 3
				temperature = obj.T;
			end
			if nargin < 4
				column = 1;
			end

			data = [];
			for i = 1:length(temperature)
				curT = ['T',num2str(temperature(i))];
				angles = obj.data.(curT).angles;
				for j = 1:length(angles)
					curA = ['A',num2str(angles(j)*60)];
					curV = obj.data.(curT).(curA).(name);
					data(j,i) = curV(column);
				end
			end

		end


		function data = SortData(obj,t_num)
			% function data = SortData(obj,t_num) 
			% sorting frequency,amplitude and Qfactor data
			% after loading and processing sound data
			% return data structure for each temperature test
			% such as before but with sorting data by two resonanse
			% frequencies 

			Frequency(:,1) = obj.getData('Frequency',obj.T(t_num),1);
			Frequency(:,2) = obj.getData('Frequency',obj.T(t_num),2);
			Amplitude(:,1) = obj.getData('Amplitude',obj.T(t_num),1);
			Amplitude(:,2) = obj.getData('Amplitude',obj.T(t_num),2);

			% find idexes of the normal amplitudes, that not less than 1/2 of the maximum
			all_ind_vect = 1:length(Frequency(:,1));
			MaxA = max(Amplitude);
			trust_ind_1 = find(Amplitude(:,1) > MaxA(1)/2);
			trust_ind_2 = find(Amplitude(:,2) > MaxA(2)/2);
			% find indexes of the unnormal (very low) amplitudes
			A_distruct_ind_1 = all_ind_vect;
			A_distruct_ind_2 = all_ind_vect;
			A_distruct_ind_1(trust_ind_1) = [];
			A_distruct_ind_2(trust_ind_2) = [];

			% find mean frequencies by trust indexes
			meanFq_1 = mean(Frequency(trust_ind_1,1));
			meanFq_2 = mean(Frequency(trust_ind_2,2));

			% find distruct indexes
			distruct_ind_1 = find(abs(Frequency(:,1)-meanFq_1)>0.1);  
			distruct_ind_2 = find(abs(Frequency(:,2)-meanFq_2)>0.1);  
			% check distruct indexes by amplitudes
			distruct_ind_1(setdiff(distruct_ind_1, A_distruct_ind_1)) = [];
			distruct_ind_2(setdiff(distruct_ind_2, A_distruct_ind_2)) = [];

			

		end



		
		function [xx, yy] = InterpFreq(obj,temperature,angleN,bplot)
			% [xx, yy] = InterpFreq(obj,temperature,angleN,bplot)
			% build and show real and interpolation freq data
			% angleN - number of the angle 

			% initialisation
			if nargin<2
				temperature = 1;
			end
			curT = obj.getF('T',temperature);

			if nargin<3
				curA = obj.getF('A',1,temperature);
			else
				curA = obj.getF('A',angleN,temperature);
			end
			
			if nargin<4
				bplot = 0;
			end
			step = 0.0001;
            fq = obj.data.(curT).(curA).R_fft_data(:,1);
            A =  obj.data.(curT).(curA).R_fft_data(:,2);
            
		    % interpolation data
		    xx = fq(1):step:fq(end);
		    yy = interp1(fq,A,xx,'spline');

		    % show reuslt
		    if bplot == 1
		    	figure; hold on; 
		    	plot(fq,A,'bo');
		    	plot(xx,yy,'r.');
                if obj.data.(curT).(curA).Frequency(1)~=0
                    plot([obj.data.(curT).(curA).Frequency(1) obj.data.(curT).(curA).Frequency(1)],...
                        get(gca,'YLim'),'r--');
                end
                if obj.data.(curT).(curA).Frequency(2)~=0
                    plot([obj.data.(curT).(curA).Frequency(2) obj.data.(curT).(curA).Frequency(2)],...
                        get(gca,'YLim'),'r--');
                end
		    	grid; set(gca,'GridAlpha',1);
		    	title(['FFt transform for ',obj.getF('T',temperature),...
                    ' temperature, and ',num2str(obj.data.(curT).angles(angleN)),' angle']);
		    end

        end


        function PlotByList(obj)
        	f = figure;
        	T_colors = ['b','g','r','c','m','k','y'];

        	axs = axes('Parent',f,'Units','Normalized','Position',[0.1 0.1 0.7 0.8]);
        	plot(obj.getData('Frequency',obj.T(1),1)); grid;
            
   			uicontrol('Parent',f,'Style','text','tag','txtTemper','Units','Normalized',...
        		'Position',[0.1 0.92 0.2 0.05],'fontsize',12,'String','Temperture:',...
        		'backgroundcolor','r');
   			for i = 1:length(obj.T)
	            chbT{i} = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
	        		'Position',[0.31+(i-1)*0.09 0.92 0.07 0.05],...
	        		'String',num2str(obj.T(i)),'Value', 0, 'tag','chbT','backgroundcolor',...
	        		T_colors(i));
   			end
   			chbT{1}.Value = 1;
            
            chbT_All = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[chbT{length(obj.T)}.Position(1)+0.1 0.92 0.07 0.05],...
        		'String','All','Value', 0, 'tag','chbT_All',...
        		'callback',@(src,evt)CheckSetTemp_All(src,evt));

        	ppmGraph = uicontrol('Parent',f,'Style','popupmenu','Units','Normalized',...
        		'Position',[0.8 0.82 0.2 0.07],'tag','ppmGraph',...
        		'String',{'Frequency','QFactor','Amplitude'},...
        		'tag','lstName','backgroundcolor','r','callback',@(src,evt)PopupList_Func(src,evt));
            chbColumn1 = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.85 0.72 0.07 0.05],...
        		'String','1','Value', 1, ...
        		'tag','chbColumn1','backgroundcolor','b');
    		chbColumn2 = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.93 0.72 0.07 0.05],...
        		'String','2','Value', 1, ...
        		'tag','chbColumn2','backgroundcolor','r');
        	uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.8 0.6 0.2 0.05],'callback',@(src,evt)CheckFFT_Func(src,evt),...
        		'String','FFT','Value', 0, ...
        		'tag','FFT_check','backgroundcolor','r')
            chbGrid = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[0.8 0.2 0.2 0.05],'callback',@(src,evt)CheckGrid_Func(src,evt),...
        		'String','Grid','Value', 1, ...
        		'tag','chbGrid','backgroundcolor','r');
        	sld = uicontrol('Parent',f,'Style','slider','tag','sld','Units','Normalized',...
        		'Position',[0.92 0.4 0.04 0.2],'callback',@(src,evt)SliderFunc(src,evt),...
        		'min',1,'max',obj.ln('A',1),'Value',1,'sliderstep',[1/obj.ln('A',1) 3/obj.ln('A',1)],...
        		'Enable','off');
        	txt = uicontrol('Parent',f,'Style','text','tag','sldValue','Units','Normalized',...
        		'Position',[0.82 0.46 0.07 0.07],'fontsize',14,'String','0','backgroundcolor','w');

%         	cla(axs); 
%         	hold on;
%         	ind = find(obj.Frequency(:,1)~=0);
%         	plot(obj.Angle(ind),obj.Frequency(ind,1),'bo--','linewidth',1.5);
%             ind = find(obj.Frequency(:,2)~=0);
%         	plot(obj.Angle(ind),obj.Frequency(ind,2),'ro--','linewidth',1.5);
%         	set(axs,'GridAlpha',1,'XGrid','on','YGrid','on'); 

        	% UI functions
        	%----------------------------------------------

            function SliderFunc(src,evt)
                num = round(get(sld,'Value'));
                v = getTchb();
                txt.String = num2str(obj.data.(getF(obj,'T',v(1))).angles(num));
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
            function CheckSetTemp_All(src,evt)
            	if chbT_All.Value == 0 
            		for i = 1:length(chbT)
                        chbT{i}.Value = 0;
                    end
		        else
            		for i = 1:length(chbT)
                        chbT{i}.Value = 1;
                    end
		        end
            end

			% Plot functions             
        	%----------------------------------------------

            function p = PlotCurrentPar(hAx)
            	cla(hAx);
                hold on;
            	p = [];
            	temper = [];
            	for i = 1:length(chbT)
            		temper(i) = chbT{i}.Value;
                end
                curColors = T_colors(find(temper));
            	temper = obj.T(find(temper));
            	if isempty(temper)
            		return;
            	end
            	columns = [chbColumn1.Value, chbColumn2.Value];
            	columns = find(columns~=0);
            	for i = 1:length(columns)
                    s = obj.getData(ppmGraph.String{ppmGraph.Value},temper,columns(i));
            		for j = 1:length(temper)
	            		ind = find(s(:,j)~=0);
            			if columns(i) == 1
		            		color_plot = ['--o',curColors(j)];
		            	elseif columns(i) == 2
		            		color_plot = ['--*',curColors(j)];
		            	end
		            	p = plot(obj.data.(['T',num2str(temper(j))]).angles,...
                            s(ind,j),color_plot,'linewidth',1.5,'Parent',hAx);  
            		end
	            end
            end

            function p = PlotCurrentFft(hAx)
            	p = [];
            	cla(hAx);

            	% get temperature checkboxes
                temper = getTchb();
                % get angle number
                numA = round(sld.Value);
                for i = 1:length(temper)
                	hold on;
                    curT = getF(obj,'T',i);
                    curA = getF(obj,'A',i);
	                [xx, yy] = InterpFreq(obj, temper(i), numA);
	                fq = obj.data.(curT).(curA).R_fft_data(:,1);
	                A = obj.data.(curT).(curA).R_fft_data(:,2);
	                plot(xx, yy,[T_colors(temper(i)),'.'])
% 	            	plot(fq,A,'ob','Parent',hAx);
	                % find resonance 1 parameters
	                if obj.data.(curT).(curA).Frequency(1) ~= 0
	                	F1 = obj.data.(curT).(curA).Frequency(1);
	                	diap = [0 0]; % diapason for find res freq
	                	[v diap(1)] = min(abs(xx-(F1-0.02)));
	                	[v diap(2)] = min(abs(xx-(F1+0.02)));
	                	[fr1 fr1_ind] = min(abs(yy(diap(1):diap(2))-F1));
	                	fr1_ind = diap(1) + fr1_ind + 1;
	                	Q1 = obj.data.(curT).(curA).QFactor(1);

	                	plot(xx(fr1_ind),yy(fr1_ind),[T_colors(temper(i)),'v'],'MarkerSize',10);
	                	text(xx(fr1_ind)+0.05,yy(fr1_ind)+0.0002,['F1 = ',num2str(F1)]);
	                	text(xx(fr1_ind)+0.15,yy(fr1_ind)*0.707,['Q1 = ',num2str(Q1)]);
	                end

	                if obj.data.(curT).(curA).Frequency(2) ~= 0
	                	F2 = obj.data.(curT).(curA).Frequency(2);
	                	diap = [0 0]; % diapason for find res freq
	                	[v diap(1)] = min(abs(xx-(F2-0.02)));
	                	[v diap(2)] = min(abs(xx-(F2+0.02)));
	                	[fr2 fr2_ind] = min(abs(yy(diap(1):diap(2))-F2));
	                	fr2_ind = diap(1) + fr2_ind + 1;
	                	Q2 = obj.data.(curT).(curA).QFactor(2);

	                	plot(xx(fr2_ind),yy(fr2_ind),[T_colors(temper(i)),'v'],'MarkerSize',10);
	                	text(xx(fr2_ind)+0.05,yy(fr2_ind)+0.0002,['F2 = ',num2str(F2)]);
	                	text(xx(fr2_ind)+0.15,yy(fr2_ind)*0.707,['Q2 = ',num2str(Q2)]);
	                end   

                end
            end

            function v = getTchb()
            	% function v = getTchb() 
            	% collect values from temperature checkbuttons
            	v = [];
				for i = 1:length(chbT)
					v(i) = chbT{i}.Value;
				end
				v = find(v);
            end


        end
        
        function curF = getF(obj,name,num,numT)
            % function [curT, curA] = getF('name',num)
            % return current field from Temperaturesound structure
            % name can be 'T' or 'A'
            % 'T' - return temperature field 
            % 'A' - return angle field 
            % num - number of the field, index of the vector obj.T or obj.data.T30.angles
            % numT - addition number for determine the temperature field
            if nargin < 4
            	numT = 1;
            end
            curF = [];
            if strcmp(name,'T')
                curF = ['T',num2str(obj.T(num))];
            elseif strcmp(name,'A')
                curF = ['A',num2str(obj.data.(['T',num2str(obj.T(numT))]).angles(num)*60)];
            end
            	
        end


        function Ln = ln(obj,name,nT)
            % function Ln = getLn(obj,name,nT)
            % return length T or angles vector of the Temperaturesound structure
            % name can be 'T' or 'A'
            % 'T' - return length temperature field 
            % 'A' - return length of the angle field, also need to determine number of the 
            % temperature field 
            % nT - number of the temperature field
            Ln = 1;
            if strcmp(name,'T')
                Ln = length(obj.T);
            elseif strcmp(name,'A')
                Ln = length(obj.data.(getF(obj,'T',nT)).angles);
            end
        end

	end % methods 
end
