#######################################################################################
##
## This function extract the DTD input for futher DTD calculation
## from the Unicorn4, and pick out the latest possible value
## for each month. Here we assume at least there is one
## available value for each month.
##
## Output: store in '\..\..\Data\DTDinput\(econ number)\compAll.jl' in table format
##    	  Column information could be found via compAll.Properties.VariableNames:
##		  'CompNo','monthDate','MarketCap','CL','LTB','TL','TA','rfr'
##
#######################################################################################
