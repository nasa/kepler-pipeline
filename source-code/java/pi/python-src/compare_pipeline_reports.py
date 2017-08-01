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


################################################################################
#
# PURPOSE: Compares contents of two files to find and display non-matching data.
#
# USAGE: compare_pipeline_reports.py input_file_path_1 input_file_path_2 
#        where input_file_1 and input_file_2 are *.txt or *.xml pipeline/trigger 
#        data files. 
#
# Author: Jean-Pierre Harrison jean-pierre.harrison@nasa.gov
#
################################################################################


import sys, re, lxml, io, pdb

from lxml import etree


# START set constants
#
PARAMETER_QUALIFIER = 'parameter_qualifier'

PARAMETER_SET = 'parameter_set'

PARAMETERS = 'parameters'

TYPE = 'type'

NAME = 'name'

VALUE = 'value'

VERSION = 'version'

LOCKED = 'locked'

CLASS_NAME = 'classname'


COMPARISON = 'comparison'

NON_MATCHING = 'non_matching'
#
# END set constants


# START store script parameters
#
p_input_file_path_1 = ''

p_input_file_path_2 = ''
#
# END store script parameters


# START declare global variables
#
g_txt_input_file_path = ''

g_xml_input_file_path = ''


g_file_handle = ''


g_file_name_suffix_regexp_txt = ''

g_file_name_suffix_regexp_xml = ''

g_parameter_set_regexp = ''

g_data_model_registry_regexp = ''

g_search_regexp = ''


g_regexp_match = ''

g_regexp_parameter_match = ''


g_hash_file_1 = {}

g_hash_file_2 = {}


g_file_contents_list_1 = []

g_file_contents_list_2 = []


g_xml_element_tree_1 = ''

g_xml_element_tree_2 = ''

g_xml_element_tree = ''


g_root_element_1 = ''

g_root_element_2 = ''


g_string = ''


g_first_level_non_matching_elements_list = []

g_second_level_non_matching_elements_list = []

g_parameter_non_matching_elements_list = []


g_boolean_flag = False


i = 0

j = 0
#
# END declare global variables


################################################################################
# PURPOSES:   Retrieves parameter data from text file.
# PARAMETERS: p_file_contents_list: Contents of text file.
# RETURNS:    Hash table containing associated parameter data referenced by root key.

def retrieveTxtParameterData(p_file_contents_list):
   
   l_regexp_match = ''

   l_hash_file = {}

   l_is_increment = False

   i = 0 
 
 
   while i < len(p_file_contents_list):
    
      l_is_increment = False

      l_regexp_match = \
      re.search("^\s*Parameter\s+Set:\s+(\w+)\s*(\(.+?\))?\s*\(type=(\w+)\,.*\)$", p_file_contents_list[i])

      if l_regexp_match:
   
         if (l_regexp_match.group(1) \
             and \
             l_regexp_match.group(2) \
             and \
             l_regexp_match.group(3)):

            l_hash_file[l_regexp_match.group(1)] = {}

            l_hash_file[l_regexp_match.group(1)][PARAMETER_QUALIFIER] = \
            l_regexp_match.group(2)[1:-1]

            l_hash_file[l_regexp_match.group(1)][TYPE] = \
            l_regexp_match.group(3)


         elif (l_regexp_match.group(1) \
               and \
               l_regexp_match.group(2) \
               and \
               (l_regexp_match.group(3) == None)):

            l_hash_file[l_regexp_match.group(1)] = {} 

            l_hash_file[l_regexp_match.group(1)][PARAMETER_QUALIFIER] = \
            l_regexp_match.group(2)[1:-1] 


         elif (l_regexp_match.group(1) \
               and \
               (l_regexp_match.group(2) == None) \
               and \
               l_regexp_match.group(3)):

            l_hash_file[l_regexp_match.group(1)] = {} 

            l_hash_file[l_regexp_match.group(1)][TYPE] = \
            l_regexp_match.group(3)


         elif (l_regexp_match.group(1) \
               and \
               (l_regexp_match.group(2) == None) \
               and \
               (l_regexp_match.group(3) == None)):

            l_hash_file[l_regexp_match.group(1)] = {}
         

         l_hash_file[l_regexp_match.group(1)][PARAMETER_SET] = {}

         i = i + 1 


         try:

            while g_parameter_set_regexp.match(p_file_contents_list[i]) == None \
                  and \
                  g_data_model_registry_regexp.match(p_file_contents_list[i]) == None:

               l_regexp_parameter_match = \
               re.search("^\s*(\w+)\s*\=\s*(.+?)\s*$", p_file_contents_list[i])         

               if l_regexp_parameter_match: 

                  if l_regexp_parameter_match.group(1) \
                     and \
                     l_regexp_parameter_match.group(2):
 
                     l_hash_file[l_regexp_match.group(1)][PARAMETER_SET][l_regexp_parameter_match.group(1)] = \
                     l_regexp_parameter_match.group(2)

               i = i + 1

               l_is_increment = True

         except IndexError: 

            i = i


      if l_is_increment == False: 

         i = i + 1

   return l_hash_file;


