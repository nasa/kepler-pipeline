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

package gov.nasa.kepler.soc;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.MeanBlackEntry;
import gov.nasa.kepler.hibernate.gar.RequantEntry;
import gov.nasa.kepler.hibernate.gar.RequantTable;

import java.util.Date;
import java.util.List;

/**
 * @author Miles Cote
 * 
 */
public class TestImportedRequantTables {

    public static final ImportedRequantTable createImportedRequantTable() {
        return new ImportedRequantTable(createRequantTable());
    }

    public static RequantTable createRequantTable() {
        RequantTable requantTable = new RequantTable();
        requantTable.setState(State.UPLINKED);
        requantTable.setExternalId(3);
        requantTable.setPlannedStartTime(new Date(4000));
        requantTable.setRequantEntries(createRequantEntries());
        requantTable.setMeanBlackEntries(createMeanBlackEntries());

        return requantTable;
    }

    public static List<RequantEntry> createRequantEntries() {
        List<RequantEntry> requantEntries = newArrayList();
        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH; i++) {
            requantEntries.add(createRequantEntry());
        }

        return requantEntries;
    }

    public static RequantEntry createRequantEntry() {
        return new RequantEntry(6);
    }

    public static List<MeanBlackEntry> createMeanBlackEntries() {
        List<MeanBlackEntry> meanBlackEntries = newArrayList();
        for (int i = 0; i < FcConstants.MEAN_BLACK_TABLE_LENGTH; i++) {
            meanBlackEntries.add(createMeanBlackEntry());
        }

        return meanBlackEntries;
    }

    public static MeanBlackEntry createMeanBlackEntry() {
        return new MeanBlackEntry(7);
    }

}
