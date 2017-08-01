function [blackRowsToExcludeInFit, chargeInjectionRows, frameTransferRows] = get_black_rows_to_exclude_for_1D_black_fit(calObject)
%
% function [blackRowsToExcludeInFit, chargeInjectionRows, frameTransferRows] = get_black_rows_to_exclude_for_1D_black_fit(calObject)
% Function to extract the CCD row indices that include excess flux due to charge 
% injection and/or parallel frame transfer. List of rows returned is
% one-based.
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

% 12/13/2011 - BC
% Added optional outputs listing chargeInjectionRows and frameTransferRows separately.
%

fcConstants = calObject.fcConstants;

chargeInjectionRowStart = fcConstants.CHARGE_INJECTION_ROW_START;   % 1059 in 1-based
ccdEndRow               = fcConstants.CCD_ROWS;                     % 1070 in 1-based               
                   
chargeInjectionRows = chargeInjectionRowStart:ccdEndRow;


frameTransferRows = [ ...
0
1
2
3
4
8
15
22
108
115
122
129
136
143
150
157
164
171
178
185
192
199
206
214
215
216
217
218
222
229
236
322
329
336
343
350
357
364
371
378
385
392
399
406
413
420
428
429
430
431
432
436
443
450
536
543
550
557
564
571
578
585
592
599
606
613
620
627
634
642
643
644
645
646
650
657
664
750
757
764
771
778
785
792
799
806
813
820
827
834
841
848
856
857
858
859
860
864
871
878
964
971
978
985
992
999
1006
1013
1020
1027
1034
1041
1048
1055
1062];

% above list is 0-based
frameTransferRows = frameTransferRows + 1; 

blackRowsToExcludeInFit = unique([chargeInjectionRows(:); frameTransferRows(:)]);


return;

