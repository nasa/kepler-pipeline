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

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections.map.DefaultedMap;
import org.hibernate.Query;

import com.google.common.collect.ImmutableList;

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.collect.ListChunkIterator;

/**
 * WARNING: Do not use this class.
 * 
 * If a target table does not have a matching supplemental target table 
 * then we use the information from the original target table.
 * 
 * Else we have a supplemental target table then we do the following to 
 * construct a new UnifiedObservedTarget...
 *
 * 0. Construct a list of kepler ids that were observed in the unit of 
 * work.  This list is constructed from the original target table.  These 
 * are the target we are interested in for a unit of work.
 * 1. For each target in the original target table get the labels assigned 
 * to that target.
 * 2. From the supplemental observed targets get the following information 
 * for each target: optimal aperture, crowding metric, flux fraction in 
 * optimal aperture, pipelineTask (that generated the observed target 
 * information).
 * 3. Get the target definitions for each target from the original target 
 * table.  These are the pixels specified in the target table uploaded to 
 * the spacecraft.  These will exist regardless of a target having an 
 * optimal aperture or not.
 * 4. foreach target:  check if we found an entry in the supplement target 
 * table.  If the entry was missing in the supplemental tad run then use 
 * the flux fraction in optimal aperture and crowding metric from the 
 * original target table.  Set the optimal aperture to empty, that is no 
 * pixels in the optimal aperture.
 * 5. foreach target: compute the number of pixels in the optimal aperture 
 * in the supplemental tad run that were not captured in the target's 
 * target definition(s).  This value should be zero for target that do not 
 * have an optimal aperture.
 *
 * @author Sean McCauliff
 *
 */
public class UnifiedObservedTargetCrud extends AbstractCrud {
    
    private final static BigInteger INT_MAX_VALUE = BigInteger.valueOf(Integer.MAX_VALUE);
    private final TargetCrud targetCrud;
    private final Cyg16 cyg16 = new Cyg16();
    
    private enum WantAperture { YES, NO };
    
    public UnifiedObservedTargetCrud() {
        targetCrud = new TargetCrud();
    }
    /**
     * @param ttable An original, non-supplemental target table.
     * @param startKeplerId inclusive
     * @param endKeplerId inclusive
     * @return A non-null list of kepler ids in ascending order.
     */
    @SuppressWarnings("unchecked")
    public List<Integer> retrieveKeplerIds(TargetTable ttable, int ccdModule, int ccdOutput, int startKeplerId, int endKeplerId) {
        
        if (startKeplerId > endKeplerId) {
            throw new IllegalArgumentException("start kepler id comes before end kepler id");
        }
        
        Query keplerIdQuery = createQuery(
            "select ot.keplerId from ObservedTarget ot\n" +
            "where ot.keplerId >= :startKeplerIdParam and ot.keplerId <= :endKeplerIdParam \n" +
            " and ot.ccdModule = :ccdModuleParam and ot.ccdOutput = :ccdOutputParam \n" +
            " and ot.targetTable = :ttableParam \n" +
            " and ot.rejected = false\n" +
            "order by ot.keplerId"
            );
        keplerIdQuery.setInteger("startKeplerIdParam", startKeplerId);
        keplerIdQuery.setInteger("endKeplerIdParam", endKeplerId);
        keplerIdQuery.setInteger("ccdModuleParam", ccdModule);
        keplerIdQuery.setInteger("ccdOutputParam", ccdOutput);
        keplerIdQuery.setParameter("ttableParam", ttable);
        
        return keplerIdQuery.list();
    }
    
