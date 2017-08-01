%% Monitored_Parameters 
% Class definition for a Monitored_Parameters class object. 
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
function obj = Monitored_Parameters( Inputs )
%% ARGUMENTS
% 
% * Function returns: obj - an object of class Monitored_Parameters.
% * |obj   -| - an object of class Monitored_Parameters.
% * Function arguments:
% * |Inputs   -| input structure
% * Inputs.param_data
% * Inputs.param_errors
% * Inputs.B1models
% * Inputs.lc_domain
% * Inputs.domain
% * Inputs.description
%
%% CODE
%

param_count         = size(Inputs.param_data,2);
lc_count            = size(Inputs.param_data,1);

lc_list             =sort(unique(Inputs.lc_domain));
domain_list         =sort(unique(Inputs.domain));

obj.param_count     = param_count;
obj.lc_count        = lc_count;

obj.values                  = Inputs.param_data;
obj.errors                  = Inputs.param_errors;
obj.B1models                = Inputs.B1models;
obj.lc_domain               = Inputs.lc_domain;
obj.param_domain            = Inputs.domain;

obj.description             = Inputs.description;

obj.SummaryOverLC           = SummaryOverADomain( lc_list, 'LC' );
obj.SummaryOverDomain       = SummaryOverADomain( domain_list, Inputs.label );
obj.ErrorSummaryOverLC      = obj.SummaryOverLC;
obj.ErrorSummaryOverDomain  = obj.SummaryOverDomain;
obj.ModelSummaryOverLC      = obj.SummaryOverLC;
obj.ModelSummaryOverDomain  = obj.SummaryOverDomain;

obj.SummaryOverLC           = initialize(obj.SummaryOverLC, obj.lc_domain, obj.values);
obj.SummaryOverDomain       = initialize(obj.SummaryOverDomain, obj.param_domain, obj.values);
obj.ErrorSummaryOverLC      = initialize(obj.ErrorSummaryOverLC, obj.lc_domain, obj.errors);
obj.ErrorSummaryOverDomain  = initialize(obj.ErrorSummaryOverDomain, obj.param_domain, obj.errors);
obj.ModelSummaryOverLC      = initialize(obj.ModelSummaryOverLC, obj.lc_domain, obj.B1models);
obj.ModelSummaryOverDomain  = initialize(obj.ModelSummaryOverDomain, obj.param_domain, obj.B1models);

obj = class(obj, 'Monitored_Parameters');  

return

end
        



