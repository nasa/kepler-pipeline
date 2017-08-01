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

package gov.nasa.kepler.ar.archive;

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

public final class BackgroundPixelValue implements Persistable {
    private int ccdRow;
    private int ccdColumn;
    private double[] background;
    private boolean[] backgroundGaps;
    private double[] backgroundUncertainties;
    private boolean[] backgroundUncertaintyGaps;
    
    /**
     * To support the Persistable interface.
     */
    public BackgroundPixelValue() {
        
    }
    
    public BackgroundPixelValue(int ccdRow, int ccdColumn,
        double[] background, boolean[] backgroundGaps,
        double[] backgroundUncertainties, boolean[] backgroundUncertaintiyGaps) {

        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
        this.background = background;
        this.backgroundGaps = backgroundGaps;
        this.backgroundUncertainties = backgroundUncertainties;
        this.backgroundUncertaintyGaps = backgroundUncertaintiyGaps;
    }
    
    
    public int getCcdRow() {
        return ccdRow;
    }
    public int getCcdColumn() {
        return ccdColumn;
    }
    public double[] getBackground() {
        return background;
    }
    public boolean[]getBackgroundGaps() {
        return backgroundGaps;
    }
    public double[] getBackgroundUncertainties() {
        return backgroundUncertainties;
    }
    public boolean[] getBackgroundUncertaintyGaps() {
        return backgroundUncertaintyGaps;
    }

    public void fillGaps(float fillValue) {
        for (int i=0; i < background.length; i++) {
            if (backgroundGaps[i]) {
                background[i] = fillValue;
            }
        }
        for (int i=0; i < backgroundUncertainties.length; i++) {
            if (backgroundUncertaintyGaps[i]) {
                backgroundUncertainties[i] =fillValue;
            }
        }
    }
    
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(background);
        result = prime * result + Arrays.hashCode(backgroundGaps);
        result = prime * result + Arrays.hashCode(backgroundUncertainties);
        result = prime * result
            + Arrays.hashCode(backgroundUncertaintyGaps);
        result = prime * result + ccdColumn;
        result = prime * result + ccdRow;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof BackgroundPixelValue))
            return false;
        BackgroundPixelValue other = (BackgroundPixelValue) obj;
        if (!Arrays.equals(background, other.background))
            return false;
        if (!Arrays.equals(backgroundGaps, other.backgroundGaps))
            return false;
        if (!Arrays.equals(backgroundUncertainties,
            other.backgroundUncertainties))
            return false;
        if (!Arrays.equals(backgroundUncertaintyGaps,
            other.backgroundUncertaintyGaps))
            return false;
        if (ccdColumn != other.ccdColumn)
            return false;
        if (ccdRow != other.ccdRow)
            return false;
        return true;
    }

}