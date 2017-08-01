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

package gov.nasa.kepler.mc.tad;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.mc.tad.Offset;
import gov.nasa.kepler.mc.tad.OffsetList;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * Used to pass data to and from MATLAB.
 * 
 * @author Miles Cote
 */
public class OptimalAperture implements Persistable {

    // NOTE: new fields need to be:
    // - Added to ObservedTarget
    //   - Remember that getters should call getObservedTarget() to make use of supplemental tad.
    //     - For example, getSaturatedRowCount() is implemented as follows:
    //         return getObservedTarget().saturatedRowCount;
    // - Set by CoaPipelineModule (LC)
    // - Set by CoaPipelineModule (SC)
    // - Set by RptsPipelineModule
    // - Set by SbtRetrieveTad
    // - Added to SbtTadData
    // - Set by SbtDataOperations
    // - Added to observed-targets.xsd
    // - Set by ObservedTargetsExporter
    // - Set by ObservedTargetsImporter
    // - Added to PaTarget for pa-coa
    private int keplerId;
    @OracleDouble
    private double signalToNoiseRatio;
    @OracleDouble
    private double fluxFractionInAperture;
    @OracleDouble
    private double crowdingMetric;
    @OracleDouble
    private double skyCrowdingMetric;
    private int badPixelCount;
    private int distanceFromEdge;
    private int referenceRow;
    private int referenceColumn;
    private int saturatedRowCount;
    private boolean apertureUpdatedWithPaCoa;

    private List<Offset> offsets = newArrayList();

    public OptimalAperture() {
    }

    OptimalAperture(Aperture aperture) {
        referenceRow = aperture.getReferenceRow();
        referenceColumn = aperture.getReferenceColumn();
        offsets = OffsetList.toList(aperture.getOffsets());
    }

    public Aperture toAperture(boolean userDefined) {
        return new Aperture(userDefined, referenceRow, referenceColumn,
            OffsetList.toDatabaseList(offsets));
    }

    public int getBadPixelCount() {
        return badPixelCount;
    }

    public void setBadPixelCount(int badPixelCount) {
        this.badPixelCount = badPixelCount;
    }

    public double getCrowdingMetric() {
        return crowdingMetric;
    }

    public void setCrowdingMetric(double crowdingMetric) {
        this.crowdingMetric = crowdingMetric;
    }

    public List<Offset> getOffsets() {
        return offsets;
    }

    public void setOffsets(List<Offset> offsets) {
        this.offsets = offsets;
    }

    public int getReferenceColumn() {
        return referenceColumn;
    }

    public void setReferenceColumn(int referenceColumn) {
        this.referenceColumn = referenceColumn;
    }

    public int getReferenceRow() {
        return referenceRow;
    }

    public void setReferenceRow(int referenceRow) {
        this.referenceRow = referenceRow;
    }

    public double getSignalToNoiseRatio() {
        return signalToNoiseRatio;
    }

    public void setSignalToNoiseRatio(double signalToNoiseRatio) {
        this.signalToNoiseRatio = signalToNoiseRatio;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public double getFluxFractionInAperture() {
        return fluxFractionInAperture;
    }

    public void setFluxFractionInAperture(double fluxFractionInAperture) {
        this.fluxFractionInAperture = fluxFractionInAperture;
    }

    public int getDistanceFromEdge() {
        return distanceFromEdge;
    }

    public void setDistanceFromEdge(int distanceFromEdge) {
        this.distanceFromEdge = distanceFromEdge;
    }

    public double getSkyCrowdingMetric() {
        return skyCrowdingMetric;
    }

    public void setSkyCrowdingMetric(double skyCrowdingMetric) {
        this.skyCrowdingMetric = skyCrowdingMetric;
    }

    public int getSaturatedRowCount() {
        return saturatedRowCount;
    }

    public void setSaturatedRowCount(int saturatedRowCount) {
        this.saturatedRowCount = saturatedRowCount;
    }

    public boolean isApertureUpdatedWithPaCoa() {
        return apertureUpdatedWithPaCoa;
    }

    public void setApertureUpdatedWithPaCoa(boolean apertureUpdatedWithPaCoa) {
        this.apertureUpdatedWithPaCoa = apertureUpdatedWithPaCoa;
    }
}
