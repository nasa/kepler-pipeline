function self = test_input_arguments_get_bart_model(self)
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

fprintf('testing input arguments on get_bart_model\n\n')


% test 3 input arguments
fprintf('\t testing not enough input arguments\n')
try
    modelStruct = get_bart_model(3,4,15);
    
catch
    msg = lasterror;
    rightError = 'get_bart_model takes 5 input arguments';
    correct = ~isempty(strfind(msg.message, rightError));
    if correct
        assert(true)
    else
        assert(false)
    end
end


% test non scalar input argruments
fprintf('\t testing non scalar input arguments\n')
try
    modelStruct = get_bart_model(2, 3:4, 20:21, 1, 0);
    
catch
    msg = lasterror; 
    rightError = 'all input arguments must be scalar';
    correct = ~isempty(strfind(msg.message, rightError));
    if correct
        assert(true)
    else
        assert(false)
       
    end
end



% test invalid module
fprintf('\t testing invalid module\n')
try
    modelStruct = get_bart_model(5, 2, 30, 1, 0);
    
catch
    msg = lasterror;
    rightError = 'invalid module';
    correct = ~isempty(strfind(msg.message, rightError));
    if correct
        assert(true)
    else
        assert(false)
    end
end


% test invalid output
fprintf('\t testing invalidoutput\n')
try
    modelStruct = get_bart_model(3, 7, 30, 1, 0);
    
catch
    msg = lasterror;
    rightError = 'invalid output';
    correct = ~isempty(strfind(msg.message, rightError));
    if correct
        assert(true)
    else
        assert(false)
    end
end


% test non-logical figFlag
fprintf('\t testing figFlags that are not either 0 or 1\n\n')
try
    modelStruct = get_bart_model(3, 1, 30, 5, 0);
    
catch
    msg = lasterror;
    rightError = 'figFlag has to be 0 or 1';
    correct = ~isempty(strfind(msg.message, rightError));
    if correct
        assert(true)
    else
        assert(false)
    end
end



% test invalid saveFlag
fprintf('\t testing invalid figFlags\n\n')
try
    modelStruct = get_bart_model(3, 1, 20, 0, 1);
    
catch
    msg = lasterror;
    rightError = 'figFlag has to be 1 and saveFlag has to be 0 or 1';
    correct = ~isempty(strfind(msg.message, rightError));
    if correct
        assert(true)
    else
        assert(false)
    end
end






