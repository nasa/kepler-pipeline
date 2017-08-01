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

package gov.nasa.kepler.systest.sbt.data;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.MjdFsIdSet;

import java.util.List;

/**
 * This class contains a group of {@link FsId}s.
 * 
 * @author Miles Cote
 * 
 */
public class SbtFsIdGroup {

    private List<FsIdSet> fsIds;
    private List<MjdFsIdSet> mjdFsIds;

    private SbtAttitudeSolution sbtAttitudeSolution;
    private List<SbtSimpleTimeSeries> pagTimeSeriesList;
    private List<SbtTargetTable> sbtTargetTables;
    private List<SbtTarget> sbtTargets;

    public SbtFsIdGroup(List<FsIdSet> fsIds, List<MjdFsIdSet> mjdFsIds,
        SbtAttitudeSolution sbtAttitudeSolution,
        List<SbtSimpleTimeSeries> pagTimeSeriesList,
        List<SbtTargetTable> sbtTargetTables, List<SbtTarget> sbtTargets) {
        this.fsIds = fsIds;
        this.mjdFsIds = mjdFsIds;
        this.sbtAttitudeSolution = sbtAttitudeSolution;
        this.pagTimeSeriesList = pagTimeSeriesList;
        this.sbtTargetTables = sbtTargetTables;
        this.sbtTargets = sbtTargets;
    }

    public List<FsIdSet> getFsIds() {
        return fsIds;
    }

    public List<MjdFsIdSet> getMjdFsIds() {
        return mjdFsIds;
    }

    public SbtAttitudeSolution getSbtAttitudeSolution() {
        return sbtAttitudeSolution;
    }

    public List<SbtSimpleTimeSeries> getPagTimeSeriesList() {
        return pagTimeSeriesList;
    }

    public List<SbtTargetTable> getSbtTargetTables() {
        return sbtTargetTables;
    }

    public List<SbtTarget> getSbtTargets() {
        return sbtTargets;
    }

}
