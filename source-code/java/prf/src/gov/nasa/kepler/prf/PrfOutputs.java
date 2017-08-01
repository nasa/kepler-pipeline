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

package gov.nasa.kepler.prf;

import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * Contains all the data and status information returned from the PRF science
 * algorithm that is to be persisted and/or reported.
 * 
 * @author Forrest Girouard
 * 
 */
public class PrfOutputs implements Persistable {

    @OracleDouble
    private double deltaCentroidNorm;
    
    private boolean centroidsConverged;
    
    private String prfCollectionBlobFileName;

    private String motionPolyBlobFileName;

    private List<PrfCentroidTimeSeries> centroids;

    public List<PrfCentroidTimeSeries> getCentroids() {
        return centroids;
    }

    public void setCentroids(List<PrfCentroidTimeSeries> centroids) {
        this.centroids = centroids;
    }

    public String getPrfBlobFileName() {
        return prfCollectionBlobFileName;
    }

    public void setPrfBlobFileName(String prfCollectionBlobFileName) {
        this.prfCollectionBlobFileName = prfCollectionBlobFileName;
    }

    public String getMotionBlobFileName() {
        return motionPolyBlobFileName;
    }

    public void setMotionBlobFileName(String motionPolyBlobFileName) {
        this.motionPolyBlobFileName = motionPolyBlobFileName;
    }

    public boolean isCentroidsConverged() {
        return centroidsConverged;
    }

    public void setCentroidsConverged(boolean centroidsConverged) {
        this.centroidsConverged = centroidsConverged;
    }

    public String getPrfCollectionBlobFileName() {
        return prfCollectionBlobFileName;
    }

    public void setPrfCollectionBlobFileName(String prfCollectionBlobFileName) {
        this.prfCollectionBlobFileName = prfCollectionBlobFileName;
    }

    public String getMotionPolyBlobFileName() {
        return motionPolyBlobFileName;
    }

    public void setMotionPolyBlobFileName(String motionPolyBlobFileName) {
        this.motionPolyBlobFileName = motionPolyBlobFileName;
    }

    public double getDeltaCentroidNorm() {
        return deltaCentroidNorm;
    }

    public void setDeltaCentroidNorm(double deltaCentroidNorm) {
        this.deltaCentroidNorm = deltaCentroidNorm;
    }

    
}
