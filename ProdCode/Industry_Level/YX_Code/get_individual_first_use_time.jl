function get_individual_first_use_time(timePerValue, dateEnd)
#=
    This function picks the first time we can use a particular financial data given three kinds of date.
    timePerValue:
    C1: Latest_Period_End (PE);
    C2: Announcement_Date (AD);
    C3: CRI_Available_Date (CRI).

    The logic of determining the first use time is based on the statistical
    analysis on the entire table [TIER3].[ENT].[FUNDAMENTALS] on 2016-04-16.
    The logic here is not perfect but statistically most accurate. To whom
    may concern, you can refer to the excel file 'FS time analysis' which
    contains the detailed statistical result on this analysis. I strongly
    suggest that such analysis be performed regularly as well as try best to
    secure the accuracy of the CRI available date.
=#
    return
end
