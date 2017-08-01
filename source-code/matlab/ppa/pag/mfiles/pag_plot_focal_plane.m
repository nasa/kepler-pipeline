function pag_plot_focal_plane(nModOuts, rowlist, collist)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pag_plot_focal_plane(nModOuts, rowlist, collist)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This fuction plots focal plane for PAG reports.
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

% Get all CCD module outputs in sequence.
[modules, outputs] = convert_to_module_output(1: nModOuts);

% Loop throught all module outputs.
for iModOut = 1 : nModOuts

    % Get the CCD module and output.
    module  = modules(iModOut);
    output  = outputs(iModOut);
    modlist = repmat(module, [1, 4]);
    outlist = repmat(output, [1, 4]);

    % Convert the MORC coordinates of the mod out to the global focal plane coordinates.
    [z, y] = morc_to_focal_plane_coords(modlist, outlist, rowlist, collist, 'one-based');

    % Use convhull to order the box edges.
    pointIndex = convhull(z,y);

    % Set the grid for displaying the state of the metrics within each mod out.
    zg = min(z) + (max(z)-min(z)) * (0:3)/3;
    yg = min(y) + (max(y)-min(y)) * (0:4)/4;

    % Plot the bounding box for the mod out, with dashed lines to demarcate the metric grid.
    plot(z(pointIndex), y(pointIndex), 'k', 'LineWidth', 1);
    hold on

    plot([zg(2), zg(2)], [yg(1), yg(5)], '--k');
    plot([zg(3), zg(3)], [yg(1), yg(5)], '--k');
    plot([zg(1), zg(4)], [yg(2), yg(2)], '--k');
    plot([zg(1), zg(4)], [yg(3), yg(3)], '--k');
    plot([zg(1), zg(4)], [yg(4), yg(4)], '--k');

    text((2*zg(2)+1*zg(3))/3, (1*yg(2)+1*yg(3))/2, [num2str(module), ', ', num2str(output)], 'FontSize', 5);

end % for iModOut

return

