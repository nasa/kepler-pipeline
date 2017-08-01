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


package gov.nasa.kepler.common;

import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.pi.PipelineException;


import java.util.*;

import org.apache.commons.lang.ArrayUtils;

/**
 * All pixel coordinates in this file should be one-based, NOT zero-based.
 * 
 * @author kester
 *
 */
public class FcConstants implements Persistable{
    // TODO Which section does this go in?
    public static final int    BITS_IN_ADC = 14;

    // TODO Which section does this go in?
    // Pixel Model Constants
    public static final float SATURATION_SPILL_UP_FRACTION = 0.50f;
    public static final double PARALLEL_CTE = 0.9996;
    public static final double SERIAL_CTE = 0.9996;
    
    // CCD constants:
    public static final int    nRowsImaging         = 1024;
    public static final int    nColsImaging         = 1100;
    public static final int    nLeadingBlack        = 12;
    public static final int    nTrailingBlack       = 20;
    public static final int    nVirtualSmear        = 26;
    public static final int    nMaskedSmear         = 20;
    public static final int    CCD_ROWS             = nMaskedSmear + nRowsImaging + nVirtualSmear;
    public static final int    CCD_COLUMNS          = nLeadingBlack + nColsImaging + nTrailingBlack;
    public static final int    LEADING_BLACK_START  = 0;
    public static final int    LEADING_BLACK_END    = nLeadingBlack - 1;
    public static final int    TRAILING_BLACK_START = nLeadingBlack + nColsImaging;
    public static final int    TRAILING_BLACK_END   = CCD_COLUMNS - 1;
    public static final int    MASKED_SMEAR_START   = 0;
    public static final int    MASKED_SMEAR_END     = nMaskedSmear - 1;
    public static final int    VIRTUAL_SMEAR_START  = nMaskedSmear + nRowsImaging;
    public static final int    VIRTUAL_SMEAR_END    = CCD_ROWS - 1;
    public static final int    CHARGE_INJECTION_ROW_START = 1059; // zero-based
    public static final int    CHARGE_INJECTION_ROW_END   = 1062; // zero-based
    public static final int    CHARGE_INJECTION_COLUMN_START = 12; // zero-based
    public static final int    CHARGE_INJECTION_COLUMN_END   = 1111; // zero-based
    
    public static final double PIXEL_SIZE_IN_MICRONS = 27.0;
    public static final double FGS_PIXEL_SIZE_IN_MICRONS = 13.0;
    
    public static final double crossTalkFactor     = 1.0e-6;

    //Geometry:
    public static final double pixel2arcsec = 3.9753235; // changed from 3.98;
	public static final double rad2arcsec = Math.toDegrees(1.0) * 3600.0;
	public static final double arcsec2rad = 1.0 / rad2arcsec;
    public static final double HALF_OFFSET_MODULE_ANGLE_DEGREES = 1.430;
    public static final double NOMINAL_FIRST_ROLL = 110.0; // nominal spacecraft roll for summer
    public static final double NOMINAL_CLOCKING_ANGLE = 13.0;
    // Module orientations:
    public static final int    nModules            = 21;
    public static final int    nModulesSpots       = 25;
    public static final int    OUTPUTS_PER_COLUMN  = 10; // the FOV is a 10x10 grid of spots for outputs
    public static final int    OUTPUTS_PER_ROW     = 10; // the FOV is a 10x10 grid of spots for outputs
    public static final int    nOutputsPerModule   =  4;
    public static final int[]  outputsList = { 1, 2, 3, 4 };
    public static final int    MODULE_OUTPUTS      = nModules * nOutputsPerModule;
    public static final int    centerModuleNumber  = 13;
    public static final int[]  modulesListWithGaps = {   0,  2,  3,  4,  0,
                                                         6,  7,  8,  9, 10,
                                                        11, 12, 13, 14, 15,
                                                        16, 17, 18, 19, 20,
                                                         0, 22, 23, 24,  0  };
    public static final int[]  modulesList         = {      2,  3,  4,   
                                                        6,  7,  8,  9, 10,
                                                       11, 12, 13, 14, 15,
                                                       16, 17, 18, 19, 20,
                                                           22, 23, 24       };
    