# end def retrieveTxtParameterData(p_file_contents_list)
################################################################################



################################################################################
# PURPOSE:    Compares first level hash parameters and returns list of those not 
#             appearing in both file parameters.
# PARAMETERS: p_hash_file_1: Contains associated parameter data referenced by root key.
#             p_hash_file_2: Contains associated parameter data referenced by root key.
#             p_input_file_path_1: Path to file containing data stored in p_hash_file_1.
#             p_input_file_path_2: Path to file containing data stored in p_hash_file_2.
# RETURNS:    List of first level hash parameters rnot appearing in both input files. 

def compareFirstLevelParameters(p_hash_file_1, p_hash_file_2, p_input_file_path_1, p_input_file_path_2):


   l_first_level_hash_keys_list_1 = \
   p_hash_file_1.keys()

   l_first_level_hash_keys_list_2 = \
   p_hash_file_2.keys()


   l_hash_keys_list_1 = []

   l_hash_keys_list_2 = []


   l_non_matching_elements_list = []


   l_length_list_1 = 0

   l_length_list_2 = 0


   l_is_found = False


   l_comparison_file = ''

   l_non_matching_file = ''


   l_string = ''


   i = 0

   j = 0


   if (len(l_first_level_hash_keys_list_1) <= len(l_first_level_hash_keys_list_2)):

      l_hash_keys_list_1 = \
      sorted(l_first_level_hash_keys_list_1)

      l_hash_keys_list_2 = \
      sorted(l_first_level_hash_keys_list_2)


      l_length_list_1 = len(l_hash_keys_list_1)

      l_length_list_2 = len(l_hash_keys_list_2)


      l_comparison_file = p_input_file_path_1

      l_non_matching_file = p_input_file_path_2


   elif (len(l_first_level_hash_keys_list_2) < len(l_first_level_hash_keys_list_1)):

      l_hash_keys_list_1 = \
      sorted(l_first_level_hash_keys_list_2)

      l_hash_keys_list_2 = \
      sorted(l_first_level_hash_keys_list_1)


      l_length_list_1 = len(l_hash_keys_list_2)

      l_length_list_2 = len(l_hash_keys_list_1)


      l_comparison_file = p_input_file_path_2

      l_non_matching_file = p_input_file_path_1



   for i in range(0, l_length_list_2):

      l_is_found = False

      j = 0

      while j < l_length_list_1:

         try:

            if l_hash_keys_list_1[j].upper() == \
               l_hash_keys_list_2[i].upper():

               l_is_found = True

               break 

         except IndexError:

            None

         j = j + 1


      if l_is_found == False:

         l_string = \
         str(l_hash_keys_list_2[i]) + \
         "\nFOUND IN FILE " + str(l_non_matching_file) + \
         "\nNOT FOUND IN FILE " + str(l_comparison_file)

         l_non_matching_elements_list.append(l_string)


   return l_non_matching_elements_list 


# end def compareFirstLevelParameters(p_hash_file_1, p_hash_file_2, p_input_file_path_1, p_input_file_path_2)
################################################################################



