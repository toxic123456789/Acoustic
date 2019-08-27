classdef TemperatureDataSound 
	properties
        AngleStep = 9;
		T = [];
		D = struc('');
	end

	methods
		function obj = TemperatureDataSound(adr,T,angle)
			% adr - directory adress
			if isstr(adr)
				if nargin < 2
					errordlg('Not enougth temperature vector','Error');
                    return;
                end
                obj.T = T;
				obj.D = Load(obj,adr,T);
            end
            if nargin > 2
                obj.AngleStep = angle;
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

	end
end



