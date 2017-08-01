function [v0data, midx, midy] = get_v0_contour_data(keplerId)

% File name
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
v0Dir = '/codesaver/work/transit_injection/v0_contour_data/';
% v0 contour data was created by Chris Burke and comes from /path/to/4JCat/v0/ 
% Option to make v0 contour plot
doPlots = false;

% Convert the keplerId(double) into a KIC string with 9 characters, including leading zeros
KICstringTmp = num2str(keplerId);
nLeadingZeros = 9 - length(KICstringTmp);
KICstring = strcat(repmat('0',1,nLeadingZeros),KICstringTmp);

% Path to v0 data file
% file = strcat(v0Dir,'detgridsV0','003114789_det.fits.gz');
file = strcat(v0Dir,'detgridsV0',KICstring,'_det.fits.gz');

% gunzip file
comstr=sprintf('gunzip %s',file);
system(comstr);

% Read header information
info=fitsinfo(file(1:end-3));

% Read data 
v0data=fitsread(file(1:end-3));
% gzip file back
comstr=sprintf('gzip %s',file(1:end-3));
system(comstr);

% Get the period spacing
minx=info.PrimaryData.Keywords{7,2};
maxx=info.PrimaryData.Keywords{8,2};
nx=info.PrimaryData.Keywords{9,2};
midx=linspace(minx,maxx,nx);

% Get Rp spacing
miny=info.PrimaryData.Keywords{10,2};
maxy=info.PrimaryData.Keywords{11,2};
ny=info.PrimaryData.Keywords{12,2};
midy=linspace(log10(miny),log10(maxy),ny);

% Get meshgrids for plot
[midx2d midy2d]=meshgrid(midx,midy);

% Make contour plot
if(doPlots)
    [~,h]=contourf(midx2d,midy2d,v0data,[0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0],'ShowText','on');
    caxis([0.0,1.0]);
    colorbar
end
