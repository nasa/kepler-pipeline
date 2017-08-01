/* ------------------------------------------------------------------------------ 
/*   MEX file name: nr_sort_array.c
/* ------------------------------------------------------------------------------ 
/*   Gateway function: 
/*
/*   void mexFunction( int nlhs,	mxArray	*plhs[], int nrhs, const mxArray
/*   *prhs[] )
/* ------------------------------------------------------------------------------ 
/*   mexFunction - Entry point from Matlab. This gateway function receives
/*   inputs from MATLAB which are in double and turns them into integers
/*   when appropriate and invokes the computational function
/*   "build_huffman_code_tree".
/*
/*   The plhs[] and prhs[] parameters are vectors that contain pointers to
/*   each left-hand side (output) variable and each right-hand side (input)
/*   variable, respectively. 
/*   Accordingly, plhs[0] contains a pointer to the first left-hand side
/*   argument, plhs[1] contains a pointer to the second left-hand side
/*   argument, and so on. Likewise, prhs[0] contains a pointer to the first
/*   right-hand side argument, prhs[1] points to the second, and so on. 
/*
/*   nlhs - number	of left hand side arguments (outputs) 
/*   plhs[0] contains a pointer to the first left-hand side (outputs)
/*   argument which is the sorted array
/*
/*   plhs[1] contains a pointer to the second left-hand side (outputs)
/*   argument which is the sort index
/* 
/*   nrhs - number	of right hand side arguments (inputs)
/*   prhs[0]	 contains pointer to input array
 * 
 * 
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
/* ------------------------------------------------------------------------------ */
#include "mex.h"
#include "matrix.h"
#define SWAP(a, b) iTemp = (a);(a)  =  (b);(b) = iTemp;
#define M 7



