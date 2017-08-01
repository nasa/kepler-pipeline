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

package gov.nasa.kepler.hibernate.tad;

import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.Index;
import org.hibernate.annotations.IndexColumn;

/**
 * This class represents {@link CelestialObject}s or locations of interest
 * (stars, GO targets, reference pixel targets, etc.). An {@link ObservedTarget}
 * can have multiple {@link TargetDefinition}s if it requires multiple
 * {@link Mask}s to cover its {@link Aperture}.
 * 
 * @author Miles Cote
 */
@Entity
@Table(name = "TAD_OBSERVED_TARGET")
public class ObservedTarget implements HasKeplerId {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "TAD_OBSERVED_TARGET_SEQ")
    @Column(nullable = false)
    private long id;

    @OneToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    @ManyToOne(optional = false)
    @Cascade(CascadeType.EVICT)
    private TargetTable targetTable;

    @Column(nullable = false)
    private int ccdModule;

    @Column(nullable = false)
    private int ccdOutput;

    @Index(name = "TAD_OTARGET_KEPID_IDX")
    private int keplerId;

    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    private Set<String> labels = new LinkedHashSet<String>();

    private boolean paCoaApertureUsed = false;

    // Optimal aperture or user defined aperture. May require more than one
    // mask.
    @OneToOne(optional = true, fetch = FetchType.LAZY)
    @Cascade(CascadeType.ALL)
    private Aperture aperture;

    @Column(nullable = true)
    private double signalToNoiseRatio;

    @Column(nullable = true)
    private float magnitude;

    @Column(nullable = true)
    private double ra;

    @Column(name = "`DEC`", nullable = true)
    private double dec;

    @Column(nullable = true)
    private float effectiveTemp;

    @Column(nullable = true)
    private int badPixelCount;

    @Column(nullable = true)
    private double crowdingMetric = 1.0;

    @Column(nullable = true)
    private double skyCrowdingMetric = 1.0;

    @Column(nullable = true)
    private double fluxFractionInAperture = 1.0;

    @Column(nullable = true)
    private int distanceFromEdge;

    // This field cannot have 'nullable = true' because it needs to be 'not null'.
    // This field is configured like targetDefsPixelCount below.
    private int saturatedRowCount = -1;

    @Column(nullable = true)
    private boolean rejected;

    // A target may require more than one TargetDefinition to cover its
    // Aperture.
    @OneToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "TAD_OBS_TARGET_TARGET_DEFS")
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    private Collection<TargetDefinition> targetDefinitions = new HashSet<TargetDefinition>();

    private int aperturePixelCount;

    private int targetDefsPixelCount;

    private transient ObservedTarget supplementalObservedTarget;

    ObservedTarget() {
    }

    public ObservedTarget(int keplerId) {
        this.keplerId = keplerId;
    }

    public ObservedTarget(TargetTable targetTable, int ccdModule,
        int ccdOutput, int keplerId) {
        this.targetTable = targetTable;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.keplerId = keplerId;
    }

    /**
     * This method should be called on an {@link ObservedTarget} from an
     * original tad run. <br>
     * This method should not be called on an {@link ObservedTarget} from a
     * supplemental tad run.<br>
     */
    public int getClippedPixelCount() {
        ClipReport clipReport = new ClipReportFactory().create(
            targetDefinitions, getAperture());

        return clipReport.getClippedOptApPixels();
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + keplerId;
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
        final ObservedTarget other = (ObservedTarget) obj;
        if (keplerId != other.keplerId)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("ccdModule", ccdModule)
            .append("ccdOutput", ccdOutput)
            .append("keplerId", keplerId)
            .append("aperture", aperture)
            .append("paCoaApertureUsed", paCoaApertureUsed)
            .append("badPixelCount", badPixelCount)
            .append("crowdingMetric", crowdingMetric)
            .append("skyCrowdingMetric", skyCrowdingMetric)
            .append("fluxFractionInAperture", fluxFractionInAperture)
            .append("signalToNoiseRatio", signalToNoiseRatio)
            .append("skyCrowdingMetric", skyCrowdingMetric)
            .append("rejected", rejected)
            .toString();
    }

    public long getId() {
        return id;
    }

    public Aperture getAperture() {
        return getObservedTarget().aperture;
    }

    public void setAperture(Aperture aperture) {
        this.aperture = aperture;
    }

    public boolean isPaCoaApertureUsed() {
        return getObservedTarget().paCoaApertureUsed;
    }

    public void setPaCoaApertureUsed(boolean paCoaApertureUsed) {
        this.paCoaApertureUsed = paCoaApertureUsed;
    }

    public int getBadPixelCount() {
        return getObservedTarget().badPixelCount;
    }

    public void setBadPixelCount(int badPixelCount) {
        this.badPixelCount = badPixelCount;
    }

    public double getCrowdingMetric() {
        return getObservedTarget().crowdingMetric;
    }

    public void setCrowdingMetric(double crowdingMetric) {
        this.crowdingMetric = crowdingMetric;
    }

    public double getSignalToNoiseRatio() {
        return getObservedTarget().signalToNoiseRatio;
    }

    public void setSignalToNoiseRatio(double signalToNoiseRatio) {
        this.signalToNoiseRatio = signalToNoiseRatio;
    }

    public void setMagnitude(float magnitude) {
        this.magnitude = magnitude;
    }

    public float getMagnitude() {
        return getObservedTarget().magnitude;
    }

    public double getRa() {
        return getObservedTarget().ra;
    }

    public void setRa(double ra) {
        this.ra = ra;
    }

    public double getDec() {
        return getObservedTarget().dec;
    }

    public void setDec(double dec) {
        this.dec = dec;
    }

    public float getEffectiveTemp() {
        return getObservedTarget().effectiveTemp;
    }

    public void setEffectiveTemp(float effectiveTemp) {
        this.effectiveTemp = effectiveTemp;
    }

    public Collection<TargetDefinition> getTargetDefinitions() {
        return targetDefinitions;
    }

    public void setTargetDefinitions(
        Collection<TargetDefinition> targetDefinitions) {
        this.targetDefinitions = targetDefinitions;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public ModOut getModOut() {
        return ModOut.of(ccdModule, ccdOutput);
    }

    public void setModOut(ModOut modOut) {
        this.ccdModule = modOut.getCcdModule();
        this.ccdOutput = modOut.getCcdOutput();
    }

    public TargetTable getTargetTable() {
        return targetTable;
    }

    @Override
    public int getKeplerId() {
        return keplerId;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public void setTargetTable(TargetTable targetTable) {
        this.targetTable = targetTable;
    }

    public boolean isRejected() {
        return rejected;
    }

    public void setRejected(boolean rejected) {
        this.rejected = rejected;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    public double getFluxFractionInAperture() {
        return getObservedTarget().fluxFractionInAperture;
    }

    public void setFluxFractionInAperture(double fluxFractionInAperture) {
        this.fluxFractionInAperture = fluxFractionInAperture;
    }

    public int getAperturePixelCount() {
        return getObservedTarget().aperturePixelCount;
    }

    public void setAperturePixelCount(int aperturePixelCount) {
        this.aperturePixelCount = aperturePixelCount;
    }

    public int getTargetDefsPixelCount() {
        return targetDefsPixelCount;
    }

    public void setTargetDefsPixelCount(int targetDefsPixelCount) {
        this.targetDefsPixelCount = targetDefsPixelCount;
    }

    public Set<String> getLabels() {
        return getObservedTarget().labels;
    }

    public void setLabels(Set<String> labels) {
        this.labels = labels;
    }

    public boolean addLabel(TargetLabel label) {
        return labels.add(label.toString());
    }

    public boolean containsLabel(TargetLabel label) {
        return getObservedTarget().labels.contains(label.toString());
    }

    public boolean removeLabel(TargetLabel label) {
        return labels.remove(label.toString());
    }

    public int getDistanceFromEdge() {
        return getObservedTarget().distanceFromEdge;
    }

    public void setDistanceFromEdge(int distanceFromEdge) {
        this.distanceFromEdge = distanceFromEdge;
    }

    public int getSaturatedRowCount() {
        return getObservedTarget().saturatedRowCount;
    }

    public void setSaturatedRowCount(int saturatedRowCount) {
        this.saturatedRowCount = saturatedRowCount;
    }

    public double getSkyCrowdingMetric() {
        return getObservedTarget().skyCrowdingMetric;
    }

    public void setSkyCrowdingMetric(double skyCrowdingMetric) {
        this.skyCrowdingMetric = skyCrowdingMetric;
    }

    /** For testing purposes only. */
    public boolean testAddLabel(String label) {
        return labels.add(label);
    }

    /** For testing purposes only. */
    ObservedTarget getSupplementalObservedTarget() {
        return supplementalObservedTarget;
    }

    public void setSupplementalObservedTarget(
        ObservedTarget supplementalObservedTarget) {
        if (supplementalObservedTarget != null) {
            int suppKeplerId = supplementalObservedTarget.getKeplerId();
            if (keplerId != suppKeplerId) {
                throw new IllegalArgumentException(
                    "The supplementalKeplerId  must be the same as the original "
                        + "keplerId.\n  origKeplerId: " + keplerId
                        + "\n  suppKeplerId: " + suppKeplerId);
            }
        }

        this.supplementalObservedTarget = supplementalObservedTarget;
    }

    protected ObservedTarget getObservedTarget() {
        if (supplementalObservedTarget != null
            && !supplementalObservedTarget.isRejected()) {
            return supplementalObservedTarget;
        } 

        return this;
    }
}
