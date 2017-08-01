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

package gov.nasa.kepler.hibernate.fc;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.AbstractCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;

public class FcCrud extends AbstractCrud {
    //private static final Log log = LogFactory.getLog(FcCrud.class);

    /**
     * Creates a new {@link FcCrud} object.
     */
    public FcCrud() {
    }

    public FcCrud(DatabaseService databaseService) {
        super(databaseService);
    }

    /**
     * @param gainHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(GainHistoryModel gainHistoryModel) {
        getSession().save(gainHistoryModel);
    }

    /**
     * @param prfHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(PrfHistoryModel prfHistoryModel) {
        getSession().save(prfHistoryModel);
    }

    /**
     * @param pixelHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(PixelHistoryModel pixelHistoryModel) {
        getSession().save(pixelHistoryModel);
    }

    /**
     * @param twoDBlackImageHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(TwoDBlackImageHistoryModel twoDBlackImageHistoryModel) {
        getSession().save(twoDBlackImageHistoryModel);
    }

    /**
     * @param smallFlatFieldImageHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(
            SmallFlatFieldImageHistoryModel smallFlatFieldImageHistoryModel) {
        getSession().save(smallFlatFieldImageHistoryModel);
    }

    /**
     * @param readNoiseHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(ReadNoiseHistoryModel readNoiseHistoryModel) {
        getSession().save(readNoiseHistoryModel);
    }

    /**
     * @param largeFlatFieldHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(LargeFlatFieldHistoryModel largeFlatFieldHistoryModel) {
        getSession().save(largeFlatFieldHistoryModel);
    }

    /**
     * @param pointingHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(PointingHistoryModel pointingHistoryModel) {
        getSession().save(pointingHistoryModel);
    }

    /**
     * @param largeFlatFieldHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(RollTimeHistoryModel rollTimeHistoryModel) {
        getSession().save(rollTimeHistoryModel);
    }

    /**
     * @param linearityHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(LinearityHistoryModel linearityHistoryModel) {
        getSession().save(linearityHistoryModel);
    }

    /**
     * @geometryHistoryModelyModel the object to store
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(GeometryHistoryModel geometryHistoryModel) {
        getSession().save(geometryHistoryModel);
    }

    /**
     * @undershootHistoryModelyModel the object to store
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(UndershootHistoryModel undershootHistoryModel) {
        getSession().save(undershootHistoryModel);
    }
    
    /**
     * @param saturationHistoryModel
     *            the object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(SaturationHistoryModel saturationHistoryModel) {
        getSession().save(saturationHistoryModel);
    }


    /**
     * Store a new ReadNoise or update an existing one.
     * 
     * @param readNoise
     *            the ReadNoise object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(ReadNoise readNoise) {
        getSession().save(readNoise);
    }

    /**
     * 
     * @param tds
     */
    public void create(Tds tds) {
        getSession().save(tds);
    }

    /**
     * Store a new Geometry or update an existing one.
     * 
     * @param gm
     *            the Geometry object to store.
     * @return a persisted version of the CharacteristicType object.
     * @throws PipelineException
     */
    public void create(Geometry gm) {
        getSession().save(gm);
    }

    public void create(LargeFlatField lff) {
        getSession().save(lff);
    }

    public void create(Linearity lt) {
        getSession().save(lt);
    }

    public void create(Obscuration obscuration) {
        getSession().save(obscuration);
    }

    public void create(Pixel pixel) {
        getSession().save(pixel);
    }

    public void create(Pointing pointing) {
        getSession().save(pointing);
    }

    public void create(RollTime rollTime) {
        getSession().save(rollTime);
    }

    public void create(Psf psf) {
        getSession().save(psf);
    }

    public void create(ScatteredLight sl) {
        getSession().save(sl);
    }

    public void create(SmallFlatFieldImage sffi) {
        getSession().save(sffi);
    }

    public void create(TwoDBlackImage tdbi) {
        getSession().save(tdbi);
    }

    public void create(Undershoot undershoot) {
        getSession().save(undershoot);
    }

    public void create(Vignetting vignetting) {
        getSession().save(vignetting);
    }

    public void create(ZodiacalLight zodi) {
        getSession().save(zodi);
    }

    public void create(Prf prf) {
        getSession().save(prf);
    }

    public void create(Gain gain) {
        getSession().save(gain);
    }

    public void create(Saturation saturation) {
        getSession().save(saturation);
    }

    public void create(SaturationColumn saturationColumn) {
        getSession().save(saturationColumn);
    }
    
    public void create(History history) {
        getSession().save(history);
    }

    public Gain retrieve(Gain gain, History history) {
        Query q = getSession()
                .createQuery(
                        "from Gain g where g.ccdModule = :module and g.ccdOutput = :output "
                                + "and g.mjd <= :time and g.history = :history order by g.mjd DESC");

        q.setParameter("module", gain.getCcdModule());
        q.setParameter("output", gain.getCcdOutput());
        q.setParameter("time", gain.getMjd());
        q.setEntity("history", history);

        q.setMaxResults(1);

        Gain out = uniqueResult(q);
        return out;
    }

    public Gain retrieveGainExact(Gain gain, History history) {
        Query q = getSession().createQuery(
                "from Gain g where g.ccdModule = :module and g.ccdOutput = :output "
                        + "and g.mjd = :time and g.history = :history");

        q.setParameter("module", gain.getCcdModule());
        q.setParameter("output", gain.getCcdOutput());
        q.setParameter("time", gain.getMjd());
        q.setEntity("history", history);

        q.setMaxResults(1);

        Gain out = uniqueResult(q);
        return out;
    }

    public ReadNoise retrieve(ReadNoise readNoise, History history) {
        Query q = getSession()
                .createQuery(
                        "from ReadNoise g where g.ccdModule = :module and g.ccdOutput = :output "
                                + "and g.mjd <= :time and g.history = :history order by g.mjd DESC");

        q.setParameter("module", readNoise.getCcdModule());
        q.setParameter("output", readNoise.getCcdOutput());
        q.setParameter("time", readNoise.getMjd());
        q.setEntity("history", history);

        q.setMaxResults(1);

        ReadNoise out = uniqueResult(q);
        if (null == out) {
            throw new PipelineException(
                    "no readNoise in database that meet criteria");
        }
        return out;
    }

    public ReadNoise retrieveMostRecentReadNoise(History history, int module,
            int output) {
        List<ReadNoiseHistoryModel> historyModels = retrieveReadNoiseHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }
        
        ReadNoise mostRecentReadNoise = historyModels.get(0).getReadNoise();
        for (ReadNoiseHistoryModel historyModel : historyModels) {
            ReadNoise readNoise = historyModel.getReadNoise();
            boolean isRightOutput = readNoise.getCcdModule() == module
                    && readNoise.getCcdOutput() == output;
            if (isRightOutput
                    && readNoise.getMjd() > mostRecentReadNoise.getMjd()) {
                mostRecentReadNoise = readNoise;
            }
        }

