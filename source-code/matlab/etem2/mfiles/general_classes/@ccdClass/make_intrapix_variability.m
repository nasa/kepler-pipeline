function intraPixVariability = make_intrapix_variability(ccdObject, psfResolution)
% function intraPixVariability = make_intrapix_variability(wavelength,
% samplesPerPixel)
%
% wavelength has to be 500 nm or 800 nm
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

pixelWidth = get(ccdObject.runParamsClass, 'pixelWidth'); % pixel width is in microns
wavelength = get(ccdObject.runParamsClass, 'intrapixWavelength'); % wavelength in nm
samplesPerPixel = round(pixelWidth/psfResolution);

% Pick which model to use (in nanometers)
switch wavelength

    case 500

        rippleX = (1 - 0.025/1.1 + 0.025/1.1 * sin(0:1*pi/samplesPerPixel:1*pi-1*pi/samplesPerPixel) )';
        rippleY = (1 - 0.025/3.5 + 0.025/3.5 * sin(0:8*pi/samplesPerPixel:8*pi-8*pi/samplesPerPixel) );

    case 800

        rippleX = (1 - 0.08/2    + 0.08/2    * sin(0:1.1*pi/samplesPerPixel:1.1*pi-1.1*pi/samplesPerPixel) )';
        rippleY = (1 - 0.11/2    + 0.11/2    * sin(0:8.0*pi/samplesPerPixel:8.0*pi-8.0*pi/samplesPerPixel) );

    otherwise

        error('Incorrect wavelength value in ccdClass:make_intrapix_variability.m')

end

intraPixVariability = repmat(rippleY, samplesPerPixel, 1) .* repmat(rippleX, 1, samplesPerPixel);
intraPixVariability = intraPixVariability / mean(mean(intraPixVariability));  % Normalize to unit gain
