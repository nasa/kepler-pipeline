%% Monitored_Residuals 
% Class definition for a Monitored_Residuals class object. 
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
function obj = Monitored_Residuals( Inputs )
%% ARGUMENTS
% 
% * Function returns:  
% * |obj   -| an object of class Monitored_Residuals.
% * Function arguments:
% * |Inputs   -| input structure
% * Inputs.residuals
% * Inputs.lc_domain
% * Inputs.row_domain
% * Inputs.column_domain
% * Inputs.FGS_frame_domain
% * Inputs.FGS_parallel_domain
% * Inputs.description
%
%% CODE
%
datum_count         = size(Inputs.residuals,2);
lc_count            = size(Inputs.residuals,1);

lc_list             =sort(unique(Inputs.lc_domain));
row_list            =sort(unique(Inputs.row_domain));
column_list         =sort(unique(Inputs.column_domain));
FGS_frame_list      =sort(unique(Inputs.FGS_frame_domain));
FGS_parallel_list   =sort(unique(Inputs.FGS_parallel_domain));

obj.datum_count     = datum_count;
obj.lc_count        = lc_count;

obj.values                  = Inputs.residuals;
obj.lc_domain               = Inputs.lc_domain;
obj.row_domain              = Inputs.row_domain;
obj.column_domain           = Inputs.column_domain;
obj.FGS_frame_domain        = Inputs.FGS_frame_domain;
obj.FGS_parallel_domain     = Inputs.FGS_parallel_domain;

obj.description             = Inputs.description;

summaryOverLC               = SummaryOverADomain( lc_list, 'LC' );
obj.SummaryOverLC           = summaryOverLC;
obj.SummaryOverRow          = SummaryOverADomain( row_list, 'row' );
obj.SummaryOverColumn       = SummaryOverADomain( column_list, 'column' );
obj.SummaryOverFGSFrame     = SummaryOverADomain( FGS_frame_list, 'FGS frame clock state' );
obj.SummaryOverFGSParallel  = SummaryOverADomain( FGS_parallel_list, 'FGS parallel clock state' );

obj.SummaryOverLCbyRow          = repmat({summaryOverLC},obj.SummaryOverRow.count,1);
obj.SummaryOverLCbyColumn       = repmat({summaryOverLC},obj.SummaryOverColumn.count,1);
obj.SummaryOverLCbyFGSFrame     = repmat({summaryOverLC},obj.SummaryOverFGSFrame.count,1);
obj.SummaryOverLCbyFGSParallel  = repmat({summaryOverLC},obj.SummaryOverFGSParallel.count,1);

obj.SummaryOverLC           = initialize(obj.SummaryOverLC, obj.lc_domain, obj.values);
obj.SummaryOverRow          = initialize(obj.SummaryOverRow, obj.row_domain, obj.values);
obj.SummaryOverColumn       = initialize(obj.SummaryOverColumn, obj.column_domain, obj.values);
obj.SummaryOverFGSFrame     = initialize(obj.SummaryOverFGSFrame, obj.FGS_frame_domain, obj.values);
obj.SummaryOverFGSParallel  = initialize(obj.SummaryOverFGSParallel, obj.FGS_parallel_domain, obj.values);

for k=1:obj.SummaryOverRow.count
    index=(obj.row_domain==row_list(k));
    if sum(1.0*index(:))>0
        obj.SummaryOverLCbyRow{k}=initialize(obj.SummaryOverLCbyRow{k}, ...
                                         obj.lc_domain( index ), ...
                                         obj.values( index ) );
    end
end

for k=1:obj.SummaryOverColumn.count
    index=(obj.column_domain==column_list(k));
    if sum(1.0*index(:))>0
        obj.SummaryOverLCbyColumn{k}=initialize(obj.SummaryOverLCbyColumn{k}, ...
                                         obj.lc_domain( index ), ...
                                         obj.values( index ) );
    end
end

for k=1:obj.SummaryOverFGSFrame.count
    index=(obj.FGS_frame_domain==FGS_frame_list(k));
    if sum(1.0*index(:))>0
        obj.SummaryOverLCbyFGSFrame{k}=initialize(obj.SummaryOverLCbyFGSFrame{k}, ...
                                         obj.lc_domain( index ), ...
                                         obj.values( index ) );
    end
end

for k=1:obj.SummaryOverFGSParallel.count
    index=(obj.FGS_parallel_domain==FGS_parallel_list(k));
    if sum(1.0*index(:))>0
        obj.SummaryOverLCbyFGSParallel{k}=initialize(obj.SummaryOverLCbyFGSParallel{k}, ...
                                         obj.lc_domain( index ), ...
                                         obj.values( index ) );
    end
end

obj = class(obj, 'Monitored_Residuals');  

return

end
        