struct tempData
{
    double *identicalElementsIndex;
    int *sortedIndex;
    int *iStack;
    int  *sortedIdenticalElementsIndex;
};
/*---------------------------------------------------------------------------------------------------
/*   void get_sort_index(int n, double *inputArray, int *sortIndex, int *iStack ) 
/*   This function is very similar to MATLAB's  [B,IX] = sort(A, 'ascend')
/*   and sorts the elements along different dimensions of an array, and
/*   inputArrayanges those elements in ascending order. Yet, this function is not
/*   identical to MATLAB's [B,IX] = sort(A, 'ascend') in the following
/*   respect:
/*       1.  The sorted array  B is not available
/*       2.  For elements of A with identical values, the order of these
/*           elements is *not*  preserved in the sorted list. 
/*
/*     This function is a slighltly modified version of the code indexxx.x
/*     given in  page 339 of Numerical Recipes in C. Unlike the Numerical
/*     Recipes in C version, array index starts from 0 in this function.
/*     This algorithm constructs the index table by Quicksort algorithm and
/*     is faster (by a factor of ~10) than GNU Scientific Library's
/*     gsl_heapsort_index.c and is slower than MATLAB's sort(A, 'ascend') by
/*     a factor of 2.
/*
/*   Indexes an array inputArray[0..n-1], i.e., outputs the array sortIndex[0..n-1] such
/*   that inputArray[sortIndex[j]] is in ascending order for j = 0, 1, 2, N-1. The input
/*   array inputArray is not changed.
/* 
/*---------------------------------------------------------------------------------------------------*/
void get_sort_index(int nLength, double *inputArray, int *sortIndex, int *iStack )
{
    int iGreaterIndex,  jthSortedIndex,  iLength,  jLessIndex,  kMedianIndex,  mSplitIndex = 0;
    int jStack = -1, iTemp = 0;
    double aDouble;
    iLength = (nLength-1);
    /* 0 based indexing*/
    
    for (jLessIndex = 0; jLessIndex < nLength; jLessIndex++){
        sortIndex[jLessIndex] = jLessIndex;
    }
    
    for (;;) {
        if (iLength-mSplitIndex < M) {                                                          /* insertion sort when subarray is small enough <= M elements */
            for (jLessIndex = mSplitIndex+1; jLessIndex <= iLength; jLessIndex++) {             /* pick out each element in turn   */
                jthSortedIndex =  sortIndex[jLessIndex];
                aDouble = inputArray[jthSortedIndex];
                for (iGreaterIndex = jLessIndex-1; iGreaterIndex >= mSplitIndex; iGreaterIndex--) {  /*    */
                    if (inputArray[sortIndex[iGreaterIndex]] <= aDouble) break;
                    sortIndex[iGreaterIndex+1] = sortIndex[iGreaterIndex];  /*    */
                }
                sortIndex[iGreaterIndex+1] = jthSortedIndex;
            }
            if (jStack < 0) break;
            iLength = iStack[jStack--];                                                         /* pop stack and begin a new round of partitioning   */
            mSplitIndex = iStack[jStack--];
        } else {                                                                                /*  quick sort */
            kMedianIndex = (mSplitIndex+iLength) >> 1;                                          /* choose median of left, center, and right elements as paritioning element a    */
            SWAP(sortIndex[kMedianIndex], sortIndex[mSplitIndex+1]);                            /* also rearrange so that a[mSplitIndex] <= a[mSplitIndex+1] <= a[iLength]  */
            if (inputArray[sortIndex[mSplitIndex]] > inputArray[sortIndex[iLength]]) {
                SWAP(sortIndex[mSplitIndex], sortIndex[iLength])
            }
            if (inputArray[sortIndex[mSplitIndex+1]] > inputArray[sortIndex[iLength]]) {
                SWAP(sortIndex[mSplitIndex+1], sortIndex[iLength])
            }
            if (inputArray[sortIndex[mSplitIndex]] > inputArray[sortIndex[mSplitIndex+1]]) {
                SWAP(sortIndex[mSplitIndex], sortIndex[mSplitIndex+1])
            }
            iGreaterIndex = mSplitIndex+1;                                                      /* initialize pointers for partitioning   */
            jLessIndex = iLength;
            jthSortedIndex = sortIndex[mSplitIndex+1];
            aDouble = inputArray[jthSortedIndex];                                               /* partitioning element    */
            for (;;) {                                                                          /* beginning of innermost loop   */
                do iGreaterIndex++; while (inputArray[sortIndex[iGreaterIndex]] < aDouble);     /* scan up to find element > aDouble   */
                do jLessIndex--; while (inputArray[sortIndex[jLessIndex]] > aDouble);           /* scan up to find element < aDouble   */
                if (jLessIndex < iGreaterIndex) break;                                          /* pointers crossed, partitioning is complete   */
                SWAP(sortIndex[iGreaterIndex], sortIndex[jLessIndex])                           /* exchange location index   */
            }
            sortIndex[mSplitIndex+1] = sortIndex[jLessIndex];                                   /*    */
            sortIndex[jLessIndex] = jthSortedIndex;
            jStack += 2;
            if (iLength-iGreaterIndex+1 >=  jLessIndex-mSplitIndex) {                            /*  push pointers to a large subarray on stack, process smaller subarray immediately   */
                iStack[jStack] = iLength;
                iStack[jStack-1] = iGreaterIndex;
                iLength = jLessIndex-1;
            } else {
                iStack[jStack] = jLessIndex-1;
                iStack[jStack-1] = mSplitIndex;
                mSplitIndex = iGreaterIndex;
            }
        }
    }
}
#undef M
#undef SWAP
/*---------------------------------------------------------------------------------------------------
/*     void  make_sorted_index_compatible_to_matlab(int nLength, double *identicalElementsIndex, 
/*     int *sortedIdenticalElementsIndex, double *inputArray, int *sortedIndex, int *iStack)
/*
/*     This function ensures that for elements of A with identical values,
/*     the order of these elements is preserved in the sorted list. This
/*     ensures compatibility with MATLAB's sort function and alows for
/*     comparing the Huffman codewords generated in two ways by: 
/*          (1) MATLAB function 
/*          (2) MATLAB calling optimized MEX code.
/*---------------------------------------------------------------------------------------------------*/
void  make_sorted_index_compatible_to_matlab(int nLength, double *identicalElementsIndex, 
int *sortedIdenticalElementsIndex, double *inputArray, int *sortedIndex, int *iStack)
{
    
    int i, j,  k,  m = 0;
    double val1, val2;
    int nIdenticalValues;
    
    
    /* locate identical elements if there are any*/
    
    for(i = 0; i < nLength-1; i++){
        /* take two consecutive elements*/
        val1 = inputArray[sortedIndex[i]];
        val2 = inputArray[sortedIndex[i+1]];
        j = 0;
        if(val1 == val2){
            /* val1 at this point must always be > val2 as this list is in ascending order
            /* checking for equality only..*/
            identicalElementsIndex[0] = sortedIndex[i];
            identicalElementsIndex[1] = sortedIndex[++i];
            j = 1;
            /* see if there more than two elements of the same value */
            while ( (i < (nLength-1)) & (val2 == inputArray[sortedIndex[i+1]]) ){
                identicalElementsIndex[++j] = sortedIndex[++i];
            }
            
            nIdenticalValues = j+1;
            
            get_sort_index(nIdenticalValues, identicalElementsIndex, sortedIdenticalElementsIndex, iStack);
            
            
            
            for(k = 0; k < nIdenticalValues; k++){
                m = i - nIdenticalValues+1+ k;
                sortedIndex[m] = (int) identicalElementsIndex[sortedIdenticalElementsIndex[k]];
            }
        }
    }
}

