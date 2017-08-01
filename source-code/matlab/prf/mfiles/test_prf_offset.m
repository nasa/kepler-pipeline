% assumes prfOffsetPattern.mat (or whatever) has been loaded
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
nDithers = length(prfOffsetCol);

raDec2PixModel = retrieve_ra_dec_2_pix_model();
raDec2PixObject = raDec2PixClass(raDec2PixModel, 'one-based');

dateMjd = datestr2mjd(startDate);
timePerDither = 1/48; % days at 30 minutes per dither
for i=1:nDithers
    % set the data time to be the first 15 minutes of a dither period
     endTimestamps(i) = dateMjd + (i-0.5)*timePerDither; % end of 15 minutes of period
%      endTimestamps(i) = dateMjd; % end of 15 minutes of period
end

[ra dec] = pix_2_ra_dec(raDec2PixObject, 13, 1, 1023, 1099, dateMjd);

[m o row col] = ra_dec_2_pix_absolute(raDec2PixObject, ...
    ra, ...
    dec, ...
    endTimestamps, ...
    prfRa, ...
    prfDec, ...
    prfRoll);
	
	
[m o relRow relCol] = ra_dec_2_pix_relative(raDec2PixObject, ...
    ra, ...
    dec, ...
    endTimestamps, ...
    prfRelativeRaOffset, ...
    prfRelativeDecOffset, ...
    0);

figure(2) ;
subplot(2,1,1) ;
plot(row-row(1),'r') ;
hold on
plot(relRow-relRow(1),'b') ;
subplot(2,1,2) ;
plot(col-col(1),'r') ;
hold on
plot(relCol-relCol(1),'b') ;

figure(1);
for i=1:length(prfRa)
	plot(row(1:i) - row(1), col(1:i) - col(1), '+', relRow(1:i) -relRow(1), relCol(1:i) - relCol(1), 'o');
	pause(0.5);
end

