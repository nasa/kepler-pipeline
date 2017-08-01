function visualize_star_configuration_energy(nSamples, deviateNPixels, ...
    catalogRa, catalogDec, varargin)       
%**************************************************************************
% visualize_star_configuration_energy(catalogRa, catalogDec...
%    nSamples, deviateNPixels)        
%**************************************************************************
% Generate a scatter plot of weighting function values by purturbing the
% catalog positions one at a time. 
% 
% INPUTS
%     nSamples       : If an empty matrix is passed, nSamples defaults to
%                      5000.
%     deviateNPixels : If an empty matrix is passed, deviateNPixels 
%                      defaults to 7.
%     catalogRa      : 
%     catalogDec     :
%     restoringCoef
%     repulsiveCoef
%     noPenaltyRadius
%
% OUTPUTS
%     (none)
%
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

    degreesPerPixel = 0.001106;
    
    
    if isempty(nSamples)
        nSamples = 2000;
    end
    
    if isempty(deviateNPixels)
        deviateNPixels = 7;
    end
    
    nPoints = length(catalogRa);
    cmap = colormap(lines(nPoints));
    minWeight = 1e32;

    hold off
    legendLabels = {};
    for n = 1:nPoints
        weightArray = zeros(nSamples, 1);
        raArray     = zeros(nSamples, 1);
        decArray    = zeros(nSamples, 1);
        ra  = catalogRa;
        dec = catalogDec;
        for i = 1:nSamples
            ra(n)  = catalogRa(n)  + deviateNPixels * degreesPerPixel * 2 * (rand(1)  - 0.5);
            dec(n) = catalogDec(n) + deviateNPixels * degreesPerPixel * 2 * (rand(1)  - 0.5);
            raArray(i)  = ra(n);
            decArray(i) = dec(n);
            weightArray(i) = ...
                apertureModelClass.compute_source_configuration_energy( ...
                    ra, dec, catalogRa, catalogDec, varargin{:});
        end

        scatter3(raArray, decArray, weightArray, 'SizeData', 5^2, ...
            'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', cmap(n, :));
        hold on
        minWeight = min([minWeight; weightArray(:)]);
%        legendLabels(end+1) = {num2str(starArray(n).keplerId)};
        legendLabels(end+1) = {sprintf('star %d', n)};
    end
    scatter3(catalogRa, catalogDec, minWeight*ones(nPoints,1), 'SizeData', 20^2, ...
        'MarkerEdgeColor', [1 1 1], 'MarkerFaceColor', [0 0 0]);
    legendLabels(end+1) = {'Catalog Positions'};

    
    switch numel(varargin)
        case 1
            subtitleStr = sprintf('(Params: restoringCoef=%0.2e)', varargin{1});
        case 2
            subtitleStr = ...
                sprintf('(Params: restoringCoef=%0.2e, repulsiveCoef=%0.2e)', ...
                    varargin{1}, varargin{2});
        case 3
            subtitleStr = ...
                sprintf('(Params: restoringCoef=%0.2e, repulsiveCoef=%0.2e, noPenaltyRadius=%0.2e)', ...
                    varargin{1}, varargin{2}, varargin{3});
        otherwise
            subtitleStr = '(Params: DEFAULT)'; 
    end    
    
    title({'Weight as a Function of Sky Coordinate Configuration', subtitleStr});
    xlabel('Right Ascension');
    ylabel('Declination');
    zlabel('Weight');
    legend(legendLabels)

    hAxes = gca;
    h_title = get(hAxes,'Title');
    titleProperties  = struct(...
        'FontName',  'Arial', ...
        'FontUnits', 'points', ...
        'FontSize', 16, ...
        'FontWeight', 'bold' ...
    );
    set(h_title, titleProperties);


    h_xlab  = get(hAxes,'XLabel');
    h_ylab  = get(hAxes,'YLabel');
    h_zlab  = get(hAxes,'ZLabel');
    axisLabelProperties = struct(...
        'FontName',  'Arial', ...
        'FontUnits', 'points', ...
        'FontSize', 14, ...
        'FontWeight', 'bold' ...
        );
    set(h_xlab,  axisLabelProperties);
    set(h_ylab,  axisLabelProperties);
    set(h_zlab,  axisLabelProperties);
end

