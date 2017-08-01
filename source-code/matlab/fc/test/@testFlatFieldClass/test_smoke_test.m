function self = test_smoke_test(self)
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
    display('smoke test');

    [modules_list outputs_list] = fc_test_get_modules_outputs_all();
    for ichannel = 1:length(modules_list)
        module = modules_list(ichannel);
        output = outputs_list(ichannel);
        
        flatFieldObjectT = flatFieldClass(retrieve_flat_field_model(module, output, 55000, 56000, (100:199)', (200:299))');
        flatFieldObject = flatFieldClass(retrieve_flat_field_model(module, output, 55000, 56000, 100:199, 200:299));
        flatFieldObjectImg = flatFieldClass(retrieve_flat_field_model(module, output));

        [flat uncert] = get_flat_field(flatFieldObject, 55000);
        [flat uncert] = get_flat_field(flatFieldObject, 55000:55009);
        [flat uncert] = get_flat_field(flatFieldObject, 55000:55009, 150:155, 250:255);
        [flat uncert] = get_flat_field(flatFieldObject, 55000, 150:155, 250:255);
        [flat uncert] = get_flat_field(flatFieldObject, 55000:55009, (150:155)', (250:255)');
        [flat uncert] = get_flat_field(flatFieldObject, 55000, (150:155)', (250:255)');

        [flat uncert] = get_flat_field(flatFieldObjectT, 55000);
        [flat uncert] = get_flat_field(flatFieldObjectT, 55000:55009);
        [flat uncert] = get_flat_field(flatFieldObject, 55000:55009, (150:155)', (250:255)');
        [flat uncert] = get_flat_field(flatFieldObject, 55000, (150:155)', (250:255)');
        
        [flat uncert] = get_flat_field(flatFieldObjectImg, 55000:55009, 150:155, 250:255);
        [flat uncert] = get_flat_field(flatFieldObjectImg, 55000:55001);
        [flat uncert] = get_flat_field(flatFieldObjectImg, 55000:55001);
    end
return