################################################################################
# PURPOSE:    Compares second level hash parameters and returns list of those not 
#             appearing in both input files.
# PARAMETERS: p_hash_file_1: Contains associated parameter data referenced by root key.
#             p_hash_file_2: Contains associated parameter data referenced by root key.
#             p_input_file_path_1: Path to file containing data stored in p_hash_file_1.
#             p_input_file_path_2: Path to file containing data stored in p_hash_file_2.
# RETURNS:    List of second level hash parameters not appearing in both input files.

def compareSecondLevelParameters(p_hash_file_1, p_hash_file_2, p_input_file_path_1, p_input_file_path_2):


   l_first_level_hash_keys_list_1 = []

   l_first_level_hash_keys_list_2 = []


   l_list_1 = []

   l_list_2 = []


   l_non_matching_elements_list = []


   l_length_list_1 = 0

   l_length_list_2 = 0


   l_parameter_qualifier_is_found = False

   l_parameter_set_is_found = False

   l_type_is_found = False


   l_comparison_file = ''

   l_non_matching_file = ''


   l_string = ''


   i = 0

   j = 0


   l_first_level_hash_keys_list_1 = \
   p_hash_file_1.keys()

   l_first_level_hash_keys_list_2 = \
   p_hash_file_2.keys()


   if (len(l_first_level_hash_keys_list_1) <= len(l_first_level_hash_keys_list_2)):

      l_hash_keys_list_1 = \
      sorted(l_first_level_hash_keys_list_1)

      l_hash_keys_list_2 = \
      sorted(l_first_level_hash_keys_list_2)


      l_length_list_1 = len(l_hash_keys_list_1)

      l_length_list_2 = len(l_hash_keys_list_2)


      l_comparison_file = p_input_file_path_1

      l_non_matching_file = p_input_file_path_2


   elif (len(l_first_level_hash_keys_list_2) < len(l_first_level_hash_keys_list_1)):

      l_hash_keys_list_1 = \
      sorted(l_first_level_hash_keys_list_2)

      l_hash_keys_list_2 = \
      sorted(l_first_level_hash_keys_list_1)


      l_length_list_1 = len(l_hash_keys_list_2)

      l_length_list_2 = len(l_hash_keys_list_1)


      l_comparison_file = p_input_file_path_2

      l_non_matching_file = p_input_file_path_1


   for i in range(0, l_length_list_2):

      l_parameter_qualifier_is_found = False

      l_type_is_found = False

      l_parameter_set_is_found = False

      for j in range(0, l_length_list_1):

         try:

            if ((l_parameter_qualifier_is_found == False) \
                and \
                ((l_hash_keys_list_1[j] in p_hash_file_1) \
                 and \
                 (l_hash_keys_list_2[i] in p_hash_file_2)) \
                and
                ((PARAMETER_QUALIFIER in p_hash_file_1[l_hash_keys_list_1[j]]) \
                  and \
                 (PARAMETER_QUALIFIER in p_hash_file_2[l_hash_keys_list_2[i]])) \
                 and \
                (p_hash_file_1[l_hash_keys_list_1[j]][PARAMETER_QUALIFIER].upper() == \
                 p_hash_file_2[l_hash_keys_list_2[i]][PARAMETER_QUALIFIER].upper())):

               l_parameter_qualifier_is_found = True


            if (l_type_is_found == False \
                and \
                ((l_hash_keys_list_1[j] in p_hash_file_1) \
                 and \
                 (l_hash_keys_list_2[i] in p_hash_file_2)) \
                and
                ((TYPE in p_hash_file_1[l_hash_keys_list_1[j]]) \
                  and \
                 (TYPE in p_hash_file_2[l_hash_keys_list_2[i]])) \
                 and \
                (p_hash_file_1[l_hash_keys_list_1[j]][TYPE].upper() == \
                 p_hash_file_2[l_hash_keys_list_2[i]][TYPE].upper())):

               l_type_is_found = True


            if (l_parameter_set_is_found == False \
                and \
                ((l_hash_keys_list_1[j] in p_hash_file_1) \
                 and \
                 (l_hash_keys_list_2[i] in p_hash_file_2)) \
                and
                ((PARAMETER_SET in p_hash_file_1[l_hash_keys_list_1[j]]) \
                  and \
                 (PARAMETER_SET in p_hash_file_2[l_hash_keys_list_2[i]])) \
                 and \
                (p_hash_file_1[l_hash_keys_list_1[j]][PARAMETER_SET] == \
                 p_hash_file_2[l_hash_keys_list_2[i]][PARAMETER_SET])):

               l_parameter_set_is_found = True

         except IndexError:

            None


      if l_parameter_qualifier_is_found == False \
         and \
         l_hash_keys_list_2[i] in p_hash_file_2 \
         and \
         PARAMETER_QUALIFIER in p_hash_file_2[l_hash_keys_list_2[i]]:

         l_string = \
         str(l_hash_keys_list_2[i]) + \
         ' >>>> PARAMETER_QUALIFIER >>>> ' + str(p_hash_file_2[l_hash_keys_list_2[i]][PARAMETER_QUALIFIER]) + \
         "\nFOUND IN FILE: " + str(l_non_matching_file) + \
         "\nNOT FOUND IN FILE: " + str(l_comparison_file)

         l_non_matching_elements_list.append(l_string)


      if l_type_is_found == False \
         and \
         l_hash_keys_list_2[i] in p_hash_file_2 \
         and \
         TYPE in p_hash_file_2[l_hash_keys_list_2[i]]:

        l_string = \
        str(l_hash_keys_list_2[i]) + \
        ' >>>> TYPE >>>> ' + str(p_hash_file_2[l_hash_keys_list_2[i]][TYPE]) + \
        "\nFOUND IN FILE: " + str(l_non_matching_file) + \
        "\nNOT FOUND IN FILE: " + str(l_comparison_file)

        l_non_matching_elements_list.append(l_string)


      if l_parameter_set_is_found == False \
         and \
         l_hash_keys_list_2[i] in p_hash_file_2 \
         and \
         PARAMETER_SET in p_hash_file_2[l_hash_keys_list_2[i]]:

        l_string = \
        str(l_hash_keys_list_2[i]) + \
        ' >>>> PARAMETER_SET >>>> ' + str(p_hash_file_2[l_hash_keys_list_2[i]][PARAMETER_SET]) + \
        "\nFOUND IN FILE: " + str(l_non_matching_file) + \
        "\nNOT FOUND IN FILE: " + str(l_comparison_file)

        l_non_matching_elements_list.append(l_string)


   return l_non_matching_elements_list


