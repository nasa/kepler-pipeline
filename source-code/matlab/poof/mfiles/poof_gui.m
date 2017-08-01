function poof_gui()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function poof_gui()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% poof_gui launches a window for visualizing tad with FFI fits file or LC
% fits files, or coa images.
%
% Image 1 gets plotted using the hot colormap, image 2 gets plotted in green
% If the Image at work is a COA image, figure backgound color will turn
% orange.
%
% If edit button for *.mat File is filled, tadStruct from the mat file
% is used, i.e., the edit fields take precedence over the drop down menu.
%
% If edit button for the *.fits file or LC directory is not empty, UI menu
% for finding/selecting the file will not activate.
%
% When there are no entries for the *.mat menu, user is expected to select 
% the appropriate module output and target list. %'Retrieve Tad' button looks 
% for the existence preloaded tadStructs before querying the database.
%
% 'Load FFI Image' button and 'Select LC Folder button' are activated once
% a tad has been retrieved. After tadStructs are retrieved or loaded, 
% another figure with radio buttonsis launched to allow labels and optimal
% apertures to be added over the image.
%
% 'Preload Tads' button fetches all tads from 84 modouts for 
% the seleced target list and saves them in mat format in the current 
% directory for faster access.
%
% for LC fits files, a directory containing 4 files are expected:
%       (1) the target long cadence file,
%       (2) mapping of the target file (pmrf), 
%       (3) background pixel file, and
%       (4) mapping of the background pixel file
%
% LC image is constructed into an FFI using the the background and target
% files but not the collateral files as spatial information in these have
% been lost when summed on-board.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  INPUT:
%
%           none, this is a GUI
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:
%
%           the POOF GUI
%           
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

% import FC Constants and not hard code
import gov.nasa.kepler.common.FcConstants;

% initialize components

% figure component
fh = figure( 'units', 'pixels','position', [ 100   100  950 650], 'tag', ...
    'poofGui', 'numbertitle', 'off', 'name', 'Poof GUI', 'visible', 'off');
set(fh,'Interruptible','on','WindowButtonMotionFcn', @move_mouse_callback)

% get tartget lists, if possible

try
    targetListInfoStruct = retrieve_target_list_sets_active;
    targetListLength = length(targetListInfoStruct);
    targetListName = cell(targetListLength, 1);
    for i = 1:targetListLength
        targetListName{i} = targetListInfoStruct(i).name;
    end

catch
    % no targetList Name
    targetListName{1} = 'No target list retrieved';
end

%initialize appdata data
setappdata(fh, 'module', 2)
setappdata(fh, 'output', 1)
setappdata(fh, 'targetList',targetListName{1})
setappdata(fh, 'ccdImage', [])
setappdata(fh, 'coaImage', [])
setappdata(fh, 'longCadenceImage', [])
setappdata(fh, 'dirLcFiles', '')
setappdata(fh, 'maskImage',[])
setappdata(fh, 'bkgPixImage', [])
setappdata(fh, 'keplerIdImage', [])
setappdata(fh, 'ffiName', '')

% make the toolbar available for zooming
set(fh,'Toolbar','figure')

% axes component
ax = axes('units', 'pixels', 'position', [ 70 50 566 565],'parent', fh);
xlabel('Column','fontsize', 12, 'fontweight', 'bold')
ylabel('Row', 'fontsize', 12, 'fontweight', 'bold')
set(ax, 'xlim', [0, FcConstants.CCD_COLUMNS-1], 'ylim',...
    [0 FcConstants.CCD_ROWS-1],'ydir', 'normal')
box on

% add frames to the 3 sections
uipanel('units', 'pixels', 'position', [ 650 360 290 255], 'parent', fh);
uipanel('units', 'pixels', 'position', [ 650 255 290 100], 'parent', fh);
uipanel('units', 'pixels', 'position', [ 650 90 290 160], 'parent', fh);
uipanel('units', 'pixels', 'position', [ 650 20 290 65], 'parent', fh);

% module components
uicontrol(fh,'style', 'text', 'string', 'Module','units', 'pixels', ...
    'position', [ 720 570 50 20], 'horizontalAlignment', 'left' );
nModules = length(FcConstants.modulesList);
menustring_module = cell( nModules, 1);
for n = 1:nModules
menustring_module{n,1} = num2str(FcConstants.modulesList(n));
end
module_h = uicontrol(fh,'style', 'popupmenu', ...
    'string', menustring_module, 'units', 'pixels','position', ...
    [780 575 50 20], 'value', 1, 'callback', @selectModule_callback); %#ok<NASGU>

