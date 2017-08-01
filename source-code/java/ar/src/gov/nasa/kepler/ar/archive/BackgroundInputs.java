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

import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;
import java.util.Collection;

/**
 * The background inputs into the archive matlab function.
 * 
 * @author Sean McCauliff
 *
 */
public class BackgroundInputs implements Persistable {

    private PixelCoordinates[] pixelCoordinates;
    private BlobFileSeries backgroundBlobs;
    
    /**
     * Use this constructor from Persistable or if you don't want to calculate 
     * background.
     */
    public BackgroundInputs() {
        pixelCoordinates = new PixelCoordinates[0];
        backgroundBlobs = new BlobFileSeries();
    }
    
    public BackgroundInputs(BlobSeries<String> backgroundBlobs, Collection<Pixel> pixels) {
        this.backgroundBlobs = new BlobFileSeries(backgroundBlobs);
        this.pixelCoordinates = new PixelCoordinates[pixels.size()];
        int i=0;
        for (Pixel p : pixels) {
            pixelCoordinates[i++] = new PixelCoordinates(p.getRow(), p.getColumn());
        }
    }

    public PixelCoordinates[] getPixelCoordinates() {
        return pixelCoordinates;
    }

    public void setPixelCoordinates(PixelCoordinates[] pixelCoordinates) {
        this.pixelCoordinates = pixelCoordinates;
    }

    public BlobFileSeries getBackgroundBlobs() {
        return backgroundBlobs;
    }

    public void setBackgroundBlobs(BlobFileSeries backgroundBlobs) {
        this.backgroundBlobs = backgroundBlobs;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((backgroundBlobs == null) ? 0 : backgroundBlobs.hashCode());
        result = prime * result + Arrays.hashCode(pixelCoordinates);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof BackgroundInputs))
            return false;
        BackgroundInputs other = (BackgroundInputs) obj;
        if (backgroundBlobs == null) {
            if (other.backgroundBlobs != null)
                return false;
        } else if (!backgroundBlobs.equals(other.backgroundBlobs))
            return false;
        if (!Arrays.equals(pixelCoordinates, other.pixelCoordinates))
            return false;
        return true;
    }
    
    
}