# end def compareSecondLevelParameters 
################################################################################



################################################################################
# PURPOSE:    Compares parameter sets and returns list of those not appearing in
#             both input files.
# PARAMETERS: p_hash_file_1: Contains associated parameter data referenced by root key.
#             p_hash_file_2: Contains associated parameter data referenced by root key.
#             p_input_file_path_1: Path to file containing data stored in p_hash_file_1.
#             p_input_file_path_2: Path to file containing data stored in p_hash_file_2.
# RETURNS:    List of parameter sets not appearing in both input files


def compareParameterSets( p_hash_file_1, p_hash_file_2, p_input_file_path_1, p_input_file_path_2 ):


   l_first_level_hash_keys_list_1 = []

   l_first_level_hash_keys_list_2 = []


   l_list_1 = []

   l_list_2 = []


   l_non_matching_elements_list = []


   l_length_list_1 = 0

   l_length_list_2 = 0


   l_parameter_hash_1 = {}

   l_parameter_hash_2 = {}


   l_parameter_keys_list_1 = []

   l_parameter_keys_list_2 = []


   l_keys_list_1 = []

   l_keys_list_2 = []


   l_key = ''


   l_comparison_file = ''

   l_non_matching_file = ''


   l_file_names_hash = {}


   l_string = ''


   i = 0

   j = 0



   l_first_level_hash_keys_list_1 = p_hash_file_1.keys()

   l_first_level_hash_keys_list_2 = p_hash_file_2.keys()


   if (len(l_first_level_hash_keys_list_1) <= len(l_first_level_hash_keys_list_2)):

      l_hash_keys_list_1 = \
      sorted(l_first_level_hash_keys_list_1)

      l_hash_keys_list_2 = \
      sorted(l_first_level_hash_keys_list_2)


      l_length_list_1 = len(l_hash_keys_list_1)

      l_length_list_2 = len(l_hash_keys_list_2)


      l_comparison_file = p_input_file_path_1

      l_non_matching_file = p_input_file_path_2


   elif (len(l_first_level_hash_keys_list_2) < len(l_first_level_hash_keys_list_1)):

      l_hash_keys_list_1 = \
      sorted(l_first_level_hash_keys_list_2)

      l_hash_keys_list_2 = \
      sorted(l_first_level_hash_keys_list_1)


      l_length_list_1 = len(l_hash_keys_list_2)

      l_length_list_2 = len(l_hash_keys_list_1)


      l_comparison_file = p_input_file_path_2

      l_non_matching_file = p_input_file_path_1


   for i in range(0, l_length_list_2):

      for j in range(0, l_length_list_1):

         try:

            if (((l_hash_keys_list_1[j] in p_hash_file_1) \
                 and \
                 (l_hash_keys_list_2[i] in p_hash_file_2)) \
                 and \
                 ((PARAMETER_SET in p_hash_file_1[l_hash_keys_list_1[j]]) \
                  and \
                  (PARAMETER_SET in p_hash_file_2[l_hash_keys_list_2[i]])) \
                and \
                (l_hash_keys_list_1[j].upper() == l_hash_keys_list_2[i].upper())):


               l_parameter_hash_1 = \
               p_hash_file_1[l_hash_keys_list_1[j]][PARAMETER_SET] 

               l_parameter_hash_2 = \
               p_hash_file_2[l_hash_keys_list_2[i]][PARAMETER_SET]            


               l_parameter_keys_list_1 = \
               l_parameter_hash_1.keys()

               l_parameter_keys_list_2 = \
               l_parameter_hash_2.keys() 


               if (len(l_parameter_keys_list_1) <= len(l_parameter_keys_list_2)):

                  l_keys_list_1 = \
                  sorted(l_parameter_keys_list_1)

                  l_keys_list_2 = \
                  sorted(l_parameter_keys_list_2)

               elif (len(l_parameter_keys_list_2) < len(l_parameter_keys_list_1)):

                  l_keys_list_1 = \
                  sorted(l_parameter_keys_list_2)

                  l_keys_list_2 = \
                  sorted(l_parameter_keys_list_1)


               for l_key in l_keys_list_1:

                  if ((l_key in l_keys_list_2) \
                      and \
                      ((l_key in l_parameter_hash_1)
                       and \
                       (l_key in l_parameter_hash_2)) \
                      and
                      (l_parameter_hash_1[l_key].upper() != l_parameter_hash_2[l_key].upper())):

                     l_string = \
                     l_hash_keys_list_2[i] + ' >>>> PARAMETER_SET: >>>> ' + \
                     str(l_key) + ' >>>> ' + str(l_parameter_hash_2[l_key]) + \
                     "\nIN FILE " + str(l_non_matching_file) + \
                     "\nDOES NOT MATCH\n" + \
                     str(l_hash_keys_list_1[j]) + ' >>>> PARAMETER_SET: >>>> ' + \
                     str(l_key) + ' >>>> ' + str(l_parameter_hash_1[l_key]) + \
                     "\nIN FILE: " + str(l_comparison_file)

                     l_non_matching_elements_list.append(l_string)

                  elif ((l_key in l_keys_list_2) \
                        and \
                        ((l_key in l_parameter_hash_1) \
                         and \
                         (l_key not in l_parameter_hash_2))):

                     l_string = \
                     l_hash_keys_list_2[i] + ' >>>> PARAMETER_SET: >>>> ' + \
                     str(l_key) + \
                     "\nFOUND IN FILE: " + str(l_comparison_file) + \
                     "\nNOT FOUND IN FILE: " + str(l_non_matching_file) 

                     l_non_matching_elements_list.append(l_string)

                  elif ((l_key in l_keys_list_2) \
                        and \
                        ((l_key not in l_parameter_hash_1) \
                         and
                         (l_key in l_parameter_hash_2))):

                     l_string = \
                     l_hash_keys_list_2[i] + ' >>>> PARAMETER_SET: >>>> ' + \
                     str(l_key) + \
                     "\nFOUND IN FILE: " + str(l_non_matching_file)
                     "\nNOT FOUND IN FILE: " + str(l_comparison_file)

                     l_non_matching_elements_list.append(l_string)

         except IndexError:

            None


   return l_non_matching_elements_list