        return mostRecentReadNoise;
    }

    public Pixel retrieveMostRecentPixel(History history, int module, int output) {
        List<PixelHistoryModel> historyModels = retrievePixelHistoryModels(history);
        Collections.sort(historyModels);
        
        if (historyModels.size() == 0) { 
            return null;
        }

        Pixel mostRecentPixel = historyModels.get(0).getPixel();
        for (PixelHistoryModel historyModel : historyModels) {
            Pixel pixel = historyModel.getPixel();
            boolean isRightOutput = pixel.getCcdModule() == module
                    && pixel.getCcdOutput() == output;
            if (isRightOutput
                    && pixel.getStartTime() > mostRecentPixel.getStartTime()) {
                mostRecentPixel = pixel;
            }
        }

        return mostRecentPixel;
    }

    public PrfHistoryModel retrieveMostRecentPrfHistoryModel(History history, int module, int output) {
        Query queryTime = getSession().createQuery(
                "select max(mjd) from PrfHistoryModel hm where " + 
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        queryTime.setParameter("ccdModule", module);
        queryTime.setParameter("ccdOutput", output);
        queryTime.setEntity("history", history);
        queryTime.setMaxResults(1);
        Double mjd = uniqueResult(queryTime);
        
        if (mjd == null) {
            return null;
        }
        
        Query query = getSession().createQuery(
                "from PrfHistoryModel hm where " + 
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput and " +
                "hm.mjd = :mjd");
        query.setParameter("ccdModule", module);
        query.setParameter("ccdOutput", output);
        query.setParameter("mjd", mjd);
        query.setEntity("history", history);

        query.setMaxResults(1);
        PrfHistoryModel prfHistoryModel = uniqueResult(query);
        return prfHistoryModel;        
    }
    
    public Prf retrieveMostRecentPrf(History history, double mjd, int module, int output) {
        PrfHistoryModel prfHistoryModel = retrieveMostRecentPrfHistoryModel(history, module, output);
        if (prfHistoryModel == null) {
            return null;
        }
        return prfHistoryModel.getPrf();
    }

    public Undershoot retrieveMostRecentUndershoot(History history, int module,
            int output) {
        List<UndershootHistoryModel> historyModels = retrieveUndershootHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }

        Undershoot mostRecentUndershoot = historyModels.get(0).getUndershoot();
        for (UndershootHistoryModel historyModel : historyModels) {
            Undershoot undershoot = historyModel.getUndershoot();
            boolean isRightOutput = undershoot.getCcdModule() == module
                    && undershoot.getCcdOutput() == output;
            if (isRightOutput
                    && undershoot.getStartMjd() > mostRecentUndershoot
                            .getStartMjd()) {
                mostRecentUndershoot = undershoot;
            }
        }

        return mostRecentUndershoot;
    }

    public SmallFlatFieldImage retrieveMostRecentSmallFlatFieldImage(History history, int ccdModule, int ccdOutput) {
        SmallFlatFieldImageHistoryModel hm = retrieveMostRecentSmallFlatFieldImageHistoryModel(history, ccdModule, ccdOutput);
        return hm.getSmallFlatFieldImage();
    }
    
    public SmallFlatFieldImageHistoryModel retrieveMostRecentSmallFlatFieldImageHistoryModel(
            History history, int module, int output) {
        
        Query queryTime = getSession().createQuery(
                "select max(mjd) from SmallFlatFieldImageHistoryModel hm where " +
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        queryTime.setParameter("ccdModule", module);
        queryTime.setParameter("ccdOutput", output);
        queryTime.setEntity("history", history);
        queryTime.setCacheable(false);
        queryTime.setReadOnly(true);
        
        queryTime.setMaxResults(1);
        Double mjd = uniqueResult(queryTime);
        if (mjd == null) {
            return null;
        }
        
        Query query = getSession().createQuery(
                "from SmallFlatFieldImageHistoryModel hm where " +
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput and " +
                "hm.mjd = :mjd");
        query.setParameter("ccdModule", module);
        query.setParameter("ccdOutput", output);
        query.setParameter("mjd", mjd);
        query.setCacheable(false);
        query.setReadOnly(true);
        query.setEntity("history", history);
        query.setMaxResults(1);
        SmallFlatFieldImageHistoryModel historyModel = uniqueResult(query);
        
        return historyModel;
    }

    public Gain retrieveMostRecentGain(History history, int module, int output) {
        List<GainHistoryModel> historyModels = retrieveGainHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }

        Gain mostRecentGain = historyModels.get(0).getGain();
        for (GainHistoryModel historyModel : historyModels) {
            Gain gain = historyModel.getGain();
            boolean isRightOutput = gain.getCcdModule() == module
                    && gain.getCcdOutput() == output;
            if (isRightOutput && gain.getMjd() > mostRecentGain.getMjd()) {
                mostRecentGain = gain;
            }
        }

        return mostRecentGain;
    }

    public TwoDBlackImageHistoryModel retrieveMostRecentTwoDBlackImageHistoryModel(History history,
            int module, int output) {
        
        Query queryTime = getSession().createQuery(
                "select max(mjd) from TwoDBlackImageHistoryModel hm where " +
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        queryTime.setParameter("ccdModule", module);
        queryTime.setParameter("ccdOutput", output);
        queryTime.setEntity("history", history);
        queryTime.setMaxResults(1);
        queryTime.setCacheable(false);
        queryTime.setReadOnly(true);
        Double mjd = uniqueResult(queryTime);
        
        Query query = getSession().createQuery(
                "from TwoDBlackImageHistoryModel hm where " +
                "hm.mjd = :mjd and " +
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        query.setParameter("mjd", mjd);
        query.setParameter("ccdModule", module);
        query.setParameter("ccdOutput", output);
        query.setEntity("history", history);
        query.setMaxResults(1);
        query.setCacheable(false);
        query.setReadOnly(true);
        TwoDBlackImageHistoryModel hm = uniqueResult(query);
        
        if (hm == null) {
            return null;
        }
        return hm;
    }

    public TwoDBlackImage retrieveMostRecentTwoDBlackImage(History history, int module, int output) {
        TwoDBlackImageHistoryModel hm = retrieveMostRecentTwoDBlackImageHistoryModel(history, module, output);
        if (hm == null) {
            return null;
        }
        return hm.getTwoDBlackImage();
    }

    public LargeFlatField retrieveMostRecentLargeFlatField(History history,
            int module, int output) {
        List<LargeFlatFieldHistoryModel> historyModels = retrieveLargeFlatFieldHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }

        LargeFlatField mostRecentLargeFlatField = historyModels.get(0)
                .getLargeFlatField();
        for (LargeFlatFieldHistoryModel historyModel : historyModels) {
            LargeFlatField largeFlatField = historyModel.getLargeFlatField();
            boolean isRightOutput = largeFlatField.getCcdModule() == module
                    && largeFlatField.getCcdOutput() == output;
            if (isRightOutput
                    && largeFlatField.getStartTime() > mostRecentLargeFlatField
                            .getStartTime()) {
                mostRecentLargeFlatField = largeFlatField;
            }
        }

        return mostRecentLargeFlatField;
    }

    public Pointing retrieveMostRecentPointing(History history) {
        List<PointingHistoryModel> historyModels = retrievePointingHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }
        Pointing mostRecentPointing = historyModels.get(0).getPointing();
        for (PointingHistoryModel historyModel : historyModels) {
            Pointing pointing = historyModel.getPointing();
            if (pointing.getMjd() > mostRecentPointing.getMjd()) {
                mostRecentPointing = pointing;
            }
        }
        return mostRecentPointing;
    }

    public RollTime retrieveMostRecentRollTime(History history) {
        List<RollTimeHistoryModel> historyModels = retrieveRollTimeHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }

        RollTime mostRecentRollTime = historyModels.get(0).getRollTime();
        for (RollTimeHistoryModel historyModel : historyModels) {
            RollTime rollTime = historyModel.getRollTime();
            if (rollTime.getMjd() > mostRecentRollTime.getMjd()) {
                mostRecentRollTime = rollTime;
            }
        }

        return mostRecentRollTime;
    }

    public Linearity retrieveMostRecentLinearity(History history, int module,
            int output) {
        List<LinearityHistoryModel> historyModels = retrieveLinearityHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }

        Linearity mostRecentLinearity = historyModels.get(0).getLinearity();
        for (LinearityHistoryModel historyModel : historyModels) {
            Linearity readNoise = historyModel.getLinearity();
            boolean isRightOutput = readNoise.getCcdModule() == module
                    && readNoise.getCcdOutput() == output;
            if (isRightOutput
                    && readNoise.getStartMjd() > mostRecentLinearity
                            .getStartMjd()) {
                mostRecentLinearity = readNoise;
            }
        }

        return mostRecentLinearity;
    }

    public Geometry retrieveMostRecentGeometry(History history) {
        List<GeometryHistoryModel> historyModels = retrieveGeometryHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }

        Geometry mostRecentGeometry = historyModels.get(0).getGeometry();
        for (GeometryHistoryModel historyModel : historyModels) {
            Geometry geometry = historyModel.getGeometry();
            if (geometry.getStartTime() > mostRecentGeometry.getStartTime()) {
                mostRecentGeometry = geometry;
            }
        }

        return mostRecentGeometry;
    }

    public ReadNoise retrieveReadNoiseExact(ReadNoise readNoise, History history) {
        List<ReadNoiseHistoryModel> historyModels = retrieveReadNoiseHistoryModels(history);
        Collections.sort(historyModels);
        
        ReadNoise result = null;
        for (ReadNoiseHistoryModel historyModel : historyModels) {
            
            ReadNoise loop = historyModel.getReadNoise();
            
            if (loop.getMjd()       == readNoise.getMjd() && 
                loop.getCcdModule() == readNoise.getCcdModule() && 
                loop.getCcdOutput() == readNoise.getCcdOutput())
            {
                result = historyModel.getReadNoise();
            }
        }
        return result;
    }

    /**
     * 
     * @param module
     * @param output
     * @param time
     *            (MJD)
     * @return
     * @throws PipelineException
     */
    public Gain retrieveGain(int module, int output, double time,
            History history) {

        // Get GainHistoryModels associated with 'history':
        //
        List<GainHistoryModel> historyModels = retrieveGainHistoryModels(history);
        Collections.sort(historyModels);

        Gain out = null;
        for (GainHistoryModel historyModel : historyModels) {
            
            Gain gain = historyModel.getGain();
            
            boolean isRightOutput = gain.getCcdModule() == module && 
            gain.getCcdOutput() == output;

            if (isRightOutput) {
                if (out == null) {
                    out = gain;
                }
                
                boolean isLater = gain.getMjd() > out.getMjd();
                if (isLater && gain.getMjd() < time) {
                    out = gain;
                }
            }
            
        }
        return out;
    }

    /**
     * 
     * @param module
     * @param output
     * @param time
     *            (MJD)
     * @return
     * @throws PipelineException
     */
    public ReadNoise retrieveReadNoise(double time, int module, int output,
            History history) {

        // Get ReadNoiseHistoryModels associated with 'history':
        //
        List<ReadNoiseHistoryModel> historyModels = retrieveReadNoiseHistoryModels(history);
        Collections.sort(historyModels);

        ReadNoise out = null;
        for (ReadNoiseHistoryModel historyModel : historyModels) {
            
            ReadNoise readNoise = historyModel.getReadNoise();
            
            boolean isRightOutput = readNoise.getCcdModule() == module &&
                                    readNoise.getCcdOutput() == output;
            
            if (isRightOutput) {
                if (out == null) {
                    out = readNoise;
                }
                
                boolean isLater = readNoise.getMjd() > out.getMjd();
                if (isLater && readNoise.getMjd() < time) {
                    out = readNoise;
                }
            }
        }

        return out;
    }

    /**
     * 
     * @param module
     * @param output
     * @param time
     *            (MJD)
     * @return
     * @throws PipelineException
     */
    public ReadNoise retrieveReadNoiseNext(double time, int module, int output,
            History history) {

        // Get ReadNoiseHistoryModels associated with 'history':
        //
        List<ReadNoiseHistoryModel> historyModels = retrieveReadNoiseHistoryModels(history);
        Collections.sort(historyModels);

        ReadNoise out = null;
        for (ReadNoiseHistoryModel historyModel : historyModels) {
            ReadNoise readNoise = historyModel.getReadNoise();
            
            boolean isRightOutput = readNoise.getCcdModule() == module &&
                                    readNoise.getCcdOutput() == output;
            
            if (isRightOutput) {
                if (out == null) {
                    out = readNoise;
                }
            
                boolean isEarlier = readNoise.getMjd() < out.getMjd();    
                if (isEarlier && readNoise.getMjd() > time) {
                    out = readNoise;
                }
            }
        }

        return out;
    }

    /**
     * 
     * @param module
     * @param output
     * @param time
     *            (MJD)
     * @return
     * @throws PipelineException
     */
    public List<Gain> retrieveGainsBetween(int module, int output,
            double mjdStart, double mjdEnd, History history) {

        // Get GainHistoryModels associated with 'history':
        List<GainHistoryModel> historyModels = retrieveGainHistoryModels(history);
        Collections.sort(historyModels);

        List<GainHistoryModel> historyModelsGood = new ArrayList<GainHistoryModel>();

        for (GainHistoryModel historyModel : historyModels) {
            Gain gain = historyModel.getGain();
            boolean isRightOutput = gain.getCcdModule() == module && 
                                    gain.getCcdOutput() == output;
            if (isRightOutput) {
                historyModelsGood.add(historyModel);
            }
        }

        // Get gains that occurred between mjdStart and mjdEnd, as well as
        // braketting Gains, if they exist:
        Gain prev = null;
        Gain next = null;
        List<Gain> gains = new ArrayList<Gain>();

        for (GainHistoryModel historyModel : historyModelsGood) {
            Gain current = historyModel.getGain();
            
            if (current.getMjd() < mjdStart) {
                prev = current;
            } else if (current.getMjd() > mjdEnd) {
                if (next == null) {
                    next = current;
                }
            } else {
                gains.add(current);
            }
        }
        
        if (prev != null) {
            gains.add(0, prev);
        }
        if (next != null) {
            gains.add(next);
        }

        return gains;
    }

    /**
     * 
     * @param module
     * @param output
     * @param time
     *            (MJD)
     * @return
     * @throws PipelineException
     */
    public ReadNoise[] retrieveReadNoisesBetween(int module, int output,
            double mjdStart, double mjdEnd, History history) {

        // Get ReadNoiseHistoryModels associated with 'history':
        //
        List<ReadNoiseHistoryModel> historyModels = retrieveReadNoiseHistoryModels(history);
        Collections.sort(historyModels);

        List<ReadNoiseHistoryModel> historyModelsGood = new ArrayList<ReadNoiseHistoryModel>();
        for (ReadNoiseHistoryModel historyModel : historyModels) {
            ReadNoise readNoise = historyModel.getReadNoise();
            boolean isRightOutput = readNoise.getCcdModule() == module && 
                                    readNoise.getCcdOutput() == output;
            if (isRightOutput) {
                historyModelsGood.add(historyModel);
            }
        }

        // Get readNoises that occurred between mjdStart and mjdEnd, as well as
        // braketting ReadNoises, if they exist:
        ReadNoise prev = null;
        ReadNoise next = null;

        List<ReadNoise> readNoises = new ArrayList<ReadNoise>();
        for (ReadNoiseHistoryModel historyModel : historyModelsGood) {
            ReadNoise current = historyModel.getReadNoise();
            
            if (current.getMjd() < mjdStart) {
                prev = current;
            } else if (current.getMjd() > mjdEnd) {
                if (next == null) {
                    next = current;
                }
            } else {
                readNoises.add(current);
            }
        }
        
        if (prev != null) {
            readNoises.add(0, prev);
        }
        if (next != null) {
            readNoises.add(next);
        }
        return readNoises.toArray(new ReadNoise[0]);
    }

    public List<Gain> retrieveAllGains(int module, int output, History history) {
        // Get GainHistoryModels associated with 'history':
        //
        List<GainHistoryModel> historyModels = retrieveGainHistoryModels(history);
        Collections.sort(historyModels);

        // Return those for the right mod/out:
        //
        List<Gain> gains = new ArrayList<Gain>();
        for (GainHistoryModel historyModel : historyModels) {
            Gain gain = historyModel.getGain();
            boolean isRightOutput = gain.getCcdModule() == module
                    && gain.getCcdOutput() == output;
            if (isRightOutput) {
                gains.add(gain);
            }
        }

        return gains;
    }

    public ReadNoise[] retrieveAllReadNoises(int module, int output,
            History history) {

        // Get HistoryModels associated with 'history':
        //
        List<ReadNoiseHistoryModel> historyModels = retrieveReadNoiseHistoryModels(history);
        Collections.sort(historyModels);

        // Return those for the right mod/out:
        //
        List<ReadNoise> readNoises = new ArrayList<ReadNoise>();
        for (ReadNoiseHistoryModel historyModel : historyModels) {
            ReadNoise readNoise = historyModel.getReadNoise();
            boolean isRightOutput = readNoise.getCcdModule() == module
                    && readNoise.getCcdOutput() == output;
            if (isRightOutput) {
                readNoises.add(readNoise);
            }
        }

        return readNoises.toArray(new ReadNoise[0]);
    }

    public Tds retrieve(Tds tds) {
        Query q = getSession()
                .createQuery(
                        "from Tds t where t.ccdModule = :module and t.ccdOutput = :output & t.startTime < :startTime");
        q.setParameter("module", tds.getCcdModule());
        q.setParameter("output", tds.getCcdOutput());
        q.setParameter("startTime", tds.getStartTime());
        q.setMaxResults(1);

        return uniqueResult(q);
    }

    /**
     * Retrieve the Geometry that is valid for the time range specified by the
     * input Geometry.
     * 
     * @param inGm
     */
    // public Geometry retrieve(Geometry geometry, History history) {
    // return retrieveMostRecent(geometry, history);
    // }
    public Geometry retrieve(Geometry geometry, History history) {
        List<GeometryHistoryModel> historyModels = retrieveGeometryHistoryModels(history);
        Collections.sort(historyModels);
        
        Geometry result = null;
        for (GeometryHistoryModel geometryHistoryModel : historyModels) {
            double loopTime = geometryHistoryModel.getGeometry().getStartTime() ;
            boolean isInRange = loopTime <= geometry.getStartTime();
            
            if (isInRange) {
                if (result == null) {
                    result = geometryHistoryModel.getGeometry();
                }
                
                boolean isNewer = result.getStartTime() <= loopTime;
                if (isNewer) {
                    result = geometryHistoryModel.getGeometry();
                }
            }
        }
        
        if (result == null) {
            result = historyModels.get(0).getGeometry();
        }
        return result;
    }

    public Geometry retrieveGeometryExact(double mjd, History history) {
        Query q = getSession()
                .createQuery(
                        "from Geometry gm where gm.startTime = :startTime and gm.history = :history");
        q.setParameter("startTime", mjd);
        q.setEntity("history", history);
        q.setMaxResults(1);
        Geometry gm = uniqueResult(q);
        return gm;
    }

    public Geometry retrieveMostRecent(Geometry geometry, History history) {
        Query q = getSession()
                .createQuery(
                        "from Geometry gm where gm.startTime <= :startTime "
                                + " and gm.history = :history order by gm.startTime desc");

        q.setParameter("startTime", geometry.getStartTime());
        q.setEntity("history", history);

        q.setMaxResults(1);
        Geometry gm = uniqueResult(q);
        return gm;
    }

    public Geometry retrieveNext(Geometry geometry, History history) {
        Query q = getSession().createQuery(
                "from Geometry gm where gm.startTime > :startTime "
                        + " and gm.history = :history "
                        + "order by gm.startTime asc");

        q.setParameter("startTime", geometry.getStartTime());
        q.setEntity("history", history);

        q.setMaxResults(1);

        return uniqueResult(q);
    }

    public List<Geometry> retrieveBetween(Geometry start, Geometry stop,
            History history) {

        Query q = getSession().createQuery(
                "from Geometry gm where gm.startTime >= :begin and "
                        + "gm.startTime <= :end "
                        + "and gm.history = :history "
                        + "order by gm.startTime asc");
        q.setParameter("begin", start.getStartTime());
        q.setParameter("end", stop.getStartTime());
        q.setEntity("history", history);

        List<Geometry> betweens = list(q);

        return betweens;
    }

    public LargeFlatField retrieve(double mjd, int ccdModule, int ccdOutput,
            History history) {

        List<LargeFlatFieldHistoryModel> historyModels = retrieveLargeFlatFieldHistoryModels(history);
        Collections.sort(historyModels);

        if (historyModels.size() == 0) {
            return null;
        }

        LargeFlatField result = null;

        for (LargeFlatFieldHistoryModel historyModel : historyModels) {
            
            LargeFlatField largeFlatField = historyModel.getLargeFlatField();
            
            boolean isRightOutput = largeFlatField.getCcdModule() == ccdModule && 
                                    largeFlatField.getCcdOutput() == ccdOutput;

            if (isRightOutput) {
                if (result == null) {
                    result = largeFlatField;
                }
                boolean isLater = largeFlatField.getStartTime() > result.getStartTime();
                if (isLater && largeFlatField.getStartTime() <= mjd) {
                    result = largeFlatField;
                }
            }
        }

        return result;
    }

    public List<LargeFlatField> retrieveLargeFlatFields(double mjdStart,
            double mjdEnd, int ccdModule, int ccdOutput, History history) {

        List<LargeFlatFieldHistoryModel> historyModels = retrieveLargeFlatFieldHistoryModels(history);
        Collections.sort(historyModels);

        List<LargeFlatField> flats = new ArrayList<LargeFlatField>();

        // Get LargeFlatField that occurred between mjdStart and mjdEnd, as well
        // as braketting LargeFlatField, if they exist:
        LargeFlatField prev = null;
        LargeFlatField next = null;
        for (LargeFlatFieldHistoryModel historyModel : historyModels) {
            LargeFlatField current = historyModel.getLargeFlatField();
            
            if (current.getStartTime() < mjdStart) {
                prev = current;
            } else if (current.getStartTime() > mjdEnd) {
                if (next == null) {
                    next = current;
                }
            } else {
                flats.add(current);
            }
        }
        
        if (prev != null) {
            flats.add(0, prev);
        }
        if (next != null) {
            flats.add(next);
        }

        return flats;
    }

    public LargeFlatField retrieveLargeFlatFieldExact(LargeFlatField flat,
            History history) {

        Query q = getSession()
                .createQuery(
                        "from LargeFlatField l where "
                                + "l.startTime = :time and "
                                + "l.ccdModule = :module and "
                                + "l.ccdOutput = :output"
                                + " and l.history = :history");
        q.setParameter("time", flat.getStartTime());
        q.setParameter("module", flat.getCcdModule());
        q.setParameter("output", flat.getCcdOutput());
        q.setEntity("history", history);

        q.setMaxResults(1);
        LargeFlatField out = uniqueResult(q);

        return out;
    }

    public List<LargeFlatField> retrieveLargeFlatFields(int ccdModule,
            int ccdOutput, History history) {

        List<LargeFlatFieldHistoryModel> historyModels = retrieveLargeFlatFieldHistoryModels(history);
        Collections.sort(historyModels);

        List<LargeFlatField> flats = new ArrayList<LargeFlatField>();

        for (LargeFlatFieldHistoryModel historyModel : historyModels) {
            LargeFlatField flat = historyModel.getLargeFlatField();
            if (flat.getCcdModule() == ccdModule
                    && flat.getCcdOutput() == ccdOutput) {
                flats.add(flat);
            }
        }
        return flats;
    }

    public LargeFlatField retrieveNext(double mjd, int ccdModule,
            int ccdOutput, History history) {

        Query q = getSession().createQuery(
                "from LargeFlatField l where "
                        + "l.startTime >= :startTime and "
                        + "l.ccdModule = :module and "
                        + "l.ccdOutput = :output and "
                        + "l.history =  :history");
        q.setParameter("startTime", mjd);
        q.setParameter("module", ccdModule);
        q.setParameter("output", ccdOutput);
        q.setEntity("history", history);

        q.setMaxResults(1);

        LargeFlatField result = uniqueResult(q);
        return result;
    }

    /**
     * Returns a list of the times (MJD) that will return different flat fields
     * for the range of dates specifed with the inputs dates "start" and "stop";
     * If the list has one element, there is only one valid flat for that
     * timerange (i.e., the flat did not change during that period).
     * 
     * @param start
     *            Start of time range.
     * @param stop
     *            End of time range.
     * @return A list of the dates for different flats in the time range.
     */
    public List<Double> retrieveUniqueLargeFlatFieldDates(double startTime,
            double endTime, History history) {

        Query q = getSession()
                .createQuery(
                        "select distinct(l.startTime) from LargeFlatField l "
                                + "where l.startTime >= :startTime and l.startTime <= :stopTime and l.history = :history");
        q.setParameter("startTime", startTime);
        q.setParameter("stopTime", endTime);
        q.setEntity("history", history);

        List<Double> dates = list(q);

        return dates;
    }

    /**
     * Returns a list of the dates that will return different 2d blacks for the
     * range of dates specified with the inputs dates "start" and "stop"; If the
     * list has one element, there is only one valid flat for that time range
     * (i.e., the flat did not change during that period).
     * 
     * @param start
     *            Start of time range.
     * @param stop
     *            End of time range.
     * @return A list of the dates for different flats in the time range.
     */
    public List<Date> retrieveDifferentTwoDBlackDates(Date start, Date stop) {
        Query q = getSession()
                .createQuery(
                        "select distinct(l.startTime) from TwoDBlackDate l where l.startTime > :startTime and l.stopTime < :stopTime");
        q.setParameter("startTime", start);
        q.setParameter("stopTime", stop);

        List<Date> dates = list(q);

        return dates;
    }

    public Linearity retrieve(int module, int output, double mjd,
            History history) {

        Query q = getSession().createQuery(
                "from Linearity l where " + "l.ccdModule = :ccdModule and "
                        + "l.ccdOutput = :ccdOutput and "
                        + "l.startMjd <= :startMjd and "
                        + "l.history = :history " + "order by startMjd DESC");

        q.setParameter("ccdModule", module);
        q.setParameter("ccdOutput", output);
        q.setParameter("startMjd", mjd);
        q.setEntity("history", history);

        q.setMaxResults(1);

        Linearity result = uniqueResult(q);
        return result;
    }

    public Linearity retrieveExact(int module, int output, double mjd) {
        Query q = getSession().createQuery(
                "from Linearity l where " + "l.ccdModule = :ccdModule and "
                        + "l.ccdOutput = :ccdOutput and "
                        + "l.startMjd = :startMjd " + "order by startMjd DESC");

        q.setParameter("ccdModule", module);
        q.setParameter("ccdOutput", output);
        q.setParameter("startMjd", mjd);

        q.setMaxResults(1);

        Linearity result = uniqueResult(q);
        return result;
    }

    /**
     * Get all linearity
     * 
     * @param module
     * @param output
     * @param startMjd
     * @param endMjd
     * @param history
     * @return
     */
    public List<Linearity> retrieveLinearityAll(int module, int output,
            History history) {

        // Get LinearityHistoryModels associated with 'history':
        //
        List<LinearityHistoryModel> historyModels = retrieveLinearityHistoryModels(history);
        Collections.sort(historyModels);

        // Return those for the right mod/out:
        //
        List<Linearity> linearitys = new ArrayList<Linearity>();
        for (LinearityHistoryModel historyModel : historyModels) {
            Linearity linearity = historyModel.getLinearity();
            boolean isRightOutput = linearity.getCcdModule() == module
                    && linearity.getCcdOutput() == output;
            if (isRightOutput) {
                linearitys.add(linearity);
            }
        }

        return linearitys;
    }

    public List<Linearity> retrieveLinearityBetween(int module, int output,
            double mjdStart, double mjdEnd, History history) {

        // Get LinearityHistoryModels associated with 'history':
        //
        List<LinearityHistoryModel> historyModels = retrieveLinearityHistoryModels(history);
        Collections.sort(historyModels);

        List<LinearityHistoryModel> historyModelsGood = retrieveLinearityHistoryModels(history);
        
        for (LinearityHistoryModel historyModel : historyModels) {
            Linearity linearity = historyModel.getLinearity();
            boolean isRightOutput = linearity.getCcdModule() == module && 
                                    linearity.getCcdOutput() == output;
            if (isRightOutput) {
                historyModelsGood.add(historyModel);
            }
        }

        // Get linearitys that occurred between mjdStart and mjdEnd, as well as
        // braketting Linearitys, if they exist:
        Linearity prev = null;
        Linearity next = null;
        List<Linearity> linearitys = new ArrayList<Linearity>();
        
        for (LinearityHistoryModel historyModel : historyModelsGood) {
            Linearity current = historyModel.getLinearity();
            
            if (current.getStartMjd() < mjdStart) {
                prev = current;
            } else if (current.getStartMjd() > mjdEnd) {
                if (next == null) {
                    next = current;
                }
            } else {
                linearitys.add(current);
            }
        }
        
        if (prev != null) {
            linearitys.add(0, prev);
        }
        if (next != null) {
            linearitys.add(next);
        }
        
        return linearitys;
    }

    public Linearity retrieveLinearityExact(Linearity linearity, History history) {
        Query q = getSession().createQuery(
                "from Linearity l where " + "l.ccdModule = :ccdModule and "
                        + "l.ccdOutput = :ccdOutput and "
                        + "l.startMjd  = :startMjd "
                        + " and l.history = :history");

        q.setParameter("ccdModule", linearity.getCcdModule());
        q.setParameter("ccdOutput", linearity.getCcdOutput());
        q.setParameter("startMjd", linearity.getStartMjd());
        q.setEntity("history", history);
        q.setMaxResults(1);

        Linearity result = uniqueResult(q);
        return result;
    }

    public Obscuration retrieve(Obscuration obscuration) {
        Query q = getSession().createQuery(
                "from Obscuration o where o.startTime  <  :startTime");
        q.setParameter("startTime", obscuration.getStartTime());

        q.setMaxResults(1);
        return uniqueResult(q);
    }

    public Pixel retrieve(Pixel pixel, History history) {
        Query q = getSession().createQuery(
                "from Pixel p where p.startTime  <=  :startTime");
        q.setParameter("startTime", pixel.getStartTime());

        q.setMaxResults(1);
        return uniqueResult(q);
    }

    public Pixel retrievePixelExact(Pixel pixel, History history) {
        Query q = getSession().createQuery("from PixelHistoryModel hm where hm.history = :history");
        q.setEntity("history", history);
        List<PixelHistoryModel> hms = list(q);
        
        for (PixelHistoryModel hm : hms) {
            Pixel loop = hm.getPixel();
            if (loop.equals(pixel)) {
                return loop;
            }
        }
        return null;
    }

    public List<Pixel> retrieveInvalidPixels(int module, int output, int row,
            int column, double time, PixelType type) {

        Query q = getSession().createQuery(
                "from Pixel p where p.startTime <= :startTime"
                        + " and p.ccdModule = :ccdModule"
                        + " and p.ccdOutput = :ccdOutput"
                        + " and p.ccdRow = :ccdRow "
                        + " and p.ccdColumn = :ccdColumn "
                        + " and p.type = :type");
        q.setParameter("startTime", time);
        q.setParameter("ccdModule", module);
        q.setParameter("ccdOutput", output);
        q.setParameter("ccdRow", row);
        q.setParameter("ccdColumn", column);
        q.setParameter("type", type);

        List<Pixel> pixels = list(q);

        return pixels;
    }

    public List<Pixel> retrieveInvalidPixels(int module, int output,
            double time, PixelType type, History history) {

        Query q = getSession().createQuery(
                "from Pixel p where p.startTime <= :startTime"
                        + " and p.ccdModule = :ccdModule"
                        + " and p.ccdOutput = :ccdOutput"
                        + " and p.type = :type");
        q.setParameter("startTime", time);
        q.setParameter("ccdModule", module);
        q.setParameter("ccdOutput", output);
        q.setParameter("type", type);

        List<Pixel> pixels = list(q);

        return pixels;
    }

    public Pixel[] retrieveBetween(Pixel pixel, History history) {
        Query q = getSession()
                .createQuery(
                        "from Pixel p where p.ccdModule = :module and "
                                + "p.ccdOutput = :output and p.startTime <= :endTime order by p.startTime ASC");

        q.setParameter("module", pixel.getCcdModule());
        q.setParameter("output", pixel.getCcdOutput());
        q.setParameter("endTime", pixel.getEndTime());

        List<Pixel> pixels = list(q);
        Pixel[] pixelsArray = new Pixel[pixels.size()];
        for (int ii = 0; ii < pixels.size(); ++ii) {
            pixelsArray[ii] = pixels.get(ii);
        }
        return pixelsArray;
    }

    /**
     * Retrieves all {@link Pixels} elements where the given date lies between
     * the {@link Pixel}s start and end times, inclusive.
     * 
     * @param date
     *            the date.
     * @return a non-{@code null} list of {@link Pixel} elements in
     *         chronological order.
     */
    public List<Pixel> retrievePixels(Date date) {
        double time = ModifiedJulianDate.dateToMjd(date);
        Criteria query = getSession().createCriteria(Pixel.class);
        query.add(Restrictions.le("startTime", time));
        query.add(Restrictions.ge("endTime", time));
        query.addOrder(Order.asc("startTime"));

        List<Pixel> pixels = list(query);

        return pixels;
    }

    public Pixel[] retrieveBetweenType(Pixel pixel, History history) {
        Query q = getSession()
                .createQuery(
                        "from Pixel p where p.ccdModule = :module and "
                                + "p.ccdOutput = :output and p.startTime <= :endTime and p.type = :type "
                                + "order by p.startTime ASC");

        q.setParameter("module", pixel.getCcdModule());
        q.setParameter("output", pixel.getCcdOutput());
        q.setParameter("endTime", pixel.getEndTime());
        q.setParameter("type", pixel.getType());

        List<Pixel> pixels = list(q);
        Pixel[] pixelsArray = new Pixel[pixels.size()];
        for (int ii = 0; ii < pixels.size(); ++ii) {
            pixelsArray[ii] = pixels.get(ii);
        }
        return pixelsArray;
    }

    public List<Pixel> retrievePixelsBetweenTimes(double startTime,
            double endTime, int module, int output, PixelType type) {
        Query q = getSession().createQuery(
                "from Pixel p where " + "p.ccdModule = :module and "
                        + "p.ccdOutput = :output and "
                        + "p.startTime >= :startTime and "
                        + "p.startTime <= :endTime and " + "p.type = :type "
                        + "order by p.startTime ASC");

        q.setParameter("module", module);
        q.setParameter("output", output);
        q.setParameter("startTime", startTime);
        q.setParameter("endTime", endTime);
        q.setParameter("type", type);

        List<Pixel> pixels = list(q);
        return pixels;
    }

    public Pixel[] retrieveTypeBetween(Pixel pixel) {
        Query q = getSession().createQuery(
                "from Pixel p where p.type = :type and "
                        + "p.startTime <= stopTime order by p.startTime ASC");

        q.setParameter("type", pixel.getType());
        q.setParameter("startTime", pixel.getStartTime());
        q.setParameter("stopTime", pixel.getEndTime());

        List<Pixel> pixels = list(q);
        return pixels.toArray(new Pixel[0]);
    }

    public Psf retrieve(Psf psf) {
        Query q = getSession()
                .createQuery(
                        "from Psf p where p.startTime <= :startTime and p.targetId = :targetId");
        q.setParameter("startTime", psf.getStartTime());
        q.setParameter("targetId", psf.getTargetId());

        q.setMaxResults(1);
        Psf out = uniqueResult(q);

        return out;
    }

    public List<Psf> retrieveAllPsf() {
        Query q = getSession().createQuery("from Psf p");
        List<Psf> psfs = list(q);

        return psfs;
    }

    public ScatteredLight retrieve(ScatteredLight scatteredLight) {
        Query q = getSession().createQuery(
                "from ScatteredLight s where s.startTime < :startTime");
        q.setParameter("startTime", scatteredLight.getStart());

        q.setMaxResults(1);
        return uniqueResult(q);
    }

    public Vignetting retrieve(Vignetting vignetting) {
        Query q = getSession().createQuery(
                "from Vignetting v where v.startTime < :startTime");
        q.setParameter("startTime", vignetting.getStartTime());

        q.setMaxResults(1);
        return uniqueResult(q);
    }

    public ZodiacalLight retrieve(ZodiacalLight zodi) {
        Query q = getSession()
                .createQuery(
                        "from ZodiacalLight z where z.startTime < :startTime and z.ccdModule = :module and z.ccdOutput = :output");
        q.setParameter("startTime", zodi.getStartTime());
        q.setParameter("module", zodi.getCcdModule());
        q.setParameter("output", zodi.getCcdOutput());

        q.setMaxResults(1);
        return uniqueResult(q);
    }

    public Saturation retrieve(int keplerId, int season) {
        Query q = getSession().createQuery("from Saturation s where s.keplerId = :keplerId and s.season = :season");
        q.setParameter("keplerId", keplerId);
        q.setParameter("season", season);

        q.setMaxResults(1);
        return uniqueResult(q);
    }
    
    public Saturation[] retrieveSaturations(int channel, int season) {
        Query q = getSession().createQuery("from Saturation s where s.channel = :channel and s.season = :season");
        
        q.setParameter("channel", channel);
        q.setParameter("season", season);
        
        List<Saturation> saturations = list(q);
        return saturations.toArray(new Saturation[0]);
    }
    
    
    /**
     * 
     * @param mjd
     * @param history
     * @return
     */
    public double retrieveSmallFlatFieldImageDateNext(double mjd,
            History history) {

        String queryString = "select mjd from SmallFlatFieldImage s where "
                + "s.mjd >= :mjd and " + "s.history = :history "
                + "order by startMjd ASC";
        Query q = getSession().createQuery(queryString);
        q.setCacheable(false);
        q.setReadOnly(true);
        q.setParameter("mjd", mjd);
        q.setEntity("history", history);
        q.setMaxResults(1);

        Double outputMjd = uniqueResult(q);
        return outputMjd;
    }

    /**
     * Retrieve the flat field data for the specified {@link SmallFlatFieldDate},
     * and module/output
     * 
     * @param date
     * @param ccdModule
     * @param ccdOutput
     * @return
     * @throws PipelineException
     */
    public SmallFlatFieldImage retrieveSmallFlatFieldImage(double mjd,
            int ccdModule, int ccdOutput, History history) {

        Query query = getSession().createQuery(
                "from SmallFlatFieldImageHistoryModel hm where hm.mjd <= :date "
                        + " and hm.ccdModule = :ccdModule "
                        + " and hm.ccdOutput = :ccdOutput"
                        + " and hm.history = :history");
        query.setParameter("date", mjd);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        query.setMaxResults(1);
        SmallFlatFieldImageHistoryModel result = uniqueResult(query);
        if (result == null) {
            return null;
        }

        SmallFlatFieldImage image = result.getSmallFlatFieldImage();
        
        getSession().setReadOnly(image, true);
        getSession().setReadOnly(image.getSmallFlatImageData(), true);
        getSession().setReadOnly(image.getSmallFlatImageUncertainty(), true);
        
        return image;
    }

    public SmallFlatFieldImage retrieveSmallFlatFieldImageExact(double mjd,
            int ccdModule, int ccdOutput, History history) {

        Query query = getSession().createQuery(
                "from SmallFlatFieldImageHistoryModel hm where hm.mjd = :date "
                        + " and hm.ccdModule = :ccdModule "
                        + " and hm.ccdOutput = :ccdOutput"
                        + " and hm.history = :history");
        query.setParameter("date", mjd);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        query.setMaxResults(1);
        SmallFlatFieldImageHistoryModel result = uniqueResult(query);
        if (result == null) {
            return null;
        }
        return result.getSmallFlatFieldImage();

    }

    public TwoDBlackImage retrieveTwoDBlackImageExact(double mjd,
            int ccdModule, int ccdOutput, History history) {
        Query q = getSession().createQuery(
                "from TwoDBlackImage s " + "where s.mjd = :date "
                        + " and s.ccdModule = :ccdModule "
                        + " and s.ccdOutput = :ccdOutput"
                        + " and s.history = :history");
        q.setParameter("date", mjd);
        q.setParameter("ccdModule", ccdModule);
        q.setParameter("ccdOutput", ccdOutput);
        q.setEntity("history", history);
        q.setCacheable(false);
        q.setReadOnly(true);

        q.setMaxResults(1);
        TwoDBlackImage result = uniqueResult(q);
        return result;
    }

    public boolean isTwoDBlackImagePersisted(double mjd, int module,
            int output, History history) {

        String queryString = "select mjd from TwoDBlackImage t where "
                + "t.mjd  = :startMjd and " + "t.ccdModule = :module and "
                + "t.ccdOutput = :output " + "order by mjd DESC";
        Query q = getSession().createQuery(queryString);
        q.setParameter("startMjd", mjd);
        q.setParameter("module", module);
        q.setParameter("output", output);

        List<Double> dates = list(q);

        return dates.size() > 0;
    }

    public boolean isSmallFlatFieldImagePersisted(double mjd, int module,
            int output, History history) {

        String queryString = "select mjd from SmallFlatFieldImage s where "
                + "s.mjd  = :startMjd and " + "s.ccdModule = :module and "
                + "s.ccdOutput = :output "
                // + "and s.history = :history ";
                + " order by mjd DESC";
        Query q = getSession().createQuery(queryString);
        q.setParameter("startMjd", mjd);
        q.setParameter("module", module);
        q.setParameter("output", output);
        // q.setEntity("history", history);

        List<Double> dates = list(q);

        return dates.size() > 0;
    }

    /**
     * Retrieve the dates for all available TwoDBlackImages
     * 
     * @param history
     * @return
     */
    public double[] retrieveTwoDBlackImageTimes(History history) {
        Query query = getSession().createQuery(
                "select hm.mjd from TwoDBlackImageHistoryModel hm where "
                        + "hm.history = :history order by hm.mjd");
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        List<Double> times = list(query);
        double[] timesArr = new double[times.size()];
        for (int ii = 0; ii < times.size(); ++ii) {
            timesArr[ii] = times.get(ii);
        }

        return timesArr;
    }
    
    /**
     * Retrieve the dates for all available TwoDBlackImages
     * 
     * @param history
     * @return
     */
    public double[] retrieveTwoDBlackImageTimes(int ccdModule, int ccdOutput, History history) {
        Query query = getSession()
                .createQuery(
                        "select hm.mjd from TwoDBlackImageHistoryModel hm where "
                                + "hm.history = :history and hm.ccdModule = :ccdModule and hm.ccdOutput = :ccdOutput "
                                + "order by hm.mjd");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        List<Double> times = list(query);
        double[] timesArr = new double[times.size()];
        for (int ii = 0; ii < times.size(); ++ii) {
            timesArr[ii] = times.get(ii);
        }

        return timesArr;
    }

    /**
     * Retrieve the dates for all available TwoDBlackImages
     * 
     * @param history
     * @return
     */
    public double[] retrieveTwoDBlackImageTimes(double mjdStart, double mjdEnd,
            History history) {

        // Times between mjdStart and mjdEnd:
        //
        Query query = getSession().createQuery(
                "select hm.mjd from TwoDBlackImageHistoryModel hm where "
                        + "hm.history = :history and hm.mjd >= :mjdStart and hm.mjd <= :mjdEnd "
                        + "order by hm.mjd");
        query.setParameter("mjdStart", mjdStart);
        query.setParameter("mjdEnd", mjdEnd);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        List<Double> times = list(query);

        
        // The lower bracketing time, if it exists:
        //
        Query queryMin = getSession().createQuery(
                "select max(hm.mjd) from TwoDBlackImageHistoryModel hm where "
                        + "hm.history = :history and hm.mjd < :mjdStart");
        queryMin.setParameter("mjdStart", mjdStart);
        queryMin.setEntity("history", history);
        queryMin.setMaxResults(1);
        queryMin.setCacheable(false);
        queryMin.setReadOnly(true);
        Double minTime = uniqueResult(queryMin);
        if (minTime != null) {
            times.add(0, minTime);
        }


        // The higher bracketing time, if it exists:
        //
        Query queryMax = getSession().createQuery(
                "select min(hm.mjd) from TwoDBlackImageHistoryModel hm where "
                        + "hm.history = :history and hm.mjd > :mjdEnd");
        queryMax.setParameter("mjdEnd", mjdEnd);
        queryMax.setEntity("history", history);
        queryMax.setCacheable(false);
        queryMax.setReadOnly(true);
        Double maxTime = uniqueResult(queryMax);
        if (maxTime != null) {
            times.add(maxTime);
        }        
        
        
        // Return as array:
        //
        double[] timesArr = new double[times.size()];
        for (int ii = 0; ii < times.size(); ++ii) {
            timesArr[ii] = times.get(ii);
        }
        return timesArr;
    }

    /**
     * Retrieve the dates for all available TwoDBlackImages
     * 
     * @param history
     * @return
     */
    public double[] retrieveTwoDBlackImageTimes(double mjdStart, double mjdEnd, int ccdModule, int ccdOutput,
            History history) {

        // Times between mjdStart and mjdEnd:
        //
        Query query = getSession().createQuery(
                "select hm.mjd from TwoDBlackImageHistoryModel hm where "
                        + "hm.ccdModule = :ccdModule and hm.ccdOutput = :ccdOutput and "
                        + "hm.history = :history and hm.mjd >= :mjdStart and hm.mjd <= :mjdEnd "
                        + "order by hm.mjd");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setParameter("mjdStart", mjdStart);
        query.setParameter("mjdEnd", mjdEnd);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);

        List<Double> times = list(query);
        
        // The lower bracketing time, if it exists:
        //
        Query queryMin = getSession().createQuery(
                        "select max(hm.mjd) from TwoDBlackImageHistoryModel hm where "
                                + "hm.ccdModule = :ccdModule and hm.ccdOutput = :ccdOutput and "
                                + "hm.history = :history and hm.mjd < :mjdStart");
        queryMin.setParameter("ccdModule", ccdModule);
        queryMin.setParameter("ccdOutput", ccdOutput);
        queryMin.setParameter("mjdStart", mjdStart);
        queryMin.setEntity("history", history);
        queryMin.setMaxResults(1);
        queryMin.setCacheable(false);
        queryMin.setReadOnly(true);
        Double minTime = uniqueResult(queryMin);
        if (minTime != null) {
            times.add(0, minTime);
        }


        // The higher bracketing time, if it exists:
        //
        Query queryMax = getSession().createQuery(
                        "select min(hm.mjd) from TwoDBlackImageHistoryModel hm where "
                                + "hm.ccdModule = :ccdModule and hm.ccdOutput = :ccdOutput and "
                                + "hm.history = :history and hm.mjd > :mjdEnd");
        queryMax.setParameter("ccdModule", ccdModule);
        queryMax.setParameter("ccdOutput", ccdOutput);
        queryMax.setParameter("mjdEnd", mjdEnd);
        queryMax.setEntity("history", history);
        queryMax.setCacheable(false);
        queryMax.setReadOnly(true);
        Double maxTime = uniqueResult(queryMax);
        if (maxTime != null) {
            times.add(maxTime);
        }        
        
        // Return as array:
        //
        double[] timesArr = new double[times.size()];
        for (int ii = 0; ii < times.size(); ++ii) {
            timesArr[ii] = times.get(ii);
        }

        return timesArr;
    
    }
     
    /**
     * Retrieve the dates for all available SmallFlatFieldImages in the given
     * range
     * 
     * @param history
     * @return
     */

    public double[] retrieveSmallFlatFieldImageTimes(double mjdStart, double mjdEnd, History history) {

        // Times between mjdStart and mjdEnd:
        //
        Query query = getSession().createQuery(
                "select hm.mjd from SmallFlatFieldImageHistoryModel hm where "
                        + "hm.history = :history and hm.mjd >= :mjdStart and hm.mjd <= :mjdEnd "
                        + "order by hm.mjd");
        query.setParameter("mjdStart", mjdStart);
        query.setParameter("mjdEnd", mjdEnd);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);

        List<Double> times = list(query);

        
        // The lower bracketing time, if it exists:
        //
        Query queryMin = getSession().createQuery(
                "select max(hm.mjd) from SmallFlatFieldImageHistoryModel hm where "
                        + "hm.history = :history and hm.mjd < :mjdStart");
        queryMin.setParameter("mjdStart", mjdStart);
        queryMin.setEntity("history", history);
        queryMin.setMaxResults(1);
        queryMin.setCacheable(false);
        queryMin.setReadOnly(true);
        Double minTime = uniqueResult(queryMin);
        if (minTime != null) {
            times.add(0, minTime);
        }


        // The higher bracketing time, if it exists:
        //
        Query queryMax = getSession().createQuery(
                "select min(hm.mjd) from SmallFlatFieldImageHistoryModel hm where "
                        + "hm.history = :history and hm.mjd > :mjdEnd");
        queryMax.setParameter("mjdEnd", mjdEnd);
        queryMax.setEntity("history", history);
        queryMax.setCacheable(false);
        queryMax.setReadOnly(true);
        Double maxTime = uniqueResult(queryMax);
        if (maxTime != null) {
            times.add(maxTime);
        }        
        
        
        // Return as array:
        //
        double[] timesArr = new double[times.size()];
        for (int ii = 0; ii < times.size(); ++ii) {
            timesArr[ii] = times.get(ii);
        }
        return timesArr;
    }
    
    /**
     * Retrieve the dates for all available SmallFlatFieldImages in the given
     * range
     * 
     * @param history
     * @return
     */
    public double[] retrieveSmallFlatFieldImageTimes(double mjdStart, double mjdEnd, int ccdModule, int ccdOutput, History history) {

        // Times between mjdStart and mjdEnd:
        //
        Query query = getSession().createQuery(
                "select hm.mjd from SmallFlatFieldImageHistoryModel hm where "
                        + "hm.ccdModule = :ccdModule and hm.ccdOutput = :ccdOutput and "
                        + "hm.history = :history and hm.mjd >= :mjdStart and hm.mjd <= :mjdEnd "
                        + "order by hm.mjd");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setParameter("mjdStart", mjdStart);
        query.setParameter("mjdEnd", mjdEnd);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);

        List<Double> times = list(query);
        
        // The lower bracketing time, if it exists:
        //
        Query queryMin = getSession().createQuery(
                        "select max(hm.mjd) from SmallFlatFieldImageHistoryModel hm where "
                                + "hm.ccdModule = :ccdModule and hm.ccdOutput = :ccdOutput and "
                                + "hm.history = :history and hm.mjd < :mjdStart");
        queryMin.setParameter("ccdModule", ccdModule);
        queryMin.setParameter("ccdOutput", ccdOutput);
        queryMin.setParameter("mjdStart", mjdStart);
        queryMin.setEntity("history", history);
        queryMin.setMaxResults(1);
        queryMin.setCacheable(false);
        queryMin.setReadOnly(true);
        Double minTime = uniqueResult(queryMin);
        if (minTime != null) {
            times.add(0, minTime);
        }

        // The higher bracketing time, if it exists:
        //
        Query queryMax = getSession().createQuery(
                        "select min(hm.mjd) from SmallFlatFieldImageHistoryModel hm where "
                                + "hm.ccdModule = :ccdModule and hm.ccdOutput = :ccdOutput and "
                                + "hm.history = :history and hm.mjd > :mjdEnd");
        queryMax.setParameter("ccdModule", ccdModule);
        queryMax.setParameter("ccdOutput", ccdOutput);
        queryMax.setParameter("mjdEnd", mjdEnd);
        queryMax.setEntity("history", history);
        queryMax.setCacheable(false);
        queryMax.setReadOnly(true);
        Double maxTime = uniqueResult(queryMax);
        if (maxTime != null) {
            times.add(maxTime);
        }        
        
        // Return as array:
        //
        double[] timesArr = new double[times.size()];
        for (int ii = 0; ii < times.size(); ++ii) {
            timesArr[ii] = times.get(ii);
        }
        return timesArr;
    
    }

    /**
     * Retrieve the dates for all available SmallFlatFieldImages
     * 
     * @param history
     * @return
     */
    public double[] retrieveSmallFlatFieldImageTimes(History history) {
        Query query = getSession().createQuery(
                "select hm.mjd from SmallFlatFieldImageHistoryModel hm where "
                        + "hm.history = :history order by hm.mjd");
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        List<Double> times = list(query);
        double[] timesArr = new double[times.size()];
        for (int ii = 0; ii < times.size(); ++ii) {
            timesArr[ii] = times.get(ii);
        }
        
        return timesArr;
    }
    
    /**
     * Retrieve the dates for all available SmallFlatFieldImages
     * 
     * @param history
     * @return
     */
    public double[] retrieveMostRecentSmallFlatFieldImageTime(History history) {
        Query query = getSession().createQuery(
                "select max(hm.mjd) from SmallFlatFieldImageHistoryModel hm where "
                        + "hm.history = :history");
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        query.setMaxResults(1);
        Double mjd = uniqueResult(query);
        
        double[] mjdArr = { mjd }; 
        return mjdArr;
    }

    public TwoDBlackImage retrieveTwoDBlackImage(double mjd, int ccdModule,
            int ccdOutput, History history) {
        TwoDBlackImageHistoryModel historyModel = retrieveTwoDBlackImageHistoryModel(history, mjd, ccdModule, ccdOutput);
        if (historyModel == null) {
            return null;
        }
        
        TwoDBlackImage image = historyModel.getTwoDBlackImage();
        getSession().setReadOnly(image, true);
        getSession().setReadOnly(image.getImageData(), true);
        getSession().setReadOnly(image.getUncertaintyData(), true);
        return image;
    }

    public Pointing retrievePointing(double mjd, History history) {
        Query q = getSession().createQuery(
                "from Pointing p where p.mjd <= :mjd "
                        + " and p.history = :history " + "order by p.mjd desc");
        q.setParameter("mjd", mjd);
        q.setEntity("history", history);

        q.setMaxResults(1);
        Pointing pointing = uniqueResult(q);
        return pointing;
    }

    public Pointing retrievePointingExact(double mjd, History history) {
        
        List<PointingHistoryModel> historyModels = retrievePointingHistoryModels(history);
        Collections.sort(historyModels);
        
        Pointing result = null;
        for (PointingHistoryModel historyModel : historyModels) {
            double loopTime = historyModel.getPointing().getMjd();
            if (loopTime == mjd) {
                result = historyModel.getPointing();
            }
        }
        return result;
    }

    /**
     * Get all pointings
     * 
     * @param history
     * @return
     */
    public List<Pointing> retrievePointing(History history) {
        // Get PointingHistoryModels associated with 'history':
        //
        List<PointingHistoryModel> historyModels = retrievePointingHistoryModels(history);
        Collections.sort(historyModels);

        List<Pointing> pointings = new ArrayList<Pointing>();

        for (PointingHistoryModel historyModel : historyModels) {
            pointings.add(historyModel.getPointing());
        }

        return pointings;
    }

    public Pointing retrieveNextPointing(double mjd, History history) {
        Query q = getSession().createQuery(
                "from Pointing p where p.mjd > :mjd and "
                        + "p.history = :history " + "order by p.mjd asc");
        q.setParameter("mjd", mjd);
        q.setEntity("history", history);

        q.setMaxResults(1);
        Pointing pointing = uniqueResult(q);
        return pointing;
    }

    public double retrievePointingRa(double mjd, History history) {
        Query q = getSession().createQuery(
                "select ra from Pointing p where p.mjd <= :mjd and "
                        + "p.history = :history " + "order by p.mjd desc");
        q.setParameter("mjd", mjd);
        q.setEntity("history", history);

        q.setMaxResults(1);
        Double ra = uniqueResult(q);
        return ra;
    }

    public double retrievePointingDec(double mjd, History history) {
        Query q = getSession().createQuery(
                "select declination from Pointing p where p.mjd <= :mjd and "
                        + "p.history = :history " + "order by p.mjd desc");
        q.setParameter("mjd", mjd);
        q.setEntity("history", history);

        q.setMaxResults(1);
        Double dec = uniqueResult(q);
        return dec;
    }

    public double retrievePointingRoll(double mjd, History history) {
        Query q = getSession().createQuery(
                "select roll from Pointing p where p.mjd <= :mjd "
                        + "and p.history = :history " + "order by p.mjd desc");
        q.setParameter("mjd", mjd);
        q.setParameter("history", history);

        q.setMaxResults(1);
        Double roll = uniqueResult(q);
        return roll;
    }

    public Pointing[] retrievePointings(double[] mjds, History history) {
        Pointing[] pointings = new Pointing[mjds.length + 1];

        for (int ii = 0; ii < mjds.length; ii++) {
            pointings[ii] = retrievePointing(mjds[ii], history);
        }

        // Bracket the pointings for interpolation:
        //
        pointings[mjds.length] = retrieveNextPointing(mjds[mjds.length - 1],
                history);

        return pointings;
    }

    public Pointing[] retrieveUniquePointings(double[] mjds, History history) {
        Pointing[] pointings = retrievePointings(mjds, history);
        List<Pointing> uniquePointings = new ArrayList<Pointing>();

        for (int ii = 0; ii < pointings.length; ++ii) {
            Pointing pointing = pointings[ii];
            int lastUniqueIndex = uniquePointings.size() - 1;

            boolean isUniquePointing = (ii == 0)
                    || !pointing.equals(uniquePointings.get(lastUniqueIndex));

            if (isUniquePointing) {
                uniquePointings.add(pointing);
            }
        }

        Pointing[] uniquePointingsArray = new Pointing[uniquePointings.size()];
        for (int ii = 0; ii < uniquePointings.size(); ++ii) {
            uniquePointingsArray[ii] = uniquePointings.get(ii);
        }

        return uniquePointingsArray;
    }

    public double[][] retrievePointingsArray(double[] mjds, History history) {
        double[][] output = new double[3][mjds.length];

        Pointing[] pointings = retrievePointings(mjds, history);

        for (int ii = 0; ii < pointings.length; ii++) {
            output[0][ii] = pointings[ii].getRa();
            output[1][ii] = pointings[ii].getDeclination();
            output[2][ii] = pointings[ii].getRoll();
        }

        return output;
    }

    public double[] retrievePointingRasArray(double[] mjds, History history) {
        double[] ras = new double[mjds.length];
        for (int ii = 0; ii < mjds.length; ii++) {
            ras[ii] = retrievePointingRa(mjds[ii], history);
        }
        return ras;
    }

    public double[] retrievePointingDecsArray(double[] mjds, History history) {
        double[] decs = new double[mjds.length];
        for (int ii = 0; ii < mjds.length; ii++) {
            decs[ii] = retrievePointingDec(mjds[ii], history);
        }
        return decs;
    }

    public double[] retrievePointingRollsArray(double[] mjds, History history) {
        double[] rolls = new double[mjds.length];
        for (int ii = 0; ii < mjds.length; ii++) {
            rolls[ii] = retrievePointingRoll(mjds[ii], history);
        }
        return rolls;
    }

    public List<Pointing> retrievePointingsBetween(double mjdStart,
            double mjdEnd, History history) {

        // Get PointingHistoryModels associated with 'history':
        //
        Query queryHistoryModels = getSession().createQuery(
                "from PointingHistoryModel hm where hm.history = :history");
        queryHistoryModels.setEntity("history", history);
        List<PointingHistoryModel> historyModels = list(queryHistoryModels);
        Collections.sort(historyModels);

        List<Pointing> pointings = new ArrayList<Pointing>();

//        for (PointingHistoryModel historyModel : historyModels) {
//            pointings.add(historyModel.getPointing());
//        }

        // Get pointings that occurred between mjdStart and mjdEnd, as well as
        // braketting Pointings, if they exist:
        Pointing prev = null;
        Pointing next = null;
        for (PointingHistoryModel historyModel : historyModels) {
            Pointing current = historyModel.getPointing();
            
            if (current.getMjd() < mjdStart) {
                prev = current;
            } else if (current.getMjd() > mjdEnd) {
                if (next == null) {
                    next = current;
                }
            } else {
                pointings.add(current);
            }
        }
        
        if (prev != null) {
            pointings.add(0, prev);
        }
        if (next != null) {
            pointings.add(next);
        }

        return pointings;
    }

    /**
     * Retrieve the latest roll time less than or equal to the specified mjd.
     * @param mjd
     * @param history
     * @return
     */
    public RollTime retrieveRollTime(double mjd, History history) {
        List<RollTimeHistoryModel> historyModels = retrieveRollTimeHistoryModels(history);
        Collections.sort(historyModels);

        RollTime rollTime = historyModels.get(0).getRollTime();
        for (RollTimeHistoryModel historyModel : historyModels) {
            if (historyModel.getRollTime().getMjd() <= mjd) {
                rollTime = historyModel.getRollTime();
            }
        }

        return rollTime;
    }
    
    public List<RollTime> retrieveRollTimeBetween(double mjdStart, double mjdEnd, History history) {
        List<RollTimeHistoryModel> historyModels = retrieveRollTimeHistoryModels(history);
        Collections.sort(historyModels);
        
        List<RollTime> rollTimes = new ArrayList<RollTime>();
        
        RollTime prev = null;
        RollTime next = null;
        for (RollTimeHistoryModel historyModel : historyModels) {
            RollTime current = historyModel.getRollTime();
            
            if (current.getMjd() < mjdStart) {
                prev = current;
            } else if (current.getMjd() > mjdEnd) {
                if (next == null) {
                    next = current;
                }
            } else {
                rollTimes.add(current);
            }
        }
        
        if (prev != null) {
            rollTimes.add(0, prev);
        }
        if (next != null) {
            rollTimes.add(next);
        }
        
        return rollTimes;        
    }
    

    public RollTime retrieveRollTimeExact(double mjd, History history) {
        List<RollTimeHistoryModel> historyModels = retrieveRollTimeHistoryModels(history);
        Collections.sort(historyModels);

        RollTime result = null;
        for (RollTimeHistoryModel historyModel : historyModels) {
            if (historyModel.getRollTime().getMjd() == mjd) {
                result = historyModel.getRollTime();
            }
        }
        return result;
    }

    public List<RollTime> retrieveAllRollTimes(History history) {
        List<RollTime> rollTimes = new ArrayList<RollTime>();
        List<RollTimeHistoryModel> historyModels = retrieveRollTimeHistoryModels(history);
        Collections.sort(historyModels);

        for (RollTimeHistoryModel historyModel : historyModels) {
            rollTimes.add(historyModel.getRollTime());
        }
        return rollTimes;
    }

    public List<Undershoot> retrieveUndershoots(int ccdModule, int ccdOutput,
            double mjdStart, double mjdEnd, History history) {

        // Get UndershootHistoryModels associated with 'history':
        List<UndershootHistoryModel> historyModels = retrieveUndershootHistoryModels(history);
        Collections.sort(historyModels);

        List<Undershoot> undershoots = new ArrayList<Undershoot>();

        for (UndershootHistoryModel historyModel : historyModels) {
            Undershoot undershoot = historyModel.getUndershoot();
            boolean isRightOutput = undershoot.getCcdModule() == ccdModule
                    && undershoot.getCcdOutput() == ccdOutput;
            if (isRightOutput) {
                undershoots.add(undershoot);
            }
        }

        Undershoot prev = null;
        Undershoot next = null;
        for (UndershootHistoryModel historyModel : historyModels) {
            Undershoot current = historyModel.getUndershoot();
            
            if (current.getStartMjd() < mjdStart) {
                prev = current;
            } else if (current.getStartMjd() > mjdEnd) {
                if (next == null) {
                    next = current;
                }
            } else {
                undershoots.add(current);
            }
        }
        
        if (prev != null) {
            undershoots.add(0, prev);
        }
        if (next != null) {
            undershoots.add(next);
        }
        
        return undershoots;
    }

    public int getUndershootCount(int ccdModule, int ccdOutput,
            double startTime, double endTime, History history) {
        return retrieveUndershoots(ccdModule, ccdOutput, startTime, endTime,
                history).size();
    }

    public Undershoot retrieveUndershoot(int ccdModule, int ccdOutput,
            double startMjd, History history) {

        Query q = getSession()
                .createQuery(
                        "from Undershoot u where u.ccdModule = :ccdModule "
                                + " and u.ccdOutput = :ccdOutput and u.startMjd <= :startMjd "
                                + " and u.history = :history order by u.startMjd desc");

        q.setParameter("startMjd", startMjd);
        q.setParameter("ccdModule", ccdModule);
        q.setParameter("ccdOutput", ccdOutput);
        q.setEntity("history", history);
        q.setMaxResults(1);

        return uniqueResult(q);
    }

    public Undershoot retrieveUndershootExact(Undershoot undershoot, History history) {

        List<UndershootHistoryModel> historyModels = retrieveUndershootHistoryModels(history);
        Collections.sort(historyModels);
        Undershoot result = null;
        
        for (UndershootHistoryModel historyModel : historyModels) {
            Undershoot loop = historyModel.getUndershoot();
            boolean isMatch = loop.getCcdModule() == undershoot.getCcdModule() &&
                              loop.getCcdOutput() == undershoot.getCcdOutput() &&
                              loop.getStartMjd()  == undershoot.getStartMjd();
            if (isMatch) {
                result = loop;
            }
        }
        
        return result;
    }

    public List<Undershoot> retrieveUndershoots(int ccdModule, int ccdOutput,
            History history) {

        List<UndershootHistoryModel> historyModels = retrieveUndershootHistoryModels(history);
        Collections.sort(historyModels);

        List<Undershoot> undershoots = new ArrayList<Undershoot>();
        for (UndershootHistoryModel historyModel : historyModels) {
            Undershoot undershoot = historyModel.getUndershoot();
            if (undershoot.getCcdModule() == ccdModule
                    && undershoot.getCcdOutput() == ccdOutput) {
                undershoots.add(undershoot);
            }
        }

        return undershoots;
    }

    public int getUndershootCount(int ccdModule, int ccdOutput, History history) {
        return retrieveUndershoots(ccdModule, ccdOutput, history).size();
    }

    public List<Undershoot> retrieveAllUndershoots() {
        Query q = getSession().createQuery(
                "from Undershoot u order by u.mjd asc");

        List<Undershoot> undershoots = list(q);

        return undershoots;
    }
    
    public Prf retrievePrf(int ccdModule, int ccdOutput) {
        double now = ModifiedJulianDate.dateToMjd(new Date());
        return retrievePrf(now, ccdModule, ccdOutput); 
    }

    public Prf retrievePrf(double mjd, int ccdModule, int ccdOutput) {
        History history = retrieveHistory(HistoryModelName.PRF);
        
        Query query = getSession().createQuery(
                "from PrfHistoryModel hm where " 
                + "hm.history = :history and "
                + "hm.ccdModule = :ccdModule and "
                + "hm.ccdOutput = :ccdOutput");
        query.setEntity("history", history);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);

        query.setMaxResults(1);
        PrfHistoryModel hm = uniqueResult(query);
        
        if (hm == null) {
            return null;
        }
        return hm.getPrf();
    }

    public Prf retrievePrfExact(int ccdModule, int ccdOutput) {
        Query query = getSession().createQuery(
                "from Prf where " + "ccdModule = :ccdModule and "
                        + "ccdOutput = :ccdOutput");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);

        Prf prf = uniqueResult(query);
        getSession().evict(prf);

        return prf;
    }

    public History retrieveHistory(String modelType, double ingestTime) {
        Query query = getSession().createQuery(
                "from History h where " + "h.modelType = :modelType and "
                        + "h.ingestTime <= :ingestTime "
                        + "order by h.ingestTime desc");
        query.setParameter("modelType", modelType);
        query.setParameter("ingestTime", ingestTime);
        query.setMaxResults(1);

        History history = uniqueResult(query);
        return history;
    }

    /**
     * Default retrieveHistory-- return the currently valid model (i.e., the
     * model with the most recent ingestTime).
     * 
     * @param modelType
     * @return
     */
    public History retrieveHistory(HistoryModelName modelType) {
        Query query = getSession()
                .createQuery(
                        "from History h where "
                                + "h.modelType = :modelType order by h.ingestTime desc");
        query.setParameter("modelType", modelType);
        query.setMaxResults(1);

        History history = uniqueResult(query);
        return history;
    }
    
    public boolean exists(HistoryModelName modelType) {
        
        History history = retrieveHistory(modelType);
        return history != null;
    }

    public List<GainHistoryModel> retrieveGainHistoryModels(History history) {
        Query query = getSession().createQuery(
                "from GainHistoryModel hm where " + "hm.history = :history");
        query.setEntity("history", history);

        List<GainHistoryModel> gainHistoryModels = list(query);
        return gainHistoryModels;
    }

    public List<PrfHistoryModel> retrievePrfHistoryModels(History history) {
        Query query = getSession().createQuery(
                "from PrfHistoryModel hm where " + 
                "hm.history = :history");
        query.setEntity("history", history);

        List<PrfHistoryModel> prfHistoryModels = list(query);
        return prfHistoryModels;
    }
    
    public List<PrfHistoryModel> retrievePrfHistoryModels(History history, double mjd, int ccdModule, int ccdOutput) {
        Query query = getSession().createQuery(
                "from PrfHistoryModel hm where " + 
                "hm.history = :history and " +
                "hm.mjd <= :mjd and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        query.setParameter("mjd", mjd);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setEntity("history", history);

        List<PrfHistoryModel> prfHistoryModels = list(query);
        return prfHistoryModels;
    }
    
    public List<PrfHistoryModel> retrievePrfHistoryModels(History history, int ccdModule, int ccdOutput) {
        Query query = getSession().createQuery(
                "from PrfHistoryModel hm where " + 
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setEntity("history", history);

        List<PrfHistoryModel> prfHistoryModels = list(query);
        return prfHistoryModels;
    }


    public List<SmallFlatFieldImageHistoryModel> retrieveSmallFlatFieldImageHistoryModels(
            History history, int ccdModule, int ccdOutput) {
        Query query = getSession().createQuery(
                "from SmallFlatFieldImageHistoryModel hm where " +
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);

        List<SmallFlatFieldImageHistoryModel> historyModels = list(query);
        return historyModels;
    }
    

    public List<SmallFlatFieldImageHistoryModel> retrieveSmallFlatFieldImageHistoryModels(
            History history, double mjd, int ccdModule, int ccdOutput) {
        Query query = getSession().createQuery(
                "from SmallFlatFieldImageHistoryModel hm where " +
                "hm.mjd = :mjd and " +
                "hm.history = :history and " +
                "hm.ccdModule = :ccdModule and " +
                "hm.ccdOutput = :ccdOutput");
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("mjd", mjd);
        query.setParameter("ccdOutput", ccdOutput);
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);

        List<SmallFlatFieldImageHistoryModel> historyModels = list(query);
        return historyModels;
    }
    
    public List<SmallFlatFieldImageHistoryModel> retrieveSmallFlatFieldImageHistoryModels(
            History history) {
        Query query = getSession().createQuery(
                "from SmallFlatFieldImageHistoryModel hm where "
                        + "hm.history = :history");
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);

        List<SmallFlatFieldImageHistoryModel> historyModels = list(query);
        return historyModels;
    }

    public List<ReadNoiseHistoryModel> retrieveReadNoiseHistoryModels(
            History history) {
        Query query = getSession().createQuery(
                "from ReadNoiseHistoryModel hm where "
                        + "hm.history = :history");
        query.setEntity("history", history);

        List<ReadNoiseHistoryModel> readNoiseHistoryModels = list(query);
        return readNoiseHistoryModels;
    }

    public List<PixelHistoryModel> retrievePixelHistoryModels(History history) {
        Query query = getSession().createQuery(
                "from PixelHistoryModel hm where " + "hm.history = :history");
        query.setEntity("history", history);

        List<PixelHistoryModel> pixelHistoryModels = list(query);
        return pixelHistoryModels;
    }

    public List<UndershootHistoryModel> retrieveUndershootHistoryModels(
            History history) {
        Query query = getSession().createQuery(
                "from UndershootHistoryModel hm where "
                        + "hm.history = :history");
        query.setEntity("history", history);

        List<UndershootHistoryModel> undershootHistoryModels = list(query);
        return undershootHistoryModels;
    }

    public List<SaturationHistoryModel> retrieveSaturationHistoryModels(
        History history) {
        Query query = getSession().createQuery(
            "from SaturationHistoryModel hm where "
            + "hm.history = :history");
        query.setEntity("history", history);

        List<SaturationHistoryModel> saturationHistoryModels = list(query);
        return saturationHistoryModels;
    }
       
    public List<LargeFlatFieldHistoryModel> retrieveLargeFlatFieldHistoryModels(
            History history) {
        Query query = getSession().createQuery(
                "from LargeFlatFieldHistoryModel hm where "
                        + "hm.history = :history");
        query.setEntity("history", history);

        List<LargeFlatFieldHistoryModel> largeFlatFieldHistoryModels = list(query);
        return largeFlatFieldHistoryModels;
    }

    public List<PointingHistoryModel> retrievePointingHistoryModels(
            History history) {
        Query query = getSession()
                .createQuery(
                        "from PointingHistoryModel hm where "
                                + "hm.history = :history");
        query.setEntity("history", history);

        List<PointingHistoryModel> pointingHistoryModels = list(query);
        return pointingHistoryModels;
    }

    public List<RollTimeHistoryModel> retrieveRollTimeHistoryModels(
            History history) {
        Query query = getSession()
                .createQuery(
                        "from RollTimeHistoryModel hm where "
                                + "hm.history = :history");
        query.setEntity("history", history);

        List<RollTimeHistoryModel> rollTimeHistoryModels = list(query);
        return rollTimeHistoryModels;
    }

    public List<LinearityHistoryModel> retrieveLinearityHistoryModels(
            History history) {
        Query query = getSession().createQuery(
                "from LinearityHistoryModel hm where hm.history = :history");
        query.setEntity("history", history);

        List<LinearityHistoryModel> linearityHistoryModels = list(query);
        return linearityHistoryModels;
    }

    public List<TwoDBlackImageHistoryModel> retrieveTwoDBlackImageHistoryModels(
            History history) {
        Query query = getSession().createQuery(
                "from TwoDBlackImageHistoryModel hm where "
                        + "hm.history = :history");
        query.setEntity("history", history);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        List<TwoDBlackImageHistoryModel> twoDBlackImageHistoryModels = list(query);
        return twoDBlackImageHistoryModels;
    }
    
    public TwoDBlackImageHistoryModel retrieveTwoDBlackImageHistoryModel(
            History history, double mjd, int ccdModule, int ccdOutput) {

        Query query = getSession().createQuery(
                "from TwoDBlackImageHistoryModel hm where "
                        + "hm.mjd = :mjd and "
                        + "hm.history = :history and "
                        + "hm.ccdModule = :ccdModule and "
                        + "hm.ccdOutput = :ccdOutput");
        query.setEntity("history", history);
        query.setParameter("mjd", mjd);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setCacheable(false);
        query.setReadOnly(true);
        
        query.setMaxResults(1);
        TwoDBlackImageHistoryModel hm = uniqueResult(query);
        
        return hm;
    }
    
    public List<TwoDBlackImageHistoryModel> retrieveTwoDBlackImageHistoryModels(
            History history, int ccdModule, int ccdOutput) {
        Query query = getSession().createQuery(
                "from TwoDBlackImageHistoryModel hm where "
                        + "hm.history = :history and "
                        + "hm.ccdModule = :ccdModule and "
                        + "hm.ccdOutput = :ccdOutput");
        query.setEntity("history", history);
        query.setParameter("ccdModule", ccdModule);
        query.setParameter("ccdOutput", ccdOutput);
        query.setCacheable(false);
        query.setReadOnly(true);
        List<TwoDBlackImageHistoryModel> twoDBlackImageHistoryModels = list(query);
        return twoDBlackImageHistoryModels;
    }

    public List<GeometryHistoryModel> retrieveGeometryHistoryModels(History history) {
        Query query = getSession().createQuery(
                "from GeometryHistoryModel hm where hm.history = :history");
        query.setEntity("history", history);

        List<GeometryHistoryModel> geometryHistoryModels = list(query);
        return geometryHistoryModels;
    }

    /**
     * Retrieves all {@link History} elements that were ingested between the
     * given times, inclusive.
     * 
     * @param startTime
     *            the starting time.
     * @param endTime
     *            the ending time.
     * @return a non-{@code null} list of {@link History} elements sorted from
     *         newest to oldest.
     */
    public List<History> retrieveHistoryByIngestDate(Date startTime,
            Date endTime) {

        Criteria criteria = getSession().createCriteria(History.class);
        criteria.add(Restrictions.ge("ingestTime", ModifiedJulianDate
                .dateToMjd(startTime)));
        criteria.add(Restrictions.le("ingestTime", ModifiedJulianDate
                .dateToMjd(endTime)));
        criteria.addOrder(Order.desc("ingestTime"));
        List<History> history = list(criteria);

        return history;
    }

    /**
     * Retrieves all {@link History} elements that were ingested between the
     * given times, inclusive.
     * 
     * @param startTime the starting time.
     * @param endTime the ending time.
     * @param modelTypes filter by the given models.
     * @return a non-{@code null} list of {@link History} elements sorted from
     * newest to oldest.
     */
    public List<History> retrieveHistoryByIngestDate(Date startTime,
            Date endTime, Collection<HistoryModelName> modelTypes) {

        Criteria criteria = getSession().createCriteria(History.class);
        criteria.add(Restrictions.ge("ingestTime", ModifiedJulianDate
                .dateToMjd(startTime)));
        criteria.add(Restrictions.le("ingestTime", ModifiedJulianDate
                .dateToMjd(endTime)));
        if (modelTypes != null && modelTypes.size() > 0) {
            criteria.add(Restrictions.in("modelType", modelTypes));
        }
        criteria.addOrder(Order.desc("ingestTime"));
        List<History> history = list(criteria);

        return history;
    }
    
    /**
     * Retrieves all {@link History} elements that where active between 
     * the start and end times.  If history element 1 had an ingest time of
     * 1.0 and history element 2 had an ingest time of 3.0 and the query terms
     * where 1.5 to 3.5 then you would get back both history elements.
     * 
     * @param startTime the starting time.
     * @param endTime the ending time.
     * @return a non-{@code null} list of {@link History} elements sorted from
     *         newest to oldest.
     */
    public List<History> retrieveActiveHistory(Date startTime, Date endTime) {
        double startMjd = ModifiedJulianDate.dateToMjd(startTime);
        double endMjd = ModifiedJulianDate.dateToMjd(endTime);
        
        if (startMjd > endMjd) {
            throw new IllegalArgumentException("Start time occurs after end time.");
        }
        
        String queryString = 
            "from History h1 where h1.ingestTime <= :endMjd and not exists \n " +
            "  (from History h2 where h2.ingestTime <= :startMjd and \n" +
            "   h2.ingestTime > h1.ingestTime and \n" +
            "   h2.modelType = h1.modelType)) \n" +
            " order by h1.ingestTime, h1.modelType";
        Query q = getSession().createQuery(queryString);
        q.setDouble("endMjd", endMjd);
        q.setDouble("startMjd", startMjd);
        
        List<History> histories = list(q);
        return histories;
    }
}