% output components
uicontrol(fh,'style', 'text', 'string', 'Output', 'units', 'pixels', ...
    'position', [ 720 520 50 20], 'horizontalAlignment', 'left');
nOutputs = length(FcConstants.outputsList);
menustring_output = cell( nOutputs, 1);
for n = 1:length(FcConstants.outputsList)
menustring_output{n,1} = num2str(FcConstants.outputsList(n));
end
output_h = uicontrol(fh, 'style', 'popupmenu', 'string', ...
    menustring_output, 'units', 'pixels', 'position', [780 525 75 20], ...
    'value', 1, 'callback', @selectOutput_callback); %#ok<NASGU>

% target list component
uicontrol(fh,'style', 'text', 'string', 'Target List', 'units', 'pixels', ...
    'position', [660 470 100 20], 'horizontalAlignment', 'left');
menutring_targetList = targetListName;
targetList_h = uicontrol(fh,'style', 'popupmenu', ...
    'string', menutring_targetList, 'units', 'pixels','position', ...
    [730 475 200 20], 'value', 1, 'callback', @selectTargetList_callback); %#ok<NASGU>

% edit box for tadStruct in mat format filecomponent 
uicontrol(fh,'style', 'text', 'string', 'OR *.mat file:', 'units', 'pixels', ...
    'position', [660 440 100 20], 'horizontalAlignment', 'left');
matTadStruct_h = uicontrol(fh, 'style', 'edit', 'units', 'pixels', 'string', '', ...
    'position', [660 420 270 20], 'backgroundcolor', 'w');

% retrieve tad component
retrieveTad_h = uicontrol(fh,'style', 'pushbutton', 'string', ...
    'Retrieve Tad', 'units', 'pixels','position', [690 370 100 40], ...
    'horizontalAlignment', 'center','callback', @retrieveTad_callback); %#ok<NASGU>

% prefetch tad compoenet
loadAllTadsFromTargetList_h = uicontrol(fh,'style', 'pushbutton', 'string', ...
    'Preload Tads', 'units', 'pixels','position', [800 370 100 40], ...
    'horizontalAlignment', 'center','callback', @loadAllTadsFromTargetList_callback); %#ok<NASGU>

% edit box for fits file or LC directory component
uicontrol(fh,'style', 'text', 'string', '*.fits file or LC directory:', 'units', 'pixels', ...
    'position', [660 325 200 20], 'horizontalAlignment', 'left');
fitsOrLCDir_h = uicontrol(fh, 'style', 'edit', 'units', 'pixels', 'string', '', ...
    'position', [660 305 270 20], 'backgroundcolor', 'w');

% load FFI file component
selectFFI_h = uicontrol(fh,'style', 'pushbutton', 'string',...
    'Load FFI Image', 'units', 'pixels','position', [690 260 100 40], ...
    'horizontalAlignment', 'center', ...
    'callback',@selectFitsFile_callback, 'enable', 'off');        

% load LC file component
selectLC_h = uicontrol(fh,'style', 'pushbutton', 'string', ...
    'Select LC Folder', 'units', 'pixels', 'position', [800 260 100 40], ...
    'horizontalAlignment', 'center', ...
    'callback', @selectLc_callback, 'enable', 'off');

% image1 component
uicontrol(fh,'style', 'text', 'string', 'Image 1', 'units', 'pixels',...
    'position', [720 210 75, 20], 'horizontalAlignment', 'left');
menustring_image1 = {'COA Image';'Target Masks';'CCD Image';'LC Image'};
image1_h = uicontrol(fh,'style', 'popupmenu', ...
    'string', menustring_image1(1:2), 'units', 'pixels', ...
    'position',[780 215 100 20],'value', 1, ...
    'callback', @selectImage1_callback);

% image2 component
uicontrol(fh,'style', 'text', 'units', 'pixels',...
    'position', [720 160 75 20],  'string', 'Image 2',...
    'horizontalAlignment', 'left');
menustring_image2 = {'Target Masks';'Background Pixels'};
image2_h = uicontrol(fh,'style', 'popupmenu', 'units','pixels', ...
    'position', [780 165 100 20],'string', menustring_image2, ...
    'value', 1, 'callback', @selectImage2_callback );

% overlay component
overlay_h = uicontrol(fh, 'style', 'pushbutton', ...
    'string', 'Overlay Images', 'units', 'pixels',...
    'position', [720 110 150 40], 'horizontalAlignment', 'center',...
    'callback', @overlay_callback, 'enable', 'off');

%fill in default appdata for selectionImage
setappdata(fh, 'selectionImage1', menustring_image1(1))
setappdata(fh, 'selectionImage2', menustring_image2(1))