# end def compareParametersets
################################################################################


################################################################################
# PURPOSES:   Retrieves parameter data from XML file.
# PARAMETERS: p_file_contents_list: Contents of XML file.
# RETURNS:    Hash table containing associated parameter data referenced by root key.

def retrieveXMLParameterData ( p_file_contents_list ):

   l_root_key = ''

   l_regexp_match = ''

   l_hash_file = {}

   l_is_increment = False

   i = 0

 
   while i < len(p_file_contents_list):

      l_is_increment = False
      
      l_regexp_match = \
      re.search("^parameter-set\:\s+\[\(\'name\'\,\s+\'(\w+)\s*(\(.+?\))?\'\)\,\s+\(\'version\'\,\s+\'(\d+)\'\)\,\s+\(\'locked\'\,\s+\'(\w+)\'\)\,\s+\(\'classname\'\,\s+\'(.+?)\'\)\]$", p_file_contents_list[i])

      if l_regexp_match:

         if (l_regexp_match.group(1) \
             and \
             l_regexp_match.group(2) \
             and \
             l_regexp_match.group(3) \
             and \
             l_regexp_match.group(4) \
             and \
             l_regexp_match.group(5)):

            l_root_key = l_regexp_match.group(1)

            l_hash_file[l_root_key] = {}

            l_hash_file[l_root_key][PARAMETER_QUALIFIER] = \
            l_regexp_match.group(2)[1:-1]

            l_hash_file[l_root_key][VERSION] = \
            l_regexp_match.group(3)

            l_hash_file[l_root_key][LOCKED] = \
            l_regexp_match.group(4)

            l_hash_file[l_root_key][CLASS_NAME] = \
            l_regexp_match.group(5)

            i = i + 1

            l_is_increment = True

         elif (l_regexp_match.group(1) \
               and not \
               l_regexp_match.group(2) \
               and \
               l_regexp_match.group(3) \
               and \
               l_regexp_match.group(4) \
               and \
               l_regexp_match.group(5)):

            l_root_key = l_regexp_match.group(1)

            l_hash_file[l_root_key] = {}

            l_hash_file[l_root_key][VERSION] = \
            l_regexp_match.group(3)

            l_hash_file[l_root_key][LOCKED] = \
            l_regexp_match.group(4)

            l_hash_file[l_root_key][CLASS_NAME] = \
            l_regexp_match.group(5)

            i = i + 1      

            l_is_increment = True


      l_regexp_match = \
      re.search("^parameter\:\s+\[\(\'name\'\,\s+\'(\w+)\'\)\,\s+\(\'value\'\,\s+\'(.+?)\'\)\]$", p_file_contents_list[i])

      if l_regexp_match:

         if PARAMETERS not in l_hash_file[l_root_key].keys():

            l_hash_file[l_root_key][PARAMETERS] = {}

         l_hash_file[l_root_key][PARAMETERS][l_regexp_match.group(1)] = \
         l_regexp_match.group(2) 

         i = i + 1

         l_is_increment = True


      if l_is_increment == False:

         i = i + 1


   return l_hash_file


