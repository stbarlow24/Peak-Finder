# Peak-Finder
An algorithm for matching rows from disparate datasets using time-based sorting.

This routine was applied to datasets from our single-vesicle analysis project.  
The project multiplexes a resistive-pulse measurement, in which single vesicles can be electrically sized, with an electrochemical measurement, in which the redox content of single vesicles is quantified.  By combining the two measurements, we seek to directly measure the concentration of redox molecules inside single vesicles, one at a time. 

Necessarily, we have two separate recordings wherein each vesicle event has two data points.  The routine outlined in this repository pulls in datasets, which are coded as either having a nanopore origin (NP), or electrochemical origin (CF).  By examining the time-series data corresponding to every event, we can identify which ones are matching by applying a simple thresholding algorithm: 

  1) Did the event occur <1 ms after a previous event from the same set of measurements? 
  2) Is it a CF event following a NP event?
  
If the answer to both of those questions is yes, the events were determined to match.  A series of operations is then applied to match rows with one another using an incrementing string variable which is later used to sort and melt rows together.  The final result is a single row for each pair of matched signals which contains both the nanopore measurement data and the electrochemical measurement data.  In doing this, we were able to quantify a number of observables about the system to validate the quality of our device for single-vesicle analysis, including:

  1) If there is a correlation between resistive-pulse magnitude or duration with electrochemical event qualities
  2) The time delay between electrochemical events and their parent resistive-pulse
  3) The frequency with which we observed matching events
  
Overall, this routine illustrates the power of binarization as a tool for sorting algorithms. 