% pixel info component row, 0 based
row_h = uicontrol(fh,'style', 'text', 'string', 'Row',...
    'position', [ 710 55 50 20] ); %#ok<NASGU>
row_dynamic_h = uicontrol(fh,'style', 'text', 'string','',...
    'position', [ 750 55 50 20] , 'backgroundcolor', 'w');

% pixel info compoenent col, 0 based
col_h = uicontrol(fh,'style', 'text', 'string', 'Col',...
    'position', [ 800 55 50 20] ); %#ok<NASGU>
col_dynamic_h = uicontrol(fh,'style', 'text', 'string','',...
    'position', [ 840 55 50 20], 'backgroundcolor', 'w');

% Kepler ID, 0 based
keplerId_h = uicontrol(fh,'style', 'text', 'string', 'Kepler ID',...
    'position', [ 680 25 70 20] ); %#ok<NASGU>
keplerId_dynamic_h =uicontrol(fh,'style', 'text', 'string', '',...
    'position', [ 750 25 100 20], 'backgroundcolor', 'w');

% Glaring text indicating what the selection of Image 1 is
image1_text_h = uicontrol(fh, 'style', 'text', 'position', [ 300 620 150 20],...
    'fontsize', 15, 'fontweight', 'bold', 'horizontalAlignment', 'left',...
    'foregroundcolor', 'm', 'backgroundcolor', [0.8 0.8 0.8]);

% normalize all components so that resizing figure still looks good
list = allchild(fh);
foundlist = findall(list, 'units', 'pixels');
for n = 1:length(foundlist)
    set(foundlist(n), 'units', 'normalized')
end

