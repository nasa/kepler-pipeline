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

package gov.nasa.kepler.ar.cli;

import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.dv.DvResultsExporter;
import gov.nasa.kepler.common.StreamingIterator;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription;
import gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.io.IOException;
import java.util.*;

import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.SessionFactory;
import org.hibernate.persister.collection.AbstractCollectionPersister;
import org.hibernate.persister.entity.EntityPersister;

import static gov.nasa.kepler.common.GarbageCollectionUtils.free;


/**
 * Export data validation results.
 * 
 * @author Sean McCauliff
 *
 */
public class DvResultsExportCli {

    private static final Log log = LogFactory.getLog(DvResultsExportCli.class);
    
    SystemProvider system;
    private final DvExportCommandLineParser parser;
    
    public DvResultsExportCli(SystemProvider systemProvider) {
        system = systemProvider;
        parser = new DvExportCommandLineParser(system);
    }
    
    void parse(String[] argv) throws IOException, ParseException {
        parser.parse(argv, getClass());
    }
    
    /**
     * Also clears the second level hibernate cache.
     */

    private void clearHibernateCache() {
        DatabaseServiceFactory.getInstance().clear();
        SessionFactory sf = 
            DatabaseServiceFactory.getInstance().getSession().getSessionFactory();
     
        @SuppressWarnings("unchecked")
        Map<String, EntityPersister> classMetadata = sf.getAllClassMetadata();
        for (EntityPersister ep : classMetadata.values()) {
            if (ep.hasCache()) {
                sf.evictEntity(ep.getCache().getRegionName());
            }
        }
     
        @SuppressWarnings("unchecked")
        Map<?, AbstractCollectionPersister> collMetadata = sf.getAllCollectionMetadata();
        for (AbstractCollectionPersister acp : collMetadata.values()) {
            if (acp.hasCache()) {
                sf.evictCollection(acp.getCache().getRegionName());
            }
        }
    }
    
    private final class TargetIterator extends
            StreamingIterator<DvTargetResults> {
        final Iterator<List<Integer>> chunkIterator;

        TargetIterator(Collection<Integer> keplerIds) {
            chunkIterator = new ListChunkIterator<Integer>(keplerIds, 1000);
        }

        @Override
        protected Iterator<DvTargetResults> nextChunk() {
            clearHibernateCache();
            if (chunkIterator.hasNext()) {
                return dvCrud().retrieveTargetResultsByPipelineInstanceId(
                        parser.pipelineInstanceId(), chunkIterator.next())
                        .iterator();
            }
            return null;
        }
    }
    
    private final class PlanetIterator extends StreamingIterator<DvPlanetResults> {
        final Iterator<List<Integer>> chunkIterator;
        
        PlanetIterator(Collection<Integer> keplerIds) {
            chunkIterator =  new ListChunkIterator<Integer>(keplerIds, 512);
        }
        
        @Override
        protected Iterator<DvPlanetResults> nextChunk() {
            clearHibernateCache();
            if (chunkIterator.hasNext()) {
                return dvCrud().retrievePlanetResultsByPipelineInstanceId(
                    parser.pipelineInstanceId(), chunkIterator.next()).iterator();
            }
            return null;
        }
    }
    
    void export() throws Exception {
        DvResultsExporter exporter = new DvResultsExporter();
        
        log.warn("--------> Do not export over NFS. <------------");
        log.warn("--------> you may experience severe performance problems. <---");
        
        final List<Integer> keplerIds = parser.keplerIds();
        
        StreamingIterator<DvTargetResults> targetResultsIt = new TargetIterator(keplerIds);
        StreamingIterator<DvPlanetResults> planetIt = new PlanetIterator(keplerIds); 

        List<DvLimbDarkeningModel> models = dvCrud().retrieveLimbDarkeningModelsByPipelineInstanceId(parser.pipelineInstanceId());

        List<DvExternalTceModelDescription> externalTceModelDescriptions = dvCrud().retrieveExternalTceModelDescription(
            parser.pipelineInstanceId());
        List<DvTransitModelDescriptions> transitModelDescriptions = dvCrud().retrieveTransitModelDescriptions(
            parser.pipelineInstanceId());
        
        log.info("Found " + keplerIds.size() + " catalog ids.");
        if (keplerIds.isEmpty()) {
            log.warn("Exiting without producing a file.");
            return;
        }
        
        DvExternalTceModelDescription xModelDescription = 
        		externalTceModelDescriptions == null  || externalTceModelDescriptions.isEmpty() ? 
        				null : externalTceModelDescriptions.get(0);
        DvTransitModelDescriptions modelDescriptions = 
        		transitModelDescriptions == null || transitModelDescriptions.isEmpty() ?
        				null : transitModelDescriptions.get(0);
        
        exporter.export(
            free(targetResultsIt, targetResultsIt = null),
            free(planetIt, planetIt = null),
            free(models, models = null),
            xModelDescription,
            modelDescriptions,
            new Date(0), 
            parser.outputDir());
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String actualName = 
            fnameFormatter.dataValidationName(exporter.maxPlanetPipeineTaskDate());
        File outputFile = exporter.outputFile();
        File destinationFile = new File(outputFile.getParentFile(), actualName);
        outputFile.renameTo(destinationFile);
        log.info("Renamed output file \"" + outputFile + "\" to " 
            + destinationFile + "\".");
    }
    
    protected DvCrud dvCrud() {
        return new DvCrud();
    }
    
    public static void main(String[] argv) throws Exception {
        DvResultsExportCli cli = new DvResultsExportCli(new DefaultSystemProvider());
        cli.parse(argv);
        cli.export();
    }
    
}
