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

import gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel;

/**
 * This class contains the limb darkening model.
 * 
 * @author Miles Cote
 * 
 */
public class SbtLimbDarkeningModel implements SbtDataContainer {

    private String modelName = "";
    private float coefficient1 = Float.NaN;
    private float coefficient2 = Float.NaN;
    private float coefficient3 = Float.NaN;
    private float coefficient4 = Float.NaN;

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("modelName", new SbtString(
            modelName).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("coefficient1",
            new SbtNumber(coefficient1).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("coefficient2",
            new SbtNumber(coefficient2).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("coefficient3",
            new SbtNumber(coefficient3).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("coefficient4",
            new SbtNumber(coefficient4).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtLimbDarkeningModel(DvLimbDarkeningModel dvLimbDarkeningModel) {
        modelName = dvLimbDarkeningModel.getModelName();
        coefficient1 = dvLimbDarkeningModel.getCoefficient1();
        coefficient2 = dvLimbDarkeningModel.getCoefficient2();
        coefficient3 = dvLimbDarkeningModel.getCoefficient3();
        coefficient4 = dvLimbDarkeningModel.getCoefficient4();
    }

    public SbtLimbDarkeningModel() {
    }

    public SbtLimbDarkeningModel(String modelName, float coefficient1,
        float coefficient2, float coefficient3, float coefficient4) {
        this.modelName = modelName;
        this.coefficient1 = coefficient1;
        this.coefficient2 = coefficient2;
        this.coefficient3 = coefficient3;
        this.coefficient4 = coefficient4;
    }

    public String getModelName() {
        return modelName;
    }

    public void setModelName(String modelName) {
        this.modelName = modelName;
    }

    public float getCoefficient1() {
        return coefficient1;
    }

    public void setCoefficient1(float coefficient1) {
        this.coefficient1 = coefficient1;
    }

    public float getCoefficient2() {
        return coefficient2;
    }

    public void setCoefficient2(float coefficient2) {
        this.coefficient2 = coefficient2;
    }

    public float getCoefficient3() {
        return coefficient3;
    }

    public void setCoefficient3(float coefficient3) {
        this.coefficient3 = coefficient3;
    }

    public float getCoefficient4() {
        return coefficient4;
    }

    public void setCoefficient4(float coefficient4) {
        this.coefficient4 = coefficient4;
    }

}
