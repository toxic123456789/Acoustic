classdef TemperatureDataSound 
	properties
		path = '';
	end

	methods
		function obj = TemperatureDataSound(adr)
			% adr - directory adress
			if isstr(adr)
				[format, normList] = checkFileFormat(obj, adr);
				if ~strcmp(format,'norm')
					errordlg('unsupported format','unsupported format');
					return;
				end
				[temprVect,angleArr,nameArr] = ScanNormList(obj,normList);
				% Sort data by temperature and angle 
				for i = 1:length(temprVect)
					T_str = ['T',num2str(temprVect(i))];
					for j = 1:length(nameArr{i})
						A_str = ['A',num2str(angleArr{i}(j))];
						obj.(T_str).(A_str) = ResonatorAcousticData([adr,nameArr{i}{j}]);
                    end
                    obj.(T_str).angles = angleArr{i};
                    obj.(T_str).names = nameArr{i};
                end
                obj.T = tempVect;
            end
		end


		function D = Load(obj,p,T)
			% D = Load_script_fcn(p,T)
			% path:
			% p = 'd:\Ð?Ð¡ÐŸÐ«Ð¢ÐÐÐ?Ð¯\2019_07_03_4Ð\';
			% temperature:
			% T = [30 35 40 45 50 55 60 65]; 

			if nargin < 2 
				T = obj.T;
			end

			D = struc('');
			i = 0;
			for i = 1:length(T)
				name = ['d',num2str(T(i))];
				try 
					disp(['Load ',name,' data ...']); 
					D.(name) = ResonatorAcousticData([p,name,'.wav'],obj.AngleStep);
				catch
					disp(['Error in ',name,' data']);
				end
			end

			save([p,'D_',num2str(T(1)),'_',num2str(T(end)),'.mat']','D');
		end



		function PlotParameter(obj,name,column,T)

			if nargin < 2
				name = 'Frequency';
			end
			if nargin < 3
				column = 1;
			end
			if nargin < 4
				T = obj.T;
			end

        	f = figure;

        	hold on; 

        	for i = 1:length(T)
        		for j = 1:length(column)
        			curNm = ['d',num2str(T(i))];
	        		curAn = obj.D.(curNm).Angle(:);
	        		curSn = obj.D.(curNm).(name)(:,column(j));
	        		ind = find(curSn~=0);
	        		plot(curAn(ind), curSn(ind),'-o','linewidth',1.5);
	        		plotLg{i} = curNm;
	        	end
        	end

        	set(gca,'XGrid','on','YGrid','on','GridAlpha',1);

        	ylabel('degree')

        	legend(plotLg);
            title(name);
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
				mFq(j) = obj.D.(curNm).GetStat('mean','Frequency',column);
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
            disp(1);
		end


	end % methods 
end



