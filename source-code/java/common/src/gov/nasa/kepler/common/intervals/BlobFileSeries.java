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

package gov.nasa.kepler.common.intervals;

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;

/**
 * Wrapper class to make {@code BlobSeries<String>} persistable.
 * 
 * @author Forrest Girouard
 * 
 */
public class BlobFileSeries implements Persistable {

    private int[] blobIndices = ArrayUtils.EMPTY_INT_ARRAY;
    private boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private String[] blobFilenames = ArrayUtils.EMPTY_STRING_ARRAY;
    private int startCadence = -1;
    private int endCadence = -1;

    public BlobFileSeries() {
        super();
    }

    public BlobFileSeries(int[] blobIndices, boolean[] gapIndicators,
        String[] blobFilenames, int startCadence, int endCadence) {
    	
    	if (blobFilenames.length == 0) {
    		return;
    	}
    	
        this.blobIndices = blobIndices;
        this.gapIndicators = gapIndicators;
        this.blobFilenames = blobFilenames;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
    }

    public BlobFileSeries(int[] blobIndices, boolean[] gapIndicators,
        Object[] blobFilenames, int startCadence, int endCadence) {
    	
    	if (blobFilenames.length == 0) {
    		return;
    	}
    	
        this.blobIndices = blobIndices;
        this.gapIndicators = gapIndicators;
        this.blobFilenames = new String[blobFilenames.length];
        for (int i = 0; i < blobFilenames.length; i++) {
            if (!(blobFilenames[i] instanceof String)) {
                throw new IllegalArgumentException("blobFilenames[" + i
                    + "] is not a String: blobFilenames[" + i + "]="
                    + blobFilenames[i]);
            }
            this.blobFilenames[i] = (String) blobFilenames[i];
        }
        this.startCadence = startCadence;
        this.endCadence = endCadence;
    }

    public BlobFileSeries(BlobSeries<String> blobSeries) {
        this(blobSeries.blobIndices(), blobSeries.gapIndicators(),
            blobSeries.blobFilenames(), blobSeries.startCadence(),
            blobSeries.endCadence());
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + Arrays.hashCode(blobFilenames);
        result = PRIME * result + Arrays.hashCode(blobIndices);
        result = PRIME * result + endCadence;
        result = PRIME * result + Arrays.hashCode(gapIndicators);
        result = PRIME * result + startCadence;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final BlobFileSeries other = (BlobFileSeries) obj;
        if (!Arrays.equals(blobFilenames, other.blobFilenames))
            return false;
        if (!Arrays.equals(blobIndices, other.blobIndices))
            return false;
        if (endCadence != other.endCadence)
            return false;
        if (!Arrays.equals(gapIndicators, other.gapIndicators))
            return false;
        if (startCadence != other.startCadence)
            return false;
        return true;
    }

    public String[] getBlobFilenames() {
        return blobFilenames;
    }

    public int[] getBlobIndices() {
        return blobIndices;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public int getStartCadence() {
        return startCadence;
    }
}
