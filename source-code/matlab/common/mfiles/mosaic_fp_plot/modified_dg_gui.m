function modified_dg_gui(ffiName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% modified_dg_gui(ffiName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% modified_dg_gui(ffiName) is the interactive tool adapted from DG.
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT:
%            
%
%       ffiName: [string] name of the ffi fitsfile
%                       fitsfile can be either single channel or multiple
%                       channel fitsfiles :)
%
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUT:
%
%         one gui figure with handle fh2
%         another gui figure with handle fh3
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% import FcConstants, needed for plotting
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
import gov.nasa.kepler.common.FcConstants;


%% Initialize interactive figure

% initialize figure 
fh2 = figure( 'position', [ 200   35   1045   830], 'tag', 'int_hist',...
    'numbertitle', 'off', 'name', 'Modified Data Goodness Tool GUI', 'visible', 'off');

%% create the third figure that is image only
fh3 = figure('visible', 'off', 'numbertitle', 'off', 'name', 'Module 2, Output 1');
fh3_ax =  axes('parent', fh3);
colormap(hot);

%%
k = retrieve_fits_primary_keywords(ffiName, 'NUM_FFI',...
    'DATATYPE', 'INT_TIME', 'NUM_FFI', 'DCT_PURP','SCCONFID', 'STARTIME', 'END_TIME');


setappdata(fh2, 'numFFI', k.NUM_FFI)
setappdata(fh2, 'startMjd', k.STARTIME)
setappdata(fh2, 'endMjd', k.END_TIME)


% add frames to the 3 sections
uipanel('units', 'pixels', 'position', [ 25 358 755 470], 'parent', fh2);
uipanel('units', 'pixels', 'position', [ 25 178 755 178], 'parent', fh2);
uipanel('units', 'pixels', 'position', [ 25 5 755 170], 'parent', fh2);
uipanel('units', 'pixels', 'position', [ 785 358 250 470], 'parent', fh2);
uipanel('units', 'pixels', 'position', [ 785 5 250 348], 'parent', fh2);

ax1 = axes('units', 'pixels', 'position', [ 180 490 400 300],'parent', fh2);
ax2 = axes('units', 'pixels', 'position', [ 80 210 450 120], 'parent', fh2);
ax3 = axes('units', 'pixels', 'position', [ 80 30 450 120], 'parent', fh2);
ax4 = axes('units', 'pixels', 'position', [ 180 370 340 70],'parent', fh2);
set(ax4, 'xticklabel', [], 'yticklabel', [])
ax5 = axes('units', 'pixels','position', [ 60 490 70 300],'parent', fh2);
set(ax5, 'xticklabel', [], 'yticklabel', [])

% by default, always display the first image of fits file,
% normalize to get DN/read
table = prepare_for_fitsread(ffiName);
module = table(1,2);
output = table(1,3);
setappdata(fh2, 'module', module)
setappdata(fh2, 'output', output)   
image = fitsread_check_modout(ffiName, module, output, table)/k.NUM_FFI; % fitsread in image and normalize

% read in the guard band values and save in appdata
%     [highGuardBand lowGuardBand] = dg_read_high_low_guard_bands...
%    (k.STARTIME, k.END_TIME);


% initialize application data
setappdata(fh2, 'image', image)
setappdata(fh2, 'displayImage', image)
setappdata(fh2, 'dispImRowStart', 0)
setappdata(fh2, 'dispImRowEnd', FcConstants.CCD_ROWS-1)
setappdata(fh2, 'dispImColStart', 0)
setappdata(fh2, 'dispImColEnd', FcConstants.CCD_COLUMNS-1)
setappdata(fh2, 'module', 2)
setappdata(fh2, 'output', 1)
% setappdata(fh2, 'lowGuardBand', lowGuardBand);
% setappdata(fh2, 'highGuardBand', highGuardBand);



% initialize zoom graphics object
hz1 = zoom(fh2); 
set(hz1, 'enable', 'off','actionpostcallback', @update_hist_scatter_callback)



%% initialize zoom push buttons, 6 total (2 for ea/ panel in col 1)

zoombutton_img_h = uicontrol(fh2,'style', 'togglebutton', ...
    'string', 'Zoom In', 'position', [ 600 500 75 30], ...
    'callback', @zoom_callback, 'value', 0);

unzoombutton_img_h = uicontrol(fh2,'style', 'togglebutton', ...
    'string', 'Zoom Out', 'position', [ 685 500 75 30], ...
    'callback', @unzoom_callback, 'value', 0);

zoombutton_hist_h = uicontrol(fh2,'style', 'togglebutton', ...
    'string', 'Zoom In', 'position', [ 600 260 75 30], ...
    'callback', @zoomhist_callback, 'value', 0);

unzoombutton_hist_h = uicontrol(fh2,'style', 'togglebutton', ...
    'string', 'Zoom Out', 'position', [ 685 260 75 30], ...
    'callback', @unzoomhist_callback, 'value', 0);

zoombutton_scatter_h = uicontrol(fh2,'style', 'togglebutton', ...
    'string', 'Zoom In', 'position', [ 600 55 75 30], ...
    'callback', @zoomscatter_callback, 'value', 0);

unzoombutton_scatter_h = uicontrol(fh2,'style', 'togglebutton', ...
    'string', 'Zoom Out', 'position', [ 685 55 75 30], ...
    'callback', @unzoomscatter_callback, 'value', 0);

%% initialize data cursor component, 2 total (1 for image, 1 for scatter)FcConstants

pixelinfobutton_img_h= uicontrol(fh2,'style', 'togglebutton', ...
    'string', ' Pixel Info', 'position', [ 600 545 75 30], ...
    'callback', @pixelinfo_callback, 'value', 0);

pixelinfobutton_scatter_h= uicontrol(fh2,'style', 'togglebutton', ...
    'string', ' Pixel Info', 'position', [ 600 100 75 30], ...
    'callback', @pixelinfoscatter_callback, 'value', 0);

%% initialize popupmenu for pixel region selection

popupmenustring = {'All', 'Star','Leading Black', 'Trailing Black', 'Masked Smear', 'Virtual Smear'};

region_h = uicontrol(fh2,'style', 'popupmenu', ...
    'string', popupmenustring, 'position', [ 600 740 150 40], ...
    'value', 1, 'callback', @selectpixelregion_callback);

uicontrol(fh2,'style', 'text', 'string', 'Select Pixel Region',...
    'position', [ 600 780 150 20] );

%% initialize popupmenu for colormap selection

menustring_colormap = {'Hot', 'Gray','Jet', 'bone', 'Summer', 'Autumn', 'Winter'};

uicontrol(fh2,'style', 'popupmenu', ...
    'string', menustring_colormap, 'position', [ 600 680 150 40], ...
    'value', 1, 'callback', @selectcolormap_callback);

uicontrol(fh2,'style', 'text', 'string', 'Select Colormap',...
    'position', [ 600 720 150 20] );

uicontrol(fh2,'style', 'text', 'string', 'Intensity Range (0 to 1)',...
    'position', [ 600 650 150 20] );

uicontrol(fh2,'style', 'text', 'string', 'Min',...
    'position', [ 600 630 30 20] );

uicontrol(fh2,'style', 'text', 'string', 'Max',...
    'position', [ 685 630 30 20] );

label_clim_min_edit_h = uicontrol(fh2,'style', 'edit',...
    'position', [ 630 630 60 20] , 'backgroundcolor', [1 1 1], ...
    'enable', 'off','callback', @climMin_callback);

label_clim_max_edit_h = uicontrol(fh2,'style', 'edit', ...
    'position', [ 715 630 60 20], 'backgroundcolor', [1 1 1], ...
    'enable', 'off','callback', @climMax_callback);

auto_checkbox_h =  uicontrol(fh2, 'style', 'checkbox', 'units', 'pixels', ...
    'position', [ 600 600 150 20], 'string', 'Auto Color Limits', 'value', 1, ...
    'callback', @autocheckbox_callback);

%% initialize bin control for histograms

bin_label_h = uicontrol(fh2, 'style', 'text', 'string', ' Bins: 1000',...
    'position', [ 600 320 150 20] );

bin_slider_h =  uicontrol(fh2, 'style', 'slider', 'min', 1, 'max', 1000,...
    'value', 1000, 'sliderstep', [1/999 10/999], ...
    'position', [ 600 300 150 20] , 'backgroundcolor', 'w', ...
    'callback', @binslider_callback);

%% plot on ax1

plot_ax1 % see subfunction at bottom


%% plot on ax2

bin = 1000; % start at 1000 bins

plot_ax2(bin) % see subfunction at bottom


%% plot on ax3

plot_ax3 % see subfunction at bottom


%% find figure with fp display, if it exists

fig_list = allchild(0);

fh1 = findall(fig_list, 'tag', 'fp_display');

% if found, create mouse_click_callback for fp display
if ~isempty(fh1) % here if there is no fp display and user just wants to view fits file with 1 channel's worth of data
set(fh1, 'windowbuttondownfcn', @mouse_click_callback); % independent of mouse_over_to_get_modout 
end

%% set filename and module output information for the data being displayed


text_h = uicontrol(fh2, 'style', 'text', 'position', [ 795 550 200 250],...
    'fontsize', 12, 'fontweight', 'bold', 'horizontalAlignment', 'left',...
    'string', sprintf('File:\n %s\n\n Module %d\n Output %d', ffiName, module, output) );

%% set the keyword panel

uicontrol(fh2, 'style', 'text', 'position', [ 795 500 200 20],...
    'string', 'Keywords')

uicontrol(fh2, 'style', 'text', 'position', [ 795 415 150 200], ...
    'string', fieldnames(k), 'horizontalalignment','left')

uicontrol(fh2, 'style', 'text', 'position', [ 930 415 75 200],...
    'string', struct2cell(k), 'horizontalalignment','left')

%% set the statistics panel for the initialized modout

% 
% dgTrimmedImageObj = dgTrimmedImageClass...
%     ( module, output, k.NUM_FFI, k.STARTIME, k.END_TIME, image*k.NUM_FFI); % remember that in appdata it got normalized
% 
% dgStatStruct = dg_compute_stat(dgTrimmedImageObj, highGuardBand, lowGuardBand);
% 
% s= dgStatStruct.star;
% 
% uicontrol(fh2, 'style', 'text', 'position', [ 795 75 150 200],...
%     'string', fieldnames(s), 'horizontalalignment','left')
% 
% fieldValues_h = uicontrol(fh2, 'style', 'text', 'position', [ 940 75 90 200],...
%     'string', struct2cell(s), 'horizontalalignment','left');
% 
% statisticsTitle_h = uicontrol(fh2, 'style', 'text', 'position', [ 795 300 200 20],...
%     'string', 'Statistics for Star Region');% by default, display star stat


%% make gui visible now that all components have been initialized

set(fh2, 'visible', 'on'); colormap(hot);
set(fh3, 'visible', 'on'); colormap(hot);



%% CALLBACK FUNCTIONS

    function climMin = climMin_callback(label_clim_min_edit_h, evd)
        displayImage = getappdata(fh2,'displayImage');
        dispImRowStart = getappdata(fh2, 'dispImRowStart');
        dispImRowEnd = getappdata(fh2, 'dispImRowEnd');
        dispImColStart = getappdata(fh2, 'dispImColStart');
        dispImColEnd = getappdata(fh2, 'dispImColEnd');

        climMinFrac = str2double(get(label_clim_min_edit_h,'string'));
        climMaxFrac = str2double(get(label_clim_max_edit_h,'string'));
        rangeDisplayImage = max(displayImage(:))-min(displayImage(:));
        climMin = (climMinFrac*rangeDisplayImage)+min(displayImage(:));
        climMax = (climMaxFrac*rangeDisplayImage)+min(displayImage(:));
        clim =[climMin, climMax];
        if isnan(climMinFrac)
            errordlg('You must enter a numeric value','Bad Input','modal');return
        elseif climMinFrac < 0 || climMinFrac > 1
            errordlg('Enter pixel range intensity from 0 to 1'); return
        elseif climMinFrac > climMaxFrac
            errordlg('Min value must be smaller than Max value'); return
        end

        % redraw
        smart_imagesc(displayImage, [dispImColStart dispImColEnd], [dispImRowStart dispImRowEnd ], ax1);
        set(ax1, 'clim', clim, 'ydir', 'normal');
        colorbar('peer', ax1);
        ylabel('Row', 'parent', ax1)
        xlabel('Column', 'parent', ax1)

        % on fh3
        smart_imagesc(displayImage, [dispImColStart dispImColEnd], [dispImRowStart dispImRowEnd ], fh3_ax);
        set(fh3_ax, 'clim', clim, 'ydir', 'normal');
        colorbar('peer', fh3_ax)
        ylabel('Row', 'parent', fh3_ax, 'fontsize', 14, 'fontweight', 'bold')
        xlabel('Column', 'parent', fh3_ax, 'fontsize', 14, 'fontweight', 'bold')
        drawnow
    end
%%
    function climMax = climMax_callback(label_clim_max_edit_h, evd)
        displayImage = getappdata(fh2,'displayImage');
        dispImRowStart = getappdata(fh2, 'dispImRowStart');
        dispImRowEnd = getappdata(fh2, 'dispImRowEnd');
        dispImColStart = getappdata(fh2, 'dispImColStart');
        dispImColEnd = getappdata(fh2, 'dispImColEnd');
        
        climMinFrac = str2double(get(label_clim_min_edit_h,'string'));
        climMaxFrac = str2double(get(label_clim_max_edit_h,'string'));
        rangeDisplayImage = max(displayImage(:))-min(displayImage(:));
        climMin = (climMinFrac*rangeDisplayImage)+min(displayImage(:));
        climMax = (climMaxFrac*rangeDisplayImage)+min(displayImage(:));
        clim =[climMin, climMax];
            if isnan(climMaxFrac)
            errordlg('You must enter a numeric value','Bad Input','modal');return
            elseif climMaxFrac < 0 || climMaxFrac > 1
            errordlg('Enter pixel range intensity from 0 to 1'); return
            elseif climMaxFrac < climMinFrac
            errordlg('Max value must be larger than Min value'); return
            end
        % redraw
        smart_imagesc(displayImage, [dispImColStart dispImColEnd], [dispImRowStart dispImRowEnd ], ax1);
        set(ax1, 'clim', clim, 'ydir', 'normal');
        colorbar('peer', ax1);
        ylabel('Row', 'parent', ax1)
        xlabel('Column', 'parent', ax1)

        % on fh3
        smart_imagesc(displayImage, [dispImColStart dispImColEnd], [dispImRowStart dispImRowEnd ], fh3_ax);
        set(fh3_ax, 'clim', clim, 'ydir', 'normal');  
        colorbar('peer', fh3_ax)
        ylabel('Row', 'parent', fh3_ax, 'fontsize', 14, 'fontweight', 'bold')
        xlabel('Column', 'parent', fh3_ax, 'fontsize', 14, 'fontweight', 'bold')
        drawnow

    end

%%

    function autocheckbox_callback(auto_checkbox_h, evd)


        if  get(auto_checkbox_h, 'value') % if checkbox is selected use autolimits
            
            plot_ax1
            
            
            
        else  % not checked, manual clims -enable the two edits
            set(label_clim_min_edit_h, 'enable', 'on')
            set(label_clim_max_edit_h, 'enable', 'on')

        end

    end
%%

    function mouse_click_callback(fh1, evd)
        
        import gov.nasa.kepler.common.FcConstants;


        modLabel = getappdata(fh1, 'modLabel');
        outLabel = getappdata(fh1, 'outLabel');

        if modLabel ~= 0  && outLabel ~= 0
            table = prepare_for_fitsread(ffiName);
            image = (fitsread_check_modout(ffiName, modLabel, outLabel, table))/k.NUM_FFI;
            setappdata(fh2, 'image', image) % save the image to appdata on fh2

            setappdata(fh2, 'displayImage', image)
            setappdata(fh2, 'dispImRowStart', 0)
            setappdata(fh2, 'dispImRowEnd', FcConstants.CCD_ROWS-1)
            setappdata(fh2, 'dispImColStart', 0)
            setappdata(fh2, 'dispImColEnd', FcConstants.CCD_COLUMNS-1)
            setappdata(fh2, 'module', modLabel)
            setappdata(fh2, 'output', outLabel)
            module = getappdata(fh2, 'module');
            output = getappdata(fh2, 'output');
            set(text_h, 'string', sprintf('File:\n %s\n\n Module %d\n Output %d', ffiName, module, output))
            set(fh3, 'name', sprintf('Module %d\n Output %d', module, output))

            zoom off
            datacursormode off
            selectpixelregion_callback(region_h, evd) % check the drop down menu selection for region




            %generate_text_and_stat % update the statistics
            cla(ax4); set(ax4, 'xticklabel', [], 'yticklabel', [])
            cla(ax5); set(ax5, 'xticklabel', [], 'yticklabel', [])



        end
        
            
            
    end

%%
    function zoom_callback(zoombutton_img_h, evd)
        
        datacursormode off
        
        set(hz1, 'enable', 'on', 'direction', 'in', 'motion','both', 'actionpostcallback', @update_hist_scatter_callback)
        
        set(pixelinfobutton_img_h, 'value', 0)
        set(unzoombutton_img_h, 'value', 0)
        set(zoombutton_hist_h, 'value', 0)
        set(unzoombutton_hist_h, 'value', 0)
        set(zoombutton_scatter_h, 'value', 0)
        set(unzoombutton_scatter_h, 'value', 0)
        set(pixelinfobutton_scatter_h, 'value', 0)
        setAllowAxesZoom(hz1, ax1, true)
        setAllowAxesZoom(hz1, ax2, false)
        setAllowAxesZoom(hz1, ax3, false)
        setAllowAxesZoom(hz1, ax4, false)
        setAllowAxesZoom(hz1, ax5, false)
        cla(ax4); set(ax4, 'xticklabel', [], 'yticklabel', [])
        cla(ax5); set(ax5, 'xticklabel', [], 'yticklabel', [])

    end

%%

    function unzoom_callback(unzoombutton_img_h, evd)
        
        datacursormode off
        
  

       set(hz1, 'enable', 'on', 'direction', 'out', 'motion','both','actionpostcallback', @update_hist_scatter_callback)
        set(pixelinfobutton_img_h, 'value', 0)
        set(zoombutton_img_h, 'value', 0)
        set(zoombutton_hist_h, 'value', 0)
        set(unzoombutton_hist_h, 'value', 0)
        set(zoombutton_scatter_h, 'value', 0)
        set(unzoombutton_scatter_h, 'value', 0)
        set(pixelinfobutton_scatter_h, 'value', 0)
        setAllowAxesZoom(hz1, ax1, true)
        setAllowAxesZoom(hz1, ax2, false)
        setAllowAxesZoom(hz1, ax3, false)
        setAllowAxesZoom(hz1, ax4, false)
        setAllowAxesZoom(hz1, ax5, false)
        cla(ax4)
        cla(ax5)
            
    end
%%

    function zoomhist_callback(zoombutton_img_h, evd)

        datacursormode off
        set(pixelinfobutton_img_h, 'value', 0)
        set(hz1, 'enable', 'on', 'direction', 'in', 'motion','both')
        set(zoombutton_img_h, 'value', 0)
        set(unzoombutton_img_h, 'value', 0)
        set(unzoombutton_hist_h, 'value', 0)
        set(zoombutton_scatter_h, 'value', 0)
        set(unzoombutton_scatter_h, 'value', 0)
        set(pixelinfobutton_scatter_h, 'value', 0)
        setAllowAxesZoom(hz1, ax1, false)
        setAllowAxesZoom(hz1, ax2, true)
        setAllowAxesZoom(hz1, ax3, false)
        setAllowAxesZoom(hz1, ax4, false)
        setAllowAxesZoom(hz1, ax5, false)
        

    end

%%

    function unzoomhist_callback(unzoombutton_img_h, evd)
                
        set(hz1, 'enable', 'on', 'direction', 'out', 'motion','both')
        set(pixelinfobutton_img_h, 'value', 0)
        set(zoombutton_img_h, 'value', 0)
        set(unzoombutton_img_h, 'value', 0)
        set(zoombutton_hist_h, 'value', 0)
        set(zoombutton_scatter_h, 'value', 0)
        set(unzoombutton_scatter_h, 'value', 0)
        set(pixelinfobutton_scatter_h, 'value', 0)
        setAllowAxesZoom(hz1, ax1, false)
        setAllowAxesZoom(hz1, ax2, true)
        setAllowAxesZoom(hz1, ax3, false)
        setAllowAxesZoom(hz1, ax4, false)
        setAllowAxesZoom(hz1, ax5, false)
        
    end

%%

    function zoomscatter_callback(zoombutton_scatter_h, evd)

        datacursormode off
        
        set(hz1, 'enable', 'on', 'direction', 'in', 'motion','both')

        set(pixelinfobutton_img_h, 'value', 0)
        set(zoombutton_img_h, 'value', 0)
        set(unzoombutton_img_h, 'value', 0)
        set(zoombutton_hist_h, 'value', 0)
        set(unzoombutton_hist_h, 'value', 0)
        set(unzoombutton_scatter_h, 'value', 0)  
        set(pixelinfobutton_scatter_h, 'value', 0)
        setAllowAxesZoom(hz1, ax1, false)
        setAllowAxesZoom(hz1, ax2, false)
        setAllowAxesZoom(hz1, ax3, true)
        setAllowAxesZoom(hz1, ax4, false)
        setAllowAxesZoom(hz1, ax5, false)

    end
    
%%

    function unzoomscatter_callback(unzoombutton_scatter_h, evd)
        
        datacursormode off
        set(hz1, 'enable', 'on', 'direction', 'out', 'motion','both')
        set(pixelinfobutton_img_h, 'value', 0)
        set(zoombutton_img_h, 'value', 0)
        set(unzoombutton_img_h, 'value', 0)
        set(zoombutton_hist_h, 'value', 0)
        set(unzoombutton_hist_h, 'value', 0)
        set(zoombutton_scatter_h, 'value', 0)
        set(pixelinfobutton_scatter_h, 'value', 0)
        setAllowAxesZoom(hz1, ax1, false)
        setAllowAxesZoom(hz1, ax2, false)
        setAllowAxesZoom(hz1, ax3, true)
        setAllowAxesZoom(hz1, ax4, false)
        setAllowAxesZoom(hz1, ax5, false)
    end
%%
    function update_hist_scatter_callback(fh2, evd)
        
        import gov.nasa.kepler.common.FcConstants;

        hitAxes = gca; % used to determine which postcallback to use
        if hitAxes ==ax1

            xLim = get(evd.Axes, 'XLim'); % x is the col
            yLim = get(evd.Axes, 'YLim'); % y is the row

            xMin = ceil(xLim(1,1)); 
            xMax = floor(xLim(1,2));
            yMin = ceil(yLim(1,1)); 
            yMax = ceil(yLim(1,2));
            
            if xMin < 0
                xMin = 0; % if zoom overshoots, don't want error
            end

         

            if xMax > FcConstants.CCD_COLUMNS-1
                xMax = FcConstants.CCD_COLUMNS-1; % if zoom overshoots, don't want error
            end

            

            if yMin < 0
                yMin = 0; % if zoom overshoots, don't want error
            end

            

            if yMax > FcConstants.CCD_ROWS-1
                yMax = FcConstants.CCD_ROWS-1; % if zoom overshoots, don't want error
            end



            image = getappdata(fh2, 'image');
            zoomImage = image(yMin+1:yMax+1, xMin+1:xMax+1);  % must add one for indexing into image
            setappdata(fh2, 'displayImage', zoomImage);
            setappdata(fh2, 'dispImRowStart', yMin)
            setappdata(fh2, 'dispImRowEnd', yMax)
            setappdata(fh2, 'dispImColStart', xMin)
            setappdata(fh2, 'dispImColEnd', xMax)
        

            bin = get(bin_slider_h, 'value');
            plot_ax2(bin)
        
        
            plot_ax3
    

        end
end
%%

    function pixelinfo_callback(pixelinfobutton_img_h, evd)

        set(hz1, 'enable', 'off')
        dcm = datacursormode(fh2);
        set(dcm, 'updatefcn', @datacursor_callback, 'snaptodatavertex', 'off',...
            'enable', 'on')
        set(zoombutton_img_h, 'value', 0)
        set(unzoombutton_img_h, 'value', 0)
        set(zoombutton_hist_h, 'value', 0)
        set(unzoombutton_hist_h, 'value', 0)
        set(zoombutton_scatter_h, 'value', 0)
        set(unzoombutton_scatter_h, 'value', 0)
        set(pixelinfobutton_scatter_h, 'value', 0)
        set(findobj(ax1, 'type', 'image'), 'hittest', 'on')
        set(findobj(ax2, 'type', 'patch'), 'hittest', 'off')
        set(findobj(ax3, 'type', 'line'), 'hittest', 'off')
        
        
    end

%%

    function txt = datacursor_callback(emptyobj, eventobj)
        
        import gov.nasa.kepler.common.FcConstants;
        
        image = getappdata(fh2, 'image');
        pos = get(eventobj, 'position');
        tar =get(eventobj, 'target');
        type  = get(tar, 'type');
        


        if strcmp(type,'line')
            indx = round(pos(1));
            displayImageArray = gen_disp_im_array;
            row = displayImageArray(indx, 2); % 0 based
            col = displayImageArray(indx, 3);
            intensity = pos(2); % index into image, so 1 based
            txt = sprintf('row = %d \ncol = %d\nintensity = %5.2f', row, col, intensity);
            
            
        elseif strcmp(type,'image')
             row = round(pos(2));
                if row < 0
                row = 0; % must do this to prevent edge/rounding probs
                end
                if row > FcConstants.CCD_ROWS-1
                row = FcConstants.CCD_ROWS-1;
                end
       
            col = round(pos(1));
                if col < 0
                col = 0;% must do this to prevent edge/rounding probs
                end
                if col > FcConstants.CCD_COLUMNS-1
                col = FcConstants.CCD_COLUMNS-1;
                end

            intensity = image(row+1, col+1); % indexing into 1 based image, so must add 1
            txt = sprintf('row = %d \ncol = %d\nintensity = %5.2f', row, col, intensity);
            
            

            pixelFlag = get(pixelinfobutton_img_h, 'value');
            if pixelFlag ==1
                plot_ax4(row+1) % display horizontal pixel values on ax4
                plot_ax5(col+1) % display vertical pixel values on ax5
            end


            
            

        else

            return % do nothing
        end

    end
        
%%


    function pixelinfoscatter_callback(pixelinfobutton_scatter_h, eventobj)
        dcm = datacursormode(fh2);
        set(dcm, 'updatefcn', @datacursor_callback, 'snaptodatavertex', 'on',...
        'enable', 'on')
        set(hz1, 'enable', 'off')
        set(zoombutton_img_h, 'value', 0)
        set(unzoombutton_img_h, 'value', 0)
        set(zoombutton_hist_h, 'value', 0)
        set(unzoombutton_hist_h, 'value', 0)
        set(zoombutton_scatter_h, 'value', 0)
        set(unzoombutton_scatter_h, 'value', 0)
        set(pixelinfobutton_img_h, 'value', 0)
        set(findobj(ax1, 'type', 'image'), 'hittest', 'off')
        set(findobj(ax2, 'type', 'patch'), 'hittest', 'off')
        set(findobj(ax3, 'type', 'line'), 'hittest', 'on')
   
    end

%%

    function selectpixelregion_callback(region_h, evd)
        
        cla(ax4); set(ax4, 'xticklabel', [], 'yticklabel', [])
        cla(ax5); set(ax5, 'xticklabel', [], 'yticklabel', [])

        val = get(region_h, 'value');

        [starRowStart, starRowEnd, starColStart,starColEnd,...
            leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
            trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
            maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
            virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
            define_pixel_regions(); % these indeces are 1 based

        switch val

            case 1 % 'All'
                startRow = 1;
                endRow = virtualSmearRowEnd;
                startCol = 1;
                endCol = trailingBlackColEnd;
            case 2 % 'Star'
                startRow = starRowStart;
                endRow = starRowEnd;
                startCol = starColStart;
                endCol = starColEnd;
            case 3 % 'Leading Black'
                startRow =  leadingBlackRowStart;
                endRow = leadingBlackRowEnd;
                startCol = leadingBlackColStart;
                endCol = leadingBlackColEnd;
            case 4 % 'Trailing Black'
                startRow = trailingBlackRowStart;
                endRow =trailingBlackRowEnd;
                startCol =trailingBlackColStart;
                endCol =trailingBlackColEnd;
            case 5 % 'Masked smear'
                startRow =   maskedSmearRowStart;
                endRow = maskedSmearRowEnd;
                startCol = maskedSmearColStart;
                endCol = maskedSmearColEnd;
            case 6 %'Virtual Smear'
                startRow = virtualSmearRowStart;
                endRow =virtualSmearRowEnd;
                startCol =virtualSmearColStart;
                endCol = virtualSmearColEnd;
        end

        image = getappdata(fh2, 'image');
        displayImage = image(startRow : endRow, startCol : endCol); % 1 based
        setappdata(fh2, 'displayImage', displayImage)
   
        setappdata(fh2, 'dispImRowStart', startRow-1) % convert to 0  based
        setappdata(fh2, 'dispImRowEnd', endRow-1) % ditto
        setappdata(fh2, 'dispImColStart', startCol-1) % ditto
        setappdata(fh2, 'dispImColEnd', endCol-1) % ditto
        
        bin =1000;
        plot_ax1
        plot_ax2(bin)
        plot_ax3
        
        set(bin_slider_h, 'enable', 'on', 'value', bin)
        set(bin_label_h, 'string', sprintf('Bins:: %3.f', bin))
        
        % generate_text_and_stat
        
    end
%%
%     function generate_text_and_stat
%         
%         
%         image = getappdata( fh2, 'image');
%         module = getappdata(fh2, 'module');
%         output = getappdata(fh2, 'output');
%         numFFI = getappdata(fh2, 'numFFI');
%         startMjd =getappdata(fh2, 'startMjd');
%         endMjd =getappdata(fh2, 'endMjd'); 
%         highGuardBand = getappdata(fh2, 'highGuardBand');
%         lowGuardBand = getappdata(fh2, 'lowGuardBand');
% 
%         dgTrimmedImageObj = dgTrimmedImageClass...
%             ( module, output, numFFI, startMjd, endMjd, image*numFFI); % remember that in appdata it got normalized
%         
%         dgStatStruct = dg_compute_stat(dgTrimmedImageObj, highGuardBand, lowGuardBand);
%         
%         val = get(region_h, 'value');
%         
% switch val
%     
%     case 1
%         region='star';
%     case 2
%         region= 'star';
%     case 3
%         region='leadingBlack';
%     case 4
%         region= 'trailingBlack';
%     case 5 
%         region= 'maskedSmear';
%     case 6
%         region = 'virtualSmear';
%         
% end
% 
% s= dgStatStruct.(region);
% 
%         
%  set(fieldValues_h, 'string', struct2cell(s))
%  set(statisticsTitle_h, 'string', sprintf('Statistics for %s Region', region))
%                  
%     end
    
 

%%
        
    function binslider_callback(bin_slider_h, evd)
        set(bin_slider_h, 'enable', 'on')
        bin = get(bin_slider_h, 'value'); 
        set(bin_label_h, 'string', sprintf('Bins: %3.f', bin))  
        plot_ax2(bin)
        
    end

%%

    function cmap = selectcolormap_callback(colormap_h, evd)
        val = get(colormap_h, 'value');

        switch val
            case 1 % hot
                cmap = 'hot';
            case 2 % gray
                cmap = 'gray';
            case 3 % jet
                cmap = 'jet';
            case 4 % spring
                cmap = 'bone';
            case 5 % summer
                cmap = 'summer';
            case 6 % autumn
                cmap = 'autumn';
            case 7 % winter
                cmap = 'winter';
        end

        figure(fh2) % make figure 2 active to change colormap
        eval(['colormap ' cmap])
        
        figure(fh3)
        eval(['colormap ' cmap])

    end


%% SUBFUNCTIONS

    function displayImageArray = gen_disp_im_array
        % generate an array of n rows by 4 with cols info
        % nth element, row of full image, col of full image, and value
        % for easy indexing, particularly ax3-datacursor callback
        
        displayImage = getappdata(fh2, 'displayImage');
        dispImRowStart = getappdata(fh2, 'dispImRowStart');
        dispImRowEnd = getappdata(fh2, 'dispImRowEnd');
        dispImColStart = getappdata(fh2, 'dispImColStart');
        dispImColEnd = getappdata(fh2, 'dispImColEnd');

        displayImageArray = zeros(numel(displayImage), 3); % preallocate
        n=1;
        while n <= numel(displayImage)
            for col = dispImColStart : dispImColEnd % 0  based
                for row = dispImRowStart: dispImRowEnd % 0  based
                    displayImageArray(n, 1) = n;
                    displayImageArray(n, 2) = row;
                    displayImageArray(n, 3) = col;
                    n=n+1;
                end
            end
        end
       
    end
%%

    function plot_ax1

        displayImage = getappdata(fh2, 'displayImage');
        dispImRowStart = getappdata(fh2, 'dispImRowStart');
        dispImRowEnd = getappdata(fh2, 'dispImRowEnd');
        dispImColStart = getappdata(fh2, 'dispImColStart');
        dispImColEnd = getappdata(fh2, 'dispImColEnd');

        smart_imagesc(displayImage, [dispImColStart dispImColEnd], [dispImRowStart dispImRowEnd ], ax1);
        set(ax1, 'ydir', 'normal');
        colorbar('peer', ax1)
        ylabel('Row', 'parent', ax1)
        xlabel('Column', 'parent', ax1)
        drawnow

        clim = get(ax1, 'clim');
        climMin = clim(1);
        climMax = clim(2);
    
        rangeDisplayImage = max(displayImage(:))-min(displayImage(:));
        climMinEdit = (climMin-min(displayImage(:)))/rangeDisplayImage(:);
        climMaxEdit = (climMax-min(displayImage(:)))/rangeDisplayImage(:);
        set(label_clim_min_edit_h, 'string', sprintf('%1.4f',climMinEdit), 'enable', 'off');
        set(label_clim_max_edit_h, 'string', sprintf('%1.4f',climMaxEdit), 'enable', 'off');
        set(auto_checkbox_h, 'value', 1);
        
       
        % on fh3 ax1
        smart_imagesc(displayImage, [dispImColStart dispImColEnd], [dispImRowStart dispImRowEnd ], fh3_ax);
        set(fh3_ax, 'ydir', 'normal');
        colorbar('peer', fh3_ax)
        ylabel('Row', 'parent', fh3_ax, 'fontsize', 14, 'fontweight', 'bold')
        xlabel('Column', 'parent', fh3_ax, 'fontsize', 14, 'fontweight', 'bold')
        drawnow



    end

%%
    
    function plot_ax2(bin)
        
        displayImage = getappdata(fh2, 'displayImage');
       
        hist(displayImage(:), bin, 'parent', ax2);
        set(ax2, 'xgrid', 'on', 'ygrid', 'on')
        
        ylabel('Count', 'parent', ax2)
        xlabel('Intensity', 'parent', ax2)
        drawnow

    end

%%

    function plot_ax3


        displayImage = getappdata(fh2, 'displayImage');
        semilogy( displayImage(:), '.b','parent', ax3);

        if all(displayImage<=1000) % if well behave collateral region
            set(ax3, 'yscale', 'linear', 'ytick', [500 750 1000],...
                'ylim', [500 1000],'ygrid', 'on', 'xtick', [],'ydir', 'normal' )

            % if missing pixels, must be able to see
        elseif any(displayImage > 1.59e7)
            set(ax3, 'yscale', 'log', 'ytick', [10^3 10^6 10^9], ...
                'ylim', [500 2^32*1.2], 'ygrid', 'on', 'xtick', [], 'ydir', 'normal')
        else
            set(ax3, 'yscale', 'log', 'ytick', [10^3 10^4],...
                'ylim', [500 (2^14)*1.2], 'ygrid', 'on', 'xtick', [], 'ydir', 'normal')
        end
        
        ylabel('Intensity', 'parent', ax3);
        xlabel('Pixels', 'parent', ax3);
        drawnow

    end

%% horizontal plot of image, or row pixels

    function plot_ax4(rowNum)
        image = getappdata(fh2, 'image');
        dispImColStart = getappdata(fh2, 'dispImColStart'); 
        dispImColEnd = getappdata(fh2, 'dispImColEnd');
        columnAddress = dispImColStart:dispImColEnd;
        plot(columnAddress, image(rowNum, columnAddress+1), 'parent', ax4)
        set(ax4, 'xlimmode', 'manual', 'xlim', [dispImColStart dispImColEnd],...
            'yaxislocation', 'right','xticklabel', [])
    end

%% vertical plot of image, or column pixels

    function plot_ax5(colNum)
        image = getappdata(fh2, 'image');
        dispImRowStart = getappdata(fh2, 'dispImRowStart');
        dispImRowEnd = getappdata(fh2, 'dispImRowEnd');
        rowAddress = dispImRowStart:dispImRowEnd;
        plot(rowAddress, image(rowAddress+1, colNum), 'parent', ax5)
        set(ax5, 'xlimmode', 'manual', 'xlim', [dispImRowStart dispImRowEnd])
        set(ax5, 'view',[90 -90],'xticklabel', [] )
    end

%% BACK TO MAIN FUNCTION



% find the handle of the histogram and make disable hittest so that data
% cursor is inactive when clicked
hist_h = findobj(ax2, 'type', 'patch');
set(hist_h, 'hittest', 'off')

% find image on fh2 and set it to colormap hot
colormap(hot)


% normalize all components so that resizing figure still looks good
list = allchild(fh2);
foundlist = findall(list, 'units', 'pixels');
    for n = 1:length(foundlist)
    set(foundlist(n), 'units', 'normalized')
    end

end % end for the main function

  

