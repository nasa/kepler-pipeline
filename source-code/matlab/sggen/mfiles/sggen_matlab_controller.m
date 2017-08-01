function outputStruct = sggen_matlab_controller(inputStruct)
% function outputStruct = sggen_matlab_controller(inputStruct)
%
% This function implements the sggen pipeline module
%
% INPUTS:
%     inputStruct:
%         raDec2PixModel    A valid raDec2PixModel.
%         mjd               The MJD.
%         stars             A vector of structs, with fields:
%             keplerId          The Kepler ID of this star.
%             ra                The right ascension of the star (in HOURS).
%             dec               The declination of the star (in degrees).
%
% OUTPUTS:
%     outputStruct:
%         stars            A vector of structs, length(inputStruct.stars) long, with fields:
%             keplerId         The Kepler ID of this star.
%             ra               The right ascension of this star (in HOURS).
%             dec              The declination of this star (in degrees).
%             ccdModule        The CCD module that this star falls on for the MJD.
%             ccdOutput        The CCD output that this star falls on for the MJD.
%             ccdRow           The CCD row that this star falls on for the MJD.
%             ccdColumn        The CCD column that this star falls on for the MJD.
%
%
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

disp('sggen_matlab_controller START');

numStars = length(inputStruct.stars);

outputStruct.stars = repmat(struct('keplerId', [], 'ra', [], 'dec', [],...
    'ccdModule', [], 'ccdOutput', [], 'ccdRow', [], 'ccdColumn', []), numStars, 1);

raDec2PixObject = raDec2PixClass(inputStruct.raDec2PixModel, 'zero-based');

[mod out row col] = ra_dec_2_pix(raDec2PixObject, [inputStruct.stars.ra] * 15, [inputStruct.stars.dec], inputStruct.mjd);

for i = 1:numStars
    outputStruct.stars(i).keplerId = inputStruct.stars(i).keplerId;
    outputStruct.stars(i).ra       = inputStruct.stars(i).ra;
    outputStruct.stars(i).dec      = inputStruct.stars(i).dec;
    outputStruct.stars(i).ccdModule = mod(i);
    outputStruct.stars(i).ccdOutput = out(i);
    outputStruct.stars(i).ccdRow    = row(i);
    outputStruct.stars(i).ccdColumn = col(i);
end

disp('sggen_matlab_controller END');
return;
