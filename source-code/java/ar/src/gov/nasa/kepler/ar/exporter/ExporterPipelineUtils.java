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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ObservedKeplerIdUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Session;

/**
 * Some common utilities for pipeline modules that export files on a per target
 * basis.
 * 
 * @author Sean McCauliff
 * 
 */
public class ExporterPipelineUtils {

    private static final Log log = LogFactory.getLog(ExporterPipelineUtils.class);

    /**
     * 
     * @param uow
     * @param ttable
     * @param targetCrud
     * @param celestialObjectOperations
     * @return A sorted list of kepler ids for the sky group specified by the
     * unit of work or ones that do not have a skygroup.
     */
    public List<Integer> filteredListOfKeplerIdsForUow(
        ObservedKeplerIdUowTask uow, TargetTable ttable, TargetCrud targetCrud,
        CelestialObjectOperations celestialObjectOperations) {
        log.info("Get all the kepler ids for this unit of work.");
        List<Integer> allKeplerIds = targetCrud.retrieveObservedKeplerIds(ttable);
        int startIndex = 
            Collections.binarySearch(allKeplerIds, uow.getStartKeplerId());
        if (startIndex < 0) {
            throw new ModuleFatalProcessingException("Bad start keplerId.");
        }
        int endIndex = Collections.binarySearch(allKeplerIds,
            uow.getEndKeplerId());
        if (endIndex < 0) {
            if (uow.getEndKeplerId() == Integer.MAX_VALUE) {
                endIndex = allKeplerIds.size() - 1;
            } else {
                throw new ModuleFatalProcessingException("Bad end keplerId");
            }
        }
        if (endIndex < startIndex) {
            throw new ModuleFatalProcessingException(
                "Start keplerId comes after endKeplerId");
        }

        List<Integer> keplerIds = 
            new LinkedList<Integer>(allKeplerIds.subList(startIndex, endIndex + 1));
        Map<Integer, Integer> keplerIdToSkyGroupId = celestialObjectOperations.retrieveSkyGroupIdsForKeplerIds(keplerIds);
        Iterator<Integer> keplerIdIterator = keplerIds.iterator();
        while (keplerIdIterator.hasNext()) {
            Integer keplerId = keplerIdIterator.next();
            Integer skyGroupId = keplerIdToSkyGroupId.get(keplerId);
            //Just leave the nulls in for now.
            if (skyGroupId != null && skyGroupId.intValue() != uow.getSkyGroupId()) {
                keplerIdIterator.remove();
            }
        }
        return keplerIds;
    }

    /**
     * Checks that the output directory exists and if not it creates one.
     * 
     * @param outputDir The NFS output directory
     * @return
     * @throws ModuleFatalProcessingException
     */
    public File createOutputDirectory(File outputDir)
        throws ModuleFatalProcessingException {
        try {
            FileUtil.mkdirs(outputDir);
        } catch (IOException e) {
            throw new ModuleFatalProcessingException(
                "Failed to make NFS output directory.", e);
        }
        if (!outputDir.canWrite()) {
            String err = "Can't write to output directory \"" + outputDir
                + "\".";
            throw new ModuleFatalProcessingException(err);
        }
        return outputDir;
    }

    /**
     * Clamps the start and end cadence to the beginning, end of the target
     * table or the override parameters specified by the user.
     */
    public Pair<Integer, Integer> calculateStartEndCadences(int paramStart,
        int paramEnd, TargetTable ttable, LogCrud logCrud) {
        log.info("Getting actual start and end cadences for target table.");
        Pair<Integer, Integer> ttableCadences = logCrud.retrieveActualCadenceTimeForTargetTable(
            ttable.getExternalId(), ttable.getType());
        log.info("Target table cadences are " + ttableCadences + ".");

        int startCadence;
        if (paramStart < 0) {
            startCadence = ttableCadences.left;
        } else if (paramStart < ttableCadences.left) {
            throw new ModuleFatalProcessingException(
                "Overridden start cadence " + paramStart
                    + " comes before target table's start cadence "
                    + ttableCadences.left);
        } else {
            startCadence = paramStart;
        }

        int endCadence;
        if (paramEnd < 0) {
            endCadence = ttableCadences.right;
        } else if (paramEnd > ttableCadences.right) {
            throw new ModuleFatalProcessingException("Overridden end cadence "
                + paramEnd + " comes after the the target table's end cadence "
                + ttableCadences.right);
        } else {
            endCadence = paramEnd;
        }
        return Pair.of(startCadence, endCadence);
    }

    public TargetTable targetTableForTargetTableId(long dbId) {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        Session session = dbService.getSession();
        return (TargetTable) session.get(TargetTable.class, dbId);
    }
    
    public String defaultFileTimestamp(TimestampSeries timestampSeries) {
        FluxFileDateFormat formatter = new FluxFileDateFormat();
        return
            formatter.format(ModifiedJulianDate.mjdToDate(timestampSeries.endTimestamps[timestampSeries.endTimestamps.length - 1]));
    }
    
}