    // See GS-FS ICD section 5.2.5.5, Requantization Table.
    // The value of MEAN_BLACK_TABLE_MAX_VALUE comes from the size of the ADC
    // since it can never be more than the size of a single read.
    public static final int REQUANT_TABLE_LENGTH = (int) Math.pow(2.0, 16.0);
    public static final int REQUANT_TABLE_MIN_VALUE = 0;
    public static final int REQUANT_TABLE_MAX_VALUE = (int) Math.pow(2.0, 23.0) - 1;
    public static final int MEAN_BLACK_TABLE_LENGTH = MODULE_OUTPUTS;
    public static final int MEAN_BLACK_TABLE_MIN_VALUE = 0;
    public static final int MEAN_BLACK_TABLE_MAX_VALUE = (int) Math.pow(2, 14) - 1;

    // See GS-FS ICD section 5.2.5.4 Huffman Encoding Table.
    public static final int HUFFMAN_TABLE_LENGTH = 131071;
    public static final int HUFFMAN_CODE_WORD_LENGTH_LIMIT = 24;
    
    // Useful stellar constants:
    //
    public static final double TWELFTH_MAGNITUDE_ELECTRON_FLUX_PER_SECOND = 2.141e5;
    
    /**
     * Useful for indexing into the moduleList array or some other array that
     * stores data on a per module basis.
     * modulesList[moduleToIndex[moduleNumber]] = moduleNumber
     */
    public static final int[] moduleToIndex = buildIndex(modulesList);
    
    /**
     * This represents an invalid value (IV) for an entry 
     * in the {@link #module2IndexList}.
     */
    private static final int IV = 0xdeadbeef;
    
    /**
     * List of values which map from module number [1-25]
     * to an array index [0,21].
     * For example, 
     * <pre>
     * perModuleValue = valuePerModule[module2IndexList[module]];
     * </pre>
     */
    public static final int[] module2IndexList  = {IV, IV,  0,  1,  2, IV,
                                                        3,  4,  5,  6,  7,
                                                        8,  9, 10, 11, 12,
                                                       13, 14, 15, 16, 17,
                                                       IV, 18, 19, 20, IV};
    /**
     * The index into a 10x10 array for a given module/output (for mod=1-25 and out=1-4)
     */
    public static final int[][] MOD_OUT_TO_INDEX = {
        {IV, IV, IV, IV, IV}, // module "0"
        {IV, IV, IV, IV, IV},
        {IV, 12, 13,  3,  2},
        {IV, 14, 15,  5,  4},
        {IV, 16, 17,  7,  6},
        {IV, IV, IV, IV, IV},
        
        {IV, 31, 21, 20, 30},
        {IV, 32, 33, 23, 22},
        {IV, 34, 35, 25, 24},
        {IV, 26, 36, 37, 27},
        {IV, 28, 38, 39, 29},
        
        {IV, 51, 41, 40, 50},
        {IV, 53, 43, 42, 52},
        {IV, 55, 45, 44, 54},
        {IV, 46, 56, 57, 47},
        {IV, 48, 58, 59, 49},
        
        {IV, 71, 61, 60, 70},
        {IV, 73, 63, 62, 72},
        {IV, 65, 64, 74, 75},
        {IV, 67, 66, 76, 77},
        {IV, 68, 78, 79, 69},
        
        {IV, IV, IV, IV, IV},
        {IV, 83, 82, 92, 93},
        {IV, 85, 84, 94, 95},
        {IV, 87, 86, 96, 97},
        {IV, IV, IV, IV, IV},
    };
    
