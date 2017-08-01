/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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


#include "RequantController.h"

#include "librequantization.h"

#include <iostream>

RequantController::RequantController(){
}

RequantController::~RequantController(){
}

int RequantController::doScience( RequantInputs& inputs, RequantOutputs& outputs ){
//
//	// Call application and library initialization. Perform this 
//	// initialization before calling any API functions or
//	// Compiler-generated libraries. 
//	// mclInitializeApplication returns a Boolean status code. 
//	// A return value of true indicates successful initialization, and false indicates failure.
//	
//
//	
//	// mclInitializeApplication allows you to set the global MCR options.
//	// They apply equally to all MCR instances. You must set these options before 
//	// creating your first MCR instance.
//	// These functions are necessary because some MCR options such as whether or not to start Java, 
//	// the location of the MCR itself, whether or not to use the MATLAB JIT feature, and so on, 
//	// are set when the first MCR instance starts and cannot be changed by subsequent instances of the MCR.		
//	// always use this code for failure to initialize the application
//		
//	if (!mclInitializeApplication(NULL,0)) 
//	{
//		outputs.errorCode = 2000;
//		outputs.errorText = "GAR CSCI:RequantController::doScience - could not initialize mclInitializeApplication ";
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}
//
//	if( !librequantizationInitialize() )
//	{
//		outputs.errorCode = 2001;
//		outputs.errorText = "GAR CSCI:RequantController::doScience - could not initialize librequantization library ";
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}
//
//	try
//	{
//		generateRequantizationTable(inputs, outputs);
//		outputs.errorCode = 0;
//		outputs.errorText = "GAR CSCI:RequantController::doScience - SUCCESS";
//	}
//	catch (const mwException& e)
//	{
//		outputs.errorCode = 2002;
//		outputs.errorText = "GAR CSCI:RequantController::doScience - generateRequantizationTable method failed\n ";
//		outputs.errorText.append(e.what());
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}
//	catch (...)
//	{
//		outputs.errorCode = 9999;
//		outputs.errorText = "GAR CSCI:RequantController::doScience - generateRequantizationTable method failed\n ";
//		outputs.errorText.append("Unexpected error thrown");
//		std::cerr << outputs.errorText << std::endl;
//		return outputs.errorCode;
//	}     
//	// Call the application and library termination routine
//	librequantizationTerminate();
//
//	mclTerminateApplication();
//	return outputs.errorCode;

}

//int RequantController::generateRequantizationTable( RequantInputs& inputs, RequantOutputs& outputs ){
//
//	// all input parameters are scalar
//	std::cout << "electronsPerADU: " << inputs.electronsPerADU << std::endl;
//	std::cout << "exposuresPerLongCadence: " << inputs.exposuresPerLongCadence << std::endl;
//	std::cout << "guardBandHigh: " << inputs.guardBandHigh << std::endl;
//	std::cout << "guardBandLow: " << inputs.guardBandLow << std::endl;
//	std::cout << "numberOfBitsInADC: " << inputs.numberOfBitsInADC << std::endl;
//	std::cout << "quantizationFraction: " << inputs.quantizationFraction << std::endl;
//	std::cout << "readNoiseInADU: " << inputs.readNoiseInADU << std::endl;
//	std::cout << "tableSize: " << inputs.tableSize << std::endl;
//	std::cout << "debugFlag: " << inputs.debugFlag << std::endl;
//	
//	//-----------------------------------------------------------------------------------
//	// create input Matlab mwArrays
//	//-----------------------------------------------------------------------------------
//	// create input mwArrays
//	mwArray _electronsPerADU(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _exposuresPerLongCadence(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _guardBandHigh(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _guardBandLow(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _numberOfBitsInADC(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _quantizationFraction(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _readNoiseInADU(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _tableSize(1,1, mxDOUBLE_CLASS, mxREAL);
//	mwArray _debugFlag(1, 1, mxDOUBLE_CLASS, mxREAL);
//
//	//-----------------------------------------------------------------------------------
//	// copy C++ primitive data types to Matlab mwArrays
//	// If the underlying array is not of the same type as the 
//	// input buffer, the data is converted to this type as it is copied.
//	// If a conversion cannot be made, an mwException is thrown. 
//	//-----------------------------------------------------------------------------------
//	_electronsPerADU.SetData(&inputs.electronsPerADU,1);
//	_exposuresPerLongCadence.SetData(&inputs.exposuresPerLongCadence,1);
//	_guardBandHigh.SetData(&inputs.guardBandHigh,1);
//	_guardBandLow.SetData(&inputs.guardBandLow,1);
//	_numberOfBitsInADC.SetData(&inputs.numberOfBitsInADC,1);
//	_quantizationFraction.SetData(&inputs.quantizationFraction,1);
//	_readNoiseInADU.SetData(&inputs.readNoiseInADU,1);
//	_tableSize.SetData(&inputs.tableSize,1);
//	_debugFlag.SetData(&inputs.debugFlag,1);
//
//	//-----------------------------------------------------------------------------------
//	// create input Matlab structure and populate the fields
//	// the field names in the char array _inputFields must match 
//	// the field names used in the MATLAB scripts 
//	//-----------------------------------------------------------------------------------
//	const char* _inputFields[] = { "electronsPerADU", "numberOfExposuresPerLongCadence", "guardBandHigh",
//							 "guardBandLow", "numberOfBitsInADC", "quantizationFraction", 
//							 "readNoiseInADU", "tableSize", "debugFlag" };
//	mwArray requantizationInputStruct(1, 1, 9, _inputFields);
//	
//	requantizationInputStruct.Get(1,1).Set(_electronsPerADU);
//	requantizationInputStruct.Get(1,2).Set(_exposuresPerLongCadence);
//	requantizationInputStruct.Get(1,3).Set(_guardBandHigh);
//	requantizationInputStruct.Get(1,4).Set(_guardBandLow);
//	requantizationInputStruct.Get(1,5).Set(_numberOfBitsInADC);
//	requantizationInputStruct.Get(1,6).Set(_quantizationFraction);
//	requantizationInputStruct.Get(1,7).Set(_readNoiseInADU);
//	requantizationInputStruct.Get(1,8).Set(_tableSize);
//	requantizationInputStruct.Get(1,9).Set(_debugFlag);
//	
//	
//	
//	//-----------------------------------------------------------------------------------
//	// create output Matlab structure
//	//-----------------------------------------------------------------------------------
//
//	const char* _outputFields[] = {"requantizationTable"};
//	mwArray requantizationResultsStruct(1, 1,  1, _outputFields);
//	
//	
//	
//	// 1 corresponds to number of output arguments
//	requantization_matlab_controller(1, requantizationResultsStruct, requantizationInputStruct);
//                           
//	//-----------------------------------------------------------------------------------
//	// create output Matlab mwArrays to receive results
//	//-----------------------------------------------------------------------------------
//		
//	mwArray _requantizationTable;
//	
//	_requantizationTable = requantizationResultsStruct.Get("requantizationTable",1,1);
//	
//	//-----------------------------------------------------------------------------------
//	// copy results to C++ object outputs
//	//-----------------------------------------------------------------------------------
//	
//	 
//    // reserve memory to avoid reallocation      
//	 outputs.requantizationTable.reserve(inputs.tableSize);
//	 int _tempInt;
//     for(int j = 0; j < inputs.tableSize; j++){
//     	_tempInt =  (int)_requantizationTable(j+1);// MATLAB uses 1-based indexing 
//     	outputs.requantizationTable.push_back(_tempInt);// do not use [j] notation 
//     }
//
//
//	return 0;
//	//-----------------------------------------------------------------------
//
//}


