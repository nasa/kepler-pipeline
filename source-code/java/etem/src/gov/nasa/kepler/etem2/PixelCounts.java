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

package gov.nasa.kepler.etem2;

import java.io.File;
import java.io.IOException;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import com.jmatio.types.MLDouble;

/**
 * This class parses the contents of the pixelCounts.mat file 
 * produced by ETEM2.  This file contains metadata describing
 * the ETEM2 output.
 * 
 * Example:
 * pixelCounts = 
 *           nTargetPixels: 43919
 *       nBackgroundPixels: 4464
 *            nBlackValues: 1070
 *      nMaskedSmearValues: 1100
 *     nVirtualSmearValues: 1100
 *       nCollateralValues: 3270
 *       nValuesPerCadence: 51653
 *               nCadences: 1440
 *               valueSize: 2
 *         bytesPerCadence: 103306
 *         
 * @author tklaus
 *
 */
public class PixelCounts {
    private static final Log log = LogFactory.getLog(PixelCounts.class);
    
    private File runDir;
	private String cadenceType;

	// values in pixelCounts.mat for both long and short cadences
    private int nValuesPerCadence = 0;
    private int nCadences = 0;
		// size of a data value (2 for quantized, 4 for non-quantized)
	private int valueSize = 0;
		// bytesPerCadence = valueSize*nValuesPerCadence
	private int bytesPerCadence = 0;
    
	// values in pixelCounts.mat for long cadences
    private int nTargetPixels = 0;
    private int nBackgroundPixels = 0;
    private int nBlackValues = 0;
    private int nMaskedSmearValues = 0;
    private int nVirtualSmearValues = 0;
    private int nCollateralValues = 0;
    private int nReferencePixels = 0;

	// values in pixelCounts.mat for short cadences
		// array giving the number of science pixels for each target
	private int[] nPixelsPerTarget = null;
		// array giving the number of black values for each target
	private int[] nBlackValuesPerTarget = null;
		// array giving the number of virtual smear values for each target
	private int[] nVirtSmearValuesPerTarget = null;
		// array giving the number of masked smear values for each target
	private int[] nMaskedSmearValuesPerTarget = null;

	private Map<String, MLArray> content;

    public PixelCounts() {
    }
    
    public PixelCounts(File runDir, String cadenceType) throws IOException {
        this.runDir = runDir;
		this.cadenceType = cadenceType;
        
        File pixelCountsMatFile = new File(runDir, "pixelCounts.mat");
        
        MatFileReader pixelCountsMat = new MatFileReader(pixelCountsMatFile);
        content = pixelCountsMat.getContent();
        
/*
        nValuesPerCadence = (int) getDoubleValue(content.get("nValuesPerCadence"));
        nCadences = (int) getDoubleValue(content.get("nCadences"));
*/
        nValuesPerCadence = getIntValue("nValuesPerCadence");
        nCadences = getIntValue("nCadences");
		valueSize = getIntValue("valueSize");
		bytesPerCadence = getIntValue("bytesPerCadence");

        if(cadenceType.equals("long")){
            // these values only available for long cadence data
/*
            nTargetPixels = (int) getDoubleValue(content.get("nTargetPixels"));
            nBackgroundPixels = (int) getDoubleValue(content.get("nBackgroundPixels"));
            nBlackValues = (int) getDoubleValue(content.get("nBlackValues"));
            nMaskedSmearValues = (int) getDoubleValue(content.get("nMaskedSmearValues"));
            nVirtualSmearValues = (int) getDoubleValue(content.get("nVirtualSmearValues"));
            nCollateralValues = (int) getDoubleValue(content.get("nCollateralValues"));
            nReferencePixels = (int) getDoubleValue(content.get("nReferencePixels"));
*/
            nTargetPixels = getIntValue("nTargetPixels");
            nBackgroundPixels = getIntValue("nBackgroundPixels");
            nBlackValues = getIntValue("nBlackValues");
            nMaskedSmearValues = getIntValue("nMaskedSmearValues");
            nVirtualSmearValues = getIntValue("nVirtualSmearValues");
            nCollateralValues = getIntValue("nCollateralValues");
            nReferencePixels = getIntValue("nReferencePixels");
        } else {	// "short"
			nPixelsPerTarget = getIntArray("nPixelsPerTarget");
			nBlackValuesPerTarget = getIntArray("nBlackValuesPerTarget");
			nVirtSmearValuesPerTarget = getIntArray("nVirtSmearValuesPerTarget");
			nMaskedSmearValuesPerTarget = getIntArray("nMaskedSmearValuesPerTarget");
		}
    }