    public static final int[][] MOD_OUT_IN_GRID_ORDER = {
        {IV, IV}, {IV, IV},     { 2,  4}, { 2,  3},      { 3,  4}, { 3,  3},      { 4,  4}, { 4,  3},      {IV, IV}, {IV, IV},
        {IV, IV}, {IV, IV},     { 2,  1}, { 2,  2},      { 3,  1}, { 3,  2},      { 4,  1}, { 4,  2},      {IV, IV}, {IV, IV},

        { 6,  3}, { 6,  2},     { 7,  4}, { 7,  3},      { 8,  4}, { 8,  3},      { 9,  1}, { 9,  4},      {10,  1}, {10,  4},
        { 6,  4}, { 6,  1},     { 7,  1}, { 7,  2},      { 8,  1}, { 8,  2},      { 9,  2}, { 9,  3},      {10,  2}, {10,  3},

        {11,  3}, {11,  2},     {12,  3}, {12,  2},      {13,  3}, {13,  2},      {14,  1}, {14,  4},      {15,  1}, {15,  4},
        {11,  4}, {11,  1},     {12,  4}, {12,  1},      {13,  4}, {13,  1},      {14,  2}, {14,  3},      {15,  2}, {15,  3},

        {16,  3}, {16,  2},     {17,  3}, {17,  2},      {18,  2}, {18,  1},      {19,  2}, {19,  1},      {20,  1}, {20,  4},
        {16,  4}, {16,  1},     {17,  4}, {17,  1},      {18,  3}, {18,  4},      {19,  3}, {19,  4},      {20,  2}, {20,  3},

        {IV, IV}, {IV, IV},     {22,  2}, {22,  1},      {23,  2}, {23,  1},      {24,  2}, {24,  1},      {IV, IV}, {IV, IV},
        {IV, IV}, {IV, IV},     {22,  3}, {22,  4},      {23,  3}, {23,  4},      {24,  3}, {24,  4},      {IV, IV}, {IV, IV}
    };
    public static final int[]   crossTalkOutputReflection = {4,3,1,2};
    public static final int[][] outputArrangements        = { {4,3,1,2}, {3,2,4,1}, {1,4,2,3}, {2,1,3,4}, {-1} };
    public static final int[]   outputMappings            = {  4, 0, 0, 0, 4,
    														   2, 0, 0, 1, 1,
    														   2, 2, 2, 1, 1,
    														   2, 2, 3, 3, 1,
    														   4, 3, 3, 3, 4  };
    
    // Time constants:
    //
    /**
     * Used to calculate the gain.  Courtesy DMC time-dep. sensitivity format.
     */
    public static final int CENTIDAYS_PER_YEAR = 36525;
    @ProxyIgnore
    // J2000 epoch is based on 12:00 PM (noon).
    public static GregorianCalendar KEPLER_SCLK_EPOCH = new ModifiedJulianDate(2000, Calendar.JANUARY, 1, 12, 0, 0);


    public static final double J2000_MJD = 51544.5; // 01/01/00 12:00 PM
    
    // Test constants:
    //
    public static final int      UNINITIALIZED_VALUE = -1;
    public static final double[] TEST_COEFFS       = { -1.0, -1.0 };
    
    // TODO: replace with library lookup for FOV center
    public static final double[] NOMINAL_FOV_CENTER_DEGREES = { (19.0 + 22.0/60.0 + 40.0/60.0/60.0) * 15.0, 44.5, 0.0 };
    public static final double[] NOMINAL_FOV_CENTER_RADIANS = { Math.toRadians(NOMINAL_FOV_CENTER_DEGREES[0]),
                                                                Math.toRadians(NOMINAL_FOV_CENTER_DEGREES[1]),
                                                                Math.toRadians(NOMINAL_FOV_CENTER_DEGREES[2]) };
    
    public static final double eclipticObliquity   = Math.toRadians( 23.4392911 );
    
    public static final double[][] zodiGrid = new double[][] {
                                     {  1.0,  2.0,  3.0,  4.0,  5.0 },
                                     { 11.0, 12.0, 13.0, 14.0, 15.0 },
                                     { 21.0, 22.0, 23.0, 24.0, 25.0 },
                                     { 31.0, 32.0, 33.0, 34.0, 35.0 },
                                     { 41.0, 42.0, 43.0, 44.0, 45.0 }                                     
                                 };

    // Cruft for FocalPlaneOverview DS9 region files:
    public static final String regionFile         = ".ffiPix.reg";
    public static final String apertureRegionFile = ".ffiApertures.reg";
    public static final String apertureHtmlFile   = ".ffiApertures.html";

    public static final int[] signalProcessingChains = {1, 2, 3, 4, 5};
    
    
    /**
     * Each key is a ccdModule.  Each value is the signalProcessingChain for the respective ccdModule.
     */
    public static final int[] signalProcessingChainMapKeys = { 10, 15, 20, 4,
        9, 14, 19, 24, 3, 8, 13, 18, 23, 2, 7, 12, 17, 22, 6, 11, 16 };
    public static final int[] signalProcessingChainMapValues = { 1, 1, 1, 2, 2,
        2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5 };
    
    public static final int[] signalProcessingOrderTimeSlice1 = {10, 19, 3, 12};
    public static final int[] signalProcessingOrderTimeSlice2 = {15, 24, 8, 17};
    public static final int[] signalProcessingOrderTimeSlice3 = {20, 4, 13, 22, 6};
    public static final int[] signalProcessingOrderTimeSlice4 = {9, 18, 2, 11};
    public static final int[] signalProcessingOrderTimeSlice5 = {14, 23, 7, 16};