    /**
     * 
     * @param ttable An original, non-supplemental target table.
     * @param ccdModule
     * @param ccdOutput
     * @param keplerIds a non-null list of kepler ids.
     * @return An non-null map.  The key is a kepler id that maps to a unified
     * target table.
     */
    public Map<Integer, UnifiedObservedTarget> retrieveUnifiedObservedTargets(TargetTable ttable,
        int ccdModule, int ccdOutput, List<Integer> keplerIds) {
        
        ListChunkIterator<Integer> keplerIdIterator = 
            new ListChunkIterator<Integer>(keplerIds.iterator(), MAX_EXPRESSIONS);
        Map<Integer, UnifiedObservedTarget> rv = null;
        for (List<Integer> keplerIdChunk : keplerIdIterator) {
            Map<Integer, UnifiedObservedTarget> chunkResult =
                internalRetrieveUnifiedObservedTargets(ttable, ccdModule, ccdOutput, keplerIdChunk);
            if (rv == null) {
                rv = chunkResult;
            } else {
                rv.putAll(chunkResult);
            }
        }
        
        return rv;
    }
    
    @SuppressWarnings("unchecked")
    private Map<Integer, UnifiedObservedTarget> internalRetrieveUnifiedObservedTargets(TargetTable ttable,
        int ccdModule, int ccdOutput, List<Integer> keplerIds) {
      
        if (keplerIds.isEmpty()) {
            return Collections.EMPTY_MAP;
        }
        
        TargetTable suppTargetTable = targetCrud.retrieveSuppTargetTableForOrigTargetTable(ttable);
        
        if (suppTargetTable == null) {
            //Just return data from the observed objects.
            StringBuilder queryBuilder = new StringBuilder(
                "from ObservedTarget ot\n" +
                "where ot.targetTable = :ttableParam \n" +
                " and ot.ccdModule = :ccdModuleParam and ot.ccdOutput = :ccdOutputParam\n" +
                " and ot.rejected = false\n" +
                " and ot.aperture is not null and ot.keplerId in ");
            appendKeplerIds(queryBuilder, keplerIds);
            Query observedTargetQuery = createQuery(queryBuilder.toString());
            observedTargetQuery.setInteger("ccdModuleParam", ccdModule);
            observedTargetQuery.setInteger("ccdOutputParam", ccdOutput);
            observedTargetQuery.setParameter("ttableParam", ttable);
            
            List<ObservedTarget> srcObservedObjects = observedTargetQuery.list();
            Map<Integer, UnifiedObservedTarget> convertedRv = new HashMap<Integer, UnifiedObservedTarget>();
            for (ObservedTarget src : srcObservedObjects) {
                UnifiedObservedTarget u = 
                    new UnifiedObservedTarget(src.getKeplerId(),
                        src.getFluxFractionInAperture(),
                        src.getCrowdingMetric(),
                        ccdModule, 
                        ccdOutput,
                        ttable,
                        suppTargetTable,
                        src.getAperture(),
                        src.getLabels(),
                        false, 
                        src.getPipelineTask());
                u.setTargetDefinitions(src.getTargetDefinitions());
                u.setClippedPixelCount(0);
                convertedRv.put(u.getKeplerId(), u);
            }
            return convertedRv;
        }
        
        Query labelQuery = createTargetLabelQuery(keplerIds, ttable, ccdModule, ccdOutput);
        
        Map<Integer, Set<String>> keplerIdToLabels = collateLabels(labelQuery.list());
            
        
        Query observedTargetPartsQuery = createObservedTargetsPartsQuery(keplerIds, WantAperture.YES);
        observedTargetPartsQuery.setParameter("ttableParam", suppTargetTable);
        observedTargetPartsQuery.setParameter("ccdModuleParam", ccdModule);
        observedTargetPartsQuery.setParameter("ccdOutputParam", ccdOutput);

        Map<Integer, UnifiedObservedTarget> observedTargets = new HashMap<Integer, UnifiedObservedTarget>();
        List<Object[]> supplementalResults = 
            (List<Object[]>) observedTargetPartsQuery.list();
        
        for (Object[] parts : supplementalResults) {
            Aperture aperture = (Aperture) parts[4];
            getSession().evict(aperture); //detach this from the database
            
            int keplerId = (Integer) parts[0];
            
            long pipelineTaskId = (Long) parts[3];
            
            PipelineTask pipelineTask = (PipelineTask) getSession().load(PipelineTask.class,pipelineTaskId);
            UnifiedObservedTarget uTarget = 
                new UnifiedObservedTarget(
                    keplerId,
                    (Double) parts[1],
                    (Double) parts[2], 
                    ccdModule, ccdOutput, 
                    ttable,
                    suppTargetTable,
                    aperture,
                    keplerIdToLabels.get(keplerId),
                    false,
                    pipelineTask);
            observedTargets.put(uTarget.getKeplerId(), uTarget);
        }

        Query targetDefinitionsQuery = createTargetDefinitionsQuery(keplerIds);
        targetDefinitionsQuery.setInteger("ccdModuleParam", ccdModule);
        targetDefinitionsQuery.setInteger("ccdOutputParam", ccdOutput);
        //This uses the original target table target.
        targetDefinitionsQuery.setParameter("ttableParam", ttable);
        
        ClipReportFactory clipReportFactory = new ClipReportFactory();
        Map<Integer, Collection<TargetDefinition>> keplerIdToTargetDef =
            collateTargetDefs((List<TargetDefinition>) targetDefinitionsQuery.list());
        
        for (Map.Entry<Integer, Collection<TargetDefinition>> tDefsForTarget : keplerIdToTargetDef.entrySet()) {
            int keplerId = tDefsForTarget.getKey();
            UnifiedObservedTarget ot = observedTargets.get(keplerId);
            if (ot == null) { 
                //This target was dropped
                //This happens infrequently
                Query droppedTargetQuery = createObservedTargetsPartsQuery(ImmutableList.of(keplerId), WantAperture.NO);
                droppedTargetQuery.setInteger("ccdModuleParam", ccdModule);
                droppedTargetQuery.setInteger("ccdOutputParam", ccdOutput);
                droppedTargetQuery.setParameter("ttableParam", ttable);
                
                Object[] parts = (Object[]) droppedTargetQuery.uniqueResult();
                long pipelineTaskId = (Long) parts[3];
                PipelineTask pipelineTask = (PipelineTask) getSession().load(PipelineTask.class, pipelineTaskId);
                ot = new UnifiedObservedTarget(
                    keplerId,
                    (Double)parts[1], 
                    (Double)parts[2], 
                    ccdModule, 
                    ccdOutput, 
                    ttable,
                    suppTargetTable, 
                    new Aperture(), //optimal aperture is empty
                    keplerIdToLabels.get(keplerId),
                    true,
                    pipelineTask);
                observedTargets.put(keplerId, ot);
            }
            if (cyg16.is16Cyg(keplerId)) {
                ot.setTargetDefinitions(Collections.singleton(cyg16.targetDefinitionFor(keplerId)));
                ot.setClippedPixelCount(0);
            } else {
                ot.setTargetDefinitions(tDefsForTarget.getValue());
                ClipReport clipReport = clipReportFactory.create(tDefsForTarget.getValue(), ot.getAperture());
                ot.setClippedPixelCount(clipReport.getClippedOptApPixels());
            }
        }
        
        return observedTargets;
    }
    
    
    private Map<Integer, Collection<TargetDefinition>> collateTargetDefs(
        List<TargetDefinition> targetDefinitions) {

        Map<Integer, Collection<TargetDefinition>> rv = 
            new HashMap<Integer, Collection<TargetDefinition>>(); 

        for (TargetDefinition tdef : targetDefinitions) {
            getSession().evict(tdef);
            int keplerId = tdef.getKeplerId();
            Collection<TargetDefinition> tdefs = rv.get(keplerId);
            if (tdefs == null) {
                tdefs = new HashSet<TargetDefinition>();
                rv.put(keplerId, tdefs);
            }
            tdefs.add(tdef);
        }
        return rv;
    }
    
