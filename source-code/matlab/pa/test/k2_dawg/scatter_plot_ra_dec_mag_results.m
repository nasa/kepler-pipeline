function figHandle = scatter_plot_ra_dec_mag_results(raDecMagFitResults, plotVars)
%**************************************************************************
% figHandle = scatter_plot_ra_dec_mag_results(raDecMagFitResults, plotVars)
%**************************************************************************
% Plot results from the RA, dec, and magnitude fitting in PA-COA.
%
% INPUTS
%     raDecMagFitResults : An array of raDecMagFitResults structs,
%                          typically obtained from the root-level PA state
%                          file. 
%     plotVars           : A cell array of no less than two and no more
%                          than four of the following strings, specifying
%                          the variables to be plotted and the order of
%                          plotting:
%
%                          'r' : plot catalog right ascension.
%                          'd' : plot catalog declination.
%                          'f' : plot catalog total stellar flux.
%                          'm' : plot catalog Kepler magnitude.
%                          'n' : plot the number of stars in each star's aperture.
%                          'id' : plot Kepler ID.
%                          'dr' : plot change in right ascension.
%                          'dd' : plot change in declination.
%                          'df' : plot change in total stellar flux.
%                          'dm' : plot change in Kepler magnitude.
%                          'tb' : plot binary categories 'target' and
%                                 'background'
%
%                          The default array is {'dr', 'dd', 'id', 'm'}.
%     
% OUTPUTS
%     figHandle
%
% USAGE
%
%     To identify interesting stars and print their Kepler IDs to the
%     command window, do the following:
%
%     1) Include Kepler IDs in the variables to be plotted.
%
%        2D plot:
%        >> scatter_plot_ra_dec_mag_results(raDecMagFitResults, {'dr', 'id'})
%
%        3D plot:
%        >> scatter_plot_ra_dec_mag_results(raDecMagFitResults, {'dr', 'dd', 'id', 'm'})
%
%     2) Select data cursor mode from the figure menu or enable it from the
%        command line:
%        >> datacursormode on
%     3) Click on points of interest. If a valid Kepler ID is associated
%        with the point, it will be printed to the command window.
%
% NOTES
%   - Note that the change in RA is scaled by cos(dec) so that plots show
%     changes in RA and dec on roughy the same distance scale.
%
%   - A note about magnitude calculations: We use a reference magnitude
%     m0=12. The corresponding flux f0=214100 e-/sec (total flux from the
%     star) is stored in fcConstants fields of the PA input structure. The
%     functions mag2b() and b2mag() capture the following relationships:
% 
%         f/f0 = mag2b(m-m0)
%         m-m0 = b2mag(f/f0)
% 
%     Note that in PA pixel flux time series have units of e-/cadence.
%**************************************************************************   
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
    ARCSEC_PER_DEG = 3600;
    VAR_DESIGNATORS = '''r'', ''d'', ''f'', ''m'', ''n'', ''id'',''dr'', ''dd'', ''df'', ''dm'', ''tb''';
    TG_COLOR = 'r';
    BG_COLOR = [0 0.5 0.2];
    AXES_LABEL_FONT_SIZE = 12;
    TG_MARKER_SIZE = 300;
    BG_MARKER_SIZE = 30;

    if ~exist('plotVars', 'var')
        plotVars = {'dr', 'dd', 'id', 'm'};
    end
 
    nVars  = numel(plotVars);
    if nVars < 2 || nVars > 4
        error('Parameters ''plotVars'' must conatin 1-4 elements.');
    end
        
    % Extract the relavant data.        
    catalogRaDegrees  = colvec([raDecMagFitResults.catalogRaDegrees]);
    raDegrees         = colvec([raDecMagFitResults.raDegrees]);
    catalogDecDegrees = colvec([raDecMagFitResults.catalogDecDegrees]);
    decDegrees        = colvec([raDecMagFitResults.decDegrees]);
    catalogMag        = colvec([raDecMagFitResults.catalogMag]);
    keplerMag         = colvec([raDecMagFitResults.keplerMag]);
    kids              = colvec([raDecMagFitResults.keplerId]);
    
    tgIndicators = ...
        [raDecMagFitResults.keplerId] == [raDecMagFitResults.targetId];
    bgIndicators = ~tgIndicators;
    

    % Convert to magnitudes to estimated total flux (e-) from the star.
    % f/f0 = mag2b(m-m0)
    % fcConstants.TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND: 214100
    f0 = 214100;
    m0 = 12;
    fCatalog = f0 .* mag2b(catalogMag - m0);
    fFitted  = f0 .* mag2b(keplerMag  - m0);
    
    scrsz = get(0,'ScreenSize');
    figHandle = figure('Position',[1 scrsz(4) 0.4*scrsz(3) scrsz(4)], 'color', 'white');    
    cmap = jet;

    % 
    tvars  = cell(nVars, 1);
    bvars  = cell(nVars, 1);
    labels = cell(nVars, 1);
    for iVar = 1:nVars
        switch plotVars{iVar}
            case 'r' % Plot catalog right ascension, scaling by cos(dec).
                tvars{iVar} = ARCSEC_PER_DEG * ...
                    catalogRaDegrees(tgIndicators) .* cos(catalogDecDegrees(tgIndicators)*pi/180);
                bvars{iVar} = ARCSEC_PER_DEG * ...
                    catalogRaDegrees(bgIndicators) .* cos(catalogDecDegrees(bgIndicators)*pi/180);
                labels{iVar} = 'Catalog RA (arcsec * cos(dec))';
            case 'd' % Plot catalog declination
                tvars{iVar} = ARCSEC_PER_DEG * catalogDecDegrees(tgIndicators);
                bvars{iVar} = ARCSEC_PER_DEG * catalogDecDegrees(bgIndicators);
                labels{iVar} = 'Catalog dec (arcsec)';
            case 'f' % Plot catalog flux
                tvars{iVar} = fCatalog(tgIndicators);
                bvars{iVar} = fCatalog(bgIndicators);
                labels{iVar} = 'Catalog Flux (e-)';   
            case 'm' % Plot catalog magnitude
                tvars{iVar} = catalogMag(tgIndicators);
                bvars{iVar} = catalogMag(bgIndicators);
                labels{iVar} = 'Catalog kepMag';   
            case 'n' % plot the number of stars in each star's aperture.
                % NOT YET IMPLEMENTED
            case 'id' % Plot Kepler ID
                tvars{iVar} = kids(tgIndicators);
                bvars{iVar} = kids(bgIndicators);
                labels{iVar} = 'Kepler ID';   
            case 'dr' % Plot change in right ascension, scaling by cos(dec).
                tvars{iVar} = ARCSEC_PER_DEG * ...
                    (raDegrees(tgIndicators) - catalogRaDegrees(tgIndicators)) .* cos(catalogDecDegrees(tgIndicators)*pi/180);
                bvars{iVar} = ARCSEC_PER_DEG * ...
                    (raDegrees(bgIndicators) - catalogRaDegrees(bgIndicators)) .* cos(catalogDecDegrees(bgIndicators)*pi/180);
                labels{iVar} = '\Delta RA (arcsec * cos(dec))';
            case 'dd' % Plot change in declination
                tvars{iVar} = ARCSEC_PER_DEG * (decDegrees(tgIndicators) - catalogDecDegrees(tgIndicators));
                bvars{iVar} = ARCSEC_PER_DEG * (decDegrees(bgIndicators) - catalogDecDegrees(bgIndicators));
                labels{iVar} = '\Delta dec (arcsec)';
            case 'df' % Plot change in flux
                tvars{iVar} = fFitted(tgIndicators) - fCatalog(tgIndicators);
                bvars{iVar} = fFitted(bgIndicators) - fCatalog(bgIndicators);
                labels{iVar} = '\Delta Flux (e-)';   
            case 'dm' % Plot change in magnitude
                tvars{iVar} = keplerMag(tgIndicators) - catalogMag(tgIndicators);
                bvars{iVar} = keplerMag(bgIndicators) - catalogMag(bgIndicators);
                labels{iVar} = '\Delta kepMag';   
            case 'tb' % Plot plot binary categories 'target' and 'background'
                tvars{iVar} = ones( nnz(tgIndicators), 1);
                bvars{iVar} = zeros(nnz(bgIndicators), 1);
                labels{iVar} = 'Target=1 / Background=0';   
            otherwise
                error('Unrecognized variable designator. Must be one of ''%s.''', ...
                    VAR_DESIGNATORS);
        end
    end
        
    if nVars < 3
        nVars = nVars + 1;
        tvars{nVars} = TG_COLOR;
        bvars{nVars} = BG_COLOR;
    end
    
    switch nVars
        case 3
            % , 'ButtonDownFcn', print_target_id
            scatter(tvars{1}, tvars{2}, TG_MARKER_SIZE, tvars{3}, ...
                'Marker', 'x', 'LineWidth', 4);
            hold on
            scatter(bvars{1}, bvars{2}, BG_MARKER_SIZE, bvars{3},...
                'Marker', 'o', 'LineWidth', 2);  
            
            % Add a color bar if we are color-coding one of the variables.
            if size(tvars{3}, 1) > 1 || size(bvars{3}, 1) > 1
                colormap(cmap);
                hcb = colorbar;
            end
            
            xlabel(labels{1}, 'FontSize', AXES_LABEL_FONT_SIZE);
            ylabel(labels{2}, 'FontSize', AXES_LABEL_FONT_SIZE);
        case 4
            scatter3(tvars{1}, tvars{2}, tvars{3}, TG_MARKER_SIZE, tvars{4}, 'Marker', 'x', 'LineWidth', 4);
            hold on
            scatter3(bvars{1}, bvars{2}, bvars{3}, BG_MARKER_SIZE, bvars{4}, 'Marker', 'o', 'LineWidth', 2);
            
            % Add a color bar if we are color-coding one of the variables.
            if size(tvars{3}, 1) > 1 || size(bvars{3}, 1) > 1
                colormap(cmap);
                hcb = colorbar;
            end
            
            xlabel(labels{1}, 'FontSize', AXES_LABEL_FONT_SIZE)
            ylabel(labels{2}, 'FontSize', AXES_LABEL_FONT_SIZE);
            zlabel(labels{3}, 'FontSize', AXES_LABEL_FONT_SIZE);
        otherwise
            error('Invalid number ov variables: %d', nVars);
    end
    
    % Enable interactive printing of Kepler IDs, if they are among the
    % variables being plotted.
    if strcmpi('id', plotVars)
        dcm_obj = datacursormode(figHandle);
        set(dcm_obj, 'UpdateFcn', @scatter_plot_callback);
    end
    
    title( sprintf('RA/Dec/Mag Fitting Results'), ...
        'FontSize', 14, 'FontWeight', 'bold' );
    legAxes = legend({'Target Stars', 'Background Stars'});
    leg = findobj(legAxes,'type','text');
    set(leg,'FontSize',10);
    
    % Label the colorbar, if it exists.
    if exist('hcb', 'var')
        colorTitleHandle = get(hcb,'Title');
        titleString = labels{end};
        set(colorTitleHandle ,'String',titleString);
    end
    
    grid on

end

function output_txt = scatter_plot_callback(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

    pos = get(event_obj,'Position');
    
    % Print KID to the command window, if it is plotted here.
    validKids = is_valid_id(pos);
    if any(validKids)
        fprintf('%d\n', pos(find(validKids, 1, 'first')));
    end
    
    output_txt = {['X: ',num2str(pos(1),4)],...
        ['Y: ',num2str(pos(2),4)]};

    % If there is a Z-coordinate in the position, display it as well
    if length(pos) > 2
        output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
    end
end

%********************************** EOF ***********************************