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

package gov.nasa.kepler.mc.pmrf;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.SortedSet;

import com.google.common.collect.Sets;

/**
 * Represents a Pixel Mapping Reference File for collateral data and some 
 * useful transformation of that mapping.
 * 
 * @author Sean McCauliff
 * @author Miles Cote
 *
 */
public class CollateralPmrfTable implements PmrfTable {

    private final CadenceType cadenceType;
    private final int ccdModule;
    private final int ccdOutput;

    private final byte[] collateralPixelTypeColumn;
    private final short[] ccdRowOrColColumn;

    public enum Duplication {
        ALLOWED, NOT_ALLOWED;
    }
    
    CollateralPmrfTable(CadenceType cadenceType, int ccdModule,
        int ccdOutput, byte[] collateralPixelTypeColumn,
        short[] ccdRowOrColColumn, Duplication duplication) {
        
        if (collateralPixelTypeColumn.length != ccdRowOrColColumn.length) {
            throw new IllegalArgumentException("collateraPixelTypeColumn.length != ccdRowOrColumn.length");
        }
        
        if (duplication == Duplication.NOT_ALLOWED) {
           SortedSet<CollateralPixel> sortedPixels = Sets.newTreeSet();
           for (int i=0; i < collateralPixelTypeColumn.length; i++) {
               byte type = collateralPixelTypeColumn[i];
               short offset = ccdRowOrColColumn[i];
               sortedPixels.add(new CollateralPixel(type, offset));
           }
           
           if (collateralPixelTypeColumn.length != sortedPixels.size()) {
               collateralPixelTypeColumn = new byte[sortedPixels.size()];
               ccdRowOrColColumn = new short[sortedPixels.size()];
           }
           int destIndex = 0;
           for (CollateralPixel collateralPixel : sortedPixels) {
               collateralPixelTypeColumn[destIndex] = collateralPixel.type();
               ccdRowOrColColumn[destIndex] = collateralPixel.offset();
               destIndex++;
           }
        }
        
        this.cadenceType = cadenceType;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.collateralPixelTypeColumn = collateralPixelTypeColumn;
        this.ccdRowOrColColumn = ccdRowOrColColumn;
        
    }
    
    /**
     * This constructor allows duplicates in the original table to be reflected
     * in the return values of these methods.  This reflects the original, duplicated 
     * values stored in the pixel mapping reference file from the DMC.
     * 
     * @param cadenceType
     * @param ccdModule
     * @param ccdOutput
     * @param collateralPixelTypeColumn
     * @param ccdRowOrColColumn
     */
    CollateralPmrfTable(CadenceType cadenceType, int ccdModule,
        int ccdOutput, byte[] collateralPixelTypeColumn,
        short[] ccdRowOrColColumn) {
        
        this(cadenceType, ccdModule, ccdOutput, collateralPixelTypeColumn, ccdRowOrColColumn, Duplication.ALLOWED);
    }

    byte[] getCollateralPixelType() {
        return collateralPixelTypeColumn;
    }
    
    public short getCcdRowOrCol(int index) {
        return ccdRowOrColColumn[index];
    }

    public short[] getCcdRowOrColColumn() {
        return ccdRowOrColColumn;
    }

    public byte getCollateralPixelType(int index) {
        return collateralPixelTypeColumn[index];
    }

