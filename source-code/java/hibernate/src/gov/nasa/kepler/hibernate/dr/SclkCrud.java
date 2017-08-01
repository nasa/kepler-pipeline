/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Provides CRUD access to the {@link SclkCoefficients}. Also provides an API to
 * convert a VTC (Vehicle Time Clock) value to a barycentric timestamp using
 * these coefficients
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class SclkCrud extends AbstractCrud {

    private static final int SECONDS_PER_DAY = 86400;

    public SclkCrud() {
    }

    public SclkCrud(DatabaseService dbs) {
        super(dbs);
    }

    /**
     * Persist a new SclkCoefficients instance
     * 
     * @param sclkCoefficients
     * @throws PipelineException
     */
    public void createSclkCoefficients(SclkCoefficients sclkCoefficients) {
        getSession().save(sclkCoefficients);
    }

    /**
     * Retrieve SclkCoefficients for the specified VTC value
     * 
     * @throws PipelineException
     */
    public SclkCoefficients retrieveSclkCoefficients(double vtcTime) {

        Session session = getSession();
        Query q = session.createQuery("from SclkCoefficients s where s.vtcEventTime <= :vtcValue order by s.vtcEventTime desc");
        q.setParameter("vtcValue", vtcTime);
        q.setMaxResults(1);

        /*
         * We want the largest base VTC (vtcEventTime) that is less than or
         * equal to the specified vtcValue. Based on the query above, this will
         * be the first result returned.
         */
        return uniqueResult(q);
    }

    /**
     * Retrieves the most recent sclk file. These files are cummulative, so the
     * latest one will have all of the data.
     * 
     * @throws PipelineException
     */
    public SclkCoefficients retrieveLatestSclkCoefficients() {
        Query query = getSession().createQuery(
            "from SclkCoefficients " + "order by receiveData desc");
        List<SclkCoefficients> list = list(query);
        return list.get(0);
    }

    /**
     * Retrieve all SclkCoefficients.
     * 
     * @throws PipelineException
     */
    public List<SclkCoefficients> retrieveAllSclkCoefficients() {

        Session session = getSession();
        Query q = session.createQuery("from SclkCoefficients s order by s.vtcEventTime asc");

        List<SclkCoefficients> list = list(q);
        return list;
    }

    /**
     * @deprecated Use VtcOperations instead.
     * 
     * Convert a VTC value to an mjd using the coefficients from the SCLK file
     * 
     * @param vtcValue
     * @return
     * @throws PipelineException
     */
    @Deprecated
    public double convertVtcToMjd(long vtcValue) {

        double vtcTime = vtcValue / 256.0;

        SclkCoefficients sclkCoefficients = retrieveSclkCoefficients(vtcTime);
        if (sclkCoefficients == null) {
            throw new PipelineException(vtcTime
                + ": no corresponding sclk coefficients available");
        }

        /*
         * double secondsSinceJ2000 = sclkCoefficients.getSecondsSinceEpoch() +
         * sclkCoefficients.getClockRate() (vtcTime -
         * sclkCoefficients.getVtcEventTime());
         * 
         * double daysSinceJ2000 = secondsSinceJ2000 / SECONDS_PER_DAY;
         * 
         * double mjd = FcConstants.J2000_MJD + daysSinceJ2000;
         */
        double mjd = convertVtcToMjd(vtcValue,
            sclkCoefficients.getSecondsSinceEpoch(),
            sclkCoefficients.getClockRate(),
            sclkCoefficients.getVtcEventTime(), FcConstants.J2000_MJD);
        return mjd;
    }

    /**
     * @deprecated Use VtcOperations instead.
     * 
     * Convert a VTC value to an mjd using the coefficients from the caller --
     * useful if using a canned set of coeffs for the conversion (ie, when not
     * connected to the datastore).
     * 
     * @param vtcValue
     * @return
     * @throws PipelineException
     */
    @Deprecated
    public double convertVtcToMjd(long vtcValue, double secondsSinceEpoch,
        double clockRate, double vtcEventTime, double J2000_MJD) {

        double vtcTime = vtcValue / 256.0;

        double secondsSinceJ2000 = secondsSinceEpoch + clockRate
            * (vtcTime - vtcEventTime);

        double daysSinceJ2000 = secondsSinceJ2000 / SECONDS_PER_DAY;

        double mjd = J2000_MJD + daysSinceJ2000;

        return mjd;

    }
}