/*---------------------------------------------------------------------------------------------------
/*     void nr_sort_array(int nLength, double *inputArray, int
/*     *sortedFinalIndex, struct tempData *tempDataStruct)
/* 
/*     This function calls the get_sort_index function first to get the sorted
/*     index table and then calls make_sorted_index_compatible_to_matlab to
/*     preserve the order of elements with identical values
/*---------------------------------------------------------------------------------------------------*/
void nr_sort_array(int nLength, double *inputArray, double *sortedFinalIndex, double *sortedArray,
struct tempData *tempDataStruct)
{
    
    double  *identicalElementsIndex;
    int *sortedIndex, *iStack,  *sortedIdenticalElementsIndex;
    int j;
    
    
    iStack = tempDataStruct->iStack;
    sortedIndex = tempDataStruct->sortedIndex;
    
    /* Call the Numerical Recipes C function*/
    get_sort_index(nLength, inputArray, sortedIndex, iStack);
    
    identicalElementsIndex = tempDataStruct->identicalElementsIndex;
    sortedIdenticalElementsIndex = tempDataStruct->sortedIdenticalElementsIndex;
    
    make_sorted_index_compatible_to_matlab(nLength, identicalElementsIndex, sortedIdenticalElementsIndex, inputArray, sortedIndex, iStack);
    
    /*copy back to double array*/
    
    for (j = 0; j < nLength; j++){
        /*
         * '1' is added to the sorted index to convert C's 0 based indexing to MATLAB's 1 based indexing convention
         **/
        sortedFinalIndex[j] = sortedIndex[j] + 1;
        sortedArray[j] = inputArray[sortedIndex[j]];
    }
}
/*---------------------------------------------------------------------------------------------------
 * MEX Gateway function
 * Accepts one input argument which is a vector of doubles (array to be
 * sorted) and returns two outputs arrays: one being the sorted array and
 *  the other being sorted array index
 *
 * Invoke this mex file at the MATLAB command prompt as [sorted_array, sort_index] = nr_sort_array[input_array]
 *
 * This function is identical to MATLAB's [sorted_array, sort_index] = nr_sort_array[input_array, 'ascend']
 *
 ---------------------------------------------------------------------------------------------------*/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray  *prhs[] )
{
    

    double nLength;
    int kLength;
    double *inputArray, *sortedFinalIndex, *sortedArray;
    
    struct tempData  *tempDataStruct;
    
    /*     Check for proper number of arguments.
        NOTE: You do not need an else statement when using
          mexErrMsgTxt within an if statement. It will never
          get to the else statement if mexErrMsgTxt is executed.
          (mexErrMsgTxt breaks you out of the MEX-file.)
    */
    if (nrhs !=   1)
        mexErrMsgTxt("one input required.");
    if (nlhs !=   2)
        mexErrMsgTxt("Two outputs required.");
    
    
    /* Create a pointer to the input matrix Trial periods.*/
    inputArray   =   mxGetPr(prhs[0]);
    /* Get the dimensions of the input */
    nLength =   mxGetM(prhs[0]);
    
    
    
    /* Set the output pointer to the MaxT */
    plhs[0]   =   mxCreateDoubleMatrix(nLength, 1,  mxREAL);
    plhs[1]   =   mxCreateDoubleMatrix(nLength, 1,  mxREAL);
    
    /* Create a C pointer to a copy of the output matrix. */
    sortedArray =  mxGetPr(plhs[0]);
    sortedFinalIndex  =   mxGetPr(plhs[1]);
    
    tempDataStruct = mxCalloc(1, sizeof(struct tempData));
    
    
    /* allocate memory  */
    kLength = (int) nLength;
    tempDataStruct->iStack = mxCalloc(kLength, sizeof(int));
    tempDataStruct->sortedIndex = mxCalloc(kLength, sizeof(int));
    tempDataStruct->identicalElementsIndex = mxCalloc(kLength, sizeof(double));
    tempDataStruct->sortedIdenticalElementsIndex = mxCalloc(kLength, sizeof(int));


    
    /* IMPORTAN++++++IMPORTANT+++++++IMPORTANT++++++++++++++++++++++++++++++++++
    /* Note    Inputs to a MEX-file are constant read-only mxArrays and
    /* should not be modified. Using mxSetCell* or mxSetField* to modify the
    /* cells or fields of an argument passed from MATLAB causes
    /* unpredictable results. Copy all the arrays that are likely to be
    /* written over, since the right-hand arguments are READ-ONLY!*/
    /* Call the C subroutine.
     **/
    nr_sort_array(nLength, inputArray, sortedFinalIndex, sortedArray, tempDataStruct);
    
    
    
    
    
    mxFree(tempDataStruct->iStack);
    mxFree(tempDataStruct->identicalElementsIndex);
    mxFree(tempDataStruct->sortedIdenticalElementsIndex);
    mxFree(tempDataStruct->sortedIndex);
    mxFree(tempDataStruct);
    
}

