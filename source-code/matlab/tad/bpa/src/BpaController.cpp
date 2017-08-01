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


#include "BpaController.h"

#include "libbpa.h"

#include <iostream>

#define _DEBUG_DISPLAY 1

BpaController::BpaController(){
}

BpaController::~BpaController(){
}

int BpaController::doScience( BpaInputs& inputs, BpaOutputs& outputs ){

	// Call application and library initialization. Perform this 
	// initialization before calling any API functions or
	// Compiler-generated libraries.
	if (!mclInitializeApplication(NULL,0)) 
	{
		outputs.errorCode = 2000;
		outputs.errorText = "BPA CSCI:BpaController::doScience - could not initialize mclInitializeApplication ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}
#if _DEBUG_DISPLAY
	std::cout << "completed mclInitializeApplication" << std::endl;
#endif

	if( !libbpaInitialize() )
	{
		outputs.errorCode = 2001;
		outputs.errorText = "BPA CSCI:BpaController::doScience - could not initialize librequantization library ";
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

#if _DEBUG_DISPLAY
	std::cout << "completed libbpaInitialize" << std::endl;
#endif
	try{
		createBackgroundApertures(inputs, outputs);
		outputs.errorCode = 0;
		outputs.errorText = "BPA CSCI:BpaController::doScience - SUCCESS";
	}catch (const mwException& e){
		outputs.errorCode = 2002;
		outputs.errorText = "BPA CSCI:BpaController::doScience - computeOptimalApertures method failed\n ";
		outputs.errorText.append(e.what());
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}catch (...){
		outputs.errorCode = 9999;
		outputs.errorText = "BPA CSCI:BpaController::doScience - generateRequantizationTable method failed\n ";
		outputs.errorText.append("Unexpected error thrown");
		std::cerr << outputs.errorText << std::endl;
		return outputs.errorCode;
	}

	// Call the application and library termination routine
	libbpaTerminate();

	mclTerminateApplication();
	return 0;
}

int BpaController::createBackgroundApertures( BpaInputs& inputs, BpaOutputs& outputs ){
	int entryNum;

#if _DEBUG_DISPLAY
	std::cout << "inside doScience" << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create input Matlab mwArrays
	//-----------------------------------------------------------------------------------
	// create input mwArrays
	// scalar objects
	mwArray _nLinesRow(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _nLinesCol(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _nEdge(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _edgeFraction(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _twoByTwoMaskIndex(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _lineStartRow(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _lineEndRow(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _lineStartCol(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _lineEndCol(1,1, mxDOUBLE_CLASS, mxREAL);
	mwArray _debug(1,1, mxDOUBLE_CLASS, mxREAL);

	//-----------------------------------------------------------------------------------
	// create array storage for input image
	//-----------------------------------------------------------------------------------
	int _numRowsInImage = inputs.image.moduleOutputImage.size();
	int _numColsInImage = inputs.image.moduleOutputImage[1].size();
#if _DEBUG_DISPLAY
	std::cout << "input image size is " << _numRowsInImage << " x " << _numColsInImage << std::endl;
#endif
	mwArray _moduleOutputImage(_numRowsInImage,_numColsInImage, mxDOUBLE_CLASS, mxREAL);
	
#if _DEBUG_DISPLAY
	std::cout << "allocated mwArrays" << std::endl;
#endif
	
	// now populate that data with the input objects
	_nLinesRow.SetData(&inputs.nLinesRow,1);
	_nLinesCol.SetData(&inputs.nLinesCol,1);
	_nEdge.SetData(&inputs.nEdge,1);	
	_edgeFraction.SetData(&inputs.EdgeFraction,1);
	_twoByTwoMaskIndex.SetData(&inputs.twoByTwoMaskIndex,1);
	_lineStartRow.SetData(&inputs.image.lineStartRow,1);
	_lineEndRow.SetData(&inputs.image.lineEndRow,1);
	_lineStartCol.SetData(&inputs.image.lineStartCol,1);
	_lineEndCol.SetData(&inputs.image.lineEndCol,1);
	_debug.SetData(&inputs.debug,1);
	
#if _DEBUG_DISPLAY
	std::cout << "set scalar values" << std::endl;
#endif
	
	//-----------------------------------------------------------------------------------
	// fill in input image
	//-----------------------------------------------------------------------------------
	for (int row=0; row<_numRowsInImage; row++) {
		for (int col=0; col<_numColsInImage; col++) {
			_moduleOutputImage(row+1, col+1) = inputs.image.moduleOutputImage[row][col];
		}
	}
	
	//-----------------------------------------------------------------------------------
	// create input configuration structure
	//-----------------------------------------------------------------------------------
	const char* _configurationInputDataFields[] =
		{ "nLinesRow", 
			"nLinesCol",
			"nEdge",
			"edgeFraction",
			"twoByTwoMaskIndex",
			"lineStartRow",
			"lineEndRow",
			"lineStartCol",
			"stepEccentricity",
			"stepInclination",
		};

	mwArray _configurationStruct(1, 1, sizeof(_configurationInputDataFields)/sizeof(char*), 
		_configurationInputDataFields);
		
	_configurationStruct("nLinesRow",1,1) = _nLinesRow;
	_configurationStruct("nLinesCol",1,1) = _nLinesCol;
	_configurationStruct("nEdge",1,1) = _nEdge;
	_configurationStruct("edgeFraction",1,1) = _edgeFraction;
	_configurationStruct("twoByTwoMaskIndex",1,1) = _twoByTwoMaskIndex;
	_configurationStruct("lineStartRow",1,1) = _lineStartRow;
	_configurationStruct("lineEndRow",1,1) = _lineEndRow;
	_configurationStruct("lineStartCol",1,1) = _lineStartCol;	
	_configurationStruct("lineEndCol",1,1) = _lineEndCol;

#if _DEBUG_DISPLAY
	std::cout << "built _configurationStruct" << _configurationStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create bpa input data structure
	//-----------------------------------------------------------------------------------
	const char* _bpaInputDataFields[] =
		{ "moduleOutputImage", 
			"bpaConfigurationStruct",
			"debug",
		};

	mwArray bpaInputStruct(1, 1, sizeof(_bpaInputDataFields)/sizeof(char*), 
		_bpaInputDataFields);
		
	bpaInputStruct("moduleOutputImage",1,1) = _moduleOutputImage;
	bpaInputStruct("bpaConfigurationStruct",1,1) = _configurationStruct;
	bpaInputStruct("debug",1,1) = _debug;
	
#if _DEBUG_DISPLAY
	std::cout << "built bpaInputStruct" << bpaInputStruct << std::endl;
#endif

	//-----------------------------------------------------------------------------------
	// create bpa output structure
	//-----------------------------------------------------------------------------------
	const char* _bpaResultsDataFields[] =
		{ "maskTable", 
			"errorStruct"
		};
	mwArray bpaResultsStruct(1, 1, sizeof(_bpaResultsDataFields)/sizeof(char*), 
		_bpaResultsDataFields);

	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	// call BPA matlab controller
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	//-----------------------------------------------------------------------------------
	
	// 1 corresponds to number of output arguments
	bpa_matlab_controller(1, bpaResultsStruct, bpaInputStruct);
	
	//-----------------------------------------------------------------------------------
	// create bpa output structure
	//-----------------------------------------------------------------------------------
	
	int numFields = bpaResultsStruct.NumberOfFields();
#if _DEBUG_DISPLAY
	std::cout << "# of fields in return struct is " << numFields << std::endl;
#endif
	for (int f=0; f<numFields; f++) {
		const char *_fname = bpaResultsStruct.GetFieldName(f);
		std::cout << _fname << std::endl;		
		if (!strcmp(_fname, "_errorStruct")) {
			_errorStruct = bpaResultsStruct("_errorStruct", 1, 1);
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
		else if (!strcmp(_fname, "targetDefinition")) {
			mwArray _targetDefinitionStruct = bpaResultsStruct("targetDefinition", 1, 1);			
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

