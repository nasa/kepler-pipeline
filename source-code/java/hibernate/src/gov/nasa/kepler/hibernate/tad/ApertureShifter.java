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

import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.hibernate.Query;

/**
 * Shifts {@link Aperture}s by a given amount.
 * 
 * @author Miles Cote
 *
 */
public class ApertureShifter extends AbstractCrud {
    public void shift(String targetListSetName, int shiftAmount) {
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);

        List<ObservedTarget> observedTargets = retrieveObservedTargets(targetListSet.getTargetTable());
        for (ObservedTarget observedTarget : observedTargets) {
            Aperture aperture = observedTarget.getAperture();
            if (aperture != null) {
                aperture.setReferenceRow(aperture.getReferenceRow()
                    + shiftAmount);
                aperture.setReferenceColumn(aperture.getReferenceColumn()
                    + shiftAmount);
            }
        }
    }

    private List<ObservedTarget> retrieveObservedTargets(TargetTable targetTable) {
        Query query = getSession().createQuery(
            "from ObservedTarget t " + "left join fetch t.aperture a "
                + "left join fetch t.targetDefinitions td "
                + "left join fetch td.mask m " + "left join fetch m.maskTable "
                + "where " + "t.targetTable = :targetTable and "
                + "t.rejected = false " + "order by t.ccdModule asc "
                + "order by t.ccdOutput asc " + "order by t.id asc");
        query.setParameter("targetTable", targetTable);

        List<ObservedTarget> list = list(query);

        Set<Long> ids = new HashSet<Long>();
        List<ObservedTarget> returnList = new ArrayList<ObservedTarget>();
        for (ObservedTarget target : list) {
            long id = target.getId();
            if (!ids.contains(id)) {
                ids.add(id);
                returnList.add(target);
            }
        }

        return returnList;
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("USAGE: shift-apertures TARGET_LIST_SET_NAME SHIFT_AMOUNT");
            System.err.println("EXAMPLE: shift-apertures quarter12_winter2011_trimmed_v5_lc_paCoa_v2 1");
            System.exit(-1);
        }

        final String targetListSetName = args[0];
        final int shiftAmount = Integer.parseInt(args[1]);

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                ApertureShifter shifter = new ApertureShifter();
                shifter.shift(targetListSetName, shiftAmount);
            }
        });

        System.out.println("Complete.");
        System.exit(0);
    }
}
