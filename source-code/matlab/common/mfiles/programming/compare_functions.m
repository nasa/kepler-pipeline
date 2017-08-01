function results = compare_functions( h1, h2, args, nOutputs, hc )
%**************************************************************************
% function results = compare_functions( h1, h2, args, nOutputs, hc )
%**************************************************************************
% A utility function for comparing the outputs of two functions. Useful for
% regression testing or comparing any two functions that should deliver the
% same outputs for a given set of inputs.
%
% INPUTS
%     h1       : A function handle.
%     h2       : A function handle.
%     args     : A cell array contianing the arguments to be passed to each
%                function. 
%     nOutputs : The number of outputs to compare (default = 1).
%     hc       : An optional handle to a comparison function. If not
%                specified, the function isequalwithequalnans() is used.
%
% OUTPUTS
%     results  : A 1-by-nOutputs logical array, each element indicating
%                whether the corresponding outputs were identical (1) or
%                different (0) according to the specified comparison
%                function.
% 
% USAGE EXAMPLES
%     >> compare_functions(@strcmp, @strcmpi, {'ABC', 'abc'})
%     >> compare_functions(@strcmp, @strcmpi, {'abc', 'abc'})
%     >> compare_functions(@svds, @svds, {[1 2; 3 4]}, 3, ...
%                          @(x,y)(max(abs(x(:)-y(:))) < 1e-6))
%
%     Note that repeatedly running the last example will reveal that svds
%     is non-deterministic.
%**************************************************************************
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

    % Check arguments and set defaults.
    if ~exist('hc', 'var')
        hc = @isequalwithequalnans;                             %#ok<NASGU>
    end
    
    if ~exist('nOutputs', 'var')
        nOutputs = 1;
    end

    % Execute function 1.
    command = '[';
    for i = 1:nOutputs
        command = [command, ',a', num2str(i)];                 
    end
    command = [command, '] = h1(args{:});'];     
    eval(command);
    
    % Execute function 2.
    command = '[';
    for i = 1:nOutputs
        command = [command, ',b', num2str(i)];                  
    end
    command = [command, '] = h2(args{:});'];
    eval(command);
   
    % Compare the results.
    for i = 1:nOutputs
        command = ['hc(a', num2str(i), ', b', num2str(i), ');'];
        results(i) = eval(command);
    end    
    
end
