#!/usr/bin/python
# 
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
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


import sys, getopt, re, io, time, os, subprocess, pdb

from time import gmtime, strftime, localtime, time, sleep


################################################################################
# SCRIPT NAME: build_nas_code.py 
#
# PURPOSE: Configures and builds code on NAS for running pipeline processes. 
#          Updates NAS code to use current software version number.          
#          Checks for and obtains available matlab licenses.
#          Build NAS code.
#
# USAGE: build_nas_code.py -c [cluster_abbreviation] -u [agency_id] -v [software_version_number] -h 
#
# RUNS ON: host
#
# Author: Jean-Pierre Harrison jean-pierre.harrison@nasa.gov
#
################################################################################


# START set parameters
#

p_clusterAbbr = None

p_agencyID = None

p_softwareVersionNumber = None

#
# END set parameters


# START set constants
#
LOGS_DIR_PATH = "/u/jharri27/scripts/logs/"

LOG_FILE_NAME = "build_nas_code."

UPDATE_NAS_CODE = "/u/jharri27/scripts/build_scripts/update_nas_code.py"

CHECK_MATLAB_LICENSES = "/u/jharri27/scripts/build_scripts/check_matlab_licenses.sh"

SUBMIT_BUILD = "/u/jharri27/scripts/build_scripts/submit_build.sh"

SLEEP_PERIOD = 960

SUCCESS = 0

FAIL = 1
#
# END set constants


# START declare global variables
# Used in main routine. May be passed as parameter to a function.
#
g_log_file_name = None

g_file_handle = None

g_output = ''

g_error = ''

g_matlabLicenseOutputList = []

g_matlabLicenseOutputListLength = 0 

g_compilerRegExp = None

g_statisticsToolboxRegExp = None

g_regExpMatch = None


g_compilerLicensesIssued = None

g_compilerLicensesInUse = None 

g_statisticsToolboxLicensesIssued = None
 
g_statisticsToolboxLicensesInUse = None


g_time = None

g_is_submit_build = False

g_string = None


i = 0

#
# END declare global variables



################################################################################
# PURPOSE:    Prints message and terminates script with FAIL value.
# PARAMETERS: p_string: Message to print.
# RETURNS:    Nothing.

def print_message_and_exit_script(p_string):

   print p_string

   sys.exit(FAIL)

# END def print_message_and_exit_script(p_string)
################################################################################



################################################################################
# PURPOSE:    Writes string to output file.
# PARAMETERS: p_file_handle: Handle to open output file.
# RETURNS:    Nothing.

def write_and_close_file(p_file_handle, p_string):


   p_file_handle.write(p_string)

   p_file_handle.close()

# END def write_and_close_file(p_file_handle, p_string)
################################################################################



################################################################################
def deleteEmptyLastListElement(p_list):

  while (len(p_list) > 0) \
        and \
        (len(p_list[-1]) == 0):

   p_list.pop()


   return(p_list)

# END def deleteEmptyLastListElement(p_list)
################################################################################



################################################################################
def convertStringToList(p_string):

   l_list = p_string.split("\n")

   l_list = deleteEmptyLastListElement(l_list)


   return(l_list)

# END def convertStringToList(p_string)
################################################################################



################################################################################
# START main


g_log_file_name = LOG_FILE_NAME + str(time()) + ".log"

g_log_file_full_path = LOGS_DIR_PATH + g_log_file_name


g_file_handle = open(g_log_file_full_path, 'w')


try:

   g_optionsList, g_argumentsList = \
   getopt.getopt(sys.argv[1:],"c:hu:v:")

except getopt.GetoptError:

   g_string = \
   'Unknown option: ' + str(sys.argv[0:]) + "\n" + \
   sys.argv[0] + " terminated on error.\n\n"

   write_and_close_file(g_file_handle, g_string)

   print_message_and_exit_script(g_string)


for g_option, g_argument in g_optionsList:

   if g_option == '-c':

      p_clusterAbbr = g_argument

      g_file_handle.write(p_clusterAbbr + "\n\n")  

   elif g_option == '-h':

      g_string =    \
      sys.argv[0] + \
      " -c [cluster_abbreviation] -u [agency_id] -v [software_version_number] -h\n\n"

      print g_string

      sys.exit(SUCCESS)

   elif g_option == '-u':

      p_agencyID = g_argument

   elif g_option == '-v':

      p_softwareVersionNumber = g_argument


if not p_clusterAbbr:

   g_string = "Cluster abbreviation [AMC|LAB|SPM|SPQ] is required.\n" + \
              sys.argv[0] + " terminated on error.\n\n"

   write_and_close_file(g_file_handle, g_string)

   print_message_and_exit_script(g_string)


