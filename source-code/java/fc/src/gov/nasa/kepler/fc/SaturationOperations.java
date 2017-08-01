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

package gov.nasa.kepler.fc;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.Saturation;
import gov.nasa.kepler.hibernate.fc.SaturationColumn;

import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class SaturationOperations {
    private static HistoryModelName HISTORY_NAME = HistoryModelName.SATURATION;
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(UndershootOperations.class);

    @SuppressWarnings("unused")
    private DatabaseService dbService;
    private FcCrud fcCrud;
    private History history;

    public SaturationOperations() {
        this(DatabaseServiceFactory.getInstance());
    }

    public SaturationOperations(DatabaseService dbService) {
        this.dbService = dbService;
        fcCrud = new FcCrud(dbService);
        history = null;
    }
    
    public void create(Saturation saturation) {
        for (SaturationColumn saturationColumn : saturation.getSaturationCoordinates()) {
            fcCrud.create(saturationColumn);
        }
        fcCrud.create(saturation);

    }
    
    public SaturationModel retrieveSaturationModel(int season, int channel) {
        Saturation[] saturations = fcCrud.retrieveSaturations(channel, season);
        SaturationModel model = FcModelFactory.saturationModel(saturations);
        model.setSeason(season);
        model.setChannel(channel);
        return model;
    }
        
    public SaturationModel retrieveSaturationModel(double mjd, int channel) {
        int season = new RollTimeOperations().mjdToSeason(mjd); 
        return retrieveSaturationModel(season, channel);
    }

    public SaturationModel retrieveSaturationModel(int season, int ccdModule, int ccdOutput) {
        int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
        return retrieveSaturationModel(season, channel);
    }

    public SaturationModel retrieveSaturationModel(double mjd, int ccdModule, int ccdOutput) {
        int season = new RollTimeOperations().mjdToSeason(mjd);
        int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
        return retrieveSaturationModel(season, channel);
    }
    
    public History getHistory() {
        if (history == null) {
            history = fcCrud.retrieveHistory(HISTORY_NAME);
        }
        if (history == null) {
            Date now = new Date();
            double mjdNow = ModifiedJulianDate.dateToMjd(now);
            history = new History(
                mjdNow,
                HISTORY_NAME,
                "created by SaturationOperations because history table was empty",
                1);
            fcCrud.create(history);
        }
        return history;
    }
    
    public void setHistory(History history) {
        this.history = history;
    }
}
