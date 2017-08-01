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


#include "PdcController.h"

#include "libpdc.h"

#include <iostream>
#include <string>
#include <vector>

PdcController::PdcController()
{}

PdcController::~PdcController()
{}

int PdcController::doScience( PdcInputs& inputs, PdcOutputs& outputs )
{

    // Call application and library initialization. Perform this
    // initialization before calling any API functions or
    // Compiler-generated libraries.
    // mclInitializeApplication returns a Boolean status code.
    // A return value of true indicates successful initialization, and false indicates failure.



    // mclInitializeApplication allows you to set the global MCR options.
    // They apply equally to all MCR instances. You must set these options before
    // creating your first MCR instance.
    // These functions are necessary because some MCR options such as whether or not to start Java,
    // the location of the MCR itself, whether or not to use the MATLAB JIT feature, and so on,
    // are set when the first MCR instance starts and cannot be changed by subsequent instances of the MCR.
    // always use this code for failure to initialize the application

    if (!mclInitializeApplication(NULL,0))
    {
        outputs.errorCode = 2000;
        outputs.errorText = "PDC CSCI:PdcController::doScience - could not initialize mclInitializeApplication ";
        std::cerr << outputs.errorText << std::endl;
        return outputs.errorCode;
    }

    if( !libpdcInitialize() )
    {
        outputs.errorCode = 2001;
        outputs.errorText = "PDC CSCI:PdcController::doScience - could not initialize libpdc library ";
        std::cerr << outputs.errorText << std::endl;
        return outputs.errorCode;
    }

    try
    {
        performPreSearchDataConditioning(inputs, outputs);
        outputs.errorCode = 0;
        outputs.errorText = "PDC CSCI:PdcController::doScience - SUCCESS";
    }
    catch (const mwException& e)
    {
        outputs.errorCode = 2002;
        outputs.errorText = "PDC CSCI:PdcController::doScience - performPreSearchDataConditioning method failed\n ";
        outputs.errorText.append(e.what());
        std::cerr << outputs.errorText << std::endl;
        return outputs.errorCode;
    }
    catch (...)
    {
        outputs.errorCode = 9999;
        outputs.errorText = "PDC CSCI:PdcController::doScience - performPreSearchDataConditioning method failed\n ";
        outputs.errorText.append("Unexpected error thrown");
        std::cerr << outputs.errorText << std::endl;
        return outputs.errorCode;
    }
    // Call the application and library termination routine
    libpdcTerminate();

    mclTerminateApplication();
    return outputs.errorCode;

}
int PdcController::performPreSearchDataConditioning( PdcInputs& inputs, PdcOutputs& outputs )
{

    //-----------------------------------------------------------------------------------
    // copy input parameters from inputs object to C++ primitive data types
    //-----------------------------------------------------------------------------------


    int _iNumberOfAncillaryTimeSeries = inputs.ancillaryDataList.size(); // number of ancillary time series for this CCD  module output
    int _iNumberOfTargets = inputs.targetInputDataList.size(); // number of targets from the same CCD module output in a unit of work

    // time stamps for missing cadences will be zero, but the length of this vector
    // is guaranteed to indicate how many cadences should be there
    int _iNumberOfCadences = inputs.mjdCadenceStartTimes.size();

    int _nWaveletCoefficients = inputs.waveletFilterCoefficients.size();

    std::cout << "Number of ancillary time series: " << _iNumberOfAncillaryTimeSeries << std::endl;
    std::cout << "Number of target stars: " << _iNumberOfTargets << std::endl;
    std::cout << "Number of cadences: " << _iNumberOfCadences << std::endl;



    // from "The C++ Standard Library" by N.M. Josuttis
    // The C++ standard library does not clearly state whether the elements of
    // a vector are required to be in continguous memory; however, it is the intention
    // that this is guaranteed. This guarantee has some important consequences. It means that
    // you could use a vector in all cases in which you could use a dynamic array.


    //-----------------------------------------------------------------------------------
    // create input Matlab mwArrays
    //-----------------------------------------------------------------------------------
    // Step 1: copy parameters from C++ object to Matlab structure
    //-----------------------------------------------------------------------------------
    // create input fields for the structures
    mwArray _designMatrixPolynomialOrder(1, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _minLongDataGapSize(1, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _outlierThresholdSigma(1, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _outlierScanWindowSize(1, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _medianFilterLength(1, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _modelOrderAR(1, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _correlationWindowLengthMultiplier(1, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _waveletFilterCoefficients(_nWaveletCoefficients, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _mjdCadenceStartTimes(_iNumberOfCadences,1, mxDOUBLE_CLASS, mxREAL);
    mwArray _mjdCadenceEndTimes(_iNumberOfCadences, 1, mxDOUBLE_CLASS, mxREAL);
    mwArray _debugFlag(1, 1, mxDOUBLE_CLASS, mxREAL);

    // now populate with data from the inputs object (this amounts to a copy of C++ data to Matlab mwArrays)
    _designMatrixPolynomialOrder.SetData(&inputs.designMatrixPolynomialOrder,1);
    _minLongDataGapSize.SetData(&inputs.minLongDataGapSize,1);
    _outlierThresholdSigma.SetData(&inputs.outlierThresholdSigma,1);
    _outlierScanWindowSize.SetData(&inputs.outlierScanWindowSize,1);
    _modelOrderAR.SetData(&inputs.modelOrderAr,1);
    _correlationWindowLengthMultiplier.SetData(&inputs.correlationWindowLengthMultiplier,1);
    _waveletFilterCoefficients.SetData(&inputs.waveletFilterCoefficients[0],_nWaveletCoefficients);
    _medianFilterLength.SetData(&inputs.medianFilterLength,1);
    _mjdCadenceStartTimes.SetData(&inputs.mjdCadenceStartTimes[0],_iNumberOfCadences); // STL vector
    _mjdCadenceEndTimes.SetData(&inputs.mjdCadenceEndTimes[0],_iNumberOfCadences);
    _debugFlag.SetData(&inputs.debugFlag,1);

    // create parameter Matlab structure and populate the fields
    // parameter structure
    const char* _parameterFields[] =
        { "designMatrixPolynomialOrder", "minLongDataGapSize",
          "outlierThresholdSigma", "outlierScanWindowSize",
          "medianFilterLength", "modelOrderAR", "correlationWindowLengthMultiplier",
          "waveletFilterCoefficients", "mjdCadenceStartTimes",
          "mjdCadenceEndTimes", "debugFlag"
        };

    mwArray pdcParametersStruct(1, 1, 11, _parameterFields);

    pdcParametersStruct.Get(1,1).Set(_designMatrixPolynomialOrder);
    pdcParametersStruct.Get(1,2).Set(_minLongDataGapSize);
    pdcParametersStruct.Get(1,3).Set(_outlierThresholdSigma);
    pdcParametersStruct.Get(1,4).Set(_outlierScanWindowSize);
    pdcParametersStruct.Get(1,5).Set(_medianFilterLength);
    pdcParametersStruct.Get(1,6).Set(_modelOrderAR);
    pdcParametersStruct.Get(1,7).Set(_correlationWindowLengthMultiplier);
    pdcParametersStruct.Get(1,8).Set(_waveletFilterCoefficients);
    pdcParametersStruct.Get(1,9).Set(_mjdCadenceStartTimes);
    pdcParametersStruct.Get(1,10).Set(_mjdCadenceEndTimes);
    pdcParametersStruct.Get(1,11).Set(_debugFlag);

    //-----------------------------------------------------------------------------------
    // Step 2: copy input target data from C++ object to Matlab structure
    //-----------------------------------------------------------------------------------
    // target input data structure
    const char* _targetInputDataFields[] =
        { "relativeFlux", "relativeFluxDataGapIndicators",
          "uncertaintiesInRelativeFlux"
        };
    mwArray pdcTargetInputDataStruct(1, _iNumberOfTargets, 3, _targetInputDataFields );

    // create the basic target data struct which will be assembled and
    // inserted into pdcTargetInputDataStruct one at atime
    // (just like std::vector < std::vector< > >)

    for(int j = 1; j <= _iNumberOfTargets; j++) //Matlab uses 1 -based indexing, C++ 0 based indexing
    {

        char tempCharArray[_iNumberOfCadences];

        // create input fields for the structures
        mwArray _relativeFlux(_iNumberOfCadences, 1,  mxDOUBLE_CLASS, mxREAL);
        mwArray _relativeFluxDataGapIndicators(_iNumberOfCadences,1,  mxLOGICAL_CLASS, mxREAL);
        mwArray _uncertaintiesInRelativeFlux(_iNumberOfCadences, 1,  mxDOUBLE_CLASS, mxREAL);


        // Copy data from supplied numeric buffer into mwarray
        _relativeFlux.SetData((&inputs.targetInputDataList[j-1].relativeFlux[0]),_iNumberOfCadences);

        // Clone() method creates a copy of an existing array.
        // The new array contains a deep copy of the input array
        // if this method is not used, then pdcTargetInputDataStruct.relativeFlux will point to the
        // memory location of _relativeFlux (Set method creates a SharedCopy);
        // then subsequent allocations will also point to _relativeFlux
        // unless a new variable is declared for each 'j'
        pdcTargetInputDataStruct("relativeFlux",1,j) = _relativeFlux.Clone();

        // Be Aware: vector<bool> uses only one bit for an element - a drawback since in C++, the smallest addressable value
        // must have a size of at least 1 byte - so needs special handling for references and iterators.
        for(int k = 0; k < _iNumberOfCadences; k++)
        {
            tempCharArray[k] = (char)inputs.targetInputDataList[j-1].relativeFluxDataGapIndicators[k];
        }


        _relativeFluxDataGapIndicators.SetData(tempCharArray,_iNumberOfCadences);

        pdcTargetInputDataStruct("relativeFluxDataGapIndicators",1,j) = _relativeFluxDataGapIndicators.Clone();

        _uncertaintiesInRelativeFlux.SetData((&inputs.targetInputDataList[j-1].uncertaintiesInRelativeFlux[0]),_iNumberOfCadences);

        pdcTargetInputDataStruct("uncertaintiesInRelativeFlux",1,j) = _uncertaintiesInRelativeFlux.Clone();


    }

    //-----------------------------------------------------------------------------------
    // Step 3: copy input target data from C++ object to Matlab structure
    //-----------------------------------------------------------------------------------
    // ancillary data structure
    const char* _ancillaryDataFields[] =
        { "mnemonic", "timestamps","values", "uncertainties",
          "isAncillaryEngineeringData", "dataGapIndicators"
        };

    mwArray pdcAncillaryDataStruct(1, _iNumberOfAncillaryTimeSeries,6, _ancillaryDataFields);


    for(int j = 1; j <= _iNumberOfAncillaryTimeSeries; j++) //Matlab uses 1 -based indexing, C++ 0 based indexing
    {


        int _nTimestamps, _nUncertainties, _nValues, _nGaps, _nLength;
        char tempChar, *temp2CharArray;

        // _mnemonic is a mwstring type; remember to include <string>
        mwArray _mnemonic(inputs.ancillaryDataList[j-1].mnemonic.data());
        pdcAncillaryDataStruct.Get("mnemonic",1,j) =  _mnemonic.Clone();

        if(&inputs.ancillaryDataList[j-1].timestamps[0] == NULL)
        {
            _nTimestamps = 0;
        }
        else
        {
            _nTimestamps = inputs.ancillaryDataList[j-1].timestamps.size();
        }

        if(_nTimestamps > 0)
        {
            mwArray _timestamps(_nTimestamps,1, mxDOUBLE_CLASS, mxREAL);
            _timestamps.SetData(&(inputs.ancillaryDataList[j-1].timestamps[0]),_nTimestamps);
            pdcAncillaryDataStruct.Get("timestamps",1,j) = _timestamps.Clone();
        }

        // for ancillary time series generated by other CSCIs, the timestamps will be empty
        // so find out how long the timeseries is
        _nValues = inputs.ancillaryDataList[j-1].values.size();
        mwArray _values(_nValues,1, mxDOUBLE_CLASS, mxREAL);
        _values.SetData(&(inputs.ancillaryDataList[j-1].values[0]),_nValues);
        pdcAncillaryDataStruct.Get("values",1,j) = _values.Clone();

        // there may be just one value or one value per contact
        _nUncertainties = inputs.ancillaryDataList[j-1].uncertainties.size();
        mwArray _uncertainties(_nUncertainties,1,mxDOUBLE_CLASS,mxREAL);
        _uncertainties.SetData(&(inputs.ancillaryDataList[j-1].uncertainties[0]),_nUncertainties);
        pdcAncillaryDataStruct.Get("uncertainties",1,j) = _uncertainties.Clone();

        tempChar = (char)inputs.ancillaryDataList[j-1].isAncillaryEngineeringData;
        mwArray _isAncillaryEngineeringData(1,1,mxLOGICAL_CLASS);
        _isAncillaryEngineeringData.SetData(&(tempChar),1);
        // same as cloning which is not available for class mwString
        pdcAncillaryDataStruct.Get("isAncillaryEngineeringData",1,j) = _isAncillaryEngineeringData.Clone();


        if(inputs.ancillaryDataList[j-1].dataGapIndicators.size() == 0)
        {
            _nGaps = 0;
        }
        else
        {
            _nGaps = inputs.ancillaryDataList[j-1].dataGapIndicators.size();
        }

        if(_nGaps > 0)
        {
            // repeated allocation and deletion - no way to avoid it as '_nGaps' varies
            // from one ancillary data type to the next
            temp2CharArray = new char[_nGaps];
            for(int k = 0; k < _nGaps; k++)
            {
                temp2CharArray[k] = (char)inputs.ancillaryDataList[j-1].dataGapIndicators[k];
            }

            mwArray _dataGapIndicators(_nGaps,1,mxLOGICAL_CLASS);
            _dataGapIndicators.SetData(temp2CharArray,_nGaps);
            pdcAncillaryDataStruct.Get("dataGapIndicators",1,j) = _dataGapIndicators.Clone();
            delete [] temp2CharArray;
        }
    }

    //-----------------------------------------------------------------------------------
    // create empty output Matlab structure
    //-----------------------------------------------------------------------------------

    const char* _targetOutputDataFields[] =
        { "correctedFlux", "uncertaintiesInCorrectedFlux",
          "outlierIndices", "outlierValues","filledIndices"
        };

    mwArray pdcResultsStruct(1, _iNumberOfTargets,  5, _targetOutputDataFields);


    //-----------------------------------------------------------------------------------
    // call PDC Matlab Controller
    //-----------------------------------------------------------------------------------


    // 1 corresponds to number of output arguments
    pdc_matlab_controller(1, pdcResultsStruct, pdcParametersStruct,
                          pdcAncillaryDataStruct, pdcTargetInputDataStruct);

    //-----------------------------------------------------------------------------------
    // create output fields (Matlab mwArrays) to receive results
    //-----------------------------------------------------------------------------------

    mwArray _correctedFlux;
    mwArray _uncertaintiesInCorrectedFlux;
    mwArray _outlierIndices;
    mwArray _outlierValues;
    mwArray _filledIndices;

    for(int j = 1; j <= _iNumberOfTargets; j++)
    {
        // instantiate TargetOutputData class
        TargetOutputData targetOutputData;
        int _nFilledIndices, _nOutliers, _nValues;
        //-----------------------------------------------------------------------------------
        // begin populating targetOutputData C++ object
        //-----------------------------------------------------------------------------------
        // get the correctedFlux field from jth element of the structure array pdcResultsStruct
        _correctedFlux = pdcResultsStruct.Get("correctedFlux",1,j);
        _uncertaintiesInCorrectedFlux = pdcResultsStruct.Get("uncertaintiesInCorrectedFlux",1,j);
        _outlierIndices = pdcResultsStruct.Get("outlierIndices",1,j);
        _outlierValues = pdcResultsStruct.Get("outlierValues",1,j);
        _filledIndices = pdcResultsStruct.Get("filledIndices",1,j);

        // std::cout << "j/iNumberOfTargets = " << j << "/"  << _iNumberOfTargets<< std::endl;
        // temporary - for debug purposes only



        // populate the targetOutputData object
        _nValues = _correctedFlux.NumberOfElements();
        _nOutliers = _outlierIndices.NumberOfElements();
        _nFilledIndices = _filledIndices.NumberOfElements();

        float _tempFloat;
        int  _tempInt;

        // reserve to avoid reallocation
        targetOutputData.correctedFlux.reserve(_nValues);
        targetOutputData.uncertaintiesInCorrectedFlux.reserve(_nValues);
        targetOutputData.outlierValues.reserve(_nOutliers);
        targetOutputData.outlierIndices.reserve(_nOutliers);
        targetOutputData.filledIndices.reserve(_nFilledIndices);

        for(int k = 1; k <= _nValues; k++)
        {
            // push_back appends a copy of the element at the end
            _tempFloat = (float)_correctedFlux(k); // check for any type-casting related problems
            targetOutputData.correctedFlux.push_back(_tempFloat);

            _tempFloat = (float)_uncertaintiesInCorrectedFlux(k);
            targetOutputData.uncertaintiesInCorrectedFlux.push_back(_tempFloat);
        }
        for(int k = 1; k <= _nOutliers; k++)
        {
            // push_back appends a copy of the element at the end
            _tempFloat = (float)_outlierValues(k);
            targetOutputData.outlierValues.push_back(_tempFloat);
            _tempInt = (int)_outlierIndices(k);
            targetOutputData.outlierIndices.push_back(_tempInt);
        }
        for(int k = 1; k <= _nFilledIndices; k++)
        {
            // push_back appends a copy of the element at the end
            _tempInt = (int)_filledIndices(k);
            targetOutputData.filledIndices.push_back(_tempInt);
        }
        //-----------------------------------------------------------------------------------
        // end populating targetOutputData C++ object
        //-----------------------------------------------------------------------------------

        // insert this object into outputs object
        outputs.targetOutputDataList.push_back(targetOutputData);

        // clear the populated fields so they can receive the next target's results
        // empties the object
        targetOutputData.correctedFlux.clear();
        targetOutputData.uncertaintiesInCorrectedFlux.clear();
        targetOutputData.outlierValues.clear();
        targetOutputData.outlierIndices.clear();
        targetOutputData.filledIndices.clear();

    }
    std::cout << "Finished... " << std::endl;

    return 0;
    //-----------------------------------------------------------------------

}



