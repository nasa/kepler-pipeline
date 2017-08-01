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

package gov.nasa.kepler.hibernate.cm;

import gov.nasa.kepler.common.TargetManagementConstants;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * This class represents a piece of sky that is desirable for viewing, but is
 * not in the KIC.
 * 
 * @author Miles Cote
 * 
 */
@Entity
@Table(name = "CM_CUSTOM_TARGET")
public class CustomTarget implements CelestialObject {

    private static final String CUSTOM_TARGET_PROVENANCE = "CUSTOM";

    @Id
    // Once Hibernate supports the initialValue parameter, the following would
    // make CustomTargetSequence obsolete.
    // @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    // @SequenceGenerator(name = "sg",
    // initialValue=TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START,
    // sequenceName = "CM_CT_SEQ")
    @Column(nullable = false)
    private int keplerId;

    // SOC-specific columns.
    @Column(nullable = false)
    private int skyGroupId;

    private transient double ra = Double.NaN;

    private transient double dec = Double.NaN;

    private transient Float raProperMotion;

    private transient Float decProperMotion;

    private transient Float uMag;

    private transient Float gMag;

    private transient Float rMag;

    private transient Float iMag;

    private transient Float zMag;

    private transient Float gredMag;

    private transient Float d51Mag;

    private transient Float twoMassJMag;

    private transient Float twoMassHMag;

    private transient Float twoMassKMag;

    private transient Float keplerMag;

    private transient Integer twoMassId;

    private transient Integer internalScpId;

    private transient Integer alternateId;

    private transient Integer alternateSource;

    private transient Integer galaxyIndicator;

    private transient Integer blendIndicator;

    private transient Integer variableIndicator;

    private transient Integer effectiveTemp;

    private transient Float log10SurfaceGravity;

    private transient Float log10Metallicity;

    private transient Float ebMinusVRedding;

    private transient Float avExtinction;

    private transient Float radius;

    private transient String source;

    private transient Integer photometryQuality;

    private transient Integer astrophysicsQuality;

    private transient Integer catalogId;

    private transient Integer scpId;

    private transient Float parallax;

    private transient Double galacticLongitude;

    private transient Double galacticLatitude;

    private transient Float totalProperMotion;

    private transient Float grColor;

    private transient Float jkColor;

    private transient Float gkColor;

    /**
     * Default constructor for Hibernate use only.
     */
    CustomTarget() {
    }

    public CustomTarget(int keplerId, int skyGroupId) {
        this.keplerId = keplerId;
        this.skyGroupId = skyGroupId;

        if (!TargetManagementConstants.isCustomTarget(keplerId)) {
            throw new IllegalArgumentException("keplerId must be greater than "
                + TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START);
        }
    }

    private CustomTarget(CustomTarget customTarget) {
        ra = customTarget.ra;
        dec = customTarget.dec;
        raProperMotion = customTarget.raProperMotion;
        decProperMotion = customTarget.decProperMotion;
        uMag = customTarget.uMag;
        gMag = customTarget.gMag;
        rMag = customTarget.rMag;
        iMag = customTarget.iMag;
        zMag = customTarget.zMag;
        gredMag = customTarget.gredMag;
        d51Mag = customTarget.d51Mag;
        twoMassJMag = customTarget.twoMassJMag;
        twoMassHMag = customTarget.twoMassHMag;
        twoMassKMag = customTarget.twoMassKMag;
        keplerMag = customTarget.keplerMag;
        keplerId = customTarget.keplerId;
        twoMassId = customTarget.twoMassId;
        internalScpId = customTarget.internalScpId;
        alternateId = customTarget.alternateId;
        alternateSource = customTarget.alternateSource;
        galaxyIndicator = customTarget.galaxyIndicator;
        blendIndicator = customTarget.blendIndicator;
        variableIndicator = customTarget.variableIndicator;
        effectiveTemp = customTarget.effectiveTemp;
        log10SurfaceGravity = customTarget.log10SurfaceGravity;
        log10Metallicity = customTarget.log10Metallicity;
        ebMinusVRedding = customTarget.ebMinusVRedding;
        avExtinction = customTarget.avExtinction;
        radius = customTarget.radius;
        source = customTarget.source;
        photometryQuality = customTarget.photometryQuality;
        astrophysicsQuality = customTarget.astrophysicsQuality;
        catalogId = customTarget.catalogId;
        scpId = customTarget.scpId;
        parallax = customTarget.parallax;
        galacticLongitude = customTarget.galacticLongitude;
        galacticLatitude = customTarget.galacticLatitude;
        totalProperMotion = customTarget.totalProperMotion;
        grColor = customTarget.grColor;
        jkColor = customTarget.jkColor;
        gkColor = customTarget.gkColor;
        skyGroupId = customTarget.skyGroupId;
    }

