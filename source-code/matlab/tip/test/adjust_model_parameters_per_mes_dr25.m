function os = adjust_model_parameters_per_mes_dr25(is)
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
os = is;

unitOfWorkDays = 4.25*365;

% extract parameters
period = is.orbitalPeriodDays;
ses = is.singleEventStatistic;
radius = is.planetRadiusREarth;
depth = is.transitDepthPpm;
Rp_Rs = is.RplanetOverRstar;
nTargets = length(period);

% seed updated ses and radius with existing values
newSes = ses;
newRadius = radius;

nTransitsFractional = unitOfWorkDays ./ period;
MES = sqrt(nTransitsFractional) .* ses;

% generate random MESes in 5 - 20 range
randomMes5to20 = 15.*rand(nTargets,1) + 5;

% factor to divide MES by to place it in 5 - 20 range
% This is also the factor to divide SES by
%int2div = ceil( MES ./ randomMes5to20 );
%int2divlo = ceil ( randomMes5to20 ./ MES );
int2div = ones(numel(MES),1);
int2div(MES>0) = MES(MES>0) ./ randomMes5to20(MES>0);

% set up logical indices
% MES > 100
m100 = MES > 100;
% 80% of MES > 20 but < 100
m20 = ~m100 & MES > 20 & rand(nTargets,1) > 0.2;
% MES < 3
m3 = MES < 3;
% 80% of MES > 3 but < 5
m5 = ~m3 & MES < 5 & rand(nTargets,1) > 0.2;

% calculate updated ses and radius for all targets in temporary space
tempSes = ses./int2div;
tempRad = radius./sqrt(int2div);
%tempSesLo = ses.*int2divlo;
%tempRadLo = radius.*sqrt(int2divlo);

% apply the updates to only the cases elected by the logical indices
newSes(m100) = tempSes(m100);
newSes(m20)  = tempSes(m20);
newSes(m3) = tempSes(m3);
newSes(m5) = tempSes(m5);
newRadius(m100) = tempRad(m100);
newRadius(m20)  = tempRad(m20);
newRadius(m3) = tempRad(m3);
newRadius(m5) = tempRad(m5);

newMES = sqrt(nTransitsFractional) .* newSes;


% % the logical indices above can be used to replace this loop
% for i = 1:nTargets
%     if MES(i) > 100        
%         newSes(i) = ses(i)/int2div(i);
%         newRadius(i) = radius(i)/sqrt(int2div(i));
%     else
%         if MES(i) > 20 && rand(1) > 0.2
%             newSes(i) = ses(i)/int2div(i);
%             newRadius(i) = radius(i)/sqrt(int2div(i));
%         end
%     end
% end

% adjust parameters which depend on ses and planet radius
newDepth = depth .* newSes ./ ses;
newRp_Rs = Rp_Rs .* newRadius ./ radius;

% update output
os.singleEventStatistic = newSes;
os.planetRadiusREarth = newRadius;
os.transitDepthPpm = newDepth;
os.RplanetOverRstar = newRp_Rs;
