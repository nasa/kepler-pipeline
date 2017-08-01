% compute flux of mag 12 star in electrons/exposure
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
modules = [2:4 6:20 22:24];

fluxOfMag12Star = 2.34E+05; % flux of a 12th magnitude start in e-/sec
integrationTime = 6.12361; % seconds
mag12StarFluxPerExposure = fluxOfMag12Star*integrationTime;

runStartMjd = datestr2mjd('23-Dec-2010 12:00:00');
runEndMjd = runStartMjd + 1;

gainObject = gainClass(retrieve_gain_model(runStartMjd, runEndMjd));

fid = fopen('saturation_estimate.txt', 'w');

maxFractionInCentralPixel = 0.6375; % based on best focus PRF based on code 5 PSF
% maxFractionInCentralPixel = 0.230; % based on worst focus PRF based on code 5 PSF

maxPerPixelFluxMag12 = mag12StarFluxPerExposure*maxFractionInCentralPixel;

fprintf(fid, 'assumes %g of flux falls on brightest pixel\n', maxFractionInCentralPixel);
fprintf(fid, 'integration time: %g seconds\n', integrationTime);
maxMagnitude = 0;
channel = 1;
for m=1:length(modules)
    for output=1:4
        module = modules(m);
        linearityObject = linearityClass(retrieve_linearity_model( ...
            runStartMjd, runEndMjd, module, output));
        
%         flatObject = flatFieldClass(retrieve_flat_field_model(module, output));
%         flat = get_flat_field(flatObject, runStartMjd);
%         meanFlat = mean(mean(flat));

        %
        % first compute the well depth
        %
        gain = get_gain(gainObject, runStartMjd, module, output);        
        polyStruct = get_weighted_polyval_struct(...
            linearityObject, runStartMjd, module, output);
        % get the cutoff value in DN
        maxDnPerExposure = double(get_max_domain(...
            linearityObject, runStartMjd, module, output));
        % convert the cutoff value to electrons
        wellDepth = maxDnPerExposure .* gain ...
            .* weighted_polyval(maxDnPerExposure, polyStruct);
		disp(['module ' num2str(module) ' output ' num2str(output) ...
			' wellDepth = ' num2str(wellDepth) ', linear depth gain*maxDnPerExposure = ' ...
			num2str(gain*maxDnPerExposure) ' nonlinear/linear = ' num2str(wellDepth/(gain*maxDnPerExposure))]);
        
        % now compute the magnitude that will hit that well depth
        % get the 2D bias
        blackObject = twoDBlackClass(...
            retrieve_two_d_black_model(module, output, runStartMjd, runEndMjd));
        blackArrayAdu = get_two_d_black(blackObject, runStartMjd);
        % get the max value
        maxBlackAdu = max(max(blackArrayAdu));
        % convert to electrons
        maxBlackElectrons = maxBlackAdu .* gain ...
            .* weighted_polyval(maxBlackAdu, polyStruct);
        
        saturationMagnitude = -2.5*log10( ...
            (wellDepth - maxBlackElectrons)/(maxPerPixelFluxMag12)) + 12;
        maxMagnitude = max([maxMagnitude, saturationMagnitude]);
        
        fprintf(fid, ...
            ['module %d output %d channel %d, well Depth = %0.4g e-, max bias %g e-, ' ...
            'safe unsaturated magnitude: %0.2f\n'], ...
            module, output, channel, wellDepth, maxBlackElectrons, saturationMagnitude);
        
        channel = channel + 1;
    end
end
fprintf(fid, 'safe unsaturated magnitude across FOV:= %0.2f\n', maxMagnitude);

fclose(fid);