# END def retrieveXMLParameterData ( p_file_contents_list ):
################################################################################




################################################################################
# START main


g_string = "\n\n" + sys.argv[0] + " started.\n"

print g_string

try:

   p_input_file_path_1 = sys.argv[1]

   p_input_file_path_2 = sys.argv[2]

except Exception:

   print 'Run this script as follows: ' + \
         sys.argv[0] + "                  \
         [path_to_input_file_1] [path_to_input_file_2]\n\n"

   print sys.argv[0] + " terminated.\n\n"

   sys.exit(1)


g_parameter_set_regexp = re.compile("^\s*Parameter\s+Set:\s+.*$")

g_data_model_registry_regexp = re.compile("^Data\s*Model\s*Registry\s*")


g_file_name_suffix_regexp_txt = re.compile(".*\.txt$")

g_file_name_suffix_regexp_xml = re.compile(".*\.xml$")


if g_file_name_suffix_regexp_txt.search(p_input_file_path_1) \
   and                                                       \
   g_file_name_suffix_regexp_txt.search(p_input_file_path_2):


   g_file_contents_list_1 = \
   [g_line.strip() for g_line in open(p_input_file_path_1, 'r')]

   g_file_contents_list_2 = \
   [g_line.strip() for g_line in open(p_input_file_path_2, 'r')]


   g_hash_file_1 = \
   retrieveTxtParameterData( g_file_contents_list_1 )

   g_hash_file_2 = \
   retrieveTxtParameterData( g_file_contents_list_2 )


   g_first_level_non_matching_elements_list = \
   compareFirstLevelParameters( g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2 )


   if (len(g_first_level_non_matching_elements_list) > 0):

      for i in range(0, len(g_first_level_non_matching_elements_list)):

         print str(g_first_level_non_matching_elements_list[i]) + "\n\n"


   g_second_level_non_matching_elements_list = \
   compareSecondLevelParameters( g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2 )


   if (len(g_second_level_non_matching_elements_list) > 0):

      print "\n\n"

      for i in range(0, len(g_second_level_non_matching_elements_list)):

         print str(g_second_level_non_matching_elements_list[i]) + "\n\n"

 
   g_parameter_non_matching_elements_list = \
   compareParameterSets( g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2 )


   print "\n\n"

   for i in range(0, len(g_parameter_non_matching_elements_list)):

      print str(g_parameter_non_matching_elements_list[i]) + "\n\n"

 
