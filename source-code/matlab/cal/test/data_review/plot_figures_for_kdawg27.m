function plot_figures_for_kdawg27()
%
% channel = 18;
%
% cd /path/to/pipeline_results/science_q2/q2_archive_ksop516/lc/cal-matlab-2376-88285
% load cal-outputs-1.mat
% 
% targetOutputs         = [outputsStruct.targetAndBackgroundPixels.values];
% uncertaintiesOutputs  = [outputsStruct.targetAndBackgroundPixels.uncertainties];
% uncertaintiesGaps     = [outputsStruct.targetAndBackgroundPixels.gapIndicators];
% uncertaintiesRows     = [outputsStruct.targetAndBackgroundPixels.row];
% uncertaintiesCols     = [outputsStruct.targetAndBackgroundPixels.column];
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

% targetOutputs(uncertaintiesGaps) = nan;
% uncertaintiesOutputs(uncertaintiesGaps) = nan;



figure;

%h1 = subplot(2,1,1);
plot(uncertaintiesOutputs)

title(['Output Uncertainties for Channel ' num2str(channel) ' Invocation 1'])
xlabel('Cadence Index')
ylabel('Flux Uncertainty (e-/cadence)')

plot_to_file(['/path/to/matlab/cal/test/kdawg27/output_uncert_' num2str(channel) '_invoc1'], false);

 
figure
%h2 = subplot(2,1,2);
plot(targetOutputs)

title(['Output Pixel Values for Channel ' num2str(channel) ' Invocation 1'])
xlabel('Cadence Index')
ylabel('Flux (e-/cadence)')

plot_to_file(['/path/to/matlab/cal/test/kdawg27/output_pixels_' num2str(channel) '_invoc1'], false);

%linkaxes([h1, h2], 'xy')

return;
   
