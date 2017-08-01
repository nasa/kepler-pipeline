function ffiKeywordStruct = extract_ffi_keywords(ffiName)
% extract_ffi_keywords obtains headers and its values
% Keywords extracted are: DATATYPE, INT_TIME, NUM_FFI, DCT_PURP, STARTIME, END_TIME
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



% create and initiate structure
ffiKeywordStruct = struct('Datatype', '', 'IntTime', 0, 'NumFfi', 0, ...
   'DctPurpose', '', 'StartTimeMjd', 0, 'EndTimeMjd', 0);



infoFfi = fitsinfo(ffiName); % infoFfi is a struct with headers



% extract datatype
indxDatatype=strmatch('DATATYPE',infoFfi.PrimaryData.Keywords(:,1), 'exact');
if isempty(indxDatatype)==0
    valDatatype=infoFfi.PrimaryData.Keywords{indxDatatype,2};
else
    valDatatype='Datatype not found';
end



% extract integration time
indxIntTime=strmatch('INT_TIME', infoFfi.PrimaryData.Keywords(:,1),'exact');
if isempty(indxIntTime)==0
    valIntTime=infoFfi.PrimaryData.Keywords{indxIntTime,2};
else
    valIntTime='Integration time not found';
end



% extract number of co-adds
indxNumFfi=strmatch('NUM_FFI', infoFfi.PrimaryData.Keywords(:,1),'exact');
if isempty(indxNumFfi)==0
    valNumFfi=infoFfi.PrimaryData.Keywords{indxNumFfi,2};
else
    valNumFfi='Number of co-adds not found';
end


% extract acitivity that called for the commissioning task
indxDctPurp=strmatch('DCT_PURP', infoFfi.PrimaryData.Keywords(:,1),'exact');
if isempty(indxDctPurp)==0
    valDctPurp=infoFfi.PrimaryData.Keywords{indxDctPurp,2};
else
    valDctPurp='DCT_PURP not found';
end



% extract start time in MJD
indxStarTimeMJD=strmatch('STARTIME', infoFfi.PrimaryData.Keywords(:,1),'exact');
if isempty(indxStarTimeMJD)==0
    valStartTimeMJD=infoFfi.PrimaryData.Keywords{indxStarTimeMJD,2};
else
    valStartTimeMJD='MJD start time not found';
end



% extract end time in MJD
indxEndTimeMJD=strmatch('END_TIME', infoFfi.PrimaryData.Keywords(:,1),'exact');
if isempty(indxEndTimeMJD)==0
    valEndTimeMJD=infoFfi.PrimaryData.Keywords{indxEndTimeMJD,2};
else
    valEndTimeMJD='MJD end time not found';
end



% place values into structure
ffiKeywordStruct.Datatype=valDatatype;
ffiKeywordStruct.IntTime=valIntTime;
ffiKeywordStruct.NumFfi=valNumFfi;
ffiKeywordStruct.DctPurpose=valDctPurp;
ffiKeywordStruct.StartTimeMjd=valStartTimeMJD;
ffiKeywordStruct.EndTimeMjd=valEndTimeMJD;