    private CustomTarget(Builder builder) {
        ra = builder.customTarget.ra;
        dec = builder.customTarget.dec;
        raProperMotion = builder.customTarget.raProperMotion;
        decProperMotion = builder.customTarget.decProperMotion;
        uMag = builder.customTarget.uMag;
        gMag = builder.customTarget.gMag;
        rMag = builder.customTarget.rMag;
        iMag = builder.customTarget.iMag;
        zMag = builder.customTarget.zMag;
        gredMag = builder.customTarget.gredMag;
        d51Mag = builder.customTarget.d51Mag;
        twoMassJMag = builder.customTarget.twoMassJMag;
        twoMassHMag = builder.customTarget.twoMassHMag;
        twoMassKMag = builder.customTarget.twoMassKMag;
        keplerMag = builder.customTarget.keplerMag;
        keplerId = builder.customTarget.keplerId;
        twoMassId = builder.customTarget.twoMassId;
        internalScpId = builder.customTarget.internalScpId;
        alternateId = builder.customTarget.alternateId;
        alternateSource = builder.customTarget.alternateSource;
        galaxyIndicator = builder.customTarget.galaxyIndicator;
        blendIndicator = builder.customTarget.blendIndicator;
        variableIndicator = builder.customTarget.variableIndicator;
        effectiveTemp = builder.customTarget.effectiveTemp;
        log10SurfaceGravity = builder.customTarget.log10SurfaceGravity;
        log10Metallicity = builder.customTarget.log10Metallicity;
        ebMinusVRedding = builder.customTarget.ebMinusVRedding;
        avExtinction = builder.customTarget.avExtinction;
        radius = builder.customTarget.radius;
        source = builder.customTarget.source;
        photometryQuality = builder.customTarget.photometryQuality;
        astrophysicsQuality = builder.customTarget.astrophysicsQuality;
        catalogId = builder.customTarget.catalogId;
        scpId = builder.customTarget.scpId;
        parallax = builder.customTarget.parallax;
        galacticLongitude = builder.customTarget.galacticLongitude;
        galacticLatitude = builder.customTarget.galacticLatitude;
        totalProperMotion = builder.customTarget.totalProperMotion;
        grColor = builder.customTarget.grColor;
        jkColor = builder.customTarget.jkColor;
        gkColor = builder.customTarget.gkColor;
        skyGroupId = builder.customTarget.skyGroupId;
    }

    // Accessors and formatters, in alphabetical order.

    @Override
    public Integer getAlternateId() {
        return alternateId;
    }

    @Override
    public Integer getAlternateSource() {
        return alternateSource;
    }

    @Override
    public Integer getAstrophysicsQuality() {
        return astrophysicsQuality;
    }

    @Override
    public Float getAvExtinction() {
        return avExtinction;
    }

    @Override
    public Integer getBlendIndicator() {
        return blendIndicator;
    }

    @Override
    public Integer getCatalogId() {
        return catalogId;
    }

    @Override
    public Float getD51Mag() {
        return d51Mag;
    }

    @Override
    public double getDec() {
        return dec;
    }

    @Override
    public Float getDecProperMotion() {
        return decProperMotion;
    }

    @Override
    public Float getEbMinusVRedding() {
        return ebMinusVRedding;
    }

    @Override
    public Integer getEffectiveTemp() {
        return effectiveTemp;
    }

    @Override
    public Double getGalacticLatitude() {
        return galacticLatitude;
    }

    @Override
    public Double getGalacticLongitude() {
        return galacticLongitude;
    }

    @Override
    public Integer getGalaxyIndicator() {
        return galaxyIndicator;
    }

    @Override
    public Float getGkColor() {
        return gkColor;
    }

    @Override
    public Float getGMag() {
        return gMag;
    }

    @Override
    public Float getGrColor() {
        return grColor;
    }

    @Override
    public Float getGredMag() {
        return gredMag;
    }

