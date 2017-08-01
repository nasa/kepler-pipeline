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

/**
 * Builds {@link CelestialObject}s.
 * 
 * @author Miles Cote
 * 
 */
public interface CelestialObjectBuilder {

    public CelestialObjectBuilder alternateId(Integer alternateId);

    public CelestialObjectBuilder alternateSource(Integer alternateSource);

    public CelestialObjectBuilder astrophysicsQuality(Integer astrophysicsQuality);

    public CelestialObjectBuilder avExtinction(Float avExtinction);

    public CelestialObjectBuilder blendIndicator(Integer blendIndicator);

    public CelestialObjectBuilder catalogId(Integer catalogId);

    public CelestialObjectBuilder dec(double dec);

    public CelestialObjectBuilder d51Mag(Float mag);

    public CelestialObjectBuilder decProperMotion(Float decProperMotion);

    public CelestialObjectBuilder ebMinusVRedding(Float ebMinusVRedding);

    public CelestialObjectBuilder effectiveTemp(Integer effectiveTemp);

    public CelestialObjectBuilder galacticLatitude(Double galacticLatitude);

    public CelestialObjectBuilder galacticLongitude(Double galacticLongitude);

    public CelestialObjectBuilder galaxyIndicator(Integer galaxyIndicator);

    public CelestialObjectBuilder gkColor(Float color);

    public CelestialObjectBuilder gMag(Float mag);

    public CelestialObjectBuilder grColor(Float color);

    public CelestialObjectBuilder gredMag(Float mag);

    public CelestialObjectBuilder iMag(Float mag);

    public CelestialObjectBuilder internalScpId(Integer id);

    public CelestialObjectBuilder jkColor(Float color);

    public CelestialObjectBuilder keplerMag(Float mag);

    public CelestialObjectBuilder log10Metallicity(Float log10Metallicity);

    public CelestialObjectBuilder log10SurfaceGravity(Float log10SurfaceGravity);

    public CelestialObjectBuilder parallax(Float parallax);

    public CelestialObjectBuilder photometryQuality(Integer photometryQuality);

    public CelestialObjectBuilder ra(double ra);

    public CelestialObjectBuilder radius(Float radius);

    public CelestialObjectBuilder raProperMotion(Float raProperMotion);

    public CelestialObjectBuilder rMag(Float mag);

    public CelestialObjectBuilder scpId(Integer scpId);

    public CelestialObjectBuilder skyGroupId(int skyGroupId);

    public CelestialObjectBuilder source(String source);

    public CelestialObjectBuilder totalProperMotion(Float totalProperMotion);

    public CelestialObjectBuilder twoMassHMag(Float twoMassHMag);

    public CelestialObjectBuilder twoMassId(Integer twoMassId);

    public CelestialObjectBuilder twoMassJMag(Float twoMassJMag);

    public CelestialObjectBuilder twoMassKMag(Float twoMassKMag);

    public CelestialObjectBuilder uMag(Float mag);

    public CelestialObjectBuilder variableIndicator(Integer variableIndicator);

    public CelestialObjectBuilder zMag(Float mag);

    public CelestialObject build();

}
