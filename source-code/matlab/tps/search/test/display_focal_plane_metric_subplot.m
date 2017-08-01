function [hfig] = display_focal_plane_metric_subplot(metric,textOnFlag,s1,s2,s3,titleString)
% function [hfig] = display_focal_plane_metric(metric,textOnFlag)
%
% Plots a focal plane image of a given metric (one value per mod/out)
%
% Inputs:
%   metric: vector of 84 values
%   textOnFlag: optional flag to indicate metric values should be written
%       in mod/out squares as text
%   subplot indices s1, s2, s3
% Outputs:
%   hfig: figure handle of resulting plot
% 
% Code was stolen from plot_pdq_encircled_energy_contour_on_focal_plane.m
% written by H. Chandrasekaran for PDQ
% revised by JVC to accomodate possibly bad mod 3 data
% either 80 inputs or fill 
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
nModOuts = 84;

if(length(metric) == 84);
    
    metric(5:8) = median(metric([1:4 9:84]));
    
end


if (length(metric) == 80);
    
    temp = [metric(1:4); repmat(min(metric),4,1); metric(5:80)];
    metric = temp;
    
end

%
% Get all CCD module outputs in sequence.
[modules, outputs] = convert_to_module_output(1: nModOuts);

southWestCoordinates = zeros(2,1);

if nargin<2
    textOnFlag=false;
end

%-----------------------------------------------------------------------------
% get the coordinates of NW, SE corner to reposition the origin at NW corner; the function
% morc_to_focal_plane_coords puts the origin at the center
%-----------------------------------------------------------------------------

for iModOut = 1 : nModOuts

    % Get the CCD module and output.
    module = modules(iModOut);
    output = outputs(iModOut);

    % Get the edges of the mod out in MORC coordinates.  The rows go from 0
    % to 1043, so the edges of the mod out are rows -0.5 to 1043.5.
    % Similarly, the edges of the true mod out in column space are at column
    % 11.5 (outermost edge of column 12, since columns 0 to 11 don't actually
    % exist) and 1111.5.
    modlist = repmat(module, [1, 4]);
    outlist = repmat(output, [1, 4]);
    rowlist = [-0.5 1043.5 1043.5 -0.5];
    collist = [11.5 11.5 1111.5 1111.5];

    % Convert the MORC coordinates of the mod out to the global focal plane
    % coordinates.
    [z, y] = morc_to_focal_plane_coords(modlist, outlist, ...
        rowlist, collist, 'one-based');

    if(min(z) < southWestCoordinates (1))
        southWestCoordinates (1) = min(z);
    end
    if(min(y) < southWestCoordinates (2))
        southWestCoordinates (2) = min(y);
    end


end

%-----------------------------------------------------------------------------
% create a scaled version of the focal plane
%-----------------------------------------------------------------------------

focalPlaneSide = ceil(abs(southWestCoordinates(1))/100) + 2 ;
focalPlane = zeros(2*focalPlaneSide, 2*focalPlaneSide);
focalPlane(:) = NaN;

% Loop throught all module outputs.

for iModOut = 1 : nModOuts


        % Get the CCD module and output.
        module = modules(iModOut);
        output = outputs(iModOut);

        % Convert the MORC coordinates of the mod out to the global focal plane
        % coordinates.

        rows = (100:100:1000)';
        cols = (100:100:1000)';

        modlist = repmat(module, length(rows), 1);
        outlist = repmat(output, length(rows),1);

        [z, y] = morc_to_focal_plane_coords(modlist, outlist, rows, cols, 'one-based');

        focalPlane(round(y./100- southWestCoordinates(1)/100 + 4), ...
            round(z./100 - southWestCoordinates(2)/100 + 4)) = metric(iModOut);

end

%-----------------------------------------------------------------------------
% plot encircled energy over the entire focal plane
%-----------------------------------------------------------------------------

%hfig = figure;
colormap hot

subplot(s1,s2,s3)
imagesc(focalPlane);
colorbar;
title(titleString)
set(gca,'XTickLabel',[],'YTickLabel',[]);

if textOnFlag
    for iModOut = 1:nModOuts
        % Get the CCD module and output.
        module = modules(iModOut);
        output = outputs(iModOut);

        % Convert the MORC coordinates of the mod out to the global focal plane
        % coordinates.

        rows = (100:100:1000)';
        cols = (100:100:1000)';

        modlist = repmat(module, length(rows), 1);
        outlist = repmat(output, length(rows),1);

        [z, y] = morc_to_focal_plane_coords(modlist, outlist, rows, cols, 'one-based');

        text(round(z(5)./100- southWestCoordinates(1)/100 + 4), ...
            round(y(5)./100 - southWestCoordinates(2)/100 + 4),...
            sprintf('%0.3g',metric(iModOut)),'Color',[0,0.7,0.7]);
    end

end
axis xy



return
end
