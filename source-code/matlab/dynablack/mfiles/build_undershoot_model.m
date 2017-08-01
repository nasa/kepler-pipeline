function undershootModelA = build_undershoot_model( longCadenceData, inputs )
% function undershootModelA = build_undershoot_model( longCadenceData, inputs )
%
% Builds the undershoot component of the model from neartrailingArp and trailingArpUs data subsets.
% The undershoot model for a given response pixel simply consists of the 20 leading pixels + a constant.
% The undershoot model is applyed only to a subset of response vector elements, the remaining
% elements have all predictor matrix elements set to zero.
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

MAX_NEARTRAILING_COLUMN = 5;

row_model        = inputs.row_model;
trailingArp      = inputs.ROI.trailingArp;
trailingArpUs    = inputs.ROI.trailingArpUs;
neartrailingArp  = inputs.ROI.neartrailingArp;
undershootSpan   = inputs.controls.undershootSpan;
undershootSpan0  = inputs.controls.undershootSpan0;
minUndershootRow = inputs.controls.minUndershootRow;
maxUndershootRow = inputs.controls.maxUndershootRow;

undershootModelA = ModelComponent( abs(undershootSpan)+1, row_model.Datum_count, 'US' );
undershoot_range = undershootSpan:-1;

rows = intersect(unique(neartrailingArp.Rows), unique(trailingArpUs.Rows));
rows = rows(rows >= minUndershootRow & rows <= maxUndershootRow);

for k = rowvec(rows)
    
    ntb_row_data0   = longCadenceData(neartrailingArp.Index( neartrailingArp.Rows == k));
    nearColRange    = 1:min(MAX_NEARTRAILING_COLUMN,length(ntb_row_data0));    
    mean_ntb        = mean( ntb_row_data0(nearColRange));
    ntb_row_data    = [ ones(abs(undershootSpan-undershootSpan0),1) * mean_ntb; ntb_row_data0 ];
    ntb_row_count   = length(ntb_row_data);
    model_row_range = find( trailingArpUs.Rows==k ) + trailingArp.Last;
    tb_row_data     = longCadenceData( trailingArpUs.Index( trailingArpUs.Rows==k) );
    row_data        = [ ntb_row_data; tb_row_data ];
    
    for k2 = 1:length(tb_row_data)
        undershootModelA.Matrix(:,model_row_range(k2)) = [1; row_data(k2 + ntb_row_count + undershoot_range)];
    end
end

undershootModelA = model_subset( undershootModelA, 1, row_model.Subset_datum_index );