    @ProxyIgnore
    private static final Map<Integer, Integer> ccdModuleToTimeSlice;
    
    static {
        ccdModuleToTimeSlice = new HashMap<Integer, Integer>(nModules * 2);
        //I think it's a bad idea to call static methods before the class is
        //completely constructed so I'm duplicating some code.
        for (int ccdModule : signalProcessingOrderTimeSlice1) {
            ccdModuleToTimeSlice.put(ccdModule, 1);
        }
        for (int ccdModule : signalProcessingOrderTimeSlice2) {
            ccdModuleToTimeSlice.put(ccdModule, 2);
        }
        for (int ccdModule : signalProcessingOrderTimeSlice3) {
            ccdModuleToTimeSlice.put(ccdModule, 3);
        }
        for (int ccdModule : signalProcessingOrderTimeSlice4) {
            ccdModuleToTimeSlice.put(ccdModule, 4);
        }
        for (int ccdModule : signalProcessingOrderTimeSlice5) {
            ccdModuleToTimeSlice.put(ccdModule, 5);
        }
    }
    
    // Methods:
    /**
     * 
     * @param ccdModule a science CCD module.
     * @return The signal processing time slice.  If the ccd module is not
     * valid then this throws an exception.
     */
    public static int getCcdModuleTimeSlice(int ccdModule) {
        Integer timeSlice = ccdModuleToTimeSlice.get(ccdModule);
        if (timeSlice == null) {
            throw new IllegalArgumentException("time slice not found for ccdModule " + ccdModule);
        }
        return timeSlice;
    }
    
    
    /**
     * 
     * Given the moduleIndex (0-24) and the outputIndex (0-3), returns the
     * output number (1-4) of that output on that module, if you read the
     * numbers in left-to-right, up-to-down order. (E.g, 4 3 1 2 would
     * correspond to 4312)
     * 
     * @param moduleIndex
     * @param outputIndex1
     * @return
     */
    public static int getCorrectOutputNumber(int moduleIndex, int outputIndex) {
        int iMapping = outputMappings[moduleIndex];
        int iOuputNumber = outputArrangements[iMapping][outputIndex];
        return iOuputNumber;
    }

    /**
     * returns
     * @param moduleIndex
     * @param outputIndex
     * @return
     */
    public static int getHDUindex(int moduleIndex, int outputIndex) {
        int moduleTimesFour = module2IndexList[moduleIndex + 1] * 4;
        int correctOutputNumber = getCorrectOutputNumber(moduleIndex, outputIndex);
        return moduleTimesFour + correctOutputNumber + 1;
    }
    
    /**
     * Returns which HDU in the FFI a given (module, output) pair corresponds to.
     *  
     * @param module the real module number (2-4, 6-20, 22-24)
     * @param output the real output number (1-4)
     * @return
     */
    public static int getHdu(int module, int output) {
        int hdu = (module - 2) * 4 + output; // valid for modules 2-4
        if (module > 4) {
            hdu -= 4; // valid for modules 2-20
        }
        if (module > 20) {
            hdu -= 4; // valid for modules 2-24
        }
        return hdu;
    }
    
    public static int getCorrectModuleNumber( int moduleIndex ) {
        return modulesList[ moduleIndex ];
    }
    public static int getCorrectModuleNumberWithGap( int moduleIndex ) {
        return modulesListWithGaps[ moduleIndex ];
    }
    
    /**
     * Return whether or not the given index into a 100-element array (a linear ized 10x10 output array) is on a real output,
     * or if it is in "module" 1, 5, 21, or 25.
     * @param outputIndex
     * @return
     */
    public static boolean isPopulatedOutput(int outputIndex) {
        boolean isPopulated = 
            outputIndex !=  0 && outputIndex !=  1 &&
            outputIndex != 10 && outputIndex != 11 &&
            outputIndex !=  8 && outputIndex !=  9 &&
            outputIndex != 18 && outputIndex != 19 &&
            outputIndex != 80 && outputIndex != 81 &&
            outputIndex != 90 && outputIndex != 91 &&
            outputIndex != 88 && outputIndex != 89 &&
            outputIndex != 98 && outputIndex != 99;
        return isPopulated;
    }
    
