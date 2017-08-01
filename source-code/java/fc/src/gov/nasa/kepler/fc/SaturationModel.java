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

import gov.nasa.kepler.hibernate.fc.Saturation;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

/**
 * The Model class that provides the Saturation data to the MATLAB science
 * modules. 
 * 
 * @author kester
 * 
 */
public class SaturationModel implements Persistable {
    private int season;
    private int channel;
    private SaturatedStar[] stars = new SaturatedStar[0];
    private FcModelMetadata fcModelMetadata = new FcModelMetadata();

    /**
     * Required by {@link Persistable}.
     */
    public SaturationModel() {
    }
    
    public SaturationModel(int season, int channel, SaturatedStar[] stars) {
        this.season = season;
        this.channel = channel;
        this.stars = stars;
    }
    
    public SaturationModel(Saturation[] saturations) {
        if (saturations.length == 0) {
            this.season = -1;
            this.channel = -1;
            this.stars = new SaturatedStar[0];
            this.fcModelMetadata = null;
            return;
        }
        this.season = saturations[0].getSeason();
        this.channel = saturations[0].getChannel();
        this.stars = new SaturatedStar[saturations.length];

        for (int ii = 0; ii < saturations.length; ++ii) {
            Saturation saturation = saturations[ii];

            // Throw an exception if the season isn't the same for all
            // saturations.
            if (this.season != saturation.getSeason()) {
                throw new FocalPlaneException("Inconsistent season in input saturations array in SaturationModel constructor");
            }

            // Copy each saturation object into the model:
            //
            this.stars[ii] = new SaturatedStar(saturation.getKeplerId(),
                saturation.getSaturationCoordinates());
        }

    }

    public int getSeason() {
        return season;
    }

    public void setSeason(int season) {
        this.season = season;
    }

    public int getChannel() {
        return channel;
    }

    public void setChannel(int channel) {
        this.channel = channel;
    }

    public SaturatedStar[] getStars() {
        return stars;
    }
    
    public int size() {
        return stars.length;
    }

    public void setStars(SaturatedStar[] stars) {
        this.stars = stars;
    }

    public FcModelMetadata getFcModelMetadata() {
        return fcModelMetadata;
    }

    public void setFcModelMetadata(FcModelMetadata fcModelMetadata) {
        this.fcModelMetadata = fcModelMetadata;
    }

    @Override
    public String toString() {
        return "SaturationModel [season=" + season + ", stars="
            + Arrays.toString(stars) + ", fcModelMetadata=" + fcModelMetadata
            + "]";
    }

}