if not p_agencyID:

   g_string = "Agency ID is required.\n" + \
              sys.argv[0] + " terminated on error.\n\n"

   write_and_close_file(g_file_handle, g_string)

   print_message_and_exit_script(g_string)


if not p_softwareVersionNumber:

   g_string = "Software version number is required.\n" + \
              sys.argv[0] + " terminated on error.\n\n"

   write_and_close_file(g_file_handle, g_string)

   print_message_and_exit_script(g_string)


(g_output, g_error) = \
subprocess.Popen([UPDATE_NAS_CODE, '-c', p_clusterAbbr, '-u', p_agencyID, '-v', p_softwareVersionNumber], stdout=subprocess.PIPE).communicate()


if g_output:

   g_string = g_output + "\n\n"

   g_file_handle.write(g_string)

   print(g_string)


if g_error:

   g_string = g_error + "\n" + \
              sys.argv[0] + " terminated on ERROR.\n\n"

   write_and_close_file(g_file_handle, g_string)

   print_message_and_exit_script(g_string)


g_is_submit_build = False

while (g_is_submit_build == False):

   (g_output, g_error) = \
   subprocess.Popen([CHECK_MATLAB_LICENSES],stdout=subprocess.PIPE).communicate()

   if g_error:

      g_string = g_error + "\n" + \
                 sys.argv[0] + " terminated on ERROR.\n\n"

      write_and_close_file(g_file_handle, g_string)
 
      print_message_and_exit_script(g_string)


   g_matlabLicenseOutputList = convertStringToList(g_output)

   g_matlabLicenseOutputListLength = len(g_matlabLicenseOutputList)

   g_compilerRegExp = \
   "\s*Compiler\s*\:\s*\(\s*(\d+)\s*licenses\s*issued\;\s*(\d+)\s*licenses\s*in\s*use\)\s*"

   g_statisticsToolboxRegExp = \
   "\s*Users\s*of\s*Statistics_Toolbox\:\s*\(Total\s*of\s*(\d+)\s*licenses\s*issued\;\s*Total\s*of\s*(\d+)\s*licenses\s*in\s*use\)\s*"


   i = 0

   while i < g_matlabLicenseOutputListLength:

      g_regExpMatch = re.search(g_compilerRegExp, g_matlabLicenseOutputList[i])

      if g_regExpMatch:

         g_compilerLicensesIssued = g_regExpMatch.group(1)

         g_compilerLicensesInUse = g_regExpMatch.group(2)


      g_regExpMatch = re.search(g_statisticsToolboxRegExp, g_matlabLicenseOutputList[i])

      if g_regExpMatch:

         g_statisticsToolboxLicensesIssued = g_regExpMatch.group(1)

         g_statisticsToolboxLicensesInUse = g_regExpMatch.group(2)   

         i = g_matlabLicenseOutputListLength


      i = i + 1



   g_string = 'Compiler licenses issued: [' + g_compilerLicensesIssued + \
              '] : Compiler licenses in use: [' + g_compilerLicensesInUse + "]\n"

   g_file_handle.write(g_string)

   print(g_string)


   g_string = 'Toolbox statistics licenses issued: [' + g_statisticsToolboxLicensesIssued + \
              '] : Toolbox statistics licenses in use: [' + g_statisticsToolboxLicensesInUse + "]\n\n"

   g_file_handle.write(g_string)

   print(g_string)


   if (int(g_compilerLicensesInUse) > 0) \
       or \
      (int(g_statisticsToolboxLicensesInUse > 2)):

      g_time = strftime("%a, %d %b %Y %H:%M:%S", localtime())

      g_string = "Matlab compiler licenses and/or toolbox statistics licenses not available.\n" + \
                 sys.argv[0] + ' started [' + str(SLEEP_PERIOD) + \
                 '] seconds sleep at [' + str(g_time) + "].\n\n"

      g_file_handle.write(g_string)

      print(g_string)

      sleep(SLEEP_PERIOD)

   else:

      g_is_submit_build = True


g_time = strftime("%a, %d %b %Y %H:%M:%S", localtime())

g_string = 'NAS build submitted at [' + str(g_time) + "].\n\n"

write_and_close_file(g_file_handle, g_string)

print(g_string)


(g_output, g_error) = \
subprocess.Popen([SUBMIT_BUILD, p_clusterAbbr],stdout=subprocess.PIPE).communicate()

if g_error:

   g_string = g_error + "\n" + \
              sys.argv[0] + " terminated on ERROR.\n\n"  

   g_file_handle.write(g_string)

   print_message_and_exit_script(g_string)

   
g_string = sys.argv[0] + " terminated on SUCCESS.\n\n"

g_file_handle.write(g_string)

g_file_handle.close()

print g_string


sys.exit(SUCCESS)


# END main
################################################################################


