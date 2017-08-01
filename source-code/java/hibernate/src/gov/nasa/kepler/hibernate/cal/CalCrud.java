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

package gov.nasa.kepler.hibernate.cal;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.mc.AbstractModOutCadenceBlob;

import java.util.Arrays;
import java.util.List;

import org.hibernate.Query;

/**
 * Manage database objects produced by cal.
 * 
 * @author Sean McCauliff
 * 
 */
public class CalCrud extends AbstractCrud {

    public CalCrud(DatabaseService dbService) {
        super(dbService);
    }

    public CalCrud() {
    }

    public <B extends AbstractModOutCadenceBlob> void create(B metadata) {
        getSession().saveOrUpdate(metadata);
    }
    
    public List<CalOneDBlackFitMetadata> retrieveOneDBlackMetadata(
        int startCadence, int endCadence, CadenceType cadenceType) {

        return retrieveCalBlobByCadence(startCadence, endCadence, cadenceType,
                                        CalOneDBlackFitMetadata.class);
    }
    
    
    public List<SmearMetadata> retrieveSmearMetadata(
            int startCadence, int endCadence, CadenceType cadenceType) {
        return retrieveCalBlobByCadence(startCadence, endCadence, cadenceType,
                SmearMetadata.class);
    }
    
    /**
     * 
     * @param startCadence
     * @param endCadence inclusive
     * @return A list of instances that fall completely or partially within the
     * specified time else this returns a zero sized list.
     */
    public List<UncertaintyTransformationMetadata> retrieveUncertaintyTransformationMetadata(
        int startCadence, int endCadence, CadenceType cadenceType) {
        
        return retrieveCalBlobByCadence(startCadence, endCadence, cadenceType, UncertaintyTransformationMetadata.class);
    }
    
    private <B extends AbstractModOutCadenceBlob> List<B> retrieveCalBlobByCadence(
        int startCadence, int endCadence, CadenceType cadenceType,
        Class<B> blobMetadataClass) {
        
        checkCadence(startCadence, endCadence);

        String q = "from " + blobMetadataClass.getSimpleName() + " u "
            + " where u.endCadence >= :paramStartCadence "
            + " and u.startCadence <= :paramEndCadence  "
            + " and cadenceType = :paramCadenceType ";

        Query query = getSession().createQuery(q);
        query.setDouble("paramStartCadence", startCadence);
        query.setDouble("paramEndCadence", endCadence);
        query.setParameter("paramCadenceType", cadenceType);

        List<B> list = list(query);
        return list;
    }

    /**
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param startCadence
     * @param endCadence inclusive
     * @return A list of instances that fall completely or partially within the
     * specified time else this returns a zero sized list.
     */
    public List<UncertaintyTransformationMetadata> retrieveUncertaintyTransformationMetadata(
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        CadenceType cadenceType) {
       
       return retrieveCalBlobByModOut(ccdModule, ccdOutput, startCadence,
                                      endCadence, cadenceType,
                                      UncertaintyTransformationMetadata.class);
    }

    
    public <B extends AbstractModOutCadenceBlob> 
        List<B> retrieveCalBlobByModOut(
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        CadenceType cadenceType, Class<B> blobMetadataClass) {
        
        checkCadence(startCadence, endCadence);
        checkModOut(ccdModule, ccdOutput);
        
        String q = "from " + blobMetadataClass.getSimpleName() + " u "
            + " where u.ccdModule = :paramCcdModule "
            + " and u.ccdOutput = :paramCcdOutput "
            + " and u.endCadence >= :paramStartCadence "
            + " and u.startCadence <= :paramEndCadence  "
            + " and cadenceType = :paramCadenceType ";

        Query query = getSession().createQuery(q);
        query.setInteger("paramCcdModule", ccdModule);
        query.setInteger("paramCcdOutput", ccdOutput);
        query.setDouble("paramStartCadence", startCadence);
        query.setDouble("paramEndCadence", endCadence);
        query.setParameter("paramCadenceType", cadenceType);

        return list(query);
    }
   
    public <B extends AbstractModOutCadenceBlob> void delete(B blobMetadata){
        getSession().delete(blobMetadata);
    }
    
    
    public void create(CalProcessingCharacteristics calPc) {
        getSession().saveOrUpdate(calPc);
    }
    
    public List<CalProcessingCharacteristics> retrieveProcessingCharacteristics(
        int ccdModule, int ccdOutput, int startCadence, int endCadence, CadenceType cadenceType) {
        
        checkCadence(startCadence, endCadence);
        checkModOut(ccdModule, ccdOutput);
        
        String queryStr =
            "from " + CalProcessingCharacteristics.class.getSimpleName() + " cpc" +
            " where cpc.ccdModule = :paramCcdModule and cpc.ccdOutput = :paramCcdOutput" +
            "    and cpc.startCadence >= :paramStartCadence and cpc.endCadence <= :paramEndCadence " +
            "    and cpc.cadenceType = :paramCadenceType " +
            " order by cpc.startCadence";
        Query q = getSession().createQuery(queryStr);
        q.setParameter("paramCcdModule", ccdModule);
        q.setParameter("paramCcdOutput", ccdOutput);
        q.setParameter("paramStartCadence", startCadence);
        q.setParameter("paramEndCadence", endCadence);
        q.setParameter("paramCadenceType", cadenceType);
        return list(q);
    }

    private static void checkCadence(int startCadence, int endCadence) {
        if (endCadence < startCadence) {
            throw new IllegalArgumentException("startCadence(" + startCadence +
                ") comes after endCadence(" + endCadence + ").");
        }
    }
    
    
    private static void checkModOut(int ccdModule, int ccdOutput) {
        if (Arrays.binarySearch(FcConstants.modulesList, ccdModule) < 0) {
            throw new IllegalArgumentException("Invalid ccdModule(" + ccdModule + ").");
        }
        if (Arrays.binarySearch(FcConstants.outputsList, ccdOutput) < 0) {
            throw new IllegalArgumentException("Invalid ccdOutput(" + ccdOutput + ").");
        }
    }
}