    @Override
    public Float getIMag() {
        return iMag;
    }

    @Override
    public Float getJkColor() {
        return jkColor;
    }

    @Override
    public Integer getInternalScpId() {
        return internalScpId;
    }

    @Override
    public int getKeplerId() {
        return keplerId;
    }

    @Override
    public Float getKeplerMag() {
        return keplerMag;
    }

    @Override
    public Float getLog10Metallicity() {
        return log10Metallicity;
    }

    @Override
    public Float getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    @Override
    public Float getParallax() {
        return parallax;
    }

    @Override
    public Integer getPhotometryQuality() {
        return photometryQuality;
    }

    @Override
    public String getProvenance() {
        return CUSTOM_TARGET_PROVENANCE;
    }

    @Override
    public double getRa() {
        return ra;
    }

    @Override
    public Float getRadius() {
        return radius;
    }

    @Override
    public Float getRaProperMotion() {
        return raProperMotion;
    }

    @Override
    public Float getRMag() {
        return rMag;
    }

    @Override
    public Integer getScpId() {
        return scpId;
    }

    @Override
    public int getSkyGroupId() {
        return skyGroupId;
    }

    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    @Override
    public String getSource() {
        return source;
    }

    @Override
    public Float getTotalProperMotion() {
        return totalProperMotion;
    }

    @Override
    public Float getTwoMassHMag() {
        return twoMassHMag;
    }

    @Override
    public Integer getTwoMassId() {
        return twoMassId;
    }

    @Override
    public Float getTwoMassJMag() {
        return twoMassJMag;
    }

    @Override
    public Float getTwoMassKMag() {
        return twoMassKMag;
    }

    @Override
    public Float getUMag() {
        return uMag;
    }

    @Override
    public Integer getVariableIndicator() {
        return variableIndicator;
    }

    @Override
    public Float getZMag() {
        return zMag;
    }

    @Override
    public final int hashCode() {
        return keplerId;
    }

