function prfModel = retrieve_prf_model(ccdModule, ccdOutput, mjd)
% prfModel = retrieve_prf_model(ccdModule, ccdOutput, mjd)
%   or
% prfModel = retrieve_prf_model(ccdModule, ccdOutput)
%
% Returns a vector of PRF model structs, one PRF model struct per
% module/output pair as given in the inputs.  If the MJD arg is not
% specified, the most recent PRF model is retrieved.  The ccdModule and
% ccdOutput inputs may be vectors, but must be equal-length.
% 
% INPUTS:
%     ccdModule: A CCD module number or vector of same.  If a vector, it
%                must have the same length as ccdOutput.
%
%     ccdOutput: A CCD output number or vector of same.  If a vector, it
%                must have the same length as ccdModule.
%
%     mjd: A MJD time.  Optional.  If not given, the PRF model with the 
%          latest date will be used.
%
%
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

    if nargin < 2 && nargin > 3
        error('Matlab:common:wrapper:retrieve_prf_model', ...
            'retrieve_prf_model must be called with 2 or 3 args.  Run "help retrieve_prf_model" for usage.');
    end
    
    import gov.nasa.kepler.systest.sbt.SandboxTools;
    SandboxTools.displayDatabaseConfig;

    import gov.nasa.kepler.fc.prf.PrfModel;
    import gov.nasa.kepler.fc.prf.PrfOperations;

    % Validate mod/out inputs.  Validate that they are equal-length. Ignore outputs.
    %
    convert_from_module_output(ccdModule, ccdOutput); %#ok<NASGU>

    ops = PrfOperations();
    for ii = 1:length(ccdModule)
        if nargin == 2
            prfModelTmp = ops.retrieveMostRecentPrfModel(ccdModule(ii), ccdOutput(ii));
            check_prf_model(prfModelTmp, nargin, ccdModule, ccdOutput);
        elseif nargin == 3
            prfModelTmp = ops.retrievePrfModel(mjd, ccdModule(ii), ccdOutput(ii));
            check_prf_model(prfModelTmp, nargin, ccdModule, ccdOutput, mjd);
        end

        prfModelJava(ii) = prfModelTmp;
    end
       
    
    % Construct a matlab-side output struct:
    %
    for ii = 1:length(prfModelJava)
        prfModel(ii).mjd       = prfModelJava(ii).getMjd();
        prfModel(ii).ccdModule = prfModelJava(ii).getCcdModule();
        prfModel(ii).ccdOutput = prfModelJava(ii).getCcdOutput();
        
        prfModel(ii).blob = processBlob(prfModelJava(ii));
    end

    import gov.nasa.kepler.hibernate.fc.HistoryModelName
    prfModel.fcModelMetadata = get_model_metadata(prfModelJava(1).getFcModelMetadata);

    import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
    dbInstance = DatabaseServiceFactory.getInstance();
    dbInstance.clear();
SandboxTools.close;
return


function inputStruct = processBlob(prfModelJava) %#ok<MCUOA>
    import gov.nasa.kepler.common.BlobUtils;
    javaFile = BlobUtils.writeBlob(prfModelJava.getBlob());
    filename = char(javaFile.getAbsolutePath());
    load(filename);
    delete(filename);
    
    if 1 ~= exist('inputStruct', 'var') || isempty(inputStruct)
        error('Matlab:common:wrapper:retrieve_prf_model', 'Lookup data inputStruct was empty.');
    end
return

function inputStruct = processBlobOld(prfModelJava) %#ok<MCUOA>
% function inputStruct = processBlob();
%
% Using syntax similar to:
%    blob = prfModelJava(ii).getBlob();
%    blob_to_struct(blob);
% errors out (presumably due to matlab/java native type differences: a
% java byte array is cast into int8 by matlab).  Instead, use this method.
% WARNING: the below (and blob_to_struct, by the way) are ABSOLUTELY
% DEPENDENT on the blob having "inputStruct" at the stuct name.
%
    filename = '.retrieve_prf_model_tmp.mat';
    if 2 == exist(filename, 'file')
        delete(filename);
    end

    file = java.io.File(filename);
    prfModelJava.writeBlob(file)
    load(filename);
    delete(filename);
    
    
    if 1 ~= exist('inputStruct', 'var') || isempty(inputStruct)
        error('Matlab:common:wrapper:retrieve_prf_model', 'Lookup data inputStruct was empty.');
    end
return

function check_prf_model(prfModelJava, numPars, ccdModule, ccdOutput, mjd)
    % Verify that something was returned.  If nothing was, return a
    % descriptive error message.
    %
    msg = 'The PRF model returned from the Java class PrfOperations is empty.  ';
    if isempty(prfModelJava)
        if numPars == 2
            msg = sprintf('%sSince you did not specify an MJD argument, the database you are pointed at is probably empty for module %d output %d.', ...
                          msg, ccdModule, ccdOutput);
        elseif numPars == 3
            msg = sprintf('%sEither there is no PRF model in the database before %f, or the database is probably empty for module %d output %d.', ...
                          msg, mjd, ccdModule, ccdOutput);
        else
            msg = 'Variable numPars is not 2 or 3.  Error!';
        end
        error('Matlab:common:wrapper:retrieve_prf_model', msg);
    end
return
