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


#include "AmtController.h"

#include "libamt.h"

#include <iostream>

#define _DEBUG_DISPLAY 1

AmtController::AmtController(){
}

AmtController::~AmtController(){
}

int AmtController::doScience( AmtInputs& inputs, AmtOutputs& outputs ){

	// Call application and library initialization. Perform this 
	// initialization before calling any API functions or
	// Compiler-generated libraries.
	if (!mclInitializeApplication(NULL,0)) 
	{
		outputs.errorCode = 2000;
		outputs.errorText = "AMT CSCI:AmtController::doScience - could not initialize mclInitializeApplication ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}
#if _DEBUG_DISPLAY
	std::cout << "completed mclInitializeApplication" << std::endl;
#endif

	if( !libamtInitialize() )
	{
		outputs.errorCode = 2001;
		outputs.errorText = "AMT CSCI:AmtController::doScience - could not initialize librequantization library ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

#if _DEBUG_DISPLAY
	std::cout << "completed libamtInitialize" << std::endl;
#endif
	try{
		createMaskTable(inputs, outputs);
		outputs.errorCode = 0;
		outputs.errorText = "AMT CSCI:AmtController::doScience - SUCCESS";
	}catch (const mwException& e){
		outputs.errorCode = 2002;
		outputs.errorText = "AMT CSCI:AmtController::doScience - computeOptimalApertures method failed\n ";
		outputs.errorText.append(e.what());
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}catch (...){
		outputs.errorCode = 9999;
		outputs.errorText = "AMT CSCI:AmtController::doScience - generateRequantizationTable method failed\n ";
		outputs.errorText.append("Unexpected error thrown");
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

	// Call the application and library termination routine
	libamtTerminate();

	mclTerminateApplication();
	return 0;
}

int AmtController::createMaskTable( AmtInputs& inputs, AmtOutputs& outputs ){
	int entryNum;

#if _DEBUG_DISPLAY
	std::cout << "inside createMaskTable" << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create input Matlab mwArrays
	//-----------------------------------------------------------------------------------
	// create input mwArrays
	// scalar objects
	mwArray _maxMasks(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _maxPixelsInMask(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _maxMaskRows(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _maxMaskCols(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _centerRow(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _centerCol(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _minEccentricity(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _maxEccentricity(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _stepEccentricity(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _stepInclination(1, 1, mxDOUBLE_CLASS, mxREAL);
	mwArray _debug(1,1, mxDOUBLE_CLASS, mxREAL);

#if _DEBUG_DISPLAY
	std::cout << "allocated mwArrays" << std::endl;
#endif
	
	// now populate that data with the input objects
	_maxMasks.SetData(&inputs.maxMasks,1);
	_maxPixelsInMask.SetData(&inputs.maxPixelsInMask,1);
	_maxMaskRows.SetData(&inputs.maxMaskRows,1);	
	_maxMaskCols.SetData(&inputs.maxMaskCols,1);
	_centerRow.SetData(&inputs.centerRow,1);
	_centerCol.SetData(&inputs.centerCol,1);
	_minEccentricity.SetData(&inputs.minEccentricity,1);
	_maxEccentricity.SetData(&inputs.maxEccentricity,1);
	_stepEccentricity.SetData(&inputs.stepEccentricity,1);
	_stepInclination.SetData(&inputs.stepInclination,1);
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
	// create array of input mask tables structures if the intput is not empty
	//-----------------------------------------------------------------------------------
	const char* _inputApertureTableFields[] =
		{ "referenceRow", 
			"referenceColumn",
			"offset"
		};				
	
	int _numApertures = inputs.optimalApertures.size();
	mwArray _apertureTableStruct(1, _numApertures, sizeof(_inputApertureTableFields)/sizeof(char*), 
		_inputApertureTableFields); // struct created empty
		
	if (_numApertures > 0) {
		for (int aperture=0; aperture<_numApertures; aperture++) {
			mwArray _referenceRow(1, 1, mxDOUBLE_CLASS, mxREAL);
			mwArray _referenceColumn(1, 1, mxDOUBLE_CLASS, mxREAL);

			_referenceRow.SetData(&inputs.optimalApertures[aperture].referenceRow, 1);
			_referenceColumn.SetData(&inputs.optimalApertures[aperture].referenceColumn, 1);
			
			// get the # of offsets for this aperture
			int _numOffsets = inputs.optimalApertures[aperture].pixels.size();
			// make a matlab struct of offsets of this size
			mwArray _offsetStruct(1, _numOffsets, sizeof(_inputOffsetFields)/sizeof(char*), 
				_inputOffsetFields); // struct created empty
			// fill in the offset values
			for (int offset=0; offset<_numOffsets; offset++) {
				mwArray _row(1, _numOffsets, mxDOUBLE_CLASS, mxREAL);
				mwArray _column(1, _numOffsets, mxDOUBLE_CLASS, mxREAL);
				_row.SetData(&inputs.optimalApertures[aperture].pixels[offset].rowOffset, 1);
				_column.SetData(&inputs.optimalApertures[aperture].pixels[offset].columnOffset, 1);
				_offsetStruct("row", 1, offset+1) = _row.Clone();
				_offsetStruct("column", 1, offset+1) = _column.Clone();
			}
			// put the offset array in this aperture
			_apertureTableStruct("offset",1,aperture+1) = _offsetStruct.Clone();			
			_apertureTableStruct("referenceRow",1,aperture+1) = _referenceRow.Clone();
			_apertureTableStruct("referenceColumn",1,aperture+1) = _referenceColumn.Clone();			
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
	// create input configuration structure
	//-----------------------------------------------------------------------------------
	const char* _configurationInputDataFields[] =
		{ "maxMasks", 
			"maxPixelsInMask",
			"maxMaskRows",
			"maxMaskCols",
			"centerRow",
			"centerCol",
			"minEccentricity",
			"maxEccentricity",
			"stepEccentricity",
			"stepInclination",
		};

	mwArray _configurationStruct(1, 1, sizeof(_configurationInputDataFields)/sizeof(char*), 
		_configurationInputDataFields);
		
	_configurationStruct("maxMasks",1,1) = _maxMasks;
	_configurationStruct("maxPixelsInMask",1,1) = _maxPixelsInMask;
	_configurationStruct("maxMaskRows",1,1) = _maxMaskRows;
	_configurationStruct("maxMaskCols",1,1) = _maxMaskCols;
	_configurationStruct("centerRow",1,1) = _centerRow;
	_configurationStruct("centerCol",1,1) = _centerCol;
	_configurationStruct("minEccentricity",1,1) = _minEccentricity;
	_configurationStruct("maxEccentricity",1,1) = _maxEccentricity;	
	_configurationStruct("stepEccentricity",1,1) = _stepEccentricity;
	_configurationStruct("stepInclination",1,1) = _stepInclination;	

#if _DEBUG_DISPLAY
	std::cout << "built _configurationStruct" << _configurationStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create amt input data structure
	//-----------------------------------------------------------------------------------
	const char* _amtInputDataFields[] =
		{ "inputMaskTableStruct", 
			"optimalApertureStruct",
			"amtConfigurationStruct",
			"debug",
		};

	mwArray amtInputStruct(1, 1, sizeof(_amtInputDataFields)/sizeof(char*), 
		_amtInputDataFields);
		
	amtInputStruct("inputMaskTableStruct",1,1) = _maskStruct;
	amtInputStruct("optimalApertureStruct",1,1) = _apertureTableStruct;
	amtInputStruct("amtConfigurationStruct",1,1) = _configurationStruct;
	amtInputStruct("debug",1,1) = _debug;
	
#if _DEBUG_DISPLAY
	std::cout << "built amtInputStruct" << amtInputStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create amt output structure
	//-----------------------------------------------------------------------------------
	const char* _amtResultsDataFields[] =
		{ "maskTable", 
			"errorStruct"
		};
	mwArray amtResultsStruct(1, 1, sizeof(_amtResultsDataFields)/sizeof(char*), 
		_amtResultsDataFields);

	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	// call AMT matlab controller
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	
	// 1 corresponds to number of output arguments
	amt_matlab_controller(1, amtResultsStruct, amtInputStruct);
	
	//-----------------------------------------------------------------------------------
	// create amt output structure
	//-----------------------------------------------------------------------------------

	
	const char* _errorStructDataFields[] =
		{ "message", 
			"identifier",
			"stack"
		};
	mwArray errorStruct(1, 1, sizeof(_errorStructDataFields)/sizeof(char*), 
		_errorStructDataFields);
	const char* _errorStackDataFields[] =
		{ "file", 
			"name",
			"line"
		};
	mwArray errorStackStruct(1, 1, sizeof(_errorStackDataFields)/sizeof(char*), 
		_errorStackDataFields);
	
	int numFields = amtResultsStruct.NumberOfFields();
#if _DEBUG_DISPLAY
	std::cout << "# of fields in return struct is " << numFields << std::endl;
#endif
	for (int f=0; f<numFields; f++) {
		const char *_fname = amtResultsStruct.GetFieldName(f);
#if _DEBUG_DISPLAY
		std::cout << _fname << std::endl;		
#endif
		if (!strcmp(_fname, "errorStruct")) {
			errorStruct = amtResultsStruct("errorStruct", 1, 1);
			int _numErrorFields = errorStruct.NumberOfFields();
#if _DEBUG_DISPLAY
			std::cout << "# of fields in _errorStruct is " << _numErrorFields << std::endl;
#endif
			if (_numErrorFields == 3) {
				mwArray errMessage = errorStruct("message", 1, 1);
				mwArray errIdentifier = errorStruct("identifier", 1, 1);
				std::cout << "Error message:" << std::endl;		
				std::cout << errMessage << std::endl;		
				std::cout << "Error identifier: " 
					<< errIdentifier << std::endl;		
				errorStackStruct = errorStruct("stack", 1, 1);
				int numErrorStackLevels = errorStackStruct.NumberOfElements();
				std::cout << "# of levels in the error stack is " << numErrorStackLevels << std::endl;
				for (int s=1; s<=numErrorStackLevels; s++) {
					mwArray errorStackFileName = errorStackStruct("file", s, 1);		
					mwArray errorStackFunctionName = errorStackStruct("name", s, 1);		
					mwArray errorStackLine = errorStackStruct("line", s, 1);		
					std::cout << "Stack level " << s << ": Error in file" << std::endl;
					std::cout << errorStackFileName << std::endl;
					std::cout << "in function " << errorStackFunctionName 
						<< " at line " << errorStackLine << std::endl;
				} // end display of error stack
			}
		} // end "errorStruct"
		else if (!strcmp(_fname, "maskDefinition")) {
			mwArray _maskDefinitionStruct = amtResultsStruct("maskDefinition", 1, 1);			
			int _numMasks = _maskDefinitionStruct.NumberOfElements();
			for (int mask=1; mask<=_numMasks; mask++) {
				// construct the individual mask aperture data
				MaskAperturePeer _thisMask;

				mwArray _offsetStruct = _maskDefinitionStruct("offset", 1, 1);
				int _numOffsets = _offsetStruct.NumberOfElements();
				for (int p=1; p<=_numOffsets; p++) {
					AperturePixelPeer _pix;
					_pix.rowOffset = _offsetStruct("row", 1, p);
					_pix.columnOffset = _offsetStruct("column", 1, p);
					_thisMask.aperturePixels.push_back(_pix);
				} // end loop through offsets
				outputs.maskApertures.push_back(_thisMask);
			}
		}  // end "maskDefinition"
		else {
			std::cout << "unrecognized field  " << _fname << " in coaResultsStruct" << std::endl;
		}
	}
	
	
	return 0;
	//-----------------------------------------------------------------------

}

