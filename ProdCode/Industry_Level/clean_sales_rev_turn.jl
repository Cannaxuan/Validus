function clean_sales_rev_turn(sales_rev_turn_raw)
     colCompNum = 1
     colIdBB = 2
     colUpdateDate = 3
     colFieldValue = 4
     colFiscalPeriod = 5
     colConsolidate = 6
     ##  for FillingStatus: MR > OR > PR > RS, namely: Most recent > Original > Preliminary > Restated
     colFillingStatus = 7
     ## for Fiscal Period (Col 5)
     # 1: annual report; 3: cimulative quarter; 1: semi-annual; 2: quarter
     orderPriority = [1 31 32 33 34 11 12 21 22 23 24]


     sales_rev_turn_raw = Matrix(unique(DataFrame(sales_rev_turn_raw)))


     sales_rev_turn_raw = sales_rev_turn_raw[.!isnan.(sales_rev_turn_raw[:, colFieldValue]), :]
     ## function unique cannot give normal output for Array in Julia 1.0.3, which need to be transferred into DataFrame.
     ## Meanwhile, Julia regard NaN in dataframe as same element.

     for i = 1:length(orderPriority)
         # global sales_rev_turn_raw, colFiscalPeriod, colFieldValue
         validIdx = sales_rev_turn_raw[:, colFiscalPeriod] .== orderPriority[i]
          ## change 1->101, 31->102, 32->103, 33->104 ... 22->109, 23->110, 24->111
          sales_rev_turn_raw[validIdx, colFiscalPeriod] .= i + 100
          if  in(orderPriority[i], [31 21 22 23 24])
              sales_rev_turn_raw[validIdx, colFieldValue] = sales_rev_turn_raw[validIdx, colFieldValue] * 4
          elseif in(orderPriority[i], [32 11 12])
              sales_rev_turn_raw[validIdx, colFieldValue] = sales_rev_turn_raw[validIdx, colFieldValue] * 2
          # elseif orderPriority[i] == 31
          #     sales_rev_turn_raw[validIdx, colFieldValue] = sales_rev_turn_raw[validIdx, colFieldValue] * 4
          # elseif orderPriority[i] == 32
          #     sales_rev_turn_raw[validIdx, colFieldValue] = sales_rev_turn_raw[validIdx, colFieldValue]/2 * 4
          elseif orderPriority[i] == 33
              sales_rev_turn_raw[validIdx, colFieldValue] = sales_rev_turn_raw[validIdx, colFieldValue]/3 * 4
          else
          end
      end


     sales_rev_turn_Sorted = Matrix(sort(DataFrame(sales_rev_turn_raw),
     (order(colCompNum), order(colUpdateDate), order(colConsolidate, rev = true), order(colFiscalPeriod), order(colFillingStatus),
     order(colIdBB), order(colFieldValue), order(8))))

     rowIndicator = uniqueidx(sales_rev_turn_Sorted[:, [colCompNum, colUpdateDate]])[1]
     sales_rev_turn_SortedUniuqe = sales_rev_turn_Sorted[rowIndicator, push!(collect(1:4), 8)]

     return sales_rev_turn_SortedUniuqe
end
