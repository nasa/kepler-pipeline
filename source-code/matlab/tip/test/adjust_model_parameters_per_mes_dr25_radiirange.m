function os = adjust_model_parameters_per_mes_dr25_radiirange(is)
% function os = adjust_model_parameters_per_mes(is)
% 
% Move targets with MES > 100 and 80% of the targets with 20 < MES < 100
% into the 5 - 20 MES range by adjusting singleEventStatistic (SES) and planetRadius
%
% Move targets with MES < 3 and 80% of targets with 3 < MES < 5 into the
% 5-20 MES range by adjusting singleEventStatistics (SES) and planetRadius
%
% INPUTS:
% is        == output struct from read_simulated_transit_parameters( tipTextFilename )
% OUTPUT:
% os        == modified output struct
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

% copy input to output

tipRadii = importdata('tip_planetradiilimits.txt');
kIds = tipRadii(:,1);
newRandomRadii = (tipRadii(:,3)-tipRadii(:,2)).*rand(numel(kIds),1) + tipRadii(:,2);

os = is;

unitOfWorkDays = 4.25*365;

% extract parameters

[c, ia, ib] = intersect(kIds,is.keplerId);
tipIds = is.keplerId(ib);
period = is.orbitalPeriodDays(ib);
ses = is.singleEventStatistic(ib);
radius = is.planetRadiusREarth(ib);
depth = is.transitDepthPpm(ib);
Rp_Rs = is.RplanetOverRstar(ib);
nTargets = length(period);

kIds = kIds(ia);
theseRandomRadii = newRandomRadii(ia);

% seed updated ses and radius with existing values
%newSes = ses;
%newRadius = radius;
%newDepth = depth(ib) .* newSes ./ ses;
%newRp_Rs = Rp_Rs(ib) .* newRadius ./ radius;

int2div = (radius./theseRandomRadii).^2;
mrand = rand(numel(tipIds),1)>0.25;
newSes = ses(mrand)./int2div(mrand);
newRadius = theseRandomRadii(mrand);
newDepth = depth(mrand).*newSes./ses(mrand);
newRp_Rs = Rp_Rs(mrand).*newRadius./radius(mrand);

% update output
os.singleEventStatistic(mrand) = newSes;
os.planetRadiusREarth(mrand) = newRadius;
os.transitDepthPpm(mrand) = newDepth;
os.RplanetOverRstar(mrand) = newRp_Rs;