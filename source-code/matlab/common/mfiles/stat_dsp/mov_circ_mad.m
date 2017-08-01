function  nanmean_madx_colvec_normalized = mov_circ_mad(f,navg,i,mScale)

%median absolute deviation robust filtering of a time series of length 2^N. For
%comuptational efficiency only every second colum of the resized input
%array f_i is median filtered, all other columns are interpolated
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

%NAME           ORGANIZATION    DATE
%P Machalek     SETI            09/24/2010
%                               basic implementation, interpolation of
%                               every other column (index_of_columns_to_med_filter) 
%                               for computational efficiency. Use
%                               nanmean_madx_colvec_normalized as the
%                               ultimate output of the routine to prevent
%                               the seemingly multivalued
%                               madx_colvec_normalized from being used as
%                               the routine output.


if navg <= 0,
    error('TPS:mov_circ_mad', 'TPS:mov_circ_mad: number of points to consider less than or equal 0!');
end

%favg = circfilt(ones(navg,1)/navg,f); % mean over a window of length navg

%% clear out variables
    madx=[];
    index_of_columns_to_med_filter=[];
    index_of_columns_to_be_interpoleated_tmp = [];
    index_of_columns_to_be_interpoleated = [];
    sparse_extended_time_series_transposed = [];
    extended_time_series_transposed = [];
    extended_time_series = [];
    f_i=[];
  
    %f_log_two = log2(length(f));   
    %navg_log_two = floor(log2(navg));

    minimum_reshape_index=i-1;
    %f_i = reshape(f,  length(f)/(2^(i-1)),2^(i-1) );
    f_i = transpose( reshape( f, 2^(minimum_reshape_index), length(f)/(2^(minimum_reshape_index))  ));
    %  f_i=transpose(f_i);
  
%% check whether reshaped matrix columns are longer than navg
      if navg >= 0.5*length(f_i(:,1))
        perform_median=0;
       % 'column too long',i
      else
        perform_median=1;
      end
     
    size_f_i=size(f_i);
    size_f=size(f);
    %% extend time series by half a window length at each end of time series 
    %ff_i_prefix= f_i((length(f_i)-navg+1):length(f_i) :)
    end_of_matrix = length(f_i(:,1));
    matrix_clipping_end = max(1,(end_of_matrix-floor(navg/2)+1));
    matrix_clipping_beginning = min(end_of_matrix,floor(navg/2));
 

    ff_i_prefix= f_i(matrix_clipping_end:end_of_matrix,:);
    size_preffix= size(ff_i_prefix);
    ff_i_suffix= f_i(1:matrix_clipping_beginning,: );
    size_suffix= size(ff_i_suffix);
    %extended_time_series = [transpose(ff_i_prefix) transpose(f_i) transpose(ff_i_suffix)];
    extended_time_series = [ff_i_prefix; f_i; ff_i_suffix];
    
    s_time_series = size(extended_time_series);
    extended_time_series_transposed = extended_time_series;
        
    
%% don't median filter every single column do only every second one or so
    %to speed up the entire routine
  
    %get number of columns of extended_time_series to only median filter
    %every nth column and then interpolate the rest
       c=size(extended_time_series_transposed);
       columns=c(2);
       index_of_columns_to_med_filter=(1:2:columns);
       index_of_columns_to_be_interpoleated_tmp = (1:1:columns);
       index_of_columns_to_be_interpoleated = setdiff( index_of_columns_to_be_interpoleated_tmp, index_of_columns_to_med_filter);
     
    
%% only median filter if we have enough points in a column for the median
%% filtering to make any sense
if perform_median == 1 
    %create sparse extended time series to median filter (in other words
    %don't median filter every single column)
       sparse_extended_time_series_transposed = extended_time_series_transposed(:,index_of_columns_to_med_filter);
       madx=extended_time_series_transposed;
       madx(:,index_of_columns_to_med_filter) = medfilt1(abs(sparse_extended_time_series_transposed),navg);
    
    %pad out all non median filtered columns with "NaN"
       median_array = median(extended_time_series_transposed(:,index_of_columns_to_be_interpoleated));
       c_med_arr=size(median_array);    
       median_matrix = repmat(NaN,c(1),c_med_arr(2)); 
       madx(:,index_of_columns_to_be_interpoleated) = median_matrix;
    
%% clip beginning and end of madx 
    %transpose madx back for clipping
    % madx=transpose(madx);
    %column_to_cut = [size_preffix(2)+1, size_preffix(2) + size_f_i(2)];
    %madx = madx(column_to_cut(1):column_to_cut(2),:);
     madx(1:size_preffix(1),:) = [];
     madx = madx(1:size_f_i(1),:);
   
%%  construct a mean of of each row of the madx values, which seem to be
    %multivalued.  Then create an index
    %index_to_iterate_across_gaps_in_nanmeanmadx_reshaped to aid itearation
    %across the NaN gaps in the nanmean_madx. Use spline interpolation to
    %avoid NaN at the edges. 
     nanmean_madx=nanmean(madx,2);
     index_to_iterate_across_gaps_in_nanmeanmadx = (1:size_f(1));
     index_to_iterate_across_gaps_in_nanmeanmadx_reshaped = transpose(reshape(index_to_iterate_across_gaps_in_nanmeanmadx, 2^(minimum_reshape_index), length(f)/(2^(minimum_reshape_index))));
     nanmean_index=nanmean(index_to_iterate_across_gaps_in_nanmeanmadx_reshaped,2);
     nanmean_madx_interpolated  = interp1(nanmean_index,nanmean_madx,index_to_iterate_across_gaps_in_nanmeanmadx_reshaped,'spline');   
    
     
%% reshape final array into a column vector     
     %http://www.mathworks.com/matlabcentral/newsreader/view_thread/119588
     madx_colvec=colvec(reshape(madx.',1,[]));
     nanmean_madx_colvec = colvec(reshape(nanmean_madx_interpolated.',1,[]));  
     
else
      %%replace colum elements with median of the column since we 
      %don't have enough points to median filter
      madx_colvec = repmat(median(abs(f)),length(f),1);
      nanmean_madx_colvec = repmat(median(abs(f)),length(f),1);
      %     medians = median(f_i);
      %    madx=repmat(column_medians,c(1),1);    
end   
    
    

%% normalize madx_colvec and nanmean_madx_colvec_normalized
    %f0 =@(x)(normcdf(x)-0.5)*2-.5
    %fzero(f0, 0.6) %fzero(f0, 0.6) ~0.6745
    %plot([std(w)',mad(w,1)' ] );

madx_colvec_normalized = madx_colvec / 0.6745;
nanmean_madx_colvec_normalized = nanmean_madx_colvec  / 0.6745;
return

