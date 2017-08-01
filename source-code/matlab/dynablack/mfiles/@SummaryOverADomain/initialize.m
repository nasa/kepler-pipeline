%% initialize 
% Method for a SummaryOverADomain class object initialization. 
%
%   Revision History:
%
%       Version 0 - 2/12/10   released for review and comment
%       Version 1 - 4/19/10   Modified classes for pre-MATLAB V7.6
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
%
%%
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
function obj = initialize( obj, domain, data )
%% ARGUMENTS
% 
% * Function returns: obj - the object of class SummaryOverADomain.
% * Function arguments:
% * |obj    -| the object
% * |domain -| domain values for each data point
% * |data   -| data to be summarized with regard to specified domain
%
%% CODE
%

is_2D=(size(data,2)>1) & (size(unique(domain,'rows'),1)==1);

if is_2D ,
    datum_means  = mean(data,1);
    datum_stDevs = std(data,1);
end

for k=1:obj.count

    subdata     =   data(domain==obj.domain_list(k));

    obj.dataSummary.means(k)    = mean(subdata);
    obj.dataSummary.medians(k)  = median(subdata);
    obj.dataSummary.q16(k)      = quantile(subdata, 0.16);
    obj.dataSummary.q84(k)      = quantile(subdata, 0.84);
    obj.dataSummary.q0013(k)    = quantile(subdata, 0.0013);
    obj.dataSummary.q9987(k)    = quantile(subdata, 0.9987);
    obj.dataSummary.stDev(k)    = std(subdata);

    if is_2D ,
        subindex     =   domain(1,:)==obj.domain_list(k);
        if sum(1.0*subindex(:))>1
            obj.dataSummary.stDevofDatumMeans(k)=std(datum_means(subindex));
            obj.dataSummary.rmsofDatumStDevs(k)=sqrt(mean(datum_stDevs(subindex).^2));
        end
    end

end


return

end