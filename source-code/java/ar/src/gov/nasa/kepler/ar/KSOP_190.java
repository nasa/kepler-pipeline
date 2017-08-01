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

package gov.nasa.kepler.ar;

import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;

/**
 * This fixes the planned target tables times and the associated target list set
 * planned times.
 * 
 * @author Sean McCauliff
 *
 */
public class KSOP_190 {

    private static final Log log = LogFactory.getLog(KSOP_190.class);
    /**
     * @param args
     */

    public static void main(String[] argv) throws Exception {
        final int targetTableExternalId = Integer.parseInt(argv[0]);
        
        Date newStart = Iso8601Formatter.dateTimeFormatter().parse(argv[1]);
        Date newEnd = Iso8601Formatter.dateTimeFormatter().parse(argv[2]);
        final boolean dryRun = (argv.length == 3) ? true : false;
        if (argv.length > 3 && !argv[3].equals("enabled")) {
            throw new IllegalArgumentException("bad command line parameter " + argv[3]);
        }
        
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        dbService.beginTransaction();
        Query query  =
            dbService.getSession().createQuery("from TargetTable ttable where ttable.state = :stateParam and ttable.externalId = :externalIdParam");
        query.setParameter("stateParam", ExportTable.State.UPLINKED);
        query.setInteger("externalIdParam", targetTableExternalId);
        
        @SuppressWarnings("unchecked")
        List<TargetTable> targetTables = query.list();
        log.info("Found " + targetTables.size() + " needing update.");
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

        for (TargetTable ttable : targetTables) {
            log.info("Setting planned start/end times on target table " + ttable);
            ttable.setPlannedStartTime(newStart);
            ttable.setPlannedEndTime(newEnd);
            
            TargetListSet tlSet = 
                targetSelectionCrud.retrieveTargetListSetByTargetTable(ttable);
            if (tlSet == null) {
                continue;
            }
            
            log.info("Setting start/end times on target list set " + tlSet);
            ExportTable.State origState = tlSet.getState();
            tlSet.setState(ExportTable.State.UNLOCKED);
            tlSet.setStart(newStart);
            tlSet.setEnd(newEnd);
            tlSet.setState(origState);
        }
        
        if (dryRun) {
            dbService.rollbackTransactionIfActive();
            log.info("Transaction rolled back.");
        } else {
            dbService.flush();
            dbService.commitTransaction();
            log.info("Changes committed.");
        }
    }

}
