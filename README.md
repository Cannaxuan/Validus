# Validus SME Toolbox
Validus is an online aggregator platform for SMEs to secure short term and medium term financing.
This SME Toolbox is developed by NUS-CRI to help Validus private SME companies' credit profile.

## Industry level
Production Procedure (Validus production code should be run shortly after monthly calibration without revision.)
As Full Period data must be ready before the monthly production, please execute 1 and 2 first.

		1.  Run CombineData_Main(DataMonth) under \\dirac\cri3\OfficialTest_AggDTD_SBChinaNA\ProductionCode\FullPeriodData
		2.  Change Folder name DataMonth_withoutRevision e.g. 201806_withoutRevision
		3.  Run Industry_Level(DataDate) for Validus
e.g DataDate = 20180629  ---- The last trading date of the month
  
The results will be saved in ProdData/DataMonth/Industry {DataPreparation/FactorModel/Products}

Before running, please reload pd60hUpToMostRecent.mat under
\\dirac\cri3\OfficialTest_AggDTD_SBChinaNA\ProductionData\FullPeriod\DataMonth_withoutRevision\Monthly\Products\P2_Pd
then resave it as pd60hUpToMostRecent_bk.mat under the industry level folder

## Firm Level
Firm_Level can be run right after validation request for Industry Level.

      As Validation team does not validate firm_level results, you should compare previous month betaMe, betaSm, betaMi with the current  betaMe, betaSm, betaMi to check any significant changes.
			
      Some of Industry Level outputs will be used as inputs for Firm_Level.
      e.g. Firm_Level(20180629) for Validus
           Firm_Level(20180629,[1 3 15]) for other Econ portfolios
