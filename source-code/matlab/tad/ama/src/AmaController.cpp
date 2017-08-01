/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 *
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */


#include "AmaController.h"

#include "libama.h"

#include <iostream>

#define _DEBUG_DISPLAY 1

AmaController::AmaController(){
}

AmaController::~AmaController(){
}

int AmaController::doScience( AmaInputs& inputs, AmaOutputs& outputs ){

	// Call application and library initialization. Perform this 
	// initialization before calling any API functions or
	// Compiler-generated libraries.
	if (!mclInitializeApplication(NULL,0)) 
	{
		outputs.errorCode = 2000;
		outputs.errorText = "AMA CSCI:AmaController::doScience - could not initialize mclInitializeApplication ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}
#if _DEBUG_DISPLAY
	std::cout << "completed mclInitializeApplication" << std::endl;
#endif

	if( !libamaInitialize() )
	{
		outputs.errorCode = 2001;
		outputs.errorText = "AMA CSCI:AmaController::doScience - could not initialize librequantization library ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

#if _DEBUG_DISPLAY
	std::cout << "completed libamaInitialize" << std::endl;
#endif
	try{
		assignMasks(inputs, outputs);
		outputs.errorCode = 0;
		outputs.errorText = "AMA CSCI:AmaController::doScience - SUCCESS";
	}catch (const mwException& e){
		outputs.errorCode = 2002;
		outputs.errorText = "AMA CSCI:AmaController::doScience - computeOptimalApertures method failed\n ";
		outputs.errorText.append(e.what());
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}catch (...){
		outputs.errorCode = 9999;
		outputs.errorText = "AMA CSCI:AmaController::doScience - generateRequantizationTable method failed\n ";
		outputs.errorText.append("Unexpected error thrown");
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

	// Call the application and library termination routine
	libamaTerminate();

	mclTerminateApplication();
	return 0;
}

int AmaController::assignMasks( AmaInputs& inputs, AmaOutputs& outputs ){
	int entryNum;

	//-----------------------------------------------------------------------------------
	// create input Matlab mwArrays
	//-----------------------------------------------------------------------------------
	// create input mwArrays
	// scalar objects
	mwArray _useHaloApertures(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _debug(1,1, mxDOUBLE_CLASS, mxREAL);

#if _DEBUG_DISPLAY
	std::cout << "allocated mwArrays" << std::endl;
#endif
	
	// now populate that data with the input objects
	_useHaloApertures.SetData(&inputs.useHaloApertures,1);
	_debug.SetData(&inputs.debug,1);
	
#if _DEBUG_DISPLAY
	std::cout << "set scalar values" << std::endl;
#endif
	

	//-----------------------------------------------------------------------------------
	// create array of input mask tables structures if the intput is not empty
	//-----------------------------------------------------------------------------------
	const char* _inputMaskFields[] =
		{ "offset"
		};				
	const char* _inputOffsetFields[] =
		{ "row", 
			"column",
		};				
	
	int _numMasks = inputs.maskApertures.size();
	mwArray _maskStruct(1, _numMasks, sizeof(_inputMaskFields)/sizeof(char*), 
		_inputMaskFields); // struct created empty
		
	if (_numMasks > 0) {
		// for each mask, fill in its offsets
		for (int mask=0; mask<_numMasks; mask++) {	
			// get the # of offsets for this mask
			int _numOffsets = inputs.maskApertures[mask].aperturePixels.size();
			// make a matlab struct of offsets of this size
			mwArray _offsetStruct(1, _numOffsets, sizeof(_inputOffsetFields)/sizeof(char*), 
				_inputOffsetFields); // struct created empty
			// fill in the offset values
			for (int offset=0; offset<_numOffsets; offset++) {
				mwArray _row(1, _numOffsets, mxDOUBLE_CLASS, mxREAL);
				mwArray _column(1, _numOffsets, mxDOUBLE_CLASS, mxREAL);
				_row.SetData(&inputs.maskApertures[mask].aperturePixels[offset].rowOffset, 1);
				_column.SetData(&inputs.maskApertures[mask].aperturePixels[offset].columnOffset, 1);
				_offsetStruct("row", 1, offset+1) = _row.Clone();
				_offsetStruct("column", 1, offset+1) = _column.Clone();
			}
			// put the offset array in this mask
			_maskStruct("offset",1,mask+1) = _offsetStruct.Clone();
		}
		
#if _DEBUG_DISPLAY
		std::cout << "built _maskStruct" << _maskStruct << std::endl;
#endif
	} else {
#if _DEBUG_DISPLAY
		std::cout << "input mask table set is empty" << std::endl;
#endif
	}
		
	
	//-----------------------------------------------------------------------------------
	// create array of input aperture structures if the intput is not empty
	//-----------------------------------------------------------------------------------
	const char* _inputApertureTableFields[] =
		{ "targetId",
			"referenceRow", 
			"referenceColumn",
			"offset"
		};				
	
	int _numApertures = inputs.amaTargetPeers.size();
	mwArray _apertureTableStruct(1, _numApertures, sizeof(_inputApertureTableFields)/sizeof(char*), 
		_inputApertureTableFields); // struct created empty
		
	if (_numApertures > 0) {
		for (int aperture=0; aperture<_numApertures; aperture++) {
			mwArray _targetId(1, 1, mxDOUBLE_CLASS, mxREAL);
			mwArray _referenceRow(1, 1, mxDOUBLE_CLASS, mxREAL);
			mwArray _referenceColumn(1, 1, mxDOUBLE_CLASS, mxREAL);

			_targetId.SetData(&inputs.amaTargetPeers[aperture].targetId, 1);
			_referenceRow.SetData(&inputs.amaTargetPeers[aperture].optimalAperturePeer.referenceRow, 1);
			_referenceColumn.SetData(&inputs.amaTargetPeers[aperture].optimalAperturePeer.referenceColumn, 1);
			
			// get the # of offsets for this aperture
			int _numOffsets = inputs.amaTargetPeers[aperture].optimalAperturePeer.pixels.size();
			// make a matlab struct of offsets of this size
			mwArray _offsetStruct(1, _numOffsets, sizeof(_inputOffsetFields)/sizeof(char*), 
				_inputOffsetFields); // struct created empty
			// fill in the offset values
			for (int offset=0; offset<_numOffsets; offset++) {
				mwArray _row(1, _numOffsets, mxDOUBLE_CLASS, mxREAL);
				mwArray _column(1, _numOffsets, mxDOUBLE_CLASS, mxREAL);
				_row.SetData(&inputs.amaTargetPeers[aperture].optimalAperturePeer.pixels[offset].rowOffset, 1);
				_column.SetData(&inputs.amaTargetPeers[aperture].optimalAperturePeer.pixels[offset].columnOffset, 1);
				_offsetStruct("row", 1, offset+1) = _row.Clone();
				_offsetStruct("column", 1, offset+1) = _column.Clone();
			}
			// put the offset array in this aperture
			_apertureTableStruct("targetId",1,aperture+1) = _targetId.Clone();
			_apertureTableStruct("referenceRow",1,aperture+1) = _referenceRow.Clone();
			_apertureTableStruct("referenceColumn",1,aperture+1) = _referenceColumn.Clone();			
			_apertureTableStruct("offset",1,aperture+1) = _offsetStruct.Clone();			
		}
#if _DEBUG_DISPLAY		
		std::cout << "built _apertureTableStruct" << _apertureTableStruct << std::endl;
#endif
	} else {
#if _DEBUG_DISPLAY
		std::cout << "input aperture table set is empty" << std::endl;
#endif
	}


	//-----------------------------------------------------------------------------------
	// create ama input data structure
	//-----------------------------------------------------------------------------------
	const char* _amaInputDataFields[] =
		{ "inputMaskTableStruct", 
			"optimalApertureStruct",
			"useHaloApertures",
			"debug",
		};

	mwArray amaInputStruct(1, 1, sizeof(_amaInputDataFields)/sizeof(char*), 
		_amaInputDataFields);
		
	amaInputStruct("inputMaskTableStruct",1,1) = _maskStruct;
	amaInputStruct("optimalApertureStruct",1,1) = _apertureTableStruct;
	amaInputStruct("useHaloApertures",1,1) = _useHaloApertures;
	amaInputStruct("debug",1,1) = _debug;
	
#if _DEBUG_DISPLAY
	std::cout << "built amaInputStruct" << amaInputStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create ama output structure
	//-----------------------------------------------------------------------------------
	const char* _amaResultsDataFields[] =
		{ "targetDefinitions", 
			"errorStruct"
		};
	mwArray amaResultsStruct(1, 1, sizeof(_amaResultsDataFields)/sizeof(char*), 
		_amaResultsDataFields);

	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	// call AMA matlab controller
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	
	// 1 corresponds to number of output arguments
	ama_matlab_controller(1, amaResultsStruct, amaInputStruct);
	
	//-----------------------------------------------------------------------------------
	// create ama output structure
	//-----------------------------------------------------------------------------------

		
	int numFields = amaResultsStruct.NumberOfFields();
#if _DEBUG_DISPLAY
	std::cout << "# of fields in return struct is " << numFields << std::endl;
#endif
	for (int f=0; f<numFields; f++) {
		const char *_fname = amaResultsStruct.GetFieldName(f);
		std::cout << _fname << std::endl;		
		if (!strcmp(_fname, "_errorStruct")) {
			_errorStruct = amaResultsStruct("_errorStruct", 1, 1);
			int _numErrorFields = _errorStruct.NumberOfFields();
			std::cout << "# of fields in _errorStruct is " << _numErrorFields << std::endl;
			if (_numErrorFields == 3) {
				mwArray _errMessage = _errorStruct("message", 1, 1);
				mwArray _errIdentifier = _errorStruct("identifier", 1, 1);
				std::cout << "Error message:" << std::endl;		
				std::cout << _errMessage << std::endl;		
				std::cout << "Error identifier: " 
					<< _errIdentifier << std::endl;		
				_errorStackStruct = _errorStruct("stack", 1, 1);
				int _numErrorStackLevels = _errorStackStruct.NumberOfElements();
				std::cout << "# of levels in the error stack is " << _numErrorStackLevels << std::endl;
				for (int s=1; s<=_numErrorStackLevels; s++) {
					mwArray _errorStackFileName = _errorStackStruct("file", s, 1);		
					mwArray _errorStackFunctionName = _errorStackStruct("name", s, 1);		
					mwArray _errorStackLine = _errorStackStruct("line", s, 1);		
					std::cout << "Stack level " << s << ": Error in file" << std::endl;
					std::cout << _errorStackFileName << std::endl;
					std::cout << "in function " << _errorStackFunctionName 
						<< " at line " << _errorStackLine << std::endl;
				} // end display of error stack
			}
		} // end "_errorStruct"
		else if (!strcmp(_fname, "targetDefinitions")) {
			mwArray _targetDefinitionStruct = amaResultsStruct("targetDefinitions", 1, 1);			
			int _numDefinitions = _targetDefinitionStruct.NumberOfElements();
			for (int def=1; def<=_numDefinitions; def++) {
				// construct the individual target definition data
				TargetDefinitionPeer _thisDefinition;
				
				_thisDefinition.targetId = (int) _targetDefinitionStruct("targetId", 1, def);
				_thisDefinition.referenceRow = (int) _targetDefinitionStruct("referenceRow", 1, def);
				_thisDefinition.referenceColumn = (int) _targetDefinitionStruct("referenceColumn", 1, def);
				// convert from MATLAB 1-based to 0-based indexing here
				_thisDefinition.maskIndex = (int) _targetDefinitionStruct("maskIndex", 1, def) - 1;
				// add to the output target definition list
				outputs.targetDefinitionPeers.push_back(_thisDefinition);
			}
		}  // end "maskDefinition"
		else {
			std::cout << "unrecognized field  " << _fname << " in coaResultsStruct" << std::endl;
		}
	}
	
	
	return 0;
	//-----------------------------------------------------------------------

}

