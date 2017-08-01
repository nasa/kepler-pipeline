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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.NotificationMessageHandler;
import gov.nasa.kepler.dr.pixels.ValidationOnlyPixelDispatcher;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class CadenceFitsValidator {

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("USAGE: validate-cadence-fits SOURCE_DIR");
            System.err.println("  example: validate-cadence-fits /path/to/smoke-test/dr/working/processing/p--2009-04-10--12.54.22--kplr2008052151540_sfnm.xml-SUCCESS/");
            System.exit(-1);
        }

        String sourceDir = args[0];

        NotificationMessageHandler handler = new NotificationMessageHandler();
        handler.setReceiveLog(new ReceiveLog(null, null, null));

        // Dispatcher dispatcher = new
        // LongCadenceTargetPmrfDispatcher(sourceDir,
        // handler);
        // dispatcher.addFileName("kplr2006264170000-300-300_lcm.fits");
        // dispatcher.dispatch();
        //
        // dispatcher = new LongCadenceCollateralPmrfDispatcher(sourceDir,
        // handler);
        // dispatcher.addFileName("kplr2006264170000-300-300_lcc.fits");
        // dispatcher.dispatch();
        //
        // dispatcher = new BackgroundPmrfDispatcher(sourceDir, handler);
        // dispatcher.addFileName("kplr2006264170000-300-300_bgm.fits");
        // dispatcher.dispatch();

        validate(DispatcherType.LONG_CADENCE_PIXEL, sourceDir, handler);

        validate(DispatcherType.SHORT_CADENCE_PIXEL, sourceDir, handler);

        System.exit(0);
    }

    private static void validate(DispatcherType dispatcherType,
        String sourceDir, NotificationMessageHandler handler) {

        String shortName = null;
        switch (dispatcherType) {
            case LONG_CADENCE_PIXEL:
                shortName = "lcs";
                break;
            case SHORT_CADENCE_PIXEL:
                shortName = "scs";
                break;
        }

        File srcDir = new File(sourceDir);
        if (!srcDir.isDirectory()) {
            throw new IllegalArgumentException(
                "sourceDir must be a directory.\n  soucreDir: " + sourceDir);
        }

        List<String> exceptions = new ArrayList<String>();
        for (File file : srcDir.listFiles()) {
            String fileName = file.getName();
            try {
                if (fileName.contains(shortName) && fileName.contains("fits")) {
                    DispatcherWrapper dispatcher = new DispatcherWrapper(
                        new ValidationOnlyPixelDispatcher(dispatcherType),
                        dispatcherType, sourceDir, handler);
                    dispatcher.addFileName(fileName);
                    dispatcher.dispatch();
                }
            } catch (Throwable e) {
                exceptions.add("An exception was thrown while validating a file.\n  file: "
                    + fileName + "  exception: " + e);
            }
        }

        if (!exceptions.isEmpty()) {
            throw new IllegalArgumentException(
                "Exceptions were thrown while validating files.\n  exceptions: "
                    + exceptions);
        }
    }

}
