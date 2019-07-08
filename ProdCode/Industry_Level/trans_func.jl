function trans_func(dataMtrx)
     #### Transform the PD and POE matrice from domain [0,1] to the whole set of real numbers
     ## Here, the choice is to transform the PD and POE into a linear combination of
     ## the input variables, i.e., the log of forward intensity
     transdataMtrx = @. log(-log(1 - dataMtrx))
     return transdataMtrx
end

# function trans_func(dataMtrx)
#      transdataMtrx = dataMtrx[:, :, 1]
#      for i = 2: size(dataMtrx, 3)
#          transdataMtrx = cat(transdataMtrx, log.(-log.(1 .- dataMtrx[:, :, i])), dims = 3)
#      end
#      return transdataMtrx
# end