    @SuppressWarnings("unchecked")
    private Map<Integer, Set<String>> collateLabels(List<Object[]> entries) {
        Map<Integer, Set<String>> rv =  new HashMap<Integer, Set<String>>(); 
        
        
        for (Object[] entry : entries) {
            int keplerId = -1;
            String label = (String) entry[1];
            if (entry[0] instanceof BigDecimal) {
                BigInteger keplerIdAsBigInt = ((BigDecimal) entry[0]).toBigIntegerExact();
                if (keplerIdAsBigInt.compareTo(INT_MAX_VALUE) > 0) {
                    throw new IllegalStateException("Bad kepler id " +
                        keplerIdAsBigInt + " for labels: \"" + label + "\".");
                }
                keplerId = (int) keplerIdAsBigInt.longValue();
            } else {
                keplerId = (Integer) entry[0];
            }
            
            Set<String> labelSet = (Set<String>) rv.get(keplerId);
            if (labelSet == null) {
                labelSet = new HashSet<String>();
                rv.put(keplerId, labelSet);
            }
            
            labelSet.add(label);
        }
        
        return DefaultedMap.decorate(rv, Collections.EMPTY_SET);
    }

    private Query createTargetDefinitionsQuery(List<Integer> keplerIds) {
        StringBuilder queryBuilder = new StringBuilder(
            "select ot.targetDefinitions from ObservedTarget ot\n" +
            "where ot.targetTable = :ttableParam and\n" + 
            " ot.ccdModule = :ccdModuleParam and ot.ccdOutput = :ccdOutputParam and\n" +
            " ot.keplerId in "
            );
        appendKeplerIds(queryBuilder, keplerIds).append("\n order by ot.keplerId");
        
        return createQuery(queryBuilder.toString());
    }
    