% make visible now that all components have been initialized
set(fh, 'visible', 'on')



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% CALLBACK FUNCTIONS SECTION

    function module = selectModule_callback(module_h, evd) %#ok<INUSD>

        oldModule = getappdata(fh, 'module'); % gets the prev module number
        val = get(module_h, 'value');
        string = get(module_h, 'string');
        module = str2double(string{val});

        if oldModule ~= module
            cla % erase image since module has changed
            set(overlay_h, 'enable', 'off') % disable, new tad needed
            setappdata(fh, 'ccdImage', []) % clear ccdImage
            setappdata(fh, 'longCadenceImage', []) % clear longCadenceImage
            found_h =findobj('type', 'figure', '-and', 'tag', 'labelsFigure');
            if ~isempty(found_h)
                delete(found_h)
            end
        end

        setappdata(fh, 'module', module)

        if ~isempty(getappdata(fh, 'ffiName'))
            output = getappdata(fh, 'output');
            ffiName = getappdata(fh, 'ffiName');
            ccdImage = create_ccdImage(ffiName, module, output);
            setappdata(fh, 'ccdImage', ccdImage)
        end

        if ~isempty(getappdata(fh, 'dirLcFiles'))
            output = getappdata(fh, 'output');
            dirLcFiles = getappdata(fh, 'dirLcFiles');
            longCadenceImage = create_longCadence_image(dirLcFiles, module, output);
            setappdata(fh, 'longCadenceImage', longCadenceImage)
        end

    end



    function output = selectOutput_callback(output_h, evd) %#ok<INUSD>

        oldOutput =  getappdata(fh, 'output');
        val = get(output_h, 'value');
        string = get(output_h, 'string');
        output = str2double(string{val});

        if oldOutput ~= output
            cla % erase image since output has changed
            set(overlay_h, 'enable', 'off') % disable, new tad needed
            setappdata(fh, 'ccdImage', [])% clear ccdImage
            setappdata(fh, 'longCadenceImage', []) % clear longCadenceImage
        found_h =findobj('type', 'figure', '-and', 'tag', 'labelsFigure');
        if ~isempty(found_h)
            delete(found_h)
        end
        end

        setappdata(fh, 'output', output)

        if ~isempty(getappdata(fh, 'ffiName'))
            module = getappdata(fh, 'module');
            ffiName = getappdata(fh, 'ffiName');
            ccdImage = create_ccdImage(ffiName, module, output);
            setappdata(fh, 'ccdImage', ccdImage)
        end


        if ~isempty(getappdata(fh, 'dirLcFiles'))
            module = getappdata(fh, 'module');
            dirLcFiles = getappdata(fh, 'dirLcFiles');
            longCadenceImage = create_longCadence_image(dirLcFiles, module, output);
            setappdata(fh, 'longCadenceImage', longCadenceImage)
        end

    end
        


    function targetList = selectTargetList_callback(targetList_h, evd) %#ok<INUSD>

        oldTargetList = getappdata(fh, 'targetList');
        val = get(targetList_h, 'value');
        string = get(targetList_h, 'string');
        targetList = string{val};

        if ~strcmpi(oldTargetList, targetList)
            cla
            set(overlay_h, 'enable', 'off') % disable, new tad needed
            set(selectFFI_h, 'enable', 'off')% disable, new tad needed
        end

        setappdata(fh, 'targetList', targetList)

    end



    function retrieveTad_callback(retrieveTad_h, evd) %#ok<INUSD>

        cla % clear axes everytime this button is punched
        found_h =findobj('type', 'figure', '-and', 'tag', 'labelsFigure');
        if ~isempty(found_h)
            delete(found_h)
        end

        % if edit button is not empty, user wants a tadStruct in mat file
        matTadStructString = get(matTadStruct_h,'string');

        if isempty(matTadStructString)

            if strcmp(targetListName{1},'No target list retrieved')
                errordlg('No tad structs available', 'Bad Input','modal')
                disp('No tad structs available')
                return

            end

            fprintf('\n\nretrieving tad...please wait...\n\n')
            module = getappdata(fh,'module');
            output = getappdata(fh, 'output');
            targetList = getappdata(fh, 'targetList');
            tadStructFileName = [targetList,'Mod',int2str(module),'Out',int2str(output),'.mat'];
            if ~exist(tadStructFileName,'file')
                tadStruct = retrieve_tad(module, output, targetList);
                eval(['save ',targetList,'Mod',int2str(module),'Out',int2str(output),'.mat tadStruct']);
            else
                load(tadStructFileName); % expect one struct only
            end

        else % load the mat file, if valid

            % if matTadStructString does not end in .mat, add it
            [path name extension] = fileparts(matTadStructString);
            
            if isempty(extension)
                matTadStructString = [matTadStructString '.mat'];
            end


            if exist(matTadStructString, 'file')
                disp('Loading mat file...')
                load(matTadStructString);
                
            else
                errordlg(['Invalid mat file: ' matTadStructString], 'Bad Input','modal')
                disp('Invalid mat file')
                return
            end


        end

        coaImage = create_coaImage(tadStruct);
        setappdata(fh, 'coaImage', coaImage)

        maskImage = create_targetMaskImage(tadStruct);
        setappdata(fh, 'maskImage', maskImage)

        bkgPixImage = create_backgroundPixelImage(tadStruct);
        setappdata(fh, 'bkgPixImage', bkgPixImage);

        keplerIdImage = create_keplerId_image(tadStruct);
        setappdata(fh, 'keplerIdImage', keplerIdImage);

        fprintf('\n\nfinished retrieving tad\n\n')
        set(overlay_h, 'enable', 'on') % enable button now that tad has been retrieved
        set(selectFFI_h, 'enable', 'on')
        set(selectLC_h, 'enable', 'on')
        poof_labels(tadStruct, ax);
    end



    function loadAllTadsFromTargetList_callback(loadAllTadsFromTargetList_h, evd) %#ok<INUSD>
        targetList = getappdata(fh, 'targetList');
        cnt = 0;
        for module = setdiff(2:24,[5,21])
            for output = 1:4
                cnt = cnt + 1;
                tadStructFileName = [targetList,'Mod',int2str(module),'Out',int2str(output),'.mat'];
                if ~exist(tadStructFileName,'file')
                    tadStruct = retrieve_tad(module, output, targetList); %#ok<NASGU>
                    eval(['save ',targetList,'Mod',int2str(module),'Out',int2str(output),'.mat tadStruct']);
                end
                waitbar(cnt/84)
            end
        end
    end


    function selectFitsFile_callback(selectFFI_h, evd) %#ok<INUSD>

        ffiName = get(fitsOrLCDir_h, 'string');

        if isempty(ffiName)
            [ffiName ffiPath] = uigetfile('*.fits', 'Select FFI:');
            ffiName = [ffiPath ffiName];
        else
            
            [path2 name2 extension2] = fileparts(ffiName);
            
            if isempty(extension2) && ~isempty(ffiName)
                ffiName = [ffiName '.fits'];
            end

            if exist(ffiName, 'file') ~= 2
                errordlg(['Invalid fits file: ' ffiName], 'Bad Input','modal')
                disp('Invalid fits file')
                return
            end

        end
        setappdata(fh, 'ffiName', ffiName)
        module = getappdata(fh,'module');
        output = getappdata(fh, 'output');
        ccdImage = create_ccdImage(ffiName, module, output);
        setappdata(fh, 'ccdImage', ccdImage);
        struct = getappdata(fh);

        if isempty(struct.longCadenceImage)
            set(image1_h, 'string', menustring_image1(1:3))
        else
            set(image1_h, 'string', menustring_image1)
        end

    end



    function selectLc_callback(selectLC_h, evd) %#ok<INUSD>
        
        dirLcFiles = get(fitsOrLCDir_h, 'string');
        
        if isempty(dirLcFiles)
        dirLcFiles = uigetdir(pwd,'Select Directory with LC and LC Mapping Files');
        else
            
            if exist(dirLcFiles, 'dir') ~= 7
                errordlg(['Invalid directory: ' dirLcFiles], 'Bad Input','modal')
                disp('Invalid directory')
                return
            end       
        end
        setappdata(fh, 'dirLcFiles', dirLcFiles);
        module = getappdata(fh,'module');
        output = getappdata(fh, 'output');
        longCadenceImage = create_longCadence_image(dirLcFiles, module, output);
        setappdata(fh, 'longCadenceImage', longCadenceImage);
        struct = getappdata(fh);

        if isempty(struct.ccdImage)
            set(image1_h, 'string', {'COA Image';'Target Masks';'LC Image'})
        else
            set(image1_h, 'string', menustring_image1)
        end

    end



    function selectImage1_callback(image1_h, evd) %#ok<INUSD>

        val = get(image1_h, 'value');
        string = get(image1_h, 'string');
        selectionImage1 = string(val);

        if strcmp(selectionImage1, 'Target Masks')
            set(image2_h, 'value', 1,'string', menustring_image2{2})
            setappdata(fh, 'selectionImage2', menustring_image2{2})
        else
            set(image2_h, 'value', 1,'string', menustring_image2)
            setappdata(fh, 'selectionImage2', menustring_image2{1})
        end

        setappdata(fh, 'selectionImage1', selectionImage1)


    end

    
        
    function selectImage2_callback(image2_h, evd) %#ok<INUSD>

        val = get(image2_h, 'value');
        string = get(image2_h, 'string'); 
        selectionImage2 = string{val};
        setappdata(fh, 'selectionImage2', selectionImage2)


    end



    function overlay_callback(overlay_h, evd) %#ok<INUSD>

        selectionImage1 = getappdata(fh, 'selectionImage1');
        selectionImage2 = getappdata(fh, 'selectionImage2');
        
        text_image1 = selectionImage1{1};
        set(image1_text_h, 'string', text_image1)

        if strcmp(selectionImage1, 'COA Image')
            image1 = getappdata(fh, 'coaImage');
        elseif strcmp(selectionImage1, 'Target Masks')
            image1 = getappdata(fh, 'maskImage');
        elseif strcmp(selectionImage1, 'CCD Image')
            image1 = getappdata(fh, 'ccdImage');
        else
            image1 = getappdata(fh,'longCadenceImage');
        end


        if strcmp(selectionImage2, menustring_image2(1))
            image2 = getappdata(fh, 'maskImage');
        else
            image2= getappdata(fh, 'bkgPixImage');
        end

        poof_overlay(image1, image2)
        if strcmp(selectionImage1, 'COA Image')
            set(fh, 'color', [1 .4 .4])
        else 
            set(fh, 'color', [.8 .8 .8])
        end

        xlabel('Column','fontsize', 12, 'fontweight', 'bold')
        ylabel('Row', 'fontsize', 12, 'fontweight', 'bold')
        radioList_h = findobj('style', 'radiobutton');
        if ~isempty(radioList_h)
            set(radioList_h, 'value', 0, 'foregroundcolor', 'k','enable', 'on')
        end

    end



    function move_mouse_callback(fh, evd) %#ok<INUSD>
        
        import gov.nasa.kepler.common.FcConstants;

        keplerIdImage = getappdata(fh, 'keplerIdImage');

        if ~isempty(keplerIdImage)
            cp = round(get(gca, 'currentpoint')); % current mouse position, 0 based
            row =cp(1,2);
            col =cp(1,1);

            if  row >= 0 && col >= 0 && row <= FcConstants.CCD_ROWS-1 && col <= FcConstants.CCD_COLUMNS-1

                set(row_dynamic_h, 'string', row)
                set(col_dynamic_h, 'string', col)
                label =keplerIdImage(row+1, col+1);

                if label ~= 0
                    set(keplerId_dynamic_h, 'string', num2str(label))
                else
                    set(keplerId_dynamic_h, 'string', '')
                end

            else

                set(row_dynamic_h, 'string', '')
                set(col_dynamic_h, 'string', '')

            end
        end
    end



end % end of the main function
