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

package gov.nasa.kepler.pa;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * 
 * @author Forrest Girouard
 * 
 */
public class PaCoaModuleParameters implements Parameters, Persistable {

    private int cadenceStep;
    private boolean computeForSaturatedTargetsEnabled;
    private boolean cdppOptimizationEnabled;
    private double cdppVsSnrStrengthFactor;
    private int cdppSweepLength;
    private int cdppMedFiltSmoothLength;
    private float mnrAddedFluxBeta;
    private float mnrBeta0;
    private float mnrDiscriminationThreshold;
    private float mnrFractionalChangeInApertureBeta;
    private float mnrFractionalChangeInMedianFluxBeta;
    private float mnrMaskUsageRatioBeta;
    private int numberOfHalosToAddToAperture;
    private int raDecFittingCadenceStep;
    private boolean revertToTadIfApertureShrank;
    private double superResolutionFactor;
    private double trialTransitPulseDurationInHours;
    private boolean usePolyFitTransitModel;
    private double varianceWindowLengthMultiplier;
    private int waveletFilterLength;

    private float boundedBoxWidth;

    public float getBoundedBoxWidth() {
        return boundedBoxWidth;
    }

    public void setBoundedBoxWidth(float boundedBoxWidth) {
        this.boundedBoxWidth = boundedBoxWidth;
    }

    public int getCadenceStep() {
        return cadenceStep;
    }

    public void setCadenceStep(int cadenceStep) {
        this.cadenceStep = cadenceStep;
    }

    public boolean isComputeForSaturatedTargetsEnabled() {
        return computeForSaturatedTargetsEnabled;
    }

    public void setComputeForSaturatedTargetsEnabled(
        boolean computeForSaturatedTargetsEnabled) {
        this.computeForSaturatedTargetsEnabled = computeForSaturatedTargetsEnabled;
    }

    public boolean isCdppOptimizationEnabled() {
        return cdppOptimizationEnabled;
    }

    public void setCdppOptimizationEnabled(boolean cdppOptimizationEnabled) {
        this.cdppOptimizationEnabled = cdppOptimizationEnabled;
    }

    public double getCdppVsSnrStrengthFactor() {
        return cdppVsSnrStrengthFactor;
    }

    public void setCdppVsSnrStrengthFactor(double cdppVsSnrStrengthFactor) {
        this.cdppVsSnrStrengthFactor = cdppVsSnrStrengthFactor;
    }

    public int getCdppSweepLength() {
        return cdppSweepLength;
    }

    public void setCdppSweepLength(int cdppSweepLength) {
        this.cdppSweepLength = cdppSweepLength;
    }

    public int getCdppMedFiltSmoothLength() {
        return cdppMedFiltSmoothLength;
    }

    public void setCdppMedFiltSmoothLength(int cdppMedFiltSmoothLength) {
        this.cdppMedFiltSmoothLength = cdppMedFiltSmoothLength;
    }
    
    public float getMnrAddedFluxBeta() {
        return mnrAddedFluxBeta;
    }
    
    public void setMnrAddedFluxBeta(float mnrAddedFluxBeta) {
        this.mnrAddedFluxBeta = mnrAddedFluxBeta;
    }
    
    public float getMnrBeta0() {
        return mnrBeta0;
    }
    
    public void setMnrBeta0(float mnrBeta0) {
        this.mnrBeta0 = mnrBeta0;
    }
    
    public float getMnrDiscriminationThreshold() {
        return mnrDiscriminationThreshold;
    }
    
    public void setMnrDiscriminationThreshold(
        float mnrDiscriminationThreshold) {
        this.mnrDiscriminationThreshold = mnrDiscriminationThreshold;
    }
    
    public float getMnrFractionalChangeInApertureBeta() {
        return mnrFractionalChangeInApertureBeta;
    }
    
    public void setMnrFractionalChangeInApertureBeta(
        float mnrFractionalChangeInApertureBeta) {
        this.mnrFractionalChangeInApertureBeta =
            mnrFractionalChangeInApertureBeta;
    }
    
    public float getMnrFractionalChangeInMedianFluxBeta() {
        return mnrFractionalChangeInMedianFluxBeta;
    }
    
    public void setMnrFractionalChangeInMedianFluxBeta(
        float mnrFractionalChangeInMedianFluxBeta) {
        this.mnrFractionalChangeInMedianFluxBeta =
            mnrFractionalChangeInMedianFluxBeta;
    }
    
    public float getMnrMaskUsageRatioBeta() {
        return mnrMaskUsageRatioBeta;
    }
    
    public void setMnrMaskUsageRatioBeta(float mnrMaskUsageRatioBeta) {
        this.mnrMaskUsageRatioBeta = mnrMaskUsageRatioBeta;
    }
    
    public int getNumberOfHalosToAddToAperture() {
        return numberOfHalosToAddToAperture;
    }

    public void setNumberOfHalosToAddToAperture(int numberOfHalosToAddToAperture) {
        this.numberOfHalosToAddToAperture = numberOfHalosToAddToAperture;
    }

    public int getRaDecFittingCadenceStep() {
        return raDecFittingCadenceStep;
    }

    public void setRaDecFittingCadenceStep(int raDecFittingCadenceStep) {
        this.raDecFittingCadenceStep = raDecFittingCadenceStep;
    }
    
    public boolean isRevertToTadIfApertureShrank() {
        return revertToTadIfApertureShrank;
    }
    
    public void setRevertToTadIfApertureShrank(boolean revertToTadIfApertureShrank) {
        this.revertToTadIfApertureShrank = revertToTadIfApertureShrank;
    }

    public double getSuperResolutionFactor() {
        return superResolutionFactor;
    }

    public void setSuperResolutionFactor(double superResolutionFactor) {
        this.superResolutionFactor = superResolutionFactor;
    }

    public double getTrialTransitPulseDurationInHours() {
        return trialTransitPulseDurationInHours;
    }

    public void setTrialTransitPulseDurationInHours(
        double trialTransitPulseDurationInHours) {
        this.trialTransitPulseDurationInHours = trialTransitPulseDurationInHours;
    }

    public boolean isUsePolyFitTransitModel() {
        return usePolyFitTransitModel;
    }

    public void setUsePolyFitTransitModel(boolean usePolyFitTransitModel) {
        this.usePolyFitTransitModel = usePolyFitTransitModel;
    }

    public double getVarianceWindowLengthMultiplier() {
        return varianceWindowLengthMultiplier;
    }

    public void setVarianceWindowLengthMultiplier(
        double varianceWindowLengthMultiplier) {
        this.varianceWindowLengthMultiplier = varianceWindowLengthMultiplier;
    }

    public int getWaveletFilterLength() {
        return waveletFilterLength;
    }

    public void setWaveletFilterLength(int waveletFilterLength) {
        this.waveletFilterLength = waveletFilterLength;
    }

}