    public void log() {
		log.info("nCadences: " + nCadences);
		log.info("nValuesPerCadence: " + nValuesPerCadence);
		log.info("valueSize: " + valueSize);
		log.info("bytesPerCadence: " + bytesPerCadence);
        if(cadenceType.equals("long")){
			log.info("nTargetPixels: " + nTargetPixels);
			log.info("nBackgroundPixels: " + nBackgroundPixels);
			log.info("nBlackValues: " + nBlackValues);
			log.info("nMaskedSmearValues: " + nMaskedSmearValues);
			log.info("nVirtualSmearValues: " + nVirtualSmearValues);
			log.info("nCollateralValues: " + nCollateralValues);
			log.info("nReferencePixels: " + nReferencePixels);
		} else {	// short
			log.info("nPixelsPerTarget: " + dump(nPixelsPerTarget));
			log.info("nBlackValuesPerTarget: " + dump(nBlackValuesPerTarget));
			log.info("nVirtSmearValuesPerTarget: " + dump(nVirtSmearValuesPerTarget));
			log.info("nMaskedSmearValuesPerTarget: " + dump(nMaskedSmearValuesPerTarget));
		}
    }

	private String dump( int[] array ) {
		String ret = "(len=" + array.length + "): ";
		int elementsToDump = array.length <= 5 ? array.length : 5;
		
		for ( int i = 0; i < elementsToDump; i++ ) {
			ret += array[i] + ", ";
		}
		return ret + "...";
	}

    /**
     * Get an int value out of an array of length 1
     * 
     * @param array
     * @return
     */
    private int getIntValue(String memberName) {
        MLArray mlArray = content.get(memberName);
        MLDouble doubleArray = (MLDouble) mlArray;
        return (int) doubleArray.get(0).doubleValue();
    }

    /**
     * Get a double value out of an array of length 1
     * 
     * @param array
     * @return
     */
    private double getDoubleValue(MLArray array) {
        MLDouble doubleArray = (MLDouble) array;
        return doubleArray.get(0).doubleValue();
    }

    /**
     * Get a double array and convert it to an int array
     * 
     * @param array
     * @return
     */
    private int[] getIntArray(String memberName) {
        MLArray mlArray = content.get(memberName);
        MLDouble doubleArray = (MLDouble) mlArray;
		int size = mlArray.getM();
		int[] ret = new int[ size ]; 
		for ( int i = 0; i < size; i++ ) {
			ret[i] = (int) doubleArray.get(i).doubleValue();
		}
        return ret;
    }

    public File getRunDir() {
        return runDir;
    }

	// values for both short and long cadences

    public int getNCadences() {
        return nCadences;
    }

    public int getNValuesPerCadence() {
        return nValuesPerCadence;
    }

	// long cadence values

    public int getBytesPerCadence() {
        return bytesPerCadence;
    }

    public int getNBackgroundPixels() {
        return nBackgroundPixels;
    }

    public int getNBlackValues() {
        return nBlackValues;
    }

    public void setNBlackValues(int n) {
        nBlackValues = n;
    }

    public int getNCollateralValues() {
        return nCollateralValues;
    }

    public int getNReferencePixels() {
        return nReferencePixels;
    }

    public int getNMaskedSmearValues() {
        return nMaskedSmearValues;
    }

    public void setNMaskedSmearValues(int n) {
        nMaskedSmearValues = n;
    }

    public int getNTargetPixels() {
        return nTargetPixels;
    }

    public int getNVirtualSmearValues() {
        return nVirtualSmearValues;
    }

    public void setNVirtualSmearValues(int n) {
        nVirtualSmearValues = n;
    }

	// short cadence values

	public int[] getNPixelsPerTarget() {
		return nPixelsPerTarget;
	}

	public int[] getNBlackValuesPerTarget() {
		return nBlackValuesPerTarget;
	}

	public int[] getNVirtSmearValuesPerTarget() {
		return nVirtSmearValuesPerTarget;
	}

	public int[] getNMaskedSmearValuesPerTarget() {
		return nMaskedSmearValuesPerTarget;
	}

}


