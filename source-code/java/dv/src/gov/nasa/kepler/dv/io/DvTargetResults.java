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

package gov.nasa.kepler.dv.io;

import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * Results for a single target.
 * 
 * @author Forrest Girouard
 */
public class DvTargetResults implements Persistable {

    private int keplerId;
    private String koiId = "";
    private String keplerName = "";

    private String[] matchedKoiIds = ArrayUtils.EMPTY_STRING_ARRAY;
    private String[] unmatchedKoiIds = ArrayUtils.EMPTY_STRING_ARRAY;

    @OracleDouble
    private double[] barycentricCorrectedTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;

    // One per target table
    private List<DvLimbDarkeningModel> limbDarkeningStruct = new ArrayList<DvLimbDarkeningModel>();

    // One per planet
    private List<DvPlanetResults> planetResultsStruct = new ArrayList<DvPlanetResults>();

    private DvQuantityWithProvenance effectiveTemp = new DvQuantityWithProvenance();
    private DvQuantityWithProvenance log10Metallicity = new DvQuantityWithProvenance();
    private DvQuantityWithProvenance log10SurfaceGravity = new DvQuantityWithProvenance();
    private DvQuantityWithProvenance radius = new DvQuantityWithProvenance();
    private DvDoubleQuantityWithProvenance decDegrees = new DvDoubleQuantityWithProvenance();
    private DvQuantityWithProvenance keplerMag = new DvQuantityWithProvenance();
    private DvDoubleQuantityWithProvenance raHours = new DvDoubleQuantityWithProvenance();

    private String quartersObserved = "";

    private String reportFilename = "";
    private CorrectedFluxTimeSeries residualFluxTimeSeries = new CorrectedFluxTimeSeries();
    private List<DvSingleEventStatistics> singleEventStatistics = new ArrayList<DvSingleEventStatistics>();

    /**
     * Creates a {@link DvTargetResults}. For use only by mock objects and
     * Hibernate.
     */
    public DvTargetResults() {
    }

    /**
     * Creates a new immutable {@link DvTargetResults} object.
     */
    public DvTargetResults(int keplerId,
        double[] barycentricCorrectedTimestamps,
        DvDoubleQuantityWithProvenance decDegrees,
        DvQuantityWithProvenance effectiveTemp,
        DvQuantityWithProvenance keplerMag, String keplerName, String koiId,
        List<DvLimbDarkeningModel> limbDarkeningModels,
        DvQuantityWithProvenance log10Metallicity,
        DvQuantityWithProvenance log10SurfaceGravity,
        String[] matchedKoiIds, List<DvPlanetResults> planetResults,
        String quartersObserved, DvQuantityWithProvenance radius,
        DvDoubleQuantityWithProvenance raHours, String reportFilename,
        CorrectedFluxTimeSeries residualFluxTimeSeries,
        List<DvSingleEventStatistics> singleEventStatistics,
        String[] unmatchedKoiIds) {

        this.keplerId = keplerId;
        this.barycentricCorrectedTimestamps = barycentricCorrectedTimestamps;
        this.decDegrees = decDegrees;
        this.effectiveTemp = effectiveTemp;
        this.keplerMag = keplerMag;
        this.keplerName = keplerName;
        this.koiId = koiId;
        limbDarkeningStruct = limbDarkeningModels;
        this.log10Metallicity = log10Metallicity;
        this.log10SurfaceGravity = log10SurfaceGravity;
        this.matchedKoiIds = matchedKoiIds;
        planetResultsStruct = planetResults;
        this.quartersObserved = quartersObserved;
        this.radius = radius;
        this.raHours = raHours;
        this.reportFilename = reportFilename;
        this.residualFluxTimeSeries = residualFluxTimeSeries;
        this.singleEventStatistics = singleEventStatistics;
        this.unmatchedKoiIds = unmatchedKoiIds;
    }

    public double[] getBarycentricCorrectedTimestamps() {
        return barycentricCorrectedTimestamps;
    }

    public DvDoubleQuantityWithProvenance getDecDegrees() {
        return decDegrees;
    }

    public DvQuantityWithProvenance getEffectiveTemp() {
        return effectiveTemp;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public DvQuantityWithProvenance getKeplerMag() {
        return keplerMag;
    }

    public String getKeplerName() {
        return keplerName;
    }

    public String getKoiId() {
        return koiId;
    }

    public List<DvLimbDarkeningModel> getLimbDarkeningModels() {
        return limbDarkeningStruct;
    }

    public DvQuantityWithProvenance getLog10Metallicity() {
        return log10Metallicity;
    }

    public DvQuantityWithProvenance getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    public String[] getMatchedKoiIds() {
        return matchedKoiIds;
    }

    public List<DvPlanetResults> getPlanetResults() {
        return planetResultsStruct;
    }

    public String getQuartersObserved() {
        return quartersObserved;
    }

    public DvQuantityWithProvenance getRadius() {
        return radius;
    }

    public DvDoubleQuantityWithProvenance getRaHours() {
        return raHours;
    }

    public String getReportFilename() {
        return reportFilename;
    }

    public CorrectedFluxTimeSeries getResidualFluxTimeSeries() {
        return residualFluxTimeSeries;
    }

    public List<DvSingleEventStatistics> getSingleEventStatistics() {
        return singleEventStatistics;
    }

    public String[] getUnmatchedKoiIds() {
        return unmatchedKoiIds;
    }
}