    @Override
    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof CustomTarget)) {
            return false;
        }
        final CustomTarget other = (CustomTarget) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        return true;
    }

    /**
     * Builds {@link CustomTarget}s.
     * 
     * @author Miles Cote
     * 
     */
    public static class Builder implements CelestialObjectBuilder {
        CustomTarget customTarget;

        public Builder(int keplerId) {
            customTarget = new CustomTarget();
            customTarget.keplerId = keplerId;
        }

        public Builder(int keplerId, double ra, double dec) {
            customTarget = new CustomTarget();
            customTarget.keplerId = keplerId;
            customTarget.ra = ra;
            customTarget.dec = dec;
        }

        public Builder(CustomTarget customTarget) {
            this.customTarget = new CustomTarget(customTarget);
        }

        /**
         * Creates a {@link Builder} object starting with an existing
         * {@link Kic} object and overriding the RA and DEC with the given
         * parameters.
         * 
         * @param kic an existing {@link Kic} object
         * @param ra the corrected right ascension
         * @param dec the corrected declination
         */
        public Builder(Kic kic, double ra, double dec) {
            customTarget = new CustomTarget(customTarget);
            customTarget.ra = ra;
            customTarget.dec = dec;
        }

        // Builders, in alphabetical order.

        @Override
        public Builder alternateId(Integer alternateId) {
            customTarget.alternateId = alternateId;
            return this;
        }

        @Override
        public Builder alternateSource(Integer alternateSource) {
            customTarget.alternateSource = alternateSource;
            return this;
        }

        @Override
        public Builder astrophysicsQuality(Integer astrophysicsQuality) {
            customTarget.astrophysicsQuality = astrophysicsQuality;
            return this;
        }

        @Override
        public Builder avExtinction(Float avExtinction) {
            customTarget.avExtinction = avExtinction;
            return this;
        }

        @Override
        public Builder blendIndicator(Integer blendIndicator) {
            customTarget.blendIndicator = blendIndicator;
            return this;
        }

        @Override
        public Builder catalogId(Integer catalogId) {
            customTarget.catalogId = catalogId;
            return this;
        }

        @Override
        public Builder dec(double dec) {
            customTarget.dec = dec;
            return this;
        }

        @Override
        public Builder d51Mag(Float mag) {
            customTarget.d51Mag = mag;
            return this;
        }

        @Override
        public Builder decProperMotion(Float decProperMotion) {
            customTarget.decProperMotion = decProperMotion;
            return this;
        }

        @Override
        public Builder ebMinusVRedding(Float ebMinusVRedding) {
            customTarget.ebMinusVRedding = ebMinusVRedding;
            return this;
        }

        @Override
        public Builder effectiveTemp(Integer effectiveTemp) {
            customTarget.effectiveTemp = effectiveTemp;
            return this;
        }

        @Override
        public Builder galacticLatitude(Double galacticLatitude) {
            customTarget.galacticLatitude = galacticLatitude;
            return this;
        }

        @Override
        public Builder galacticLongitude(Double galacticLongitude) {
            customTarget.galacticLongitude = galacticLongitude;
            return this;
        }

        @Override
        public Builder galaxyIndicator(Integer galaxyIndicator) {
            customTarget.galaxyIndicator = galaxyIndicator;
            return this;
        }

        @Override
        public Builder gkColor(Float color) {
            customTarget.gkColor = color;
            return this;
        }

        @Override
        public Builder gMag(Float mag) {
            customTarget.gMag = mag;
            return this;
        }

        @Override
        public Builder grColor(Float color) {
            customTarget.grColor = color;
            return this;
        }

        @Override
        public Builder gredMag(Float mag) {
            customTarget.gredMag = mag;
            return this;
        }

        @Override
        public Builder iMag(Float mag) {
            customTarget.iMag = mag;
            return this;
        }

        @Override
        public Builder internalScpId(Integer id) {
            customTarget.internalScpId = id;
            return this;
        }

        @Override
        public Builder jkColor(Float color) {
            customTarget.jkColor = color;
            return this;
        }

        @Override
        public Builder keplerMag(Float mag) {
            customTarget.keplerMag = mag;
            return this;
        }

        @Override
        public Builder log10Metallicity(Float log10Metallicity) {
            customTarget.log10Metallicity = log10Metallicity;
            return this;
        }

        @Override
        public Builder log10SurfaceGravity(Float log10SurfaceGravity) {
            customTarget.log10SurfaceGravity = log10SurfaceGravity;
            return this;
        }

        @Override
        public Builder parallax(Float parallax) {
            customTarget.parallax = parallax;
            return this;
        }

        @Override
        public Builder photometryQuality(Integer photometryQuality) {
            customTarget.photometryQuality = photometryQuality;
            return this;
        }

        @Override
        public Builder ra(double ra) {
            customTarget.ra = ra;
            return this;
        }

        @Override
        public Builder radius(Float radius) {
            customTarget.radius = radius;
            return this;
        }

        @Override
        public Builder raProperMotion(Float raProperMotion) {
            customTarget.raProperMotion = raProperMotion;
            return this;
        }

        @Override
        public Builder rMag(Float mag) {
            customTarget.rMag = mag;
            return this;
        }

        @Override
        public Builder scpId(Integer scpId) {
            customTarget.scpId = scpId;
            return this;
        }

        @Override
        public Builder skyGroupId(int skyGroupId) {
            customTarget.skyGroupId = skyGroupId;
            return this;
        }

        @Override
        public Builder source(String source) {
            customTarget.source = source;
            return this;
        }

        @Override
        public Builder totalProperMotion(Float totalProperMotion) {
            customTarget.totalProperMotion = totalProperMotion;
            return this;
        }

        @Override
        public Builder twoMassHMag(Float twoMassHMag) {
            customTarget.twoMassHMag = twoMassHMag;
            return this;
        }

        @Override
        public Builder twoMassId(Integer twoMassId) {
            customTarget.twoMassId = twoMassId;
            return this;
        }

        @Override
        public Builder twoMassJMag(Float twoMassJMag) {
            customTarget.twoMassJMag = twoMassJMag;
            return this;
        }

        @Override
        public Builder twoMassKMag(Float twoMassKMag) {
            customTarget.twoMassKMag = twoMassKMag;
            return this;
        }

        @Override
        public Builder uMag(Float mag) {
            customTarget.uMag = mag;
            return this;
        }

        @Override
        public Builder variableIndicator(Integer variableIndicator) {
            customTarget.variableIndicator = variableIndicator;
            return this;
        }

        @Override
        public Builder zMag(Float mag) {
            customTarget.zMag = mag;
            return this;
        }

        @Override
        public CustomTarget build() {
            return new CustomTarget(this);
        }
    }

}
