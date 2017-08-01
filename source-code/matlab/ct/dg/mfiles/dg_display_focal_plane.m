function  dg_display_focal_plane(fpDisplayStruct, ffiName)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dg_display_focal_plane(fpDisplayStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% displays the focal plane image using information from fpDisplayStruct
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%             
%   fpDisplayStruct, a struct with 21 entries with the following fields-
%
%               module: [int] module number
%              fpCoord: vector[z y] focal plane coordintes of the bottom 
%                       left output at pixel 1,1
%            binFactor: [int] bin factor of the input binnedStarImage
%          moduleImage: [single] image with 4 outputs put together in the
%               correct orientation with gaps filled in and correct
%               rotation
%
%    ffiName: [ string ] name of fits file
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS: a figure image of the focal plane
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% define the outmost edge of CCD in focal plane
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
fpSpan = 5903 * 2;  % note this will always be an even number

% create focal plane grid, note rows = cols b/c symmetry
fpRow = floor(fpSpan/fpDisplayStruct(1).binFactor);

% make a focal plane that is in reality 12000 x 12000 pixels and 
% preallocate zeros for the focal plane
%numRow = 12000/fpDisplayStruct(1).binFactor;axis

fp = zeros(fpRow, fpRow);
modTag = zeros(fpRow, fpRow);
outTag= zeros(fpRow, fpRow);

% place each module in the big grid
for nMod = 1:21

    fpCoord= ceil((fpDisplayStruct(nMod).fpCoord)/(fpDisplayStruct(nMod).binFactor) + fpRow/2) +1;
    
    [r c] = size(fpDisplayStruct(nMod).moduleImage);
    
    fp(fpCoord(2):fpCoord(2) + r - 1, fpCoord(1) : fpCoord(1) + c - 1) ...
        = fpDisplayStruct(nMod).moduleImage;

    modTag(fpCoord(2):fpCoord(2) + r - 1, fpCoord(1) : fpCoord(1) + c - 1) ...
        = fpDisplayStruct(nMod).moduleLabel;
    
    outTag(fpCoord(2):fpCoord(2) + r - 1, fpCoord(1) : fpCoord(1) + c - 1) ...
        = fpDisplayStruct(nMod).outputLabel;


end

limits= size(modTag);
rowMax =limits(2);
colMax =limits(1);

% create structure for storing gui_data
gui_data.modTag = modTag; % an array
gui_data.outTag = outTag; % an array
gui_data.rowMax = rowMax; % maximum number of rows
gui_data.colMax = colMax; % ditto
gui_data.modLabel = 0;
gui_data.outLabel = 0;
gui_data.fh2 = 0; % initialize to no second figure
gui_data.ax1 = 0;
gui_data.ax2 = 0;
gui_data.ax3 = 0;
gui_data.image = [];

fh1 = figure('position', [29 500 560 420]); % create figure for fp
imagesc(log10(fp));
colormap(hot)
set(gca, 'ydir', 'normal', 'xtick', [], 'ytick', [])
set(gcf, 'numbertitle', 'off', 'name', 'Focal Plane Display');

% save stucture in using guidata
guidata(fh1, gui_data);

% start gui calling the subfunction
subfunction_display_fp;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function subfunction_display_fp
        % create text object
        ht =text('parent', gca, ...
            'color', 'w', ...
            'horizontalalignment', 'left', ...
            'verticalalignment', 'bottom', ...
            'tag', 'here');

        set(fh1,'Interruptible','off', ...
            'DoubleBuffer', 'on',...
            'WindowButtonMotionFcn', @move_mouse_callback,...
            'windowButtonDownFcn', @mouse_click_callback);
  
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        function move_mouse_callback(obj, evd)
            persistent modLabel outLabel
            % retrieve guidata
            gui_data = guidata(fh1);



            cp = round(get(gca, 'currentpoint')); % current mouse position
            row =cp(1,2);
            col =cp(1,1);

            if  row>=1 && col>=1 && row <= gui_data.rowMax && col <= gui_data.colMax

                modLabel = modTag(row, col);
                outLabel = outTag(row, col);

                if modLabel ~= 0 && outLabel ~=0
                    set(ht, 'position', [col row], ...
                        'string', sprintf('module %d\n output %d', modLabel, outLabel))
                    gui_data.modLabel = modLabel;
                    gui_data.outLabel = outLabel;
                else
                    set(ht, 'position', [col row], 'string', '')
                end
            end

            % save gui_data
            guidata(fh1, gui_data);

        end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        function mouse_click_callback(obj, evd)
            
            % retrieve guidata
            gui_data = guidata(fh1);
            fh2 = gui_data.fh2;
            ax1 = gui_data.ax1;
            ax2 = gui_data.ax2;
            ax3 = gui_data.ax3;
            modLabel = gui_data.modLabel; display(modLabel)
            outLabel = gui_data.outLabel; display(outLabel)
            
            % initialize figure
            ffiName ='/path/to/goodData.fits';
            table = prepare_for_fitsread(ffiName);
            image = fitsread_check_modout(ffiName, modLabel, outLabel, table);
            
            if gui_data.fh2 == 0
                fh2 = figure( 'position', [ 375   108   580   900] );
                ax1 = axes('units', 'pixels', 'position', [ 40 520 350 350],'parent', fh2);
                ax2 = axes('units', 'pixels', 'position', [ 40 280 350 185], 'parent', fh2);
                ax3 = axes('units', 'pixels', 'position', [ 40 40 350 185], 'parent', fh2);

            end
            set(fh2, 'numbertitle', 'off', 'name', sprintf('%s, module %d, output %d', ffiName, modLabel, outLabel));
            
            if modLabel ~= 0 && outLabel ~= 0
  


            % intilize ax1 data
            figure(fh2)
            imagesc(log10(image), 'parent', ax1); colormap(hot);
            set(ax1, 'ydir', 'normal');

            % initialize zoom
            hz1 = zoom;
            set(hz1, 'actionpostcallback', @zoomcallback);
            set(hz1, 'enable', 'on')
            
            
            % initialize histogram on ax2
            bin = 20;
            hist(image(:), bin, 'parent', ax2);
            setAllowAxesZoom(hz1, ax2, false);
            
            % initialize scatter plot on ax3
            
            semilogy(image(:), '.b','parent', ax3);
            setAllowAxesZoom(hz1, ax3, false);
            end
            
            set(ax1, 'units', 'normalized');
            set(ax2, 'units', 'normalized');
            set(ax3, 'units', 'normalized');
            
            gui_data.fh2 =fh2;
            gui_data.ax1 = ax1;
            gui_data.ax2 = ax2;
            gui_data.ax3 =ax3;
            gui_data.image = image;
            guidata(fh1, gui_data);
            figure(fh1) % return control to fp display
        end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function zoomcallback(obj, evd)
   
gui_data = guidata(fh1); % retrieve guidata

ax2 = gui_data.ax2; display(ax2)
ax3 = gui_data.ax3;
image = gui_data.image;


newXLim  = get(evd.Axes,'XLim'); 
newYLim =get(evd.Axes,'YLim');


xMin = round(newXLim(1)); display(xMin)
xMax = round(newXLim(2));
yMin = round(newYLim(1));
yMax = round(newYLim(2));

zoomimage = image(xMin:xMax, yMin:yMax);

% redraw histotram using data within xMin, xMax, yMin, yMax
bin =20; % must give a bin option button for user initial one too
hist(zoomimage(:), bin, 'parent', ax2);

% setAllowAxesZoom(hz1,ax2,false); % disable zoom callback for ax2


% replot scatter plot using data within xMin, xMax, yMin, yMax
semilogy(zoomimage(:), '.b','parent', ax3);

% setAllowAxesZoom(hz1,ax3,false); % disable zoom callback for ax2

guidata(fh1, gui_data);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    end       
end

