
# Name of the pipeline module
# Used as the name of the shared library (NAME.so)
# and as the name of the executable (NAME)
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# NASA acknowledges the SETI Institute's primary role in authoring and
# producing the Kepler Data Processing Pipeline under Cooperative
# Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
# NNX11AI14A, NNX13AD01A & NNX13AD16A.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
# 
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#
NAME=etem2

# Relative path to the matlab directory
SOC_CODE_MATLAB_REL_PATH=../..

-include $(SOC_CODE_MATLAB_REL_PATH)/build/macros.mk

# Specify your .m files here. 
# Not all .m files used by your module need to be specified here
# the MATLAB compiler is pretty good about auto-detecting dependencies,
# so usually just specifying your entry point is good enough.  It does miss
# a few though (like calling a function dynamically using eval()), so in those
# cases just add them to the list here.
MSRC=\
	etem2_matlab_controller.m \
	etem2.m \
	set_etem2_locations.m \
	ETEM2_inputs_ORT1_offset.m \
	ETEM2_inputs_TC01.m \
	ETEM2_inputs_TC02.m \
	ETEM2_inputs_TC05.m \
	ETEM2_inputs_TC06.m \
	ETEM2_inputs_cal_test.m \
	ETEM2_inputs_compression_3_12_09.m \
	ETEM2_inputs_debug.m \
	ETEM2_inputs_dv.m \
	ETEM2_inputs_example.m \
	ETEM2_inputs_ffi_only.m \
	ETEM2_inputs_pdq.m \
	ETEM2_inputs_pdq_offset_dec.m \
	ETEM2_inputs_pdq_offset_phi.m \
	ETEM2_inputs_pdq_offset_ra.m \
	ETEM2_inputs_pdq_test.m \
	ETEM2_inputs_rg_sc.m \
	ETEM2_inputs_systest.m \
	defined_plugin_classes.m \
	user_utilities/get_pixel_numbers.m \
	user_utilities/get_short_cadence_pixel_numbers.m \
	user_utilities/get_target_definitions.m \
	utilities/InverseOvercompleteWaveletTransform.m \
	utilities/generate_vignetting_data.m \
	utilities/mkppcdf.m \
	utilities/bin_matrix.m \
	utilities/compute_small_light_curve.m \
	utilities/randp_tfu.m \
	utilities/ETEM2_svn_version.m \
	utilities/OvercompleteWaveletTransform.m \
	utilities/calcnoisesig.m \
	utilities/fake_zodi_model.m \
	utilities/ppcdfinv.m \
	utilities/evenextend.m \
	utilities/make_binned_design_matrix.m \
	utilities/daubh0.m \
	utilities/select_structure_vectors.m \
	utilities/gcrpdf.m \
	utilities/make_tad_input.m \
	utilities/consolidate_partitions.m \
	utilities/zpad.m \
	utilities/quick_centroid.m \
	utilities/detrendcols.m \
	utilities/compute_light_curve.m \
	utilities/fake_requant_table.m \
	general_classes/check_runParamsObject_inputs.m

MCCARCHIVEFILES=\
	configuration_files/optimizedMaskDefinitions.mat \
	configuration_files/maskDefinitions.mat \
	configuration_files/gcmshapes_03_16_2005.mat \
	configuration_files/requantizationTable.mat \
	configuration_files/jitter06a_perf_befDesat_0p5sec144hr.mat \
	configuration_files/solnew.mat \
	configuration_files/atlasNonlinearLimbDarkeningData.mat \
	configuration_files/keplerInitialOrbit.mat \
	configuration_files/vignettingData.mat \
	configuration_files/Besancon_Catalog.mat \
	psf_files/psf_focus_4_z1f1.mat \
	radec2pix_classes/@noRaDec2PixClass/ \
	radec2pix_classes/@oldRaDec2PixClass/ \
	radec2pix_classes/@productionRaDec2PixClass/ \
	flat_field_component_classes/@etemFlatFieldClass \
	flat_field_component_classes/@interPixelVariabilityClass \
	flat_field_component_classes/@vignettingClass \
	pixel_noise_classes/@constantReadNoiseClass \
	pixel_noise_classes/@etemReadNoiseClass \
	pixel_noise_classes/@shotNoiseClass \
	psf_classes/@modelPsfClass \
	psf_classes/@psfFromPrfClass \
	psf_classes/@specificPsfClass \
	psf_classes/@psfByModOutClass \
	catalog_classes/@etem1CatalogReaderClass \
	catalog_classes/@fakeGridCatalogClass \
	catalog_classes/@targetOnlyCatalogClass \
	catalog_classes/@modifyCatalogClass \
	catalog_classes/@kicCatalogReaderClass \
	tad_input_classes/@databaseTadClass \
	tad_input_classes/@tadFileReaderClass \
	tad_input_classes/@runTadClass \
	radec2pix_classes/@oldRaDec2PixClass \
	radec2pix_classes/@productionRaDec2PixClass \
	radec2pix_classes/@noRaDec2PixClass \
	pixel_effect_classes/@spatialWellDepthClass \
	pixel_effect_classes/@etemTwoDBlackTestClass \
	pixel_effect_classes/@cteClass \
	pixel_effect_classes/@nonlinearEtoAduClass \
	pixel_effect_classes/@etemTwoDBlackClass \
	pixel_effect_classes/@scalarBlackClass \
	pixel_effect_classes/@linearEtoAduClass \
	star_selector_classes/@randomStarSelectorClass \
	motion_classes/@jitterMotionClass \
	motion_classes/@jitterNoMotionClass \
	motion_classes/@dvaMotionClass \
	motion_classes/@pointingJitterMotionClass \
	motion_classes/@dvaNoMotionClass \
	additive_background_classes/@zodiacalLightClass \
	additive_background_classes/@scalarZodiLightClass \
	additive_background_classes/@darkCurrentClass \
	additive_background_classes/@stellarBackgroundClass \
	target_selector_classes/@selectTargetByPropertyClass \
	astrophysics_classes/@cosmicRayClass \
	astrophysics_classes/@targetScienceManagerClass \
	astrophysics_classes/lightcurve_classes/@transitingSystemClass \
	astrophysics_classes/lightcurve_classes/@transitingPlanetClass \
	astrophysics_classes/lightcurve_classes/@injectFileModulationClass \
	astrophysics_classes/lightcurve_classes/@testSineClass \
	astrophysics_classes/lightcurve_classes/@transitingStarClass \
	astrophysics_classes/lightcurve_classes/@sohoSolarVariabilityClass \
	astrophysics_classes/lightcurve_classes/@transitingOrbitClass \
	astrophysics_classes/stellar_properties_classes/@simpleStellarPropertiesClass \
	astrophysics_classes/stellar_properties_classes/@nonlinearLimbDarkeningClass \
	astrophysics_classes/@backgroundBinaryClass \
	astrophysics_classes/@barycentricTimeCorrectionClass \
	dynamic_noise_classes/@dynamicNoiseClass \
	dynamic_noise_classes/@dynamicBartNoiseClass \
	dynamic_noise_classes/@fgsCrosstalkClass \
	dynamic_noise_classes/@temperatureFunctionClass \
	dynamic_noise_classes/@rollingBandClass \
	general_classes/@ccdPlaneClass \
	general_classes/@longCadenceDataClass \
	general_classes/@shortCadenceDataClass \
	general_classes/@ccdDarkClass \
	general_classes/@runParamsClass \
	general_classes/@ccdClass \
	electronics_effect_classes/@etemUndershootClass



-include $(SOC_CODE_MATLAB_REL_PATH)/build/rules.mk