    /**
     * Converts an array which is a packed list of valid ids, into an unpacked
     * array where unpacked[id] is alwalys valid and has the value of the index
     * of id in the packed array so that:
     * unpacked[packed[i]] == i
     * An invalid index into the unpacked array will have a value of -1;
     * @param packed a list of module or output ids in increasing order.
     * @return in
     */
    private static int[] buildIndex(int[] packed) {
        int[] rv = new int[packed[packed.length - 1]+1];
        Arrays.fill(rv, -1);
        for (int i=0; i < packed.length; i++) {
            rv[packed[i]] =  i;
        }
        return rv;
    }
    
    /**
     * Accepts a module/output and returns a channel (1-84).
     * @param ccdModule
     * @param ccdOutput
     * @return
     */
    public static int getChannelNumber(int ccdModule, int ccdOutput) {
        int moduleIndex = ArrayUtils.indexOf(modulesList, ccdModule);
        int outputIndex = ArrayUtils.indexOf(outputsList, ccdOutput);
        int channel = moduleIndex * FcConstants.nOutputsPerModule + outputIndex + 1;
        
        return channel;
    }
    
    public static List<Integer> getChannelNumbers(int[] ccdModules, int[] ccdOutputs) {
    	List<Integer> channels = new ArrayList<Integer>();
    	for (int ii = 0; ii < ccdModules.length; ++ii) {
    		channels.add(getChannelNumber(ccdModules[ii], ccdOutputs[ii]));
    	}
    	return channels;
    }
    
    /**
     * Accepts a channel number (1-84) and returns a Pair with module=left and output=right
     * @param channelNumber
     * @return
     * @throws PipelineException 
     */
    public static Pair<Integer, Integer> getModuleOutput(int channelNumber) {
        if (channelNumber < 1 || channelNumber > 84) {
            throw new PipelineException("Channel number " + channelNumber
                + " is out of range (1-84)");
        }
        
        int module = (channelNumber - 1) / 4 + 2; // correct for modules 2-4
        if (module > 4) { // perform the adjustment for module 6-20
            module += 1;
        }
        if (module > 20) { // perform the adjustment for module 22-24
            module += 1;
        }
        
        int output = 1 + ((channelNumber-1) % 4);
        
        return Pair.of(module, output);
    }
    
    public static List<Pair<Integer, Integer>> getModuleOutput(int[] channelNumbers) {
    	List<Pair<Integer, Integer>> moduleOutputs = new ArrayList<Pair<Integer, Integer>>();
    	for (int channelNumber : channelNumbers) {
			moduleOutputs.add(getModuleOutput(channelNumber));
		}
    	return moduleOutputs;
    }
    
    /**
     * Returns {@code true} if the given CCD module value is valid.
     */
    public static boolean validCcdModule(int ccdModule) {
        return ccdModule > 0 && ccdModule < FcConstants.module2IndexList.length && 
            FcConstants.module2IndexList[ccdModule] != IV;
    }
    
    /**
     * Returns {@code true} if the given CCD output value is valid.
     */
    public static boolean validCcdOutput(int ccdOutput) {
        return ccdOutput > 0 && ccdOutput <= FcConstants.nOutputsPerModule;
    }
    
    /**
     * Returns {@code true} if the given value is any row in accumulation memory.
     */
    public static boolean validRow(int row) {
        return row >= 0 && row <= nMaskedSmear + nRowsImaging + nVirtualSmear;
    }

    /**
     * Returns {@code true} if the given value is any column in accumulation memory.
     */
    public static boolean validColumn(int column) {
        return column >= 0
            && column <= nLeadingBlack + nColsImaging + nTrailingBlack;
    }

    /**
     * Returns {@code true} if the given value is an exposed CCD row.
     */
    public static boolean validScienceRow(int row) {
        return row >= nMaskedSmear && row <= nMaskedSmear + nRowsImaging;
    }

    /**
     * Returns {@code true} if the given value is an exposed CCD column.
     */
    public static boolean validScienceColumn(int column) {
        return column >= nLeadingBlack
            && column <= nLeadingBlack + nColsImaging;
    }
    
    /**
     * Returns the signal processing chain number (1 through 5) that 
     * this ccdModule is a part of.
     */
    public static int getSignalProcessingChain(int ccdModule) {
        for (int i = 0; i < signalProcessingChainMapKeys.length; i++) {
            if (signalProcessingChainMapKeys[i] == ccdModule) {
                return signalProcessingChainMapValues[i];
            }
        }
        
        return -1;
    }

    public static final double KEPLER_END_OF_MISSION_MJD = 56444.0;
}