    private Query createTargetLabelQuery(List<Integer> keplerIds, TargetTable ttable, int ccdModule, int ccdOutput) {
        StringBuilder queryBuilder = new StringBuilder(
            "select ot.kepler_id, labels.element \n" +
            " from tad_observed_target ot \n" + 
            " inner join tad_observed_target_labels labels on ot.id = labels.tad_observed_target_id\n" + 
            " where ot.tad_target_table_id = " + ttable.getId() + " and \n" +
            " ot.ccd_module = " + ccdModule + " and \n" +
            " ot.ccd_output = " + ccdOutput + " and\n" +
            " ot.kepler_id in ");
        appendKeplerIds(queryBuilder, keplerIds);
        
        Query q = getSession().createSQLQuery(queryBuilder.toString());
        //System.out.println(q);
        return q;
    }
    
    private Query createObservedTargetsPartsQuery(List<Integer> keplerIds, WantAperture wantAperture) {
        StringBuilder queryBuilder = new StringBuilder(
            "select ot.keplerId, ot.fluxFractionInAperture, ot.crowdingMetric, ot.pipelineTask.id \n" +
            " from ObservedTarget ot\n" + 
            " where ot.targetTable = :ttableParam and\n" + 
            "  ot.ccdModule = :ccdModuleParam and ot.ccdOutput = :ccdOutputParam and\n" +
            "  ot.rejected = false and\n" +
            "  ot.keplerId in "
            );

         appendKeplerIds(queryBuilder, keplerIds);
         
         if (wantAperture == WantAperture.YES) {
             int insertIndex = queryBuilder.indexOf("from");
             queryBuilder.insert(insertIndex, ", ot.aperture ");
             queryBuilder.append("\n and ot.aperture is not null");
         }
         //System.out.println(suppQueryBldr);
         
         return createQuery(queryBuilder.toString());
    }
    
    private static StringBuilder appendKeplerIds(StringBuilder queryBuilder, List<Integer> keplerIds) {
        queryBuilder.append(" (");
        for (int keplerId : keplerIds) {
            queryBuilder.append(keplerId).append(',');
        }
        queryBuilder.setCharAt(queryBuilder.length() - 1, ')');
        return queryBuilder;
    }
    

}