elif g_file_name_suffix_regexp_xml.search(p_input_file_path_1) \
     and                                                       \
     g_file_name_suffix_regexp_xml.search(p_input_file_path_2):


   try:

      g_xml_element_tree_1 = \
      etree.ElementTree(file=p_input_file_path_1)

   except IOError:

      g_string = \
      'Error reading from input file [' + \
      p_input_file_path_1 +               \
      "]\n\n" + sys.argv(0) + " terminated on error.\n\n" 

      print g_string

      sys.exit(1)

   except etree.XMLSyntaxError:

      g_string = \
      'XML syntax error in input file [' + \
      p_input_file_path_1 +                \
      "]\n\n" + sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1) 


   try:

      for g_element in g_xml_element_tree_1.getiterator():

         g_string = \
         str(g_element.tag) + \
         ': ' + \
         str(g_element.items())
 
         g_file_contents_list_1.append(g_string)
 
   except AttributeError:

      g_string = \
      'Error reading from input file [' + \
      p_input_file_path_1 +               \
      "]\n\n" + sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1)


   try:

      g_xml_element_tree_2 = \
      etree.ElementTree(file=p_input_file_path_2)

   except IOError:

      g_string = \
      'Error reading from input file [' + \
      p_input_file_path_2 +               \
      "]\n\n" + sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1)

   except etree.XMLSyntaxError:

      g_string = \
      'XML syntax error in input file [' + \
      p_input_file_path_2 +                \
      "]\n\n" + sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1)


   try:

      for g_element in g_xml_element_tree_2.getiterator():

         g_string = \
         str(g_element.tag) + \
         ': ' + \
         str(g_element.items())

         g_file_contents_list_2.append(g_string)

   except AttributeError:

      g_string = \
      'Error reading from input file [' + \
      p_input_file_path_2 +               \
      "]\n\n" + sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1)


   g_hash_file_1 = \
   retrieveXMLParameterData( g_file_contents_list_1 )

   g_hash_file_2 = \
   retrieveXMLParameterData( g_file_contents_list_2 )


   g_first_level_non_matching_elements_list = \
   compareFirstLevelParameters( g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2 )


   if (len(g_first_level_non_matching_elements_list) > 0):

      for i in range(0, len(g_first_level_non_matching_elements_list)):

         print str(g_first_level_non_matching_elements_list[i]) + "\n\n"


   g_second_level_non_matching_elements_list = \
   compareSecondLevelParameters( g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2 )


   if (len(g_second_level_non_matching_elements_list) > 0):

      print "\n\n"

      for i in range(0, len(g_second_level_non_matching_elements_list)):

         print str(g_second_level_non_matching_elements_list[i]) + "\n\n"


   g_parameter_non_matching_elements_list = \
   compareParameterSets( g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2 )


   print "\n\n"

   for i in range(0, len(g_parameter_non_matching_elements_list)):

      print str(g_parameter_non_matching_elements_list[i]) + "\n\n"