    public CadenceType getCadenceType() {
        return cadenceType;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public List<FsId> getPixelFsIds() {
        return getPixelFsIds(null);
    }

    /**
     * 
     * @param collateralType this may be null, in which case it means all types.
     * @return
     */
    public List<FsId> getPixelFsIds(CollateralType collateralType) {
        final List<FsId> fsIds = new ArrayList<FsId>(FcConstants.CCD_COLUMNS);
        find(collateralType, new CollateralPixelVisitor() {
            @Override
            public void visit(CollateralType collateralType,  short offset) {
                fsIds.add(DrFsIdFactory.getCollateralPixelTimeSeries(
                    TimeSeriesType.ORIG, cadenceType, collateralType, ccdModule,
                    ccdOutput, offset));
            }
        });

        return fsIds;
    }
    
    public List<FsId> getCalibratedPixelFsIds(CollateralType collateralType) {
        return getCalibratedFsIds(collateralType, CalFsIdFactory.PixelTimeSeriesType.SOC_CAL);
    }
    
    public List<FsId> getCalibratedUncertainityFsIds(CollateralType collateralType) {
        return getCalibratedFsIds(collateralType, CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES);
    }
    
    private List<FsId> getCalibratedFsIds(CollateralType collateralType,
        final CalFsIdFactory.PixelTimeSeriesType pixelTimeSeriesType) {
        
        final List<FsId> fsIds = new ArrayList<FsId>(FcConstants.CCD_COLUMNS);
        find(collateralType, new CollateralPixelVisitor() {
            @Override
            public void visit(CollateralType collateralType,  short offset) {
                FsId id = 
                    CalFsIdFactory.getCalibratedCollateralFsId(collateralType,
                        pixelTimeSeriesType,
                        cadenceType, ccdModule, ccdOutput, offset);
                fsIds.add(id);
            }
        });

        return fsIds;
    }
    
    /**
     * 
     * @param collateralType this may be null, in which case it means all types.
     * @return
     */
    public List<FsId> getCosmicRayFsIds(CollateralType collateralType) {
        final List<FsId> fsIds = new ArrayList<FsId>(collateralPixelTypeColumn.length);
        find(collateralType, new CollateralPixelVisitor() {
            @Override
            public void visit(CollateralType collateralType,  short offset) {
                fsIds.add(CalFsIdFactory.getCosmicRaySeriesFsId(collateralType,
                    cadenceType, ccdModule, ccdOutput, offset));
            }
        });

        return fsIds;
    }

    public List<Short> getPixelCoordinates(CollateralType collateralType) {
        final List<Short> coordinateList = new ArrayList<Short>();
        find(collateralType, new CollateralPixelVisitor() {
            @Override
            public void visit(CollateralType collateralType, short offset) {
                coordinateList.add(offset);
            }
        });
        return coordinateList;
    }
    
    /**
     * 
     * @param collateralType
     * @param pulseDurations Dynablack, rollingband, pulse durations.  non-null
     * @return Ids are by pixel and then by pulse duration so that all the pulse
     * durations for a pixel appear in a contiguous sequence.
     */
    public List<FsId> getRollingBandVariation(CollateralType collateralType, final int[] pulseDurations) {
        if (collateralType != CollateralType.BLACK_LEVEL || cadenceType == CadenceType.SHORT) {
            return Collections.emptyList();
        }
        final List<FsId> fsIds = new ArrayList<FsId>(collateralPixelTypeColumn.length);
        find(collateralType, new CollateralPixelVisitor() {
            @Override
            public void visit(CollateralType collateralType, short offset) {
                for (int pulseDuration : pulseDurations) {
                    fsIds.add(DynablackFsIdFactory.getRollingBandArtifactVariationFsId(ccdModule, ccdOutput, offset, pulseDuration));
                }
            }
        });
        return fsIds;
    }
    

    /**
     * 
     * @param collateralType
     * @param pulseDurations Dynablack, rollingband, pulse durations.  non-null
     * @return Ids are by pixel and then by pulse duration so that all the pulse
     * durations for a pixel appear in a contiguous sequence.
     */
    public List<FsId> getRollingBandFlags(CollateralType collateralType, final int[] pulseDurations) {
        if (collateralType != CollateralType.BLACK_LEVEL || cadenceType == CadenceType.SHORT) {
            return Collections.emptyList();
        }
        final List<FsId> fsIds = new ArrayList<FsId>(collateralPixelTypeColumn.length);
        find(collateralType, new CollateralPixelVisitor() {
            @Override
            public void visit(CollateralType collateralType, short offset) {
                for (int pulseDuration : pulseDurations) {
                    fsIds.add(DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(ccdModule, ccdOutput, offset, pulseDuration));
                }
            }
        });
        return fsIds;
    }
    
    private interface CollateralPixelVisitor {
        void visit(CollateralType collateralType, short offset);
    }
    
    /**
     * Encapsulate the finding logic.
     */
    private void find(CollateralType selectedType, CollateralPixelVisitor visitor) {
        for (int i = 0; i < collateralPixelTypeColumn.length; i++) {
            CollateralType currentType = CollateralType.valueOf(collateralPixelTypeColumn[i]);
            if (selectedType == null || selectedType.equals(currentType)) {
                visitor.visit(currentType, ccdRowOrColColumn[i]);
            }
        }
    }
    
    private static final class CollateralPixel implements Comparable<CollateralPixel> {
        private final byte type;
        private final short offset;
        
        public CollateralPixel(byte type, short offset) {;
            this.type = type;
            this.offset = offset;
        }
        
        public byte type() {
            return type;
        }
        
        public short offset() {
            return offset;
        }

        @Override
        public int compareTo(CollateralPixel o) {
            int diff = this.type - o.type;
            if (diff != 0) {
                return diff;
            }
            return this.offset - o.offset;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + offset;
            result = prime * result + type;
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            CollateralPixel other = (CollateralPixel) obj;
            if (offset != other.offset)
                return false;
            if (type != other.type)
                return false;
            return true;
        }

    }
    
    @Override
    public int length() {
       return ccdRowOrColColumn.length;
    }

    @Override
    public FsId getFsId(int rowIndex) {
       return DrFsIdFactory.getCollateralPixelTimeSeries(TimeSeriesType.ORIG,
           cadenceType,
           CollateralType.valueOf(collateralPixelTypeColumn[rowIndex]),
           ccdModule, ccdOutput, ccdRowOrColColumn[rowIndex]);
    }
    
}
