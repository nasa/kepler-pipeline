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
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * Results for a single planet.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class DvPlanetResults implements Persistable {

    private DvPlanetModelFit allTransitsFit = new DvPlanetModelFit();
    private DvBinaryDiscriminationResults binaryDiscriminationResults = new DvBinaryDiscriminationResults();
    private DvCentroidResults centroidResults = new DvCentroidResults();
    private int detrendFilterLength;
    private List<DvDifferenceImageResults> differenceImageResults = new ArrayList<DvDifferenceImageResults>();
    private DvPlanetModelFit evenTransitsFit = new DvPlanetModelFit();

    // This is a SimpleFloatTimeSeries in sheep's clothing, like
    // DvPlanetModelFit.robustWeights. The values are valid for all cadences, so
    // all gap indicators are implied to be true.
    private float[] foldedPhase = new float[0];

    private DvGhostDiagnosticResults ghostDiagnosticResults = new DvGhostDiagnosticResults();
    private int keplerId;
    private String keplerName = "";
    private float koiCorrelation = -1;
    private String koiId = "";
    private SimpleFloatTimeSeries modelLightCurve = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries whitenedModelLightCurve = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries whitenedFluxTimeSeries = new SimpleFloatTimeSeries();
    private CorrectedFluxTimeSeries detrendedFluxTimeSeries = new CorrectedFluxTimeSeries();
    private DvPlanetModelFit oddTransitsFit = new DvPlanetModelFit();
    private List<DvPixelCorrelationResults> pixelCorrelationResults = new ArrayList<DvPixelCorrelationResults>();
    private DvPlanetCandidate planetCandidate = new DvPlanetCandidate();
    private int planetNumber;
    private List<DvPlanetModelFit> reducedParameterFits = new ArrayList<DvPlanetModelFit>();
    private DvSecondaryEventResults secondaryEventResults = new DvSecondaryEventResults();
    private DvPlanetModelFit trapezoidalFit = new DvPlanetModelFit();
    private SimpleFloatTimeSeries trapezoidalModelLightCurve = new SimpleFloatTimeSeries();
    private DvImageArtifactResults imageArtifactResults = new DvImageArtifactResults();
    private String reportFilename = "";

    /**
     * Creates a {@link DvPlanetResults}. For use only by mock objects and
     * Hibernate.
     */
    public DvPlanetResults() {
    }

    /**
     * Creates a new immutable {@link DvPlanetResults} from the given
     * {@link Builder} object.
     */
    protected DvPlanetResults(Builder builder) {
        keplerId = builder.keplerId;
        planetNumber = builder.planetNumber;
        allTransitsFit = builder.allTransitsFit;
        binaryDiscriminationResults = builder.binaryDiscriminationResults;
        centroidResults = builder.centroidResults;
        detrendFilterLength = builder.detrendFilterLength;
        differenceImageResults = builder.differenceImageResults;
        evenTransitsFit = builder.evenTransitsFit;
        foldedPhase = builder.foldedPhase;
        ghostDiagnosticResults = builder.ghostDiagnosticResults;
        keplerName = builder.keplerName;
        koiCorrelation = builder.koiCorrelation;
        koiId = builder.koiId;
        modelLightCurve = builder.modelLightCurve;
        whitenedModelLightCurve = builder.whitenedModelLightCurve;
        whitenedFluxTimeSeries = builder.whitenedFluxTimeSeries;
        detrendedFluxTimeSeries = builder.detrendedFluxTimeSeries;
        oddTransitsFit = builder.oddTransitsFit;
        pixelCorrelationResults = builder.pixelCorrelationResults;
        planetCandidate = builder.planetCandidate;
        reducedParameterFits = builder.reducedParameterFits;
        secondaryEventResults = builder.secondaryEventResults;
        trapezoidalFit = builder.trapezoidalFit;
        trapezoidalModelLightCurve = builder.trapezoidalModelLightCurve;
        imageArtifactResults = builder.imageArtifactResults;
        reportFilename = builder.reportFilename;
    }

    /**
     * Used to construct an immutable {@link DvPlanetResults} object. To use
     * this class, a {@link Builder} object is created and then non-null fields
     * are set using the available builder methods. Finally, a
     * {@link DvPlanetResults} object is created using the {@code build} method.
     * For example:
     * 
     * <pre>
     * DvPlanetResults planetResults = new DvPlanetResults.Builder().allTransitsFit(
     *     allTransitsFit)
     *     .centroidResults(centroidResults)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */

    public static class Builder {
        private DvPlanetModelFit allTransitsFit = new DvPlanetModelFit();
        private DvBinaryDiscriminationResults binaryDiscriminationResults = new DvBinaryDiscriminationResults();
        private DvCentroidResults centroidResults = new DvCentroidResults();
        private int detrendFilterLength;
        private List<DvDifferenceImageResults> differenceImageResults = new ArrayList<DvDifferenceImageResults>();
        private DvPlanetModelFit evenTransitsFit = new DvPlanetModelFit();
        private float[] foldedPhase = new float[0];
        private DvGhostDiagnosticResults ghostDiagnosticResults = new DvGhostDiagnosticResults();
        private int keplerId;
        private String keplerName = "";
        private float koiCorrelation = -1;
        private String koiId = "";
        private SimpleFloatTimeSeries modelLightCurve = new SimpleFloatTimeSeries();
        private SimpleFloatTimeSeries whitenedModelLightCurve = new SimpleFloatTimeSeries();
        private SimpleFloatTimeSeries whitenedFluxTimeSeries = new SimpleFloatTimeSeries();
        private CorrectedFluxTimeSeries detrendedFluxTimeSeries = new CorrectedFluxTimeSeries();
        private DvPlanetModelFit oddTransitsFit = new DvPlanetModelFit();
        private List<DvPixelCorrelationResults> pixelCorrelationResults = new ArrayList<DvPixelCorrelationResults>();
        private DvPlanetCandidate planetCandidate = new DvPlanetCandidate();
        private int planetNumber;
        private List<DvPlanetModelFit> reducedParameterFits = new ArrayList<DvPlanetModelFit>();
        private DvSecondaryEventResults secondaryEventResults = new DvSecondaryEventResults();
        private DvPlanetModelFit trapezoidalFit = new DvPlanetModelFit();
        private SimpleFloatTimeSeries trapezoidalModelLightCurve = new SimpleFloatTimeSeries();
        private DvImageArtifactResults imageArtifactResults = new DvImageArtifactResults();
        private String reportFilename = "";

        public Builder(int keplerId, int planetNumber) {
            this.keplerId = keplerId;
            this.planetNumber = planetNumber;
        }

        public Builder alltransitsFit(DvPlanetModelFit allTransitsFit) {
            this.allTransitsFit = allTransitsFit;
            return this;
        }

        public Builder binaryDiscriminationResults(
            DvBinaryDiscriminationResults binaryDiscriminationResults) {
            this.binaryDiscriminationResults = binaryDiscriminationResults;
            return this;
        }

        public Builder centroidResults(DvCentroidResults centroidResults) {
            this.centroidResults = centroidResults;
            return this;
        }

        public Builder detrendFilterLength(int detrendFilterLength) {
            this.detrendFilterLength = detrendFilterLength;
            return this;
        }

        public Builder differenceImageResults(
            List<DvDifferenceImageResults> differenceImageResults) {
            this.differenceImageResults = differenceImageResults;
            return this;
        }

        public Builder evenTransitsFit(DvPlanetModelFit evenTransitsFit) {
            this.evenTransitsFit = evenTransitsFit;
            return this;
        }

        public Builder foldedPhase(float[] foldedPhase) {
            this.foldedPhase = foldedPhase;
            return this;
        }

        public Builder ghostDiagnosticResults(
            DvGhostDiagnosticResults ghostDiagnosticResults) {
            this.ghostDiagnosticResults = ghostDiagnosticResults;
            return this;
        }

        public Builder keplerName(String keplerName) {
            this.keplerName = keplerName;
            return this;
        }

        public Builder koiCorrelation(float koiCorrelation) {
            this.koiCorrelation = koiCorrelation;
            return this;
        }

        public Builder koiId(String koiId) {
            this.koiId = koiId;
            return this;
        }

        public Builder modelLightCurve(SimpleFloatTimeSeries modelLightCurve) {
            this.modelLightCurve = modelLightCurve;
            return this;
        }

        public Builder whitenedModelLightCurve(
            SimpleFloatTimeSeries whitenedModelLightCurve) {
            this.whitenedModelLightCurve = whitenedModelLightCurve;
            return this;
        }

        public Builder whitenedFluxTimeSeries(
            SimpleFloatTimeSeries whitenedFluxTimeSeries) {
            this.whitenedFluxTimeSeries = whitenedFluxTimeSeries;
            return this;
        }

        public Builder detrendedFluxTimeSeries(
            CorrectedFluxTimeSeries detrendedFluxTimeSeries) {
            this.detrendedFluxTimeSeries = detrendedFluxTimeSeries;
            return this;
        }

        public Builder oddTransitsFit(DvPlanetModelFit oddTransitsFit) {
            this.oddTransitsFit = oddTransitsFit;
            return this;
        }

        public Builder pixelCorrelationResults(
            List<DvPixelCorrelationResults> pixelCorrelationResults) {
            this.pixelCorrelationResults = pixelCorrelationResults;
            return this;
        }

        public Builder planetCandidate(DvPlanetCandidate planetCandidate) {
            this.planetCandidate = planetCandidate;
            return this;
        }

        public Builder reducedParameterFits(
            List<DvPlanetModelFit> reducedParameterFits) {
            this.reducedParameterFits = reducedParameterFits;
            return this;
        }

        public Builder secondaryEventResults(
            DvSecondaryEventResults secondaryEventResults) {
            this.secondaryEventResults = secondaryEventResults;
            return this;
        }

        public Builder trapezoidalFit(DvPlanetModelFit trapezoidalFit) {
            this.trapezoidalFit = trapezoidalFit;
            return this;
        }

        public Builder trapezoidalModelLightCurve(
            SimpleFloatTimeSeries trapezoidalModelLightCurve) {
            this.trapezoidalModelLightCurve = trapezoidalModelLightCurve;
            return this;
        }

        public Builder imageArtifactResults(
            DvImageArtifactResults imageArtifactResults) {
            this.imageArtifactResults = imageArtifactResults;
            return this;
        }

        public Builder reportFilename(String reportFilename) {
            this.reportFilename = reportFilename;
            return this;
        }

        public DvPlanetResults build() {
            return new DvPlanetResults(this);
        }
    }

    public DvPlanetModelFit getAllTransitsFit() {
        return allTransitsFit;
    }

    public DvBinaryDiscriminationResults getBinaryDiscriminationResults() {
        return binaryDiscriminationResults;
    }

    public DvCentroidResults getCentroidResults() {
        return centroidResults;
    }

    public int getDetrendFilterLength() {
        return detrendFilterLength;
    }

    public List<DvDifferenceImageResults> getDifferenceImageResults() {
        return differenceImageResults;
    }

    public DvPlanetModelFit getEvenTransitsFit() {
        return evenTransitsFit;
    }

    public float[] getFoldedPhase() {
        return foldedPhase;
    }

    public DvGhostDiagnosticResults getGhostDiagnosticResults() {
        return ghostDiagnosticResults;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public String getKeplerName() {
        return keplerName;
    }

    public float getKoiCorrelation() {
        return koiCorrelation;
    }

    public String getKoiId() {
        return koiId;
    }

    public SimpleFloatTimeSeries getModelLightCurve() {
        return modelLightCurve;
    }

    public SimpleFloatTimeSeries getWhitenedModelLightCurve() {
        return whitenedModelLightCurve;
    }

    public SimpleFloatTimeSeries getWhitenedFluxTimeSeries() {
        return whitenedFluxTimeSeries;
    }

    public CorrectedFluxTimeSeries getDetrendedFluxTimeSeries() {
        return detrendedFluxTimeSeries;
    }

    public DvPlanetModelFit getOddTransitsFit() {
        return oddTransitsFit;
    }

    public List<DvPixelCorrelationResults> getPixelCorrelationResults() {
        return pixelCorrelationResults;
    }

    public DvPlanetCandidate getPlanetCandidate() {
        return planetCandidate;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public List<DvPlanetModelFit> getReducedParameterFits() {
        return reducedParameterFits;
    }

    public String getReportFilename() {
        return reportFilename;
    }

    public DvSecondaryEventResults getSecondaryEventResults() {
        return secondaryEventResults;
    }

    public DvPlanetModelFit getTrapezoidalFit() {
        return trapezoidalFit;
    }

    public SimpleFloatTimeSeries getTrapezoidalModelLightCurve() {
        return trapezoidalModelLightCurve;
    }

    public DvImageArtifactResults getImageArtifactResults() {
        return imageArtifactResults;
    }
}
