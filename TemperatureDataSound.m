classdef TemperatureDataSound 
	properties
		path = '';
        data = '';
        T = '';
	end

	methods

		function obj = TemperatureDataSound
			% adr - directory adress
				PrewData = UI_getPar(obj);
		end

		function obj = UI_getPar(obj)
			% Create window for collect parameters for data procession
            data = [];
            FigSize=[300 900];
            ScrSize=get(0,'screensize');
            h = FigSize(2);
            FigPos(1)=(ScrSize(3)/2)-(FigSize(1)/2);
            FigPos(2)=(ScrSize(4)/2)-(FigSize(2)/2);
            FigPos(3:4)=FigSize;
            ParData = read_ParData_from_file();

            F  = figure('position',FigPos,'NumberTitle','off','Name',...
                'Parameters set','MenuBar','None','Tag','TMwind','Resize','off',...
                'DeleteFcn',@(src,evt)close_saving(src,evt));
            set(F,'position',[FigPos(1) FigPos(2)+200 FigPos(3) 300]);

            txt_path =  uicontrol('Parent',F,'Style','text','Units','Normalized',...
        		'Position',[0.02 0.852+0.07 0.78 0.07],...
        		'String','Data files path','tag','txt_diap');

            ppm_path = uicontrol('Parent',F,'Style','popupmenu','Units','Normalized',...
        		'Position',[0.07 0.792+0.07 0.73 0.05],...
        		'String',{'path'},'tag','ppm_path',...
        		'callback',@(src,evt)PopupEdit_Func(src,evt));

            edt_path = uicontrol('Parent',F,'Style','edit','Units','Normalized',...
        		'Position',[0.07 0.776+0.07 0.68 0.065],...
        		'String','path','tag','edt_path','KeyPressFcn',@Enter_on_edit);

            btn_path = uicontrol('Parent',F,'Style','pushbutton','Units','Normalized',...
        		'Position',[0.8 0.77+0.07 0.2 0.08],'callback',@btn_find_path,...
        		'String','find ','tag','btn_path');

            txt_prew =  uicontrol('Parent',F,'Style','text','Units','Normalized',...
        		'Position',[0.02 0.65+0.12 0.78 0.07],...
        		'String','File prewiev','tag','txt_prew');

            btn_scan = uicontrol('Parent',F,'Style','pushbutton','Units','Normalized',...
        		'Position',[0.06 0.575+0.14 0.2 0.07],'callback',@btn_scan_path,...
        		'String','Scan','tag','btn_prew');

            ppm_scan = uicontrol('Parent',F,'Style','popupmenu','Units','Normalized',...
        		'Position',[0.28 0.59+0.14 0.5 0.05],...
        		'String',{'----'},'tag','ppm_prew');

            btn_prew = uicontrol('Parent',F,'Style','pushbutton','Units','Normalized',...
        		'Position',[0.80 0.575+0.14 0.2 0.07],'callback',@btn_prew_file,...
        		'String','File prewiev','tag','btn_prew');

            txt_diap =  uicontrol('Parent',F,'Style','text','Units','Normalized',...
        		'Position',[0.02 0.45+0.17 0.78 0.07],...
        		'String','Set diapason','tag','txt_diap');

            ppm_diap = uicontrol('Parent',F,'Style','popupmenu','Units','Normalized',...
        		'Position',[0.07 0.37+0.21 0.73 0.05],...
        		'String',{'2000 4000'}, 'tag','ppm_diap',...
                'callback',@(src,evt)PopupEdit_Func(src,evt));

            edt_diap = uicontrol('Parent',F,'Style','edit','Units','Normalized',...
        		'Position',[0.07 0.355+0.21 0.68 0.065],'KeyPressFcn',@Enter_on_edit,...
        		'String', '2000 - 4000', 'tag','edt_diap');

            txt_save = uicontrol('Parent',F,'Style','text','Units','Normalized',...
                'Position',[0.03 0.241+0.19 0.6 0.07],...
                'String', 'Save data to variable name:', 'tag','txt_save',...
                'HorizontalAlignment','left');

            edt_save = uicontrol('Parent',F,'Style','edit','Units','Normalized',...
                'Position',[0.5 0.25+0.19 0.5 0.065],...
                'String', 'a', 'tag','edt_save');

            btn_load = uicontrol('Parent',F,'Style','pushbutton','Units','Normalized',...
        		'Position',[0.25 0.05+0.26 0.5 0.1],'callback',@btn_load_all,...
        		'String','Load','tag','btn_load','fontsize',13,'fontweight','bold');

            txt_file = uicontrol('Parent',F,'Style','text','Units','Normalized',...
                'Position',[0.1 0.25 0.65 0.05],'HorizontalAlignment','left',...
                'String', 'Loaded data:', 'tag','txt_file');

            lst_file = uicontrol('Parent',F,'Style','listbox','Units','Normalized',...
                'Position',[0.1 0.01 0.8 0.24],...
                'String',{'Load'},'tag','lst_file','fontsize',12,'fontweight','bold');

            c = uicontextmenu;
            lst_file.UIContextMenu = c;
            uimenu(c,'Label','PlotByList','Callback',@(src,evt)menuBrowser(src,evt));
            uimenu(c,'Label','Protocol','Callback',@(src,evt)menuBrowser(src,evt));
            uimenu(c,'Label','Plot_TK4','Callback',@(src,evt)menuBrowser(src,evt));
            refresh_listbox();

            % Set ParData
            ppm_path.String = ParData.pathes;
            edt_path.String = ParData.pathes{1};
            
            ppm_diap.String = ParData.f_diapason_str;
            edt_diap.String = ParData.f_diapason_str{1}; 


            function btn_load_all(src,evt)
	        	% Load data acoustic files with set parameters

	        	% Get current parameters
	        	ParData = get_ParData_fromUI(src,evt);

	        	% Save parameters
                Save_Par_Data(ParData);

                % Load data from path
                path = ParData.pathes{1};
                diap = ParData.f_diapason(1,:);
                if path(end)~='\'; path(end+1)='\'; end

               	% get data file list
				[format, normList] = getFileList(obj, path);
				if ~strcmp(format,'norm')
					errordlg('unsupported format','unsupported format');
					return;
				end
				[temprVect,angleArr,nameArr] = ScanNormList(obj,normList);
                obj.T = temprVect;
                obj.path = path;
                w_ln = length(normList);
                % Sort data by temperature and angle 
                f_w = waitbar(0,'Please wait...');
                counter = 0;
                for i = 1:length(temprVect)
	                T_str = obj.getF('T',i);
                    obj.data.(T_str).angles = angleArr{i};
                    obj.data.(T_str).names = nameArr{i};
                    for j = 1:length(nameArr{i})
                        % name of angle consist of symbol A and angle in
                        % minutes
                        counter = counter + 1;
                        waitbar( counter/w_ln, f_w,...
                            ['file ',nameArr{i}{j},' processing ...']);
                        A_str = obj.getF('A',j,i);
                        obj.data.(T_str).(A_str) = [];
                        obj.data.(T_str).(A_str) = ResonatorAcousticData([path,nameArr{i}{j}],diap);
                    end
                    obj.data.(T_str).meanFq_1 = [];
                    obj.data.(T_str).meanFq_2 = [];
                    obj = obj.SortData(i);
                end
                close(f_w);
                % save results in variable
                vars = evalin('base','whos');
                StorageTDS = [];
                for i= 1:length(vars)
                    if strcmp(vars(i).name,'StorageTDS')
                        StorageTDS =  evalin('base','StorageTDS');
                    end
                end
                StorageTDS.(edt_save.String) = obj;
                assignin('base','StorageTDS',StorageTDS);
                refresh_listbox(src,evt);
	        end
            
            
            function refresh_listbox(src,evt)
                vars = evalin('base','whos');
                list = {''}; j = 1;
                for i= 1:length(vars)
                    if strcmp(vars(i).name,'StorageTDS')
                        StorageTDS =  evalin('base','StorageTDS');
                        list = fieldnames(StorageTDS);
                    end
                end
                if isempty(list)
                    list{1} = '------';
                end
                lst_file.String = list;
            end


            function menuBrowser(src,evt)
                % variants of get submenu name for different matlabs vers:
                try
                    str = evt.Source.Text;
                catch
                    str = evt.Source.Label;
                end
                nm = lst_file.String{lst_file.Value};
                if strcmp(nm,'ans')
                    errordlg('data is empty','data is empty');
                	return;
                end
                if strcmp(str,'PlotByList')
					evalin('base',['StorageTDS.',nm,'.PlotByList']); 
                elseif strcmp(str,'Protocol')
					evalin('base',['StorageTDS.',nm,'.getProtocol']); 
				elseif strcmp(str,'Plot_TK4')
					evalin('base',['StorageTDS.',nm,'.Get_TKF(1,1)']);
                end
            end

            function ParData = Init_Par_data()
            	ParData = struct('f_diapason',[2000 4000],...
            		'pathes','g:\TESTS\2019_08_22_10K\',...
            		'f_diapason_str','2000 - 4000');
            end

            function ParData = read_ParData_from_file()
            	if exist('parameters_set.txt','file')
            		% read parameters from file
            		fid = fopen('parameters_set.txt','r');
            		strArr = {};
            		i = 0;
            		while ~feof(fid)
            			i = i+1;
            			strArr{i} = fgetl(fid);
            		end
            		ind = 0;

            		f_diapason = [];
            		pathes = {};

            		for i = 1:length(strArr)

            			if strcmp(strArr{i},'f_diapason')
            				ind = 1;
            			elseif strcmp(strArr{i},'pathes')
            				ind = 2;
            			elseif isempty(strArr{i})
            				ind = 0;
            			end
                        
            			if ind == 1 && ~strcmp(strArr{i},'f_diapason')
                            ind1 = find(strArr{i}=='-');
            				f_diapason = [f_diapason; [str2num(strArr{i}(1:ind1-1)) str2num(strArr{i}(ind1+1:end))]];
                        elseif ind == 2 && ~strcmp(strArr{i},'pathes')
            				pathes = [pathes, strArr{i}];
            			end

                    end
                    fclose(fid);
                    
                    ParData.f_diapason_str = {};
                    for i = 1:length(f_diapason(:,1))
                        ParData.f_diapason_str{i} = [num2str(f_diapason(i,1)),...
                        ' - ',num2str(f_diapason(i,2))];
                    end
        			ParData.pathes = pathes;
        			ParData.f_diapason = f_diapason;
        			
            	else
            		% initialize parameters data
            		ParData = Init_Par_data();
            	end
            end
            

            function PopupEdit_Func(src,evt)
            	% change related edtit content
            	% and sort data in the current popupmenu:
            	% first begin chosen value in the popup.
                % Popupmenu and edit must have the same sufix and standar
                % prefix
                % for example: ppm_path , edt_path

            	% define popup sufix
            	ind = find(src.Tag == '_');
                sufix = src.Tag(ind:end);
                % set ind edit tag curent popup string
                src.Parent.findobj('tag',['edt',sufix]).String = ...
                    src.String{src.Value};
                % sort data in the popupmenu 
                curStr = src.String{src.Value};
                allStr = src.String;
                allStr(src.Value) = [];
                allStr = [curStr; allStr];
                src.String = allStr;
                % refresh variable name
                edt_save.String = scan_data_name(obj,edt_path.String,'variable');
            end
            

            function Enter_on_edit(src,evt)
                drawnow;
                if isequal(evt.Key,'return')
                    color = src.BackgroundColor;
                    src.BackgroundColor = 'g';
                    pause(0.1);
	                % get current sting 
                    curStr = (get(src,'String'));
	            	% define popup sufix
	            	ind = find(src.Tag == '_');
	                sufix = src.Tag(ind:end);
	                % get popup string list
					allStr = src.Parent.findobj('tag',['ppm',sufix]).String;
	                % find if exist equal string
	                v_eq = strfind(allStr,curStr);
					ind_eq = find(not(cellfun('isempty',v_eq)));
					if ~isempty(ind_eq)
						allStr(ind_eq) = [];
					end
					% sort data in the popupmenu 
					allStr = [curStr; allStr];
					src.Parent.findobj('tag',['ppm',sufix]).String = allStr;
                    src.BackgroundColor = color;
                end
            end


            function btn_find_path(src,evt)
            	% open file browser for get path to data files 
                drawnow
            	path = uigetdir(src.Parent.findobj('tag','edt_path').String);
                if path == 0
                    return;
                end
            	if exist(path)~=0
            		allStr = src.Parent.findobj('tag','ppm_path').String;
                    % find if exist equal string
	                v_eq = strfind(allStr,path);
					ind_eq = find(not(cellfun('isempty',v_eq)));
					if ~isempty(ind_eq)
						allStr(ind_eq) = [];
                    end
                    % add 
            		allStr = [path; allStr];
            		src.Parent.findobj('tag','ppm_path').String = allStr;
                    src.Parent.findobj('tag','edt_path').String = path;
                    % set variable name
                    try
                        path_arr = split(obj.path,'\');
                    catch
                        path_arr = strsplit(obj.path,'\');
                    end
                    expr = '\d+_\d+_\d+_.+';
                    file = '';
                    for i = 1:length(path_arr)
                        matchStr = regexp(path_arr{i},expr,'match');
                        if ~isempty(matchStr)
                            file = matchStr; file = file{1};
                            break;
                        else
                            file = 'undefined';
                        end
                    end
                    % refresh variable name in edit
                    edt_save.String = scan_data_name(obj,edt_path.String,'variable');
            	else
            		errordlg('incorrect path','incorrect path');
            	end
            end


            function btn_scan_path(src,evt)
            	% chek data acoustic files in current path and 
            	% load apropriate filenames in popupmenu

            	path = src.Parent.findobj('tag','edt_path').String;
            	content = dir(path);
            	if ~isempty(content)
            		apr_files = {};
            		expr = '^d(\d)+_a\d+(\.\d+)*\.wav';
            		for i = 1:length(content)
            			matchStr = regexp(content(i).name,expr,'match');
            			if ~isempty(matchStr)
            				apr_files = [apr_files, matchStr];
            			end
            		end
            		if ~isempty(apr_files)
            			src.Parent.findobj('tag','ppm_prew').String = apr_files;
                        clr = src.Parent.findobj('tag','ppm_prew').BackgroundColor;
                        src.Parent.findobj('tag','ppm_prew').BackgroundColor = 'g';
                        pause(0.1);
                        src.Parent.findobj('tag','ppm_prew').BackgroundColor = clr;
            		else
            			errordlg('not find apropriate files',...
            				'not find apropriate files');
                        src.Parent.findobj('tag','ppm_prew').String = {'------'};
                    end
                    drawnow
                else
                    errordlg('not find apropriate files',...
                        'not find apropriate files');
                    src.Parent.findobj('tag','ppm_prew').String = {'------'};
            	end
            end


            function btn_prew_file(src,evt)
            	% show fft plot for selected file

            	path = src.Parent.findobj('tag','edt_path').String;
            	name = src.Parent.findobj('tag','ppm_prew').String{...
            	src.Parent.findobj('tag','ppm_prew').Value};
                
                try
                    if path(end)~='\';
                        path(end+1)='\';
                    end
                    
                	[M, Fs] = audioread([path,name]);

                	[A, fq] = fft_prc(M,Fs,0);

                	figure; 
                	subplot(211); plot([1:length(M)]/Fs,M); grid;
                	subplot(212); plot(fq,A); grid;
                catch
                    errordlg('incorrect file name','incorrect file name');
                end
            end
        

            function Save_Par_Data(ParData)
            	% write parameters to the file
               	fid = fopen('parameters_set.txt','w');
               	fprintf(fid,'f_diapason\n');
               	for i = 1:size(ParData.f_diapason,1)
               		fprintf(fid,'%d - %d\n',ParData.f_diapason(i,1),ParData.f_diapason(i,2));
               	end
               	fprintf(fid,'\n');
               	fprintf(fid,'pathes\n');
               	for i = 1:length(ParData.pathes)
               		fprintf(fid,'%s\n',ParData.pathes{i});
               	end
               	fclose(fid);
            end

            function ParData = get_ParData_fromUI(src,evt)
            	% get all data from user interface
                ppm_ui1 = src.Parent.findobj('tag','ppm_diap');
                if length(ppm_ui1)>1
                    ppm_ui1 = ppm_ui1(1);
                end
                ppm_ui2 = src.Parent.findobj('tag','ppm_path');
                if length(ppm_ui2)>1
                    ppm_ui2 = ppm_ui2(1);
                end
            	ParData.f_diapason_str = ppm_ui1.String;
            	ParData.pathes = ppm_ui2.String;
            	j = 0;
                for i = 1:length(ParData.f_diapason_str)
                	str = ParData.f_diapason_str{i};
	                ind = find(str=='-');
	                if ~isempty(ind)&&~isempty(str2num(str(1:ind-1)))&&~isempty(str2num(str(ind+1:end)))
	                	j = j+1;
	                	ParData.f_diapason(j,:) = [str2num(str(1:ind-1)) str2num(str(ind+1:end))];
					else
						ParData.f_diapason_str(i) = [];
	                end
                end
                
                if isempty (ParData.f_diapason_str)
                	PpData = Init_Par_data;
                	ParData.f_diapason_str = PpData.f_diapason_str;
                	ParData.f_diapason = PpData.f_diapason;
                end
                
            end

            function close_saving(src,evt)
            	% save data in file before closing

	        	% Get current parameters
	        	ParData = get_ParData_fromUI(src,evt);

	        	% Save parameters
                Save_Par_Data(ParData);
            end

        end


		function [TKFa, TKF]= Get_TKF(obj,column,bplot)
            % TKF = Get_TKF(obj,column,bplot)
            % function get column number (first or second frequency) and 
            % return two Termal Frequencies coefficients 
            % first by approximation method, and second TKF by direct 
            % calculation 

            TKF  = [];
			TKFa = [];
			if nargin < 2
				column = 1;
			end
			if nargin < 3
				bplot = 0;
			end
			T = obj.T;

			for j = 1:length(T)
                mFq(j) = getStat(obj,'mean','Frequency',j,column);
			end
            % TKF by direct calculation
            TKF = (max(mFq)-min(mFq))/(max(T)-min(T));
            % TKF by approximamtion 
            fit_model = polyfit(T,mFq,1);
            fit_data = polyval(fit_model,[T(1):0.1:T(end)]);
            TKFa = fit_model(1);

            
            if bplot ~= 0 
                figure; hold on; 
                plot(T,mFq,'o--b','linewidth',1.5);
                set(gca,'XGrid','on','YGrid','on','GridAlpha',1);
				plot([T(1):0.1:T(end)],fit_data,'.r','linewidth',1.5);
				text(mean(T)-5,mean(mFq)-0.1,['TK4 exp = ',num2str(TKF)]);
				text(mean(T)-5,mean(mFq)-0.2,['TK4 fit = ',num2str(TKFa)]);
				ylabel('Hz');
				xlabel('Celsium degree')
				legend({'experemental','fit'})
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


		function statValue = getStat(obj,stat,name,indT,column)
			% statValue = getStat(obj,stat,name,column)
            % Temp by index (1,2,3);
            
			% Initialise
			if nargin < 2
				stat = 'mean';
            end
            
			if nargin < 3
				name = 'Frequency';
            end
            
            if nargin < 4
				indT = 1;
            end
            
			if nargin < 5
				column = 1;
            end
            
            Tname = obj.getF('T',indT);
			% get values
            if strcmp(name,'Frequency')
                data = obj.getData('Frequency',indT,column);
            elseif strcmp(name,'Amplitude');
                data = obj.getData('Amplitude',indT,column);
            elseif strcmp(name,'QFactor');
                data = obj.getData('QFactor',indT,column);
            end
			ind = find(data~=0);

            if strcmp(stat,'mean')
                statValue = mean(data(ind));
            elseif strcmp(stat,'min')
                statValue = min(data(ind));
            elseif strcmp(stat,'max')
                statValue = max(data(ind));
            end

		end


		function data = getData(obj,name,temperature,column,num)
			% function data = getData(obj,name,temperature,column,num)
			% function collect data for definite parameter from definite temperatures
			% Temperature can be a vector not only one single nuber 
			% in this case function return array with collected data

			% Initialisation
			angle_ind = 0;
			if nargin < 2 
				name = 'Frequency';
			end
			if strcmp(name,'Angle')
				name = 'Frequency';
				angle_ind = 1;
			end
			if nargin < 3
				temperature = 1:length(obj.T);
			end
			if nargin < 4
				column = 1;
			end

            data = [];
            for i = 1:length(temperature)
                curT = getF(obj,'T',temperature(i));
                angles = obj.data.(curT).angles;
                if nargin < 5
                    num = 1:length(angles);
                end
				for j = 1:length(num)
					curA = ['A',num2str(angles(num(j))*60)];
					curV = obj.data.(curT).(curA).(name);
					data(j,i) = curV(column);
				end
			end
			if angle_ind == 1
				data = angles;
			end
        end


        function obj = setData(obj,name,temperature,column,num,value)
            % function data = setData(obj,name,temperature,column,num)
            % function set data for definite parameter from definite temperatures
            % Temperature can be a vector not only one single nuber 
            % in this case function return array with collected data

            % Initialisation
            angle_ind = 0;
            if nargin < 2 
                name = 'Frequency';
            end
            if nargin < 3
                temperature = 1:length(obj.T);
            end
            if nargin < 4
                column = 1;
            end
            if nargin < 6
                value = 0;
            end

            data = [];
            for i = 1:length(temperature)
                curT = getF(obj,'T',temperature(i));
                angles = obj.data.(curT).angles;
                for j = 1:length(num)
                    curA = ['A',num2str(angles(num(j))*60)];
                    obj.data.(curT).(curA).(name)(column) = value;
                end
            end
        end

        
        function data = getDataT(obj,name,temperature)
            data = [];
            for i = 1:2
                data = [data, getData(obj,'Frequency',temperature,i)];
            end
        end
        
		function obj = SortData(obj,t_num)
			% function data = SortData(obj,t_num) 
			% sorting frequency,amplitude and Qfactor data
			% after loading and processing sound data
			% return data structure for each temperature test
			% such as before but with sorting data by two resonanse
			% frequencies 

            Frequency(:,1) = obj.getData('Frequency',t_num,1);
			Frequency(:,2) = obj.getData('Frequency',t_num,2);
			Amplitude(:,1) = obj.getData('Amplitude',t_num,1);
			Amplitude(:,2) = obj.getData('Amplitude',t_num,2);
			QFactor(:,1) = obj.getData('QFactor',t_num,1);
			QFactor(:,2) = obj.getData('QFactor',t_num,2);
            
            Frequency0 = Frequency;
			Frequency0 = Frequency;
			Amplitude0 = Amplitude;
			Amplitude0 = Amplitude;
			QFactor0 = QFactor;
			QFactor0 = QFactor;            
        
            curT = obj.getF('T',t_num);
			% ============= Sort data ===================

            nAmplitude = Amplitude0./max(max(Amplitude));
            [sArr sInd] = sort(abs(nAmplitude(:,1)-nAmplitude(:,2)));
            midleInd = 0;
            for j = 1:length(sInd)
                if nAmplitude(sInd(j),1)>0.25
                    midleInd = sInd(j);
                end
                if midleInd ~= 0 
                    break
                end
            end
            % Set the support frequencies
            fq1 = Frequency0(midleInd,1);
            obj.data.(curT).meanFq_1 = fq1;
            fq2 = Frequency0(midleInd,2);
            obj.data.(obj.getF('T',t_num)).meanFq_2 = fq2;
            ind1 = find(nAmplitude(:,1)>0.1); ind11 = find(Frequency0(:,1)>0);
            ind2 = find(nAmplitude(:,2)>0.1); ind22 = find(Frequency0(:,2)>0);
            ind1 = intersect(ind1,ind11);
            ind2 = intersect(ind2,ind22);
            % concatenate two vectors
            Frequency1 = [Frequency0(ind1,1); Frequency0(ind2,2)];
            Amplitude1 = [Amplitude0(ind1,1); Amplitude0(ind2,2)];
            QFactor1 = [QFactor0(ind1,1); QFactor0(ind2,2)];
            Index = [ind1;ind2];
            % Sort new two freq and ampl vectors;
            ln = length(Frequency0(:,1));
            vFq1(1:ln) = 0; vFq2(1:ln) = 0;
            vAm1(1:ln) = 0; vAm2(1:ln) = 0;
            vQf1(1:ln) = 0; vQf2(1:ln) = 0;
%             figure; hold on; plot(ind1,Frequency0(ind1,1),'o-'); plot(ind2,Frequency0(ind2,2),'o-');
%             plot(get(gca,'XLim'),[fq1 fq1],'r--');
%             plot(get(gca,'XLim'),[fq2 fq2],'r--');
%             bb = plot([Index(1) Index(1)],get(gca,'YLim'),'b--');
            for i = 1:length(Index)
%                         delete(bb);
%                 bb = plot([Index(i) Index(i)],get(gca,'YLim'),'b--');
                if abs(Frequency1(i)-fq1)<abs(Frequency1(i)-fq2)
                    if vFq1(Index(i))==0
                        vFq1(Index(i)) = Frequency1(i);
                        vAm1(Index(i)) = Amplitude1(i);
                        vQf1(Index(i)) = QFactor1(i);
                    else
                        if Frequency1(i) > vFq1(Index(i))
                            vFq2(Index(i)) = Frequency1(i);
                            vAm2(Index(i)) = Amplitude1(i);
                            vQf2(Index(i)) = QFactor1(i);
                        else
                            vFq2(Index(i)) = vFq1(Index(i));
                            vAm2(Index(i)) = vAm1(Index(i));
                            vQf2(Index(i)) = vQf1(Index(i));
                            vFq1(Index(i)) = Frequency1(i);
                            vAm1(Index(i)) = Amplitude1(i);
                            vQf1(Index(i)) = QFactor1(i);
                        end
                    end
%                     plot(Index(i),vFq1(Index(i)),'bp');
                elseif abs(Frequency1(i)-fq2)<abs(Frequency1(i)-fq1)
                    if vFq2(Index(i))==0
                        vFq2(Index(i)) = Frequency1(i);
                        vAm2(Index(i)) = Amplitude1(i);
                        vQf2(Index(i)) = QFactor1(i);
                    else
                        if Frequency1(i) > vFq2(Index(i))
                            vFq1(Index(i)) = vFq2(Index(i));
                            vAm1(Index(i)) = vAm2(Index(i));
                            vQf1(Index(i)) = vQf2(Index(i));
                            vFq2(Index(i)) = Frequency1(i);
                            vAm2(Index(i)) = Amplitude1(i);
                            vQf2(Index(i)) = QFactor1(i);
                        else
                            vFq1(Index(i)) = Frequency1(i);
                            vAm1(Index(i)) = Amplitude1(i);
                            vQf1(Index(i)) = QFactor1(i);
                        end
                    end
%                     plot(Index(i),vFq2(Index(i)),'r*');
                end

            end
            % find eq
            ind1 = find(vFq1>0);
            ind2 = find(vFq2>0);

            % zeroing previous results
            for i = 1:length(obj.data.(['T',num2str(obj.T(t_num))]).angles)
                curA = getF(obj,'A',i,t_num);
                obj.data.(curT).(curA).QFactor(1) = 0;
                obj.data.(curT).(curA).Frequency(1) = 0;
                obj.data.(curT).(curA).Amplitude(1) = 0;
                obj.data.(curT).(curA).QFactor(2) = 0;
                obj.data.(curT).(curA).Frequency(2) = 0;
                obj.data.(curT).(curA).Amplitude(2) = 0;
            end
            % processing & writing new results
            for i = 1:length(ind1)
                curA = getF(obj,'A',ind1(i),t_num);
                obj.data.(curT).(curA).Frequency(1) = vFq1(ind1(i));
                obj.data.(curT).(curA).Amplitude(1) = vAm1(ind1(i));
                obj.data.(curT).(curA).QFactor(1) = vQf1(ind1(i));
            end

            for i = 1:length(ind2)
                curA = getF(obj,'A',ind2(i),t_num);
                obj.data.(curT).(curA).Frequency(2) = vFq2(ind2(i));
                obj.data.(curT).(curA).Amplitude(2) = vAm2(ind2(i));
                obj.data.(curT).(curA).QFactor(2) = vQf2(ind2(i));
            end

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
            
   			uicontrol('Parent',f,'Style','text','tag','txtTemper','Units','Normalized',...
        		'Position',[0.1 0.92 0.2 0.05],'fontsize',12,'String','Temperture:',...
        		'backgroundcolor','r');
   			for i = 1:length(obj.T)
	            chbT{i} = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
	        		'Position',[0.31+(i-1)*0.09 0.92 0.07 0.05],...
	        		'String',num2str(obj.T(i)),'Value', 0, 'tag','chbT','backgroundcolor',...
	        		T_colors(i),'callback',@(src,evt)ChbTemp_Func(src,evt));
   			end
   			chbT{1}.Value = 1;
            
            chbT_All = uicontrol('Parent',f,'Style','checkbox','Units','Normalized',...
        		'Position',[chbT{length(obj.T)}.Position(1)+0.1 0.92 0.07 0.05],...
        		'String','All','Value', 0, 'tag','chbT_All',...
        		'callback',@(src,evt)CheckSetTemp_All(src,evt));
            % group #1 elements
            %=====================================
        	% axes for plot all parameters
        	axs1 = axes('Parent',f,'Units','Normalized','Position',[0.19 0.48 0.59 0.4]);
            group1 = uipanel('Units','normalize','tag','frm','Position',[0.79 0.48 0.2 0.4],'Title','Data');
        	ppmGraph = uicontrol('Parent',group1,'Style','popupmenu','Units','Normalized',...
        		'Position',[0.05 0.85 0.9 0.1],'tag','ppmGraph',...
        		'String',{'Frequency','QFactor','Amplitude'},...
        		'tag','lstName','backgroundcolor','r','callback',@(src,evt)PopupList_Func(src,evt));
            chbColumn1 = uicontrol('Parent',group1,'Style','checkbox','Units','Normalized',...
        		'Position',[0.05 0.70 0.45 0.09],...
        		'String','1(o)','Value', 1, 'callback',@(src,evt)ChbTemp_Func(src,evt), ...
        		'tag','chbColumn1','fontsize',12);
    		chbColumn2 = uicontrol('Parent',group1,'Style','checkbox','Units','Normalized',...
        		'Position',[0.55 0.70 0.45 0.09],...
        		'String','2(*)','Value', 1, 'callback',@(src,evt)ChbTemp_Func(src,evt), ...
        		'tag','chbColumn2','fontsize',12);
        	txt = uicontrol('Parent',group1,'Style','text','tag','sldValue','Units','Normalized',...
        		'Position',[0.3 0.55 0.5 0.11],'fontsize',12,'String','0','backgroundcolor','r',...
                'fontweight','bold');
            txtN = uicontrol('Parent',group1,'Style','text','tag','sldNumber','Units','Normalized',...
        		'Position',[0.3 0.40 0.5 0.11],'fontsize',12,'String','0','backgroundcolor','r',...
                'fontweight','bold');
        	sld = uicontrol('Parent',group1,'Style','slider','tag','sld','Units','Normalized',...
        		'Position',[0.05 0.25 0.9 0.1],'callback',@(src,evt)SliderFunc(src,evt),...
        		'min',1,'max',obj.ln('A',1),'Value',1,'sliderstep',[1/obj.ln('A',1) 3/obj.ln('A',1)],...
        		'Enable','on');
            chbGrid1 = uicontrol('Parent',group1,'Style','checkbox','Units','Normalized',...
        		'Position',[0.05 0.1 0.5 0.09],'callback',@(src,evt)CheckGrid_Func(src,evt),...
        		'String','Grid1','Value', 1, ...
        		'tag','chbGrid','backgroundcolor','r');

            % axes #1 uicontrols
            %=====================================
            group3 = uipanel('Units','normalize','tag','frm','Position',[0.01 0.48 0.12 0.4],'Title','Plot');
            btnPlotYY_data = uicontrol('Parent',group3,'Style','pushbutton','Units','Normalized',...
                'Position',[0.05 0.05 0.9 0.1],'callback',@btn_Plot_yy,...
                'String','PlotYY','tag','Plot_yy','fontsize',11,'fontweight','normal');
            btnPlotSineFit = uicontrol('Parent',group3,'Style','pushbutton','Units','Normalized',...
                'Position',[0.05 0.25 0.9 0.1],'callback',@btn_sine_fint,...
                'String','SineFit 1','tag','btnSineFit1','fontsize',11,'fontweight','normal');
            btnPlotSineFit = uicontrol('Parent',group3,'Style','pushbutton','Units','Normalized',...
                'Position',[0.05 0.15 0.9 0.1],'callback',@btn_sine_fint,...
                'String','SineFit 2','tag','btnSineFit2','fontsize',11,'fontweight','normal');
            % group #2 elements
            %=====================================
            % axes for plot in current point
            axs2 = axes('Parent',f,'Units','Normalized','Position',[0.19 0.05 0.58 0.35]);
            group2 = uipanel('Units','normalize','tag','frm','Position',[0.79 0.05 0.2 0.44],'Title','Point');

            txt_P1 = uicontrol('Parent',group2,'Style','text','Units','Normalized',...
                'Position',[0.05 0.90 0.45 0.09],'String','Point 1','Value', 1, ...
                'tag','txtP1','fontsize',8);

            txt_P2 = uicontrol('Parent',group2,'Style','text','Units','Normalized',...
                'Position',[0.55 0.90 0.45 0.09],'String','Point 2','Value', 1, ...
                'tag','txtP2','fontsize',8);

            btnRew = uicontrol('Parent',group2,'Style','pushbutton','Units','Normalized',...
                'Position',[0.40 0.92 0.2 0.07],'callback',@btn_rew,...
                'String','R','tag','rew','fontsize',11,'fontweight','normal');

            txt_F = uicontrol('Parent',group2,'Style','text','Units','Normalized',...
                'Position',[0.25 0.82 0.47 0.09],'String','Frequency','Value', 1, ...
                'tag','txtF','fontsize',8);

            edtF_P1 = uicontrol('Parent',group2,'Style','edit','Units','Normalized',...
                'Position',[0.05 0.75 0.45 0.09],'String','0','Value', 1, ...
                'tag','editFP1','fontsize',8);

            edtF_P2 = uicontrol('Parent',group2,'Style','edit','Units','Normalized',...
                'Position',[0.55 0.75 0.45 0.09],'String','0','Value', 1, ...
                'tag','editFP2','fontsize',8);

            txt_A = uicontrol('Parent',group2,'Style','text','Units','Normalized',...
                'Position',[0.25 0.63 0.47 0.09],'String','Amplitude','Value', 1, ...
                'tag','txtA','fontsize',8);

            edtA_P1 = uicontrol('Parent',group2,'Style','edit','Units','Normalized',...
                'Position',[0.05 0.55 0.45 0.09],'String','0','Value', 1, ...
                'tag','editAP1','fontsize',8);

            edtA_P2 = uicontrol('Parent',group2,'Style','edit','Units','Normalized',...
                'Position',[0.55 0.55 0.45 0.09],'String','0','Value', 1, ...
                'tag','editAP2','fontsize',8);


            txt_Q = uicontrol('Parent',group2,'Style','text','Units','Normalized',...
                'Position',[0.25 0.42 0.47 0.09],'String','QFactor','Value', 1, ...
                'tag','txtQ','fontsize',8);

            edtQ_P1 = uicontrol('Parent',group2,'Style','edit','Units','Normalized',...
                'Position',[0.05 0.35 0.45 0.09],'String','0','Value', 1, ...
                'tag','editAP1','fontsize',8);

            edtQ_P2 = uicontrol('Parent',group2,'Style','edit','Units','Normalized',...
                'Position',[0.55 0.35 0.45 0.09],'String','0','Value', 1, ...
                'tag','editAP2','fontsize',8);

            btnSet = uicontrol('Parent',group2,'Style','pushbutton','Units','Normalized',...
                'Position',[0.20 0.20 0.6 0.1],'callback',@btn_set,...
                'String','Set','tag','btn_set','fontsize',11,'fontweight','normal');
            
            btnP01 = uicontrol('Parent',group2,'Style','pushbutton','Units','Normalized',...
                'Position',[0.02 0.20 0.16 0.1],'callback',@btn_zero,...
                'String','0','tag','btn_P01','fontsize',11,'fontweight','normal');
            btnP02 = uicontrol('Parent',group2,'Style','pushbutton','Units','Normalized',...
                'Position',[0.82 0.20 0.16 0.1],'callback',@btn_zero,...
                'String','0','tag','btn_P02','fontsize',11,'fontweight','normal');

            btnFind = uicontrol('Parent',group2,'Style','pushbutton','Units','Normalized',...
                'Position',[0.05 0.04 0.4 0.1],'callback',@btn_Find,...
                'String','Find','tag','btn_Find','fontsize',11,'fontweight','normal');
                        
            txt_dFVal = uicontrol('Parent',group2,'Style','text','Units','Normalized',...
                'Position',[0.5 0.05 0.5 0.09],'String','','Value', 1, ...
                'tag','txtdFVal','fontsize',8);

            % axes2 uicontrols 
            %=====================================
            group4 = uipanel('Units','normalize','tag','frm','Position',[0.01 0.05 0.12 0.40],'Title','Plot');
            btnPlotAllFFt = uicontrol('Parent',group4,'Style','pushbutton','Units','Normalized',...
                'Position',[0.05 0.05 0.9 0.1],'callback',@btn_PlotFFt_all,...
                'String','Plot All','tag','btn_PlotFFtAll','fontsize',11,'fontweight','normal');
            
            edit_dFQ1 = uicontrol('Parent',group4,'Style','edit','Units','Normalized',...
                'Position',[0.25 0.85 0.45 0.1],...
                'String','0','tag','edt_dFQ1','fontsize',11,'fontweight','normal');
            text_dFQ1 = uicontrol('Parent',group4,'Style','text','Units','Normalized',...
                'Position',[0.01 0.85 0.23 0.1],...
                'String','dFq1','tag','txt_dFQ1','fontsize',11,'fontweight','normal');
            btn_dFQ1 = uicontrol('Parent',group4,'Style','pushbutton','Units','Normalized',...
                'Position',[0.72 0.85 0.27 0.1],'callback',@btn_zero_Q,...
                'String','0','tag','btn_dFQ1','fontsize',11,'fontweight','normal');
            edit_dFQ2 = uicontrol('Parent',group4,'Style','edit','Units','Normalized',...
                'Position',[0.25 0.7 0.45 0.1],...
                'String','0','tag','edt_dFQ2','fontsize',11,'fontweight','normal');
            text_dFQ2 = uicontrol('Parent',group4,'Style','text','Units','Normalized',...
                'Position',[0.01 0.7 0.23 0.1],...
                'String','dFq2','tag','txt_dFQ2','fontsize',11,'fontweight','normal');
            btn_dFQ2 = uicontrol('Parent',group4,'Style','pushbutton','Units','Normalized',...
                'Position',[0.72 0.7 0.27 0.1],'callback',@btn_zero_Q,...
                'String','0','tag','btn_dFQ2','fontsize',11,'fontweight','normal');
            cla(axs1);
            cla(axs2);
            hold on;
            F1 = obj.getData('Frequency',1,1);
            A1 = obj.getData('Angle',1);
            F2 = obj.getData('Frequency',1,2);
            ind = find(F1~=0);
            plot(A1(ind),F1(ind),'bo--','linewidth',1.5,'Parent',axs1);
            ind = find(F2~=0);
            hold(axs1,'on');
            plot(A1(ind),F2(ind),'b*--','linewidth',1.5,'Parent',axs1);            
        	set(axs1,'GridAlpha',1,'XGrid','on','YGrid','on'); 
        	PlotCurrentFft();
            set(axs2,'GridAlpha',1,'XGrid','on','YGrid','on');

            d = struct('Object',obj,'Diapason',[]);
            set(f,'UserData',d); 

        	% UI functions
        	%----------------------------------------------
            
            function SliderFunc(src,evt)
                num = round(get(sld,'Value'));
                v = getTchb();
                txt.String = [num2str(obj.data.(getF(obj,'T',v(1))).angles(num)),char(176)];
                txtN.String = [char(35),num2str(num)];
                cla(axs1);
                cla(axs2);
                
                PlotCurrentPar();
                PlotCurrentFft();

                edtF_P1.String = num2str(obj.getData('Frequency',v(1),1,num));
                edtF_P2.String = num2str(obj.getData('Frequency',v(1),2,num));
                
                edtA_P1.String = num2str(obj.getData('Amplitude',v(1),1,num));
                edtA_P2.String = num2str(obj.getData('Amplitude',v(1),2,num));
                
                edtQ_P1.String = num2str(obj.getData('QFactor',v(1),1,num));
                edtQ_P2.String = num2str(obj.getData('QFactor',v(1),2,num));
                
                YL1 = get(axs1,'YLim');
                n = obj.data.(getF(obj,'T',v(1))).angles(num);
                plot([n, n]',YL1','k--','linewidth',1.5,'Parent',axs1);
                set(axs1,'YLim',YL1);
            end
            
            function PopupList_Func(src,evt)
                PlotCurrentPar();
                PlotCurrentFft();
            end

            function ChbTemp_Func(src,evt)
                PlotCurrentPar();
                PlotCurrentFft();
            end

            function CheckGrid_Func(src,evt)
            	if chbGrid1.Value == 0 
		        	set(axs1,'XGrid','off','YGrid','off'); 
		        else
		        	set(axs1,'GridAlpha',1,'XGrid','on','YGrid','on'); 
                end
                if chbGrid2.Value == 0 
		        	set(axs2,'XGrid','off','YGrid','off'); 
		        else
		        	set(axs2,'GridAlpha',1,'XGrid','on','YGrid','on'); 
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
		        p = PlotCurrentPar();
            end

            function btn_Find(src,evt)
                v = getTchb();
                num = round(get(sld,'Value'));
                curT = obj.getF('T',v(1));
                name = obj.data.(curT).names{num};
                curA = obj.getF('A',num,v(1));
                temp = ResonatorAcousticData([obj.path,name],f.UserData.Diapason);
                [vi, ind_i] = max(temp.Frequency);
                
                if vi > max(obj.data.(curT).(curA).Frequency)
                    p_ind = 2;
                else
                    p_ind = 1;
                end
                obj.data.(curT).(curA).Frequency(p_ind) = temp.Frequency(ind_i);
                obj.data.(curT).(curA).Amplitude(p_ind) = temp.Amplitude(ind_i);
                obj.data.(curT).(curA).QFactor(p_ind) = temp.QFactor(ind_i);
                PlotCurrentFft();
                
                lbx = src.Parent.Parent.Parent.findobj('Tag','lst_file');
                nameObj = lbx.String{lbx.Value};
                assignin('base',nameObj,obj);
                
                % redraw vertical cursor on axes 1
                p = PlotCurrentPar();
                YL1 = get(axs1,'YLim');
                n = obj.data.(getF(obj,'T',v(1))).angles(num);
                plot([n, n]',YL1','k--','linewidth',1.5,'Parent',axs1);
                set(axs1,'YLim',YL1);
                
                % refresh data in edits
                if p_ind == 1
                    edtF_P1.String = temp.Frequency(ind_i);
                    edtA_P1.String = temp.Amplitude(ind_i);
                    edtQ_P1.String = temp.QFactor(ind_i);
                end
                if p_ind == 2
                    edtF_P2.String = temp.Frequency(ind_i);
                    edtA_P2.String = temp.Amplitude(ind_i);
                    edtQ_P2.String = temp.QFactor(ind_i);
                end
            end
            
            function btn_zero_Q(src,evt)
                v = getTchb();
                num = round(get(sld,'Value'));
                curT = obj.getF('T',v(1));
                curA = obj.getF('A',num,v(1));
                if strcmp(src.Tag,'btn_dFQ1')
                    obj.data.(curT).(curA).QFactor(1) = 0;
                end
                if strcmp(src.Tag,'btn_dFQ2')
                    obj.data.(curT).(curA).QFactor(2) = 0;
                end
                PlotCurrentFft();
                PlotCurrentPar();
            end

            function findPoint(gcbo, eventdata, handles)
                P = eventdata.IntersectionPoint(1);
                PlotCurrentFft();
                plot([P P],axs2.YLim,'-k','linewidth',1.5,'Parent',axs2);
                plot([P+0.2 P+0.2],axs2.YLim,'--k','linewidth',0.7,'Parent',axs2);
                plot([P-0.2 P-0.2],axs2.YLim,'--k','linewidth',0.7,'Parent',axs2);
                f.UserData.Diapason = [P-0.2 P+0.2];
            end
                     
            function btn_rew(src,evt)
                    
                    buf_1 = edtF_P1.String;
                    buf_2 = edtA_P1.String;
                    buf_3 = edtQ_P1.String;

                    edtF_P1.String = edtF_P2.String;
                    edtA_P1.String = edtA_P2.String;
                    edtQ_P1.String = edtQ_P2.String;

                    edtF_P2.String = buf_1;
                    edtA_P2.String = buf_2;
                    edtQ_P2.String = buf_3;
            end
            
            function btn_zero(src,evt)
                if strcmp(evt.Source.Tag,'btn_P01')
                    edtF_P1.String = '0';
                    edtA_P1.String = '0';
                    edtQ_P1.String = '0';
                end
                if strcmp(evt.Source.Tag,'btn_P02')
                    edtF_P2.String = '0';
                    edtA_P2.String = '0';
                    edtQ_P2.String = '0';
                end
            end
            

            function btn_set(src,evt)

                num = round(get(sld,'Value'));
                v = getTchb();
                lbx = src.Parent.Parent.Parent.findobj('Tag','lst_file');
                nameObj = lbx.String{lbx.Value};
                F_P1 = str2num(edtF_P1.String);
                F_P2 = str2num(edtF_P2.String);
                A_P1 = str2num(edtA_P1.String);
                A_P2 = str2num(edtA_P2.String);
                Q_P1 = str2num(edtQ_P1.String);
                Q_P2 = str2num(edtQ_P2.String);
                p = PlotCurrentPar();

                obj = obj.setData('Frequency',v(1),1,num,F_P1);
                obj = obj.setData('Frequency',v(1),2,num,F_P2);
                obj = obj.setData('Amplitude',v(1),1,num,A_P1);
                obj = obj.setData('Amplitude',v(1),2,num,A_P2);
                obj = obj.setData('QFactor',v(1),1,num,Q_P1);
                obj = obj.setData('QFactor',v(1),2,num,Q_P2);
                
                p = PlotCurrentPar();
                p = PlotCurrentFft();                
                
                YL1 = get(axs1,'YLim');
                n = obj.data.(getF(obj,'T',v(1))).angles(num);
                plot([n, n]',YL1','k--','linewidth',1.5,'Parent',axs1);
                set(axs1,'YLim',YL1);
                
                assignin('base',nameObj,obj);
            end
            
			% Plot functions             
            %----------------------------------------------
        	%----------------------------------------------
            function p = PlotCurrentPar()
            	cla(axs1);
                hold on;
            	p = [];
            	temper = [];
            	for i = 1:length(chbT)
            		temper(i) = chbT{i}.Value;
                end
                curColors = T_colors(find(temper));
            	temper = find(temper);
            	if isempty(temper)
            		return;
            	end
            	columns = [chbColumn1.Value, chbColumn2.Value];
            	columns = find(columns~=0);
                xlim_max = 0;
            	for i = 1:length(columns)
                    s = obj.getData(ppmGraph.String{ppmGraph.Value},temper,columns(i));
            		for j = 1:length(temper)
	            		ind = find(s(:,j)~=0);
            			if columns(i) == 1
		            		color_plot = ['--o',curColors(j)];
		            	elseif columns(i) == 2
		            		color_plot = ['--*',curColors(j)];
		            	end
		            	p = plot(obj.data.(obj.getF('T',temper(j))).angles(ind),...
                            s(ind,j),color_plot,'linewidth',1.5,'Parent',axs1);  
                        if (obj.data.(obj.getF('T',temper(j))).angles(end)) > xlim_max
                            xlim_max = (obj.data.(obj.getF('T',temper(j))).angles(end));
                        end
                    end

                end
                if xlim_max == 0; xlim_max = 1; end;
                set(axs1,'XLim',[0 xlim_max]);
                axs1.YLimMode = 'auto';
            end


            function p = PlotCurrentFft() 
                p = [];
                cla(axs2);

            	% get temperature checkboxes
                temper = getTchb();
                % get angle number
                numA = round(sld.Value);
                hold on;
                v = getTchb();
                if isempty(v)
                    return;
                end
                min_marg = obj.data.(getF(obj,'T',temper(1))).meanFq_1;
                max_marg = obj.data.(getF(obj,'T',temper(1))).meanFq_2;
                for i = 1:length(temper)
                    % try
                    curT = getF(obj,'T',temper(i));
                    curA = getF(obj,'A',numA,temper(i));
	                [xx, yy] = InterpFreq(obj, temper(i), numA);
	                h = plot(xx, yy,[T_colors(temper(i)),'.'],'Parent',axs2);
                    set(h,'ButtonDownFcn',@findPoint,'HitTest','on','PickableParts','all');
	                % find resonance 1 parameters
	                if obj.data.(curT).(curA).Frequency(1) ~= 0
	                	F1 = obj.data.(curT).(curA).Frequency(1);
	                	diap = [0 0]; % diapason for find res freq
	                	[v diap(1)] = min(abs(xx-(F1-0.02)));
	                	[v diap(2)] = min(abs(xx-(F1+0.02)));
                            if obj.data.(curT).(curA).QFactor(1) ~= 0
                                % find and show QFactor 1
                                [v indF11] = min(abs(xx-(F1)));
                                F11 = xx(indF11);
                                v_v = 0.707 * obj.data.(curT).(curA).Amplitude(1);
                                dmF = (obj.data.(curT).meanFq_2 - obj.data.(curT).meanFq_1)/2;
                                if dmF > 0.6; dmF = 0.6; end;
                                [v, min_m] = min(abs(xx-(F1-dmF)));
                                [v, max_m] = min(abs(xx-(F1+dmF)));
                                [v, ind_1] = min(abs(yy(min_m:indF11)-v_v));
                                [v, ind_2] = min(abs(yy(indF11:max_m)-v_v));
                                qm1 = min_m + ind_1 - 1;
                                qm2 = ind_2 + indF11 - 1;
                                plot([xx(qm1) xx(qm2)],[yy(qm1) yy(qm2)],T_colors(temper(i)));
                                dQf1 = yy(qm2) - yy(qm1);
                                set(edit_dFQ1,'String', sprintf('%2.3e',dQf1));
                            else
                                edit_dFQ1.String = '0';
                            end
                            
	                	[fr1 fr1_ind] = min(abs(yy(diap(1):diap(2))-F1));
 	                	fr1_ind = diap(1) + fr1_ind + 1;
	                	Q1 = obj.data.(curT).(curA).QFactor(1);
                        
                
	                	plot(xx(fr1_ind),yy(fr1_ind),[T_colors(temper(i)),'v'],'MarkerSize',10,'Parent',axs2);
                        
	                	text(xx(fr1_ind)+0.05,yy(fr1_ind)+yy(fr1_ind)*0.01,['F1 = ',num2str(F1)],...
                            'Color',T_colors(temper(i)));
	                	text(xx(fr1_ind)+0.15,yy(fr1_ind)*0.707,['Q1 = ',num2str(Q1)],...
                            'Color',T_colors(temper(i)));
                    else
                        edit_dFQ1.String = '0';
	                end

	                if obj.data.(curT).(curA).Frequency(2) ~= 0
	                	F2 = obj.data.(curT).(curA).Frequency(2);
	                	diap = [0 0]; % diapason for find res freq
	                	[v diap(1)] = min(abs(xx-(F2-0.02)));
	                	[v diap(2)] = min(abs(xx-(F2+0.02)));
                            if obj.data.(curT).(curA).QFactor(2) ~= 0
                                % find and plot QFactor 2
                                [v indF21] = min(abs(xx-(F2)));
                                F21 = xx(indF21);
                                v_v = 0.707 * obj.data.(curT).(curA).Amplitude(2);
                                dmF = (obj.data.(curT).meanFq_2 - obj.data.(curT).meanFq_1)/2;
                                if dmF > 0.6; dmF = 0.6; end;
                                [v, min_m] = min(abs(xx-(F2-dmF)));
                                [v, max_m] = min(abs(xx-(F2+dmF)));
                                [v, ind_1] = min(abs(yy(min_m:indF21)-v_v));
                                [v, ind_2] = min(abs(yy(indF21:max_m)-v_v));
                                qm1 = min_m + ind_1 - 1;
                                qm2 = ind_2 + indF21 - 1;
                                plot([xx(qm1) xx(qm2)],[yy(qm1) yy(qm2)],T_colors(temper(i)));
                                dQf2 = yy(qm2) - yy(qm1);
                                set(edit_dFQ2,'String', sprintf('%2.3e',dQf2));
                            else
                                edit_dFQ2.String = '0';
                            end
	                	[fr2 fr2_ind] = min(abs(yy(diap(1):diap(2))-F2));
	                	fr2_ind = diap(1) + fr2_ind + 1;
	                	Q2 = obj.data.(curT).(curA).QFactor(2);

	                	plot(xx(fr2_ind),yy(fr2_ind),[T_colors(temper(i)),'v'],'MarkerSize',10,'Parent',axs2);
	                	text(xx(fr2_ind)+0.05,yy(fr2_ind)+yy(fr2_ind)*0.01,['F2 = ',num2str(F2)],...
                            'Color',T_colors(temper(i)),'Parent',axs2);
	                	text(xx(fr2_ind)+0.15,yy(fr2_ind)*0.707,['Q2 = ',num2str(Q2)],...
                            'Color',T_colors(temper(i)),'Parent',axs2);
                    else
                        edit_dFQ2.String = '0';
                    end
                    if obj.data.(curT).meanFq_1 < min_marg
                        min_marg = obj.data.(curT).meanFq_1;
                    end
                    if obj.data.(curT).meanFq_2 > min_marg
                        max_marg = obj.data.(curT).meanFq_2;
                    end
                    axs2.XLim = [min_marg-3 max_marg+3];
                    % end% try
                end
                axs2.YLimMode = 'auto';
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

            function btn_PlotFFt_all(src,evt)
                % initialise
                v = getTchb();
                curT = obj.getF('T',v(1));
                Angles = obj.getData('Angle',v(1));
                % plot
                fft_plot_all = figure;
                hold on; 
                meanFq_1 = obj.data.(curT).meanFq_1;
                meanFq_2 = obj.data.(curT).meanFq_2;
                for i = 1:length(Angles)
                    curA = obj.getF('A',i,v(1));
                    [xx, yy] = obj.InterpFreq(v(1),i);
                    [vv, d1] = min(abs(xx-(meanFq_1-1)));
        		    [vv, d2] = min(abs(xx-(meanFq_2+1)));
                    plot(xx(d1:d2),yy(d1:d2));
                    ind_F = find(obj.data.(curT).(curA).Frequency);
                    for j = 1:length(ind_F)
                        plot(obj.data.(curT).(curA).Frequency(ind_F(j)),...
                            obj.data.(curT).(curA).Amplitude(ind_F(j)),...
                            'o','MarkerSize',6,'linewidth',3);
                    end
                end
                grid;
                YL = get(gca,'YLim');
                plot([meanFq_1 meanFq_1],YL,'k--','linewidth',2);
                plot([meanFq_2 meanFq_2],YL,'k--','linewidth',2);
                set(gca,'GridAlpha',1,'XGrid','on','YGrid','on');
                title(curT);
                ylabel('Amplitude');
                xlabel('Frequency');
            end

            function btn_Plot_yy(src,evt)
                figure;
                v = getTchb(); 
                curT = obj.getF('T',v(1));
                Angles = obj.getData('Angle',v(1));
                name = ppmGraph.String{ppmGraph.Value};
                D1 = obj.getData(name,v(1),1);
                D2 = obj.getData(name,v(1),2);
                ind_1 = find(D1~=0);
                ind_2 = find(D2~=0);
                [yy_axes,L1,L2] = plotyy(Angles(ind_1),D1(ind_1),Angles(ind_2),D2(ind_2));
                title(name);
                set(L1,'Marker','o','linewidth',2)
                set(L2,'Marker','*','linewidth',2)
                set(yy_axes(1),'GridAlpha',1,'XGrid','on','YGrid','on');
                set(yy_axes(2),'GridAlpha',1,'XGrid','on','YGrid','on');
                xlabel('degree');
                ylabel(yy_axes(1),[name,' 1']);
                ylabel(yy_axes(2),[name,' 2']);
            end
            
            function btn_sine_fint(src,evt)

                v = getTchb(); 
                curT = obj.getF('T',v(1));
                Angles = obj.getData('Angle',v(1));
                name = ppmGraph.String{ppmGraph.Value};
                
                if strcmp(src.Tag,'btnSineFit1')
                    IND = 1;
                else
                    IND = 2;
                end
                
                Data = obj.getData(name,v(1),IND);
                ind = find(Data~=0);
                angle = Angles(ind)';
                Data = Data(ind);
                SineP = sineFit(angle,Data);
                
                figure;
                hold on;
                set(gca,'XGrid','on','YGrid','on','GridAlpha',1);
                
                plot(angle,Data,'bo:');
                xx = 0:1:angle(end);
                yy = SineP(1)+SineP(2)*sin(2*pi*SineP(3)*xx+SineP(4));
                plot(xx,yy,'r.','linewidth',2);

            end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            function SineParams=sineFit(x,y)
            %Purpose: Estimation of noisy sine curve parameters by FFT and non linear fitting.
            %
            % Syntax:
            %       [SineParams]=sineFit(x,y)
            %       Input: x and y values, y=offs+amp+sin(2*pi*f*x+phi)+noise
            %       Output: SineParams(1): offset (offs)
            %               SineParams(2): amplitude (amp)
            %               SineParams(3): frequency (f)
            %               SineParams(4): phaseshift (phi)
            %       yOut=offs+amp*sin(2*pi*f*x+phi)
            %
            % Example:
            % % generate y(x)
            % x=-4:5;
            % y=1+2*(sin(2*pi*0.1*x+2)+0.3*randn(size(x)));%Sine + noise
            % [SineP]=sineFit(x,y)
            % figure;
            % xx=x(1):(x(end)-x(1))/222:x(end);%better resolution
            % plot(x,y,xx,SineP(1)+SineP(2)*sin(2*pi*SineP(3)*xx+SineP(4)));
            % %uncomment following lines if you want to save y=f(x) and run it sineFitDemo
            % %paramsClean=[1,2,0.1,2];
            % % save('xy.mat','x','y','paramsClean');
            %
            %You may want to comment/uncomment the last statement (PlotResults) in the first function.
            %Author: Peter Seibold
            % FFT
            pi2=2*pi;
            NumSamples=length(x);
            T=x(2)-x(1);
            fNy=1/(2*T);%Nyquist frequency
            offs=mean(y);%DC value
            y_m=y-offs;%FFT much better without offset
            n = 128*2^nextpow2(NumSamples);%heavy zero padding
            Y = fft(y_m,n);%Y(f)
            n2=floor(n/2);
            P2 = abs(Y/NumSamples);
            P1 = P2(1:n2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            fs = (0:n2)/n/T;% frequency scale
            % %FFT parameters at peak
            [maxFFT,maxFFTindx]=max(P1);%Peak magnitude and location
            fPeak=fs(maxFFTindx);% f at peak
            Phip=angle(Y(maxFFTindx))+pi/2;%Phi-Peak is for cos, sin(90°+alpha)=cos(betta), alpha=-betta
            Phip=Phip-x(1)*fPeak*pi2;%shift for phi at x=0
            %Better estimate for offset:
            omega=pi2*fPeak;
            offs=offs-maxFFT*(cos(omega*x(1)+Phip)-cos(omega*x(end)+Phip))/(omega*(x(end)-x(1)));
            % Fitting
            paramsFFTp=[offs,maxFFT,fPeak,Phip];
            if maxFFTindx<0.99*n2
              %FFT peak not at f-Nyquist
              NumPeaks=1;
              paramsFFT=paramsFFTp;
            else
              %Samples per period close to 2, max FFT peak close to f-Nyquist
              %Set 1st evaluation point a little below f-Nyquist
              fIndxExtra1=round(maxFFTindx*.995);
              fExtra1=fs(fIndxExtra1);
              PhiExtra1=angle(Y(fIndxExtra1))+pi/2-x(1)*fExtra1*pi2;
              %extra f for evaluation left of max peak 
              fIndxExtra2=round(0.75*maxFFTindx);
              fExtra2=fs(fIndxExtra2);
              PhiExtra2=angle(Y(fIndxExtra2))+pi/2-x(1)*fExtra2*pi2;
              paramsFFT=[[offs,maxFFT,fPeak*.995,PhiExtra1];...
                [offs,0.8*maxFFT,fExtra2,PhiExtra2]]; 
              NumPeaks=2;
            end
            paramsOut=zeros(NumPeaks,6);%for regression outputs
            % find best fit in time domain
            modelfun = @(paramc,x) paramc(1) + paramc(2) * sin(pi2*paramc(3)*x+paramc(4));
            opts = statset('nlinfit');opts.MaxIter=1000;%620 is the limit in evaluated test set.
            warning('off','all');%disable warnings from nlinfit
            for i=1:NumPeaks
              [SineParams,~,~,~,MSE] = nlinfit(x,y,modelfun,paramsFFT(i,:),opts);
              %make frequency positive
              if SineParams(3)<0
                SineParams(3)=-SineParams(3);
                SineParams(4)=pi-SineParams(4);%sin(2*pi*-f-phi)=sin(2*pi*f+phi+pi)
              end
              %make amplitude positive
              if SineParams(2)<0
                SineParams(2)=-SineParams(2);
                SineParams(4)=SineParams(4)+pi;
              end
              paramsOut(i,:)=[SineParams,MSE,MSE];
              if NumSamples<5% && SineParams(3)<=fNy
                %No valid MSE from nlinfit if num samples <5
                %Overwrite MSE, set priority to 1st result (by *i)
                %will be overwritten again with max allowed amplitude
                paramsOut(i,5)=0.003*i;
              end
              if SineParams(3)>fNy
                %f larger than nyquist limit
                paramsOut(i,5)=Inf;%set MSE to terrible
              end
            end
            warning('on','all');
            % take best manipulated score
            [MSEmin,MSEminIndx]=min(paramsOut(:,5));
            SineParams=paramsOut(MSEminIndx,1:4);
            %  Determine max allowed amplitude by MSEmin
            if MSEmin<=0.00001 || ...%extremly good MSE
                NumSamples<5 || ... %no MSE with nlinfit for less than 5 samples
                (NumSamples==5 && SineParams(3)<0.8*paramsFFT(1,3)) ||... %num period propably <1
                (MSEmin<1 && x(end)-x(1)<0.5/SineParams(3))%propably less than 0.5 periods
              maxAmp=66*maxFFT;%max allowed amplitude
            elseif MSEmin>0.3
              maxAmp=4*maxFFT;
            elseif MSEmin>0.01
              maxAmp=6*maxFFT;
            elseif MSEmin>0.001
              maxAmp=18*maxFFT;
            else
              %very good MSE, 0.00001 < MSE <0.001
              maxAmp=33*maxFFT;
            end
            % maxAmp=0;%TEST! Force FFT output
            if SineParams(2)>maxAmp || SineParams(3)>fNy
              %Best regression has too big amplitude or is over Nyquist limit,
              %take original FFT result
              SineParams=paramsFFTp;
              MSE=NaN;%for PlotResults
            else
              MSE=paramsOut(MSEminIndx,6);%for PlotResults
            end
            %make phase between 0 and 2 pi
            SineParams(4)=rem(SineParams(4),pi2);
            if SineParams(4)<0
              SineParams(4)=SineParams(4)+pi2;
            end
        end
        
        %Plot, uncomment following line or delete all following lines:
        % PlotResults(x,y,SineParams,paramsFFT,fs,P1,maxFFTindx,maxFFT,MSE);
        % Plot results (optional, uncomment statement above)
        function PlotResults(x,y,SineParams,paramsFFT,fs,P1,maxFFTindx,maxFFT,MSE)
        xstart=x(1);
        xend=x(end);
        x3b=(1:numel(x));
        x3=(xend-xstart)/(numel(x)-1)*(x3b-1)+xstart;
        x4b=1:0.01:numel(x);
        x4=(xend-xstart)/(numel(x)-1)*(x4b-1)+xstart;
        y5=SineParams(1)+SineParams(2)*sin(2*pi*SineParams(3)*x4+SineParams(4));%result
        yFFT=paramsFFT(1,1)+paramsFFT(1,2)*sin(2*pi*paramsFFT(1,3)*x4+paramsFFT(1,4));
        figure;%for time
        plot(x3,y,'k.');%time series as dots
        xlabel('Time [s]');
        hold on;
        pIn=plot(x3,y,'r-');%time series as line
        pFFT=plot(x4,yFFT,'color',[0.9 0.9 0.9]);
        pResult=plot(x4,y5,'b-');%result
        legend([pIn,pResult,pFFT],'Input','Result', 'FFT peak');
        hold off;
        grid on;
        figure;%for FFT
        % title('FFT');
        pFFTin=plot(fs,P1,'r-');
        xlabel('Frequency [Hz]');
        ylabel('Amplitude')
        hold on;
        pFFTmax=plot(fs(maxFFTindx),maxFFT,'r+','MarkerSize',12);%max FFT
        pFFTresult=plot(SineParams(3),SineParams(2),'b+','LineWidth',2);
        plot([SineParams(3),SineParams(3)],[0,max(max(P1)*1.01,SineParams(2))],'b-');
        hLeg=legend([pFFTin,pFFTresult,pFFTmax],'Input',...
          ['Result:     ' num2str(SineParams(2),3) ', ' num2str(SineParams(3),3) ' Hz'],...
          ['max FFT:  ' num2str(maxFFT,3) ', ' num2str(fs(maxFFTindx),3) ' Hz'],...
          'Location','best');
        title(hLeg,'        amplitude | frequency','FontSize',8);
        hold off;
        grid on;
        disp(['Result:        y= ' num2str(SineParams(1)) ' + ' num2str(SineParams(2)) ...
          ' * sin(2*pi*' num2str(SineParams(3)) '+' num2str(SineParams(4)) ')   MSE: ' num2str(MSE)]);
        disp(['FFT:           y= ' num2str(paramsFFT(1,1)) ' + ' num2str(paramsFFT(1,2)) ...
          ' * sin(2*pi*' num2str(paramsFFT(1,3)) '+' num2str(paramsFFT(1,4)) ')' ]);

        end   
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            

        end   % End PlotByList
        %-------------------------------------------------------

        
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


        function getProtocol(obj)
        	
			fid = fopen('Protocol.txt','w');

			fprintf(fid,'\t\t\t Protocol N \n');
			fprintf(fid,'\t\t\t Results of acoustic testing\n');

			ln_str = '--------------------------------------------------------------';

			fprintf(fid,'%s\n\n\n',ln_str);
			fprintf(fid,'Data directory: %s\n',obj.path);
			name = scan_data_name(obj,obj.path,'date');
			fprintf(fid,'Testing date: %d  %d  %d \n',name(1),name(2),name(3));
			a = clock;
			date_str = [num2str(a(3)),'_',num2str(a(2)),'_',num2str(a(1))];
			fprintf(fid,'Protocol date: %s\n',date_str);
			time_str = [num2str(a(4)),'h_',num2str(a(5)),'m'];
			fprintf(fid,'Protocol time: %s\n',time_str);
			fprintf(fid,'%s\n',ln_str);
			fprintf(fid,'Testing temperatures,testing angles: \n');
			for i = 1:length(obj.T)
                try
				fprintf(fid,'t+%d C, angles: %2.2f : %2.2f : %2.2f \n',obj.T(i),...
                    obj.data.(obj.getF('T',i)).angles(1),...
                    abs(obj.data.(obj.getF('T',i)).angles(2)-obj.data.(obj.getF('T',i)).angles(1)),...
                    obj.data.(obj.getF('T',i)).angles(end));
                end
            end
            

            fprintf(fid,'\n%s\n',ln_str);
            fprintf(fid,'\t\t\t\t   Minimum values \n');
            fprintf(fid,'\t [Fq1]     [Fq2]      [Am1]      [Am2]      [Q1]    [Q2]\n');
            for i = 1:length(obj.T)
                fprintf(fid,'t+%d\t%7.2f\t%7.2f\t%7.5f\t%7.5f\t%6.0f %6.0f \n',...
                    obj.T(i), getStat(obj,'min','Frequency',i,1),...
                    getStat(obj,'min','Frequency',i,2),...
                    getStat(obj,'min','Amplitude',i,1),...
                    getStat(obj,'min','Amplitude',i,2),...
                    getStat(obj,'min','QFactor',i,1),...
                    getStat(obj,'min','QFactor',i,2)...
                    );
            end    


			fprintf(fid,'\n%s\n',ln_str);
            fprintf(fid,'\t\t\t\t   Mean values \n');
			fprintf(fid,'\t [Fq1]     [Fq2]      [dFq]      [Am2]      [Q1]    [Q2]\n');
			for i = 1:length(obj.T)
				fprintf(fid,'t+%d\t%7.2f\t%7.2f\t%7.5f\t%7.5f\t%6.0f %6.0f \n',...
					obj.T(i), getStat(obj,'mean','Frequency',i,1),...
					getStat(obj,'mean','Frequency',i,2),...
					abs(getStat(obj,'mean','Frequency',i,2)-getStat(obj,'mean','Frequency',i,1)),...
					getStat(obj,'mean','Amplitude',i,2),...
					getStat(obj,'mean','QFactor',i,1),...
					getStat(obj,'mean','QFactor',i,2)...
					);
            end

            
            fprintf(fid,'\n%s\n',ln_str);
            fprintf(fid,'\t\t\t\t   Maximum values \n');
            fprintf(fid,'\t [Fq1]     [Fq2]      [Am1]      [Am2]      [Q1]    [Q2]\n');
            for i = 1:length(obj.T)
                fprintf(fid,'t+%d\t%7.2f\t%7.2f\t%7.5f\t%7.5f\t%6.0f %6.0f \n',...
                    obj.T(i), getStat(obj,'max','Frequency',i,1),...
                    getStat(obj,'max','Frequency',i,2),...
                    getStat(obj,'max','Amplitude',i,1),...
                    getStat(obj,'max','Amplitude',i,2),...
                    getStat(obj,'max','QFactor',i,1),...
                    getStat(obj,'max','QFactor',i,2)...
                    );
            end           
            
            fprintf(fid,'\n%s\n',ln_str);

            fprintf(fid,'\t\t\t   Termal frequency coefficient \n');
            

            [TK4a1, TK41]= obj.Get_TKF(1);
            [TK4a2, TK42]= obj.Get_TKF(2);
            fprintf(fid,'%s\n',ln_str);
            fprintf(fid,'\t by first Fq \t\t\tby second Fq\n');
            fprintf(fid,'%s\n',ln_str);
            fprintf(fid,'k_aprox \t k_diff \t\t k_aprox \t k_diff \n');
            fprintf(fid,'%5.5f \t %5.5f \t\t\t %5.5f \t %5.5f \n',TK4a1,TK41,TK4a2,TK42);
 			fprintf(fid,'%s\n',ln_str);



			fclose(fid);
			dos(['start wordpad "', 'Protocol.txt', '"']);
            
        end

        function [name, date] = scan_data_name(obj,path,arg)
            % get path to data files and return name for the protocol by default
            % with second argument can return such variables:
            % arg "protocol" - return name for protocol by default
            % arg "date" - return data got from path
            % arg "variable" - return name for variable

            if nargin < 3
                arg = 'protocol';
            end

            % find directory name in path
            % ---------------------------
            try
                path_arr = split(path,'\');
            catch
                path_arr = strsplit(path,'\');
            end
            expr = '\d+_\d+_\d+_.+';
            name = '';
            for i = 1:length(path_arr)
                matchStr = regexp(path_arr{i},expr,'match');
                if ~isempty(matchStr)
                    name = matchStr; name = name{1};
                    break;
                else
                    name = 'undefined';
                end
            end
            if strcmp(name,'undefined')
                return;
            end
            % ---------------------------

            % creating name by arg
            if strcmp(arg,'protocol')
            	name = [name,'.txt'];
            elseif strcmp(arg,'date')
                str_ind = findstr('_',name);
                if length(str_ind) >= 3
                    date(1) = str2num(name(1:str_ind(1)-1));
                    date(2) = str2num(name(str_ind(1)+1:str_ind(2)-1));
                    date(3) = str2num(name(str_ind(2)+1:str_ind(3)-1));
                    name = date;
                end
            elseif strcmp(arg,'variable')
	            name = strrep(name,'-','_');
                name = ['v',name];
            end
        end

  
        
        

        
%         function [ft,rmse] = sinefit(t,y) 
%             f = @(A,t) A(1)*sin((y + A(2))*2*pi) + A(3); 
%             % Solve the equation
%             % Set some options for fminsearch:        
%             opts = optimset('Display','off');
%             % Define a sum-of-squares function that figures out the mismatch between data and the fit: 
%             fcn = @(A) sum((f(A,t) - y).^2); 
%             ft = fminsearch(fcn,[rms(y)*2/sqrt(2) -0.5 mean(y)],opts); 
% 
%             % Package up the outputs
%             % Standardize amplitude and phase terms: 
%             if ft(1)<0 
%                ft(1) = -ft(1);  % ensures a positive amplitude
%                ft(2) = ft(2)+.5;% but also means we'll have to change the phase by half a cycle. 
%             end
%             % Convert the phase term (decimal years) into something meaningful (day of year corresponding to max of sine wave):
%             ft(2) = 365.24*(mod(0.25 - ft(2),1)); 
%             % Estimate errors: 
%             if nargout==2
%                rmse = rms(y - sineval(ft,t)); 
%             end
%         end







	end % methods 

end





