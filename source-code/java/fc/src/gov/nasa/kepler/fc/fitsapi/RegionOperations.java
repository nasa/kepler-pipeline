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

package gov.nasa.kepler.fc.fitsapi;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Collection;
import java.util.List;

public class RegionOperations {
    private DatabaseService dbService;
    private FcCrud fcCrud = null;
    
    public  static String REGION_FILENAME = "./.ffiOverviewRegion.reg";
    
    public RegionOperations(DatabaseService dbService) {
        this.dbService = dbService;
//        System.setProperty(ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP, 
//                                                       "etc/kepler.properties");
    }
    
    public void writeInvalidPixelRegionFile(PixelType type, double start, double stop) {
        try {
            String region = getRegionTypeString(type, start, stop);
            BufferedWriter buf = new BufferedWriter(new FileWriter(REGION_FILENAME));
            buf.write(region);
            buf.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    
    
 
    /**
     *  Write the DS9 region file for the apertures in the given input cadence
     *   
     * @param type
     * @param cadence
     * @throws PipelineException
     */
    public void writeApertureRegionFile(String type, int cadence) {
        
        String apertureRegion = "";
        try {
            TargetCrud targetCrud = new TargetCrud(dbService);
            
            List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(TargetType.LONG_CADENCE, cadence, cadence);
            
            for (TargetTableLog ttl : targetTableLogs) {
                int FAKE_MODULE = 13;
                int FAKE_OUTPUT =  4;
                
                Collection<ObservedTarget> targets = targetCrud.retrieveObservedTargets(ttl.getTargetTable(), FAKE_MODULE, FAKE_OUTPUT);
                for (ObservedTarget target : targets) {
                    apertureRegion += getApertureRegion(target);
                }
            }
        
            BufferedWriter buf = new BufferedWriter(new FileWriter(REGION_FILENAME));
            buf.write(apertureRegion);
            buf.close();
            
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }

    }
    
    /**
     * Generate the Region line for the aperture defined by the input Target.
     * @param target
     * @return
     */
    public String getApertureRegion(ObservedTarget target) {
        String apertureRegion ="";
        Collection<TargetDefinition> targetDefs = target.getTargetDefinitions();

        for (TargetDefinition td : targetDefs) {
            int row = td.getReferenceRow();
            int col = td.getReferenceColumn();
            Collection<Offset> apPixels = td.getMask().getOffsets();

            for (Offset apPix : apPixels) {
                apertureRegion = "" +row + " " + col + " " + apPix.getRow() + " " + apPix.getColumn();
            }
            
        }        
        return apertureRegion;
    }
    
    
    /**
     * Generate a DS9 region string for the pixels in the invalid pixel table
     * that match the type of the input pixel and are between the start and stop
     * dates of the input pixel.
     * 
     * @param searchPixel
     * @return
     * @throws PipelineException 
     */
    public String getRegionTypeString(Pixel searchPixel) {
        fcCrud = new FcCrud(dbService);
        Pixel[] pixels = fcCrud.retrieveTypeBetween(searchPixel);
        
        String region = "#composite(0,0,0)" + 
                        " || tag={testCompositeRegion}" +
                        " edit=0 move=0" + 
//                        " color=" + Pixel.PixelType2Color.get(searchPixel.getType()) +
                        "\n";
        
        for (int ii = 0; ii < pixels.length-1; ++ii) {
            region += pixels[ii].regionCompositeString("X", "FcCrud Group", false) +"\n";
        }
        region += pixels[pixels.length-1].regionCompositeString("X", "FcCrud.Group", true) + "\n";
        return region;
    }

    /**
     * Generate a region string for an array of pixels.  See {@link FcgetRegionTypeString}.
     * @param searchPixels
     * @return
     * @throws PipelineException 
     */
    public String getRegionTypeStrings(Pixel[] searchPixels) {
        String region = "";
        for (Pixel pix : searchPixels) {
            region += getRegionTypeString(pix);
        }
        return region;
    }
    
    /**
     * Generate a region string for a pixel.  See {@link getRegionTypeString}.
     * 
     * @param type
     * @param start
     * @param stop
     * @return
     * @throws PipelineException 
     */
    public String getRegionTypeString(PixelType type, double start, double stop) {
        return getRegionTypeString(new Pixel(13,4,512,512, type, start, stop));
    }
    
}