elif ((g_file_name_suffix_regexp_txt.search(p_input_file_path_1)  \
       and                                                        \
       g_file_name_suffix_regexp_xml.search(p_input_file_path_2)) \
      or                                                          \
      (g_file_name_suffix_regexp_txt.search(p_input_file_path_2)  \
       and                                                        \
       g_file_name_suffix_regexp_xml.search(p_input_file_path_1))):

 
   g_txt_input_file_path = p_input_file_path_1

   if g_file_name_suffix_regexp_txt.search(p_input_file_path_2):

      g_txt_input_file_path = p_input_file_path_2


   g_xml_input_file_path = p_input_file_path_2

   if g_file_name_suffix_regexp_xml.search(p_input_file_path_1):

      g_xml_input_file_path = p_input_file_path_1


   g_file_contents_list_1 = \
   [g_line.strip() for g_line in open(g_txt_input_file_path, 'r')]

   g_hash_file_1 = \
   retrieveTxtParameterData( g_file_contents_list_1 )

 
   try:

      g_xml_element_tree = \
      etree.ElementTree(file=g_xml_input_file_path)

   except IOError:

      g_string = \
      'Error reading from input file [' + \
      g_xml_input_file_path +             \
      "]\n\n" + sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1)

   except etree.XMLSyntaxError:

      g_string = \
      'XML syntax error in input file [' + \
      g_xml_input_file_path +              \
      "]\n\n" +                            \
      sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1)


   try:

      for g_element in g_xml_element_tree.getiterator():

         g_string =           \
         str(g_element.tag) + \
         ': ' +               \
         str(g_element.items())

         g_file_contents_list_2.append(g_string)

   except AttributeError:

      g_string = \
      'Error reading from input file [' + \
      g_xml_input_file_path +             \
      "]\n\n" +                           \
      sys.argv(0) + " terminated on error.\n\n"

      print g_string

      sys.exit(1)


   g_hash_file_2 = \
   retrieveXMLParameterData( g_file_contents_list_2 )


   g_first_level_non_matching_elements_list = \
   compareFirstLevelParameters(g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2)


   if (len(g_first_level_non_matching_elements_list) > 0):

      for i in range(0, len(g_first_level_non_matching_elements_list)):

         print str(g_first_level_non_matching_elements_list[i]) + "\n\n"


   g_second_level_non_matching_elements_list = \
   compareSecondLevelParameters(g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2)


   if (len(g_second_level_non_matching_elements_list) > 0):

      for i in range(0, len(g_second_level_non_matching_elements_list)):

         print str(g_second_level_non_matching_elements_list[i]) + "\n\n"


   g_parameter_non_matching_elements_list = \
   compareParameterSets(g_hash_file_1, g_hash_file_2, p_input_file_path_1, p_input_file_path_2)

   for i in range(0, len(g_parameter_non_matching_elements_list)):

      print str(g_parameter_non_matching_elements_list[i]) + "\n\n"


g_string = sys.argv[0] + " terminated on SUCCESS.\n\n"

print g_string


exit(0)


# END main
################################################################################
