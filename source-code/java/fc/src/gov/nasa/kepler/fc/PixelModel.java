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

package gov.nasa.kepler.fc;

import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

public class PixelModel implements Persistable {
    private int[] ccdModules;
    private int[] ccdOutputs;
    private int[] ccdRows;
    private int[] ccdColumns;
    private String[] types;
    private double[] startTimes;
    private double[] endTimes;
    private double[] pixelValues;
    private FcModelMetadata fcModelMetadata = new FcModelMetadata();

    /**
     * Required by {@link Persistable}.
     */
    public PixelModel() {
    }

    public PixelModel(Pixel[] pixels) {
        init(pixels);
    }

    public PixelModel(List<Pixel> pixels) {
        Pixel[] pixelsArray = new Pixel[pixels.size()];
        for (int ipix = 0; ipix < pixels.size(); ++ipix) {
            pixelsArray[ipix] = pixels.get(ipix);
        }
        
        init(pixelsArray);
    }

    private void init(Pixel[] pixels) {
        ccdModules = new int[pixels.length];
        ccdOutputs = new int[pixels.length];
        ccdRows = new int[pixels.length];
        ccdColumns = new int[pixels.length];
        types = new String[pixels.length];
        startTimes = new double[pixels.length];
        endTimes = new double[pixels.length];
        pixelValues = new double[pixels.length];

        for (int ipix = 0; ipix < pixels.length; ++ipix) {
            Pixel pixel = pixels[ipix];

            ccdModules[ipix] = pixel.getCcdModule();
            ccdOutputs[ipix] = pixel.getCcdOutput();
            ccdRows[ipix] = pixel.getCcdRow();
            ccdColumns[ipix] = pixel.getCcdColumn();
            types[ipix] = pixel.getType().name();
            startTimes[ipix] = pixel.getStartTime();
            endTimes[ipix] = pixel.getEndTime();
            pixelValues[ipix] = pixel.getPixelValue();
        }
    }
    
    public int size() {
        return ccdModules.length;
    }
    
    public Pixel getPixel(int ipixel) {
    	Pixel pixel = new Pixel(
            getCcdModules()[ipixel],
            getCcdOutputs()[ipixel],
            getCcdRows()[ipixel],
            getCcdColumns()[ipixel],
            PixelType.valueOf(getTypes()[ipixel]),
            getStartTimes()[ipixel],
            getEndTimes()[ipixel],
            getPixelValues()[ipixel]
        );
        return pixel;
    }

    public int[] getCcdModules() {
        return ccdModules;
    }

    public void setCcdModules(int[] ccdModules) {
        this.ccdModules = ccdModules;
    }

    public int[] getCcdOutputs() {
        return ccdOutputs;
    }

    public void setCcdOutputs(int[] ccdOutputs) {
        this.ccdOutputs = ccdOutputs;
    }

    public int[] getCcdRows() {
        return ccdRows;
    }

    public void setCcdRows(int[] ccdRows) {
        this.ccdRows = ccdRows;
    }

    public int[] getCcdColumns() {
        return ccdColumns;
    }

    public void setCcdColumns(int[] ccdColumns) {
        this.ccdColumns = ccdColumns;
    }

    public String[] getTypes() {
        return types;
    }

    public void setTypes(String[] types) {
        this.types = types;
    }

    public double[] getStartTimes() {
        return startTimes;
    }

    public void setStartTimes(double[] startTimes) {
        this.startTimes = startTimes;
    }

    public double[] getEndTimes() {
        return endTimes;
    }

    public void setEndTimes(double[] endTimes) {
        this.endTimes = endTimes;
    }

    public double[] getPixelValues() {
        return pixelValues;
    }

    public void setPixelValues(double[] pixelValues) {
        this.pixelValues = pixelValues;
    }

    public void setFcModelMetadata(FcModelMetadata fcModelMetadata) {
        this.fcModelMetadata = fcModelMetadata;
    }

    public FcModelMetadata getFcModelMetadata() {
        return fcModelMetadata;
    }
}